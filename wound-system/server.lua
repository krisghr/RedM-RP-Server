local woundsByPlayer = {}
local nextWoundIdByPlayer = {}
local persistedByKey = {}
local VORPcore = nil

if Config.UseVorpIdentity and GetResourceState('vorp_core') == 'started' then
    VORPcore = exports.vorp_core:GetCore()
end

local function debugPrint(msg)
    if Config.Debug then
        print(("[rp_wounds:server] %s"):format(msg))
    end
end

local function hasPermission(_source)
    -- Placeholder permission hook for admins/doctors.
    return IsPlayerAceAllowed(_source, 'rp_wounds.admin') or _source == 0
end

local function canUseDebug(source)
    if source == 0 then return true end
    if Config.AllowDebugCommandsWithoutAce then return true end
    if Config.Debug then return true end
    return hasPermission(source)
end

local function notify(target, msg)
    TriggerClientEvent('rp_wounds:client:notify', target, msg)
end

local function resolvePlayerKeys(src)
    local license = nil
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:find('license:') then
            license = id
            break
        end
    end

    local charKey = nil
    if VORPcore then
        local user = VORPcore.getUser(src)
        if user and user.getUsedCharacter then
            local character = type(user.getUsedCharacter) == 'function' and user.getUsedCharacter() or user.getUsedCharacter
            if character and character.charIdentifier then
                local charId = type(character.charIdentifier) == 'function' and character.charIdentifier() or character.charIdentifier
                if charId then
                    charKey = ('char:%s'):format(charId)
                end
            end
        end
    end

    -- Primary key intentionally prefers license so relog/character-load timing does not change persistence lookup.
    local primary = license or charKey or ('src:%s'):format(src)
    local aliases = {}
    if charKey and charKey ~= primary then aliases[#aliases + 1] = charKey end
    if license and license ~= primary then aliases[#aliases + 1] = license end
    aliases[#aliases + 1] = ('src:%s'):format(src)

    return primary, aliases
end

local function getPlayerKey(src)
    local primary = resolvePlayerKeys(src)
    return primary
end

local function randomHoursToSeconds(minH, maxH)
    local hours = math.random(minH, maxH)
    return hours * 3600
end

local function computeFallChances(categoryCfg, damageAmount)
    local out = { minor = 0, severe = 0 }
    for _, row in ipairs(categoryCfg.chancesByDamage) do
        if damageAmount >= row.damage then
            out.minor, out.severe = row.minor, row.severe
        end
    end
    return out
end

local function rollSeverity(categoryCfg, damageAmount)
    local chances = categoryCfg.chances or computeFallChances(categoryCfg, damageAmount)
    local severeRoll = math.random(1, 100)
    if severeRoll <= chances.severe then
        return 'severe', chances, severeRoll, nil
    end
    local minorRoll = math.random(1, 100)
    if minorRoll <= chances.minor then
        return 'minor', chances, severeRoll, minorRoll
    end
    return nil, chances, severeRoll, minorRoll
end

local function choose(list)
    return list[math.random(1, #list)]
end

local function ensurePlayer(src)
    woundsByPlayer[src] = woundsByPlayer[src] or {}
    nextWoundIdByPlayer[src] = nextWoundIdByPlayer[src] or 1
end

local function recalcPenalties(src)
    ensurePlayer(src)
    local hpTotal, staminaTotal = 0, 0
    for _, wound in ipairs(woundsByPlayer[src]) do
        hpTotal = hpTotal + wound.hpReduction
        staminaTotal = staminaTotal + wound.staminaReduction
    end

    hpTotal = math.min(Config.MaxTotalReductionPercent, hpTotal)
    staminaTotal = math.min(Config.MaxTotalReductionPercent, staminaTotal)

    TriggerClientEvent('rp_wounds:client:applyPenalties', src, {
        hpReduction = hpTotal,
        staminaReduction = staminaTotal
    })

    debugPrint(("recalc for %s => hp%% %s stamina%% %s"):format(src, hpTotal, staminaTotal))
end

local function syncPersistedForPlayer(src)
    local primary, aliases = resolvePlayerKeys(src)
    persistedByKey[primary] = woundsByPlayer[src] or {}
    for _, key in ipairs(aliases) do
        if key ~= primary then
            persistedByKey[key] = nil
        end
    end
end

local function saveState()
    local payload = { byKey = {} }

    -- Start from known persisted/offline entries so active-player saves do not wipe relog data.
    for key, wounds in pairs(persistedByKey) do
        payload.byKey[key] = wounds
    end

    -- Active player state always overrides stale persisted copies.
    for src, wounds in pairs(woundsByPlayer) do
        local key = getPlayerKey(src)
        payload.byKey[key] = wounds
    end

    SaveResourceFile(GetCurrentResourceName(), 'wounds_state.json', json.encode(payload), -1)
end

local function loadState()
    local raw = LoadResourceFile(GetCurrentResourceName(), 'wounds_state.json')
    if not raw or raw == '' then return {} end
    local decoded = json.decode(raw)
    return decoded and decoded.byKey or {}
end

persistedByKey = loadState()

local function restorePlayer(src)
    local primary, aliases = resolvePlayerKeys(src)

    local restored = persistedByKey[primary]
    if not restored then
        for _, key in ipairs(aliases) do
            if persistedByKey[key] then
                restored = persistedByKey[key]
                break
            end
        end
    end

    woundsByPlayer[src] = restored or {}
    local maxId = 0
    for _, wound in ipairs(woundsByPlayer[src]) do
        maxId = math.max(maxId, wound.id or 0)
    end
    nextWoundIdByPlayer[src] = maxId + 1

    -- Normalize any alias keys into the current primary key.
    persistedByKey[primary] = woundsByPlayer[src]
    for _, key in ipairs(aliases) do
        if key ~= primary then
            persistedByKey[key] = nil
        end
    end

    recalcPenalties(src)
    saveState()
end

local function cleanupExpiredForPlayer(src)
    ensurePlayer(src)
    local now = os.time()
    local kept = {}
    local removed = 0
    for _, wound in ipairs(woundsByPlayer[src]) do
        if wound.expiresAt and wound.expiresAt <= now then
            removed = removed + 1
        else
            kept[#kept + 1] = wound
        end
    end
    woundsByPlayer[src] = kept
    if removed > 0 then
        notify(src, ("%d wound(s) healed naturally."):format(removed))
        debugPrint(("expired %s wounds for %s"):format(removed, src))
        syncPersistedForPlayer(src)
        recalcPenalties(src)
        saveState()
    end
end

local function addWound(src, category, severity, bodyPart)
    local cfg = Config.DamageCategories[category]
    if not cfg then return nil, 'invalid category' end
    ensurePlayer(src)

    local id = nextWoundIdByPlayer[src]
    nextWoundIdByPlayer[src] = id + 1

    local label = choose(severity == 'minor' and cfg.minorPool or cfg.severePool)
    local penalties = cfg.penalties[severity]
    local now = os.time()

    local wound = {
        id = id,
        label = label,
        source = category,
        severity = severity,
        bodyPart = bodyPart or choose(Config.BodyParts),
        treated = severity == 'minor',
        hpReduction = penalties.hp,
        staminaReduction = penalties.stamina,
        createdAt = now,
        expiresAt = nil
    }

    if severity == 'minor' then
        wound.expiresAt = now + randomHoursToSeconds(cfg.minorHours[1], cfg.minorHours[2])
    end

    table.insert(woundsByPlayer[src], wound)
    syncPersistedForPlayer(src)
    recalcPenalties(src)
    saveState()
    debugPrint(("wound created for %s: #%s %s (%s)"):format(src, wound.id, wound.label, severity))

    local healTxt = wound.expiresAt and ("~%dm"):format(math.max(1, math.floor((wound.expiresAt - now) / 60))) or "requires treatment"
    notify(src, ("^1New Wound^7 [#%s] %s | %s | %s | heal: %s"):format(wound.id, wound.label, wound.severity, wound.bodyPart, healTxt))

    return wound
end

local function treatWound(src, woundId, actor)
    ensurePlayer(src)
    local now = os.time()
    for _, wound in ipairs(woundsByPlayer[src]) do
        if wound.id == woundId then
            local cfg = Config.DamageCategories[wound.source]
            if wound.severity == 'minor' then
                if wound.expiresAt and wound.expiresAt > now then
                    local remaining = wound.expiresAt - now
                    wound.expiresAt = now + math.floor(remaining * 0.25)
                    wound.treated = true
                end
            else
                if not wound.treated then
                    wound.treated = true
                    wound.expiresAt = now + randomHoursToSeconds(cfg.severeHours[1], cfg.severeHours[2])
                end
            end
            syncPersistedForPlayer(src)
            recalcPenalties(src)
            saveState()
            debugPrint(("wound treated by %s on %s #%s"):format(actor, src, wound.id))
            return true, wound
        end
    end
    return false, 'wound not found'
end

RegisterNetEvent('rp_wounds:server:onDamageDetected', function(payload)
    local src = source
    cleanupExpiredForPlayer(src)
    local cfg = Config.DamageCategories[payload.category]
    if not cfg then return end

    local severity, chances, severeRoll, minorRoll = rollSeverity(cfg, payload.damageAmount or 0)
    debugPrint(("roll src=%s cat=%s dmg=%s sevRoll=%s minRoll=%s chances(min=%s sev=%s)")
        :format(src, payload.category, payload.damageAmount, severeRoll, tostring(minorRoll), chances.minor, chances.severe))

    if not severity then return end
    local wound = addWound(src, payload.category, severity, payload.bodyPart)
end)

RegisterCommand('wounds', function(source)
    local src = source
    cleanupExpiredForPlayer(src)
    ensurePlayer(src)
    if #woundsByPlayer[src] == 0 then
        return notify(src, 'You have no active wounds.')
    end
    notify(src, ('Active wounds: %d'):format(#woundsByPlayer[src]))
    for _, wound in ipairs(woundsByPlayer[src]) do
        local remaining = wound.expiresAt and math.max(0, wound.expiresAt - os.time()) or -1
        local remainingTxt = remaining >= 0 and ('%dm'):format(math.floor(remaining / 60)) or 'n/a'
        notify(src, ('[#%s] %s | %s | %s | treated:%s | heal:%s')
            :format(wound.id, wound.label, wound.severity, wound.bodyPart, tostring(wound.treated), remainingTxt))
    end
end, false)

RegisterCommand('treatwound', function(source, args)
    if source ~= 0 and not hasPermission(source) then return notify(source, 'No permission.') end
    local target = tonumber(args[1])
    local woundId = tonumber(args[2])
    if not target or not woundId then
        return notify(source, 'Usage: /treatwound [playerId] [woundId]')
    end
    local ok, result = treatWound(target, woundId, source)
    if ok then
        notify(target, ('Wound #%s treated.'):format(woundId))
        if source ~= 0 then notify(source, 'Treatment applied.') end
    else
        if source ~= 0 then notify(source, result) end
    end
end, true)

RegisterCommand('npcdoctor', function(source)
    local src = source
    ensurePlayer(src)
    cleanupExpiredForPlayer(src)
    local targetId = nil
    for _, w in ipairs(woundsByPlayer[src]) do
        if w.severity == 'severe' and not w.treated then targetId = w.id break end
    end
    if not targetId then
        for _, w in ipairs(woundsByPlayer[src]) do
            if w.severity == 'minor' and w.expiresAt and w.expiresAt > os.time() then targetId = w.id break end
        end
    end
    if not targetId then return notify(src, 'NPC doctor found no wounds to treat.') end
    local ok = treatWound(src, targetId, 'npcdoctor')
    if ok then
        notify(src, ('NPC doctor treated wound #%s. Cost placeholder: $%s'):format(targetId, Config.NpcDoctorCost))
    end
end, false)

RegisterCommand('debuggivewound', function(source, args)
    if not canUseDebug(source) then return notify(source, 'No permission.') end
    local target, category, severity = tonumber(args[1]), args[2], args[3]
    if not target or not category or (severity ~= 'minor' and severity ~= 'severe') then
        return notify(source, 'Usage: /debuggivewound [playerId] [type] [severity]')
    end
    local wound = addWound(target, category, severity)
    if wound then notify(target, ('Debug wound applied: #%s %s'):format(wound.id, wound.label)) end
end, true)

RegisterCommand('debugremovewound', function(source, args)
    if not canUseDebug(source) then return notify(source, 'No permission.') end
    local target, woundId = tonumber(args[1]), tonumber(args[2])
    if not target or not woundId then return notify(source, 'Usage: /debugremovewound [playerId] [woundId]') end
    ensurePlayer(target)
    for i, w in ipairs(woundsByPlayer[target]) do
        if w.id == woundId then table.remove(woundsByPlayer[target], i) syncPersistedForPlayer(target) recalcPenalties(target) saveState() return end
    end
end, true)

RegisterCommand('debugclearwounds', function(source, args)
    if not canUseDebug(source) then return notify(source, 'No permission.') end
    local target = tonumber(args[1])
    if not target then return notify(source, 'Usage: /debugclearwounds [playerId]') end
    woundsByPlayer[target] = {}
    nextWoundIdByPlayer[target] = 1
    syncPersistedForPlayer(target)
    recalcPenalties(target)
    saveState()
end, true)

RegisterCommand('debuglistwounds', function(source, args)
    if not canUseDebug(source) then return notify(source, 'No permission.') end
    local target = tonumber(args[1])
    if not target then return notify(source, 'Usage: /debuglistwounds [playerId]') end
    ensurePlayer(target)
    notify(source, ('Wounds for %s: %s'):format(target, #woundsByPlayer[target]))
    for _, w in ipairs(woundsByPlayer[target]) do
        notify(source, json.encode(w))
    end
end, true)

RegisterCommand('debugvorpstats', function(source, args)
    if not canUseDebug(source) then return notify(source, 'No permission.') end
    if not VORPcore then return notify(source, 'VORP core is not active.') end

    local target = tonumber(args[1]) or source
    local user = VORPcore.getUser(target)
    if not user or not user.getUsedCharacter then
        return notify(source, ('No VORP character found for %s.'):format(target))
    end

    local character = type(user.getUsedCharacter) == 'function' and user.getUsedCharacter() or user.getUsedCharacter
    if not character then
        return notify(source, ('No used character loaded for %s.'):format(target))
    end

    local function safeRead(fnName)
        local fn = character[fnName]
        if type(fn) ~= 'function' then return 'n/a' end
        local ok, value = pcall(fn, character)
        return ok and value or 'n/a'
    end

    notify(source, ('VORP stats for %s -> HealthOuter:%s HealthInner:%s StaminaOuter:%s StaminaInner:%s')
        :format(target, tostring(safeRead('HealthOuter')), tostring(safeRead('HealthInner')), tostring(safeRead('StaminaOuter')), tostring(safeRead('StaminaInner'))))
end, true)

AddEventHandler('playerJoining', function()
    restorePlayer(source)
end)

AddEventHandler('playerDropped', function()
    local src = source
    syncPersistedForPlayer(src)
    woundsByPlayer[src] = nil
    nextWoundIdByPlayer[src] = nil
    saveState()
end)


AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    for _, src in ipairs(GetPlayers()) do
        restorePlayer(tonumber(src))
    end
end)

CreateThread(function()
    while true do
        Wait(Config.CleanupIntervalMs)
        for _, src in ipairs(GetPlayers()) do
            cleanupExpiredForPlayer(tonumber(src))
        end
    end
end)
