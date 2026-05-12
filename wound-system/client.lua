local prevHealth = nil
local debugDamageInfoEnabled = false
local recentGunshotUntil = 0
local ignoreDamageUntil = 0
local lastAppliedStaminaCap = Config.DefaultMaxStamina
local baseMaxHealth = nil
local baseMaxStamina = nil
local lastAppliedHpCap = nil
local baseHealthCore = nil
local baseStaminaCore = nil

local function debugPrint(msg)
    if Config.Debug then
        print(("[rp_wounds:client] %s"):format(msg))
    end
end

local function notify(msg)
    TriggerEvent('chat:addMessage', { args = { '^3Wounds', msg } })
end

local function debugDamageOutput(msg)
    print(("[rp_wounds:damage] %s"):format(msg))
    TriggerEvent('chat:addMessage', { args = { '^6WoundDebug', msg } })
end

local function getBodyPartFromBone(bone)
    if bone == 0 then return "torso" end
    local head = {21030, 14283}
    local legs = {55120, 45454, 33646, 6884, 43312}
    local arms = {54187, 46065, 37873, 22711}

    for _, b in ipairs(head) do if bone == b then return "head" end end
    for _, b in ipairs(legs) do if bone == b then return "left_leg" end end
    for _, b in ipairs(arms) do if bone == b then return "left_arm" end end
    return "torso"
end

local function wasDamagedByWeapon(ped, hashList, causeHash)
    for _, hash in ipairs(hashList) do
        if causeHash ~= 0 and causeHash == hash then
            return true, hash
        end

        if causeHash ~= 0 and HasEntityBeenDamagedByWeapon(ped, hash, 0) then
            return true, hash
        end
    end
    return false, nil
end

local function markRecentGunshot(ms)
    recentGunshotUntil = math.max(recentGunshotUntil, GetGameTimer() + ms)
end

local function hasRecentGunshot()
    return GetGameTimer() <= recentGunshotUntil
end

local function findNearbyAnimalAttacker(victimPed)
    local victimCoords = GetEntityCoords(victimPed)
    local nearestPed, nearestDist = 0, (Config.AnimalDetectionRadius or 10.0)

    for _, ped in ipairs(GetGamePool('CPed')) do
        if ped ~= victimPed and DoesEntityExist(ped) and not IsEntityDead(ped) and IsPedInCombat(ped, victimPed) and not IsPedHuman(ped) then
            local coords = GetEntityCoords(ped)
            local dist = #(victimCoords - coords)
            if dist <= nearestDist then
                nearestDist = dist
                nearestPed = ped
            end
        end
    end

    return nearestPed
end

local function getSelectedWeaponHashSafe(ped)
    if type(GetSelectedPedWeapon) == 'function' then
        return GetSelectedPedWeapon(ped)
    end

    if type(GetCurrentPedWeapon) == 'function' then
        local ok, weaponHash = GetCurrentPedWeapon(ped, true, 0, false)
        if ok then return weaponHash end
    end

    return 0
end

local function isLikelyFirearmEquipped(attackerPed)
    local weaponHash = getSelectedWeaponHashSafe(attackerPed)
    if not weaponHash or weaponHash == 0 or weaponHash == `WEAPON_UNARMED` then
        return false
    end

    for _, knifeHash in ipairs(Config.WeaponHints.knife or {}) do
        if weaponHash == knifeHash then
            return false
        end
    end

    return IsPedArmed(attackerPed, 4) or IsPedArmed(attackerPed, 6)
end

local function findNearbyHumanShooter(victimPed)
    local victimCoords = GetEntityCoords(victimPed)
    local nearestPed, nearestDist = 0, 25.0

    for _, ped in ipairs(GetGamePool('CPed')) do
        if ped ~= victimPed and DoesEntityExist(ped) and not IsEntityDead(ped) and IsPedHuman(ped) and isLikelyFirearmEquipped(ped) and IsPedInCombat(ped, victimPed) then
            local coords = GetEntityCoords(ped)
            local dist = #(victimCoords - coords)
            if dist <= nearestDist then
                nearestDist = dist
                nearestPed = ped
            end
        end
    end

    return nearestPed
end

local function detectDamageCategory(ped, damageAmount)
    -- Best-effort categorization: RedM does not always expose reliable per-hit metadata.
    local sourceEntity = 0
    if type(GetPedSourceOfDamage) == 'function' then
        sourceEntity = GetPedSourceOfDamage(ped)
    elseif type(GetEntityDamageSource) == 'function' then
        sourceEntity = GetEntityDamageSource(ped)
    end

    local causeHash = type(GetPedCauseOfDeath) == 'function' and GetPedCauseOfDeath(ped) or 0

    -- Fallback for runtimes where direct damage source natives are unreliable/zero.
    if sourceEntity == 0 then
        local nearbyAnimal = findNearbyAnimalAttacker(ped)
        if nearbyAnimal ~= 0 then
            sourceEntity = nearbyAnimal
        else
            local nearbyShooter = findNearbyHumanShooter(ped)
            if nearbyShooter ~= 0 then
                sourceEntity = nearbyShooter
            end
        end
    end

    local entityType = sourceEntity ~= 0 and GetEntityType(sourceEntity) or 0

    -- Prioritize direct attacker entity checks before weapon hints.
    -- This avoids stale weapon flags classifying wolf/bear attacks as gunshot wounds.
    if entityType == 1 and sourceEntity ~= ped and IsEntityAPed(sourceEntity) then
        if IsPedHuman(sourceEntity) then
            local dist = #(GetEntityCoords(ped) - GetEntityCoords(sourceEntity))
            if isLikelyFirearmEquipped(sourceEntity) and dist > 3.0 then
                markRecentGunshot(3500)
                return "gunshot", causeHash, entityType, nil
            end
            return "melee", causeHash, entityType, nil
        end

        local model = GetEntityModel(sourceEntity)
        if model == `A_C_BEAR_01` then
            return "predator", causeHash, entityType, nil
        end
        return "animal", causeHash, entityType, nil
    end

    local isShotgun, shotgunHash = wasDamagedByWeapon(ped, Config.WeaponHints.shotgun, causeHash)
    if isShotgun then markRecentGunshot(3500) return "shotgun", causeHash, entityType, shotgunHash end

    local isKnife, knifeHash = wasDamagedByWeapon(ped, Config.WeaponHints.knife, causeHash)
    if isKnife then return "knife", causeHash, entityType, knifeHash end

    local isFire, fireHash = wasDamagedByWeapon(ped, Config.WeaponHints.fire, causeHash)
    if isFire or IsEntityOnFire(ped) then return "fire", causeHash, entityType, fireHash end

    local isExplosion, expHash = wasDamagedByWeapon(ped, Config.WeaponHints.explosion, causeHash)
    if isExplosion then return "explosion", causeHash, entityType, expHash end

    if IsPedFalling(ped) or IsPedRagdoll(ped) then return "fall", causeHash, entityType, nil end

    -- When RedM does not expose attacker/hash (0/0), only inherit gunshot during
    -- a recent confirmed gunshot window. Do not infer from damage amount alone,
    -- otherwise animal hits can be mislabeled as bullet wounds.
    if causeHash == 0 and entityType == 0 and hasRecentGunshot() and damageAmount >= 5 then
        return "gunshot", causeHash, entityType, nil
    end

    return "melee", causeHash, entityType, nil
end

CreateThread(function()
    Wait(2000)
    local ped = PlayerPedId()
    prevHealth = GetEntityHealth(ped)
    baseMaxHealth = GetEntityMaxHealth(ped)
    baseMaxStamina = Config.DefaultMaxStamina
    lastAppliedHpCap = baseMaxHealth
    lastAppliedStaminaCap = baseMaxStamina
    baseHealthCore = type(GetAttributeCoreValue) == 'function' and GetAttributeCoreValue(ped, 0) or 100
    baseStaminaCore = type(GetAttributeCoreValue) == 'function' and GetAttributeCoreValue(ped, 1) or 100

    while true do
        Wait(Config.DamagePollMs)
        ped = PlayerPedId()
        if DoesEntityExist(ped) and not IsEntityDead(ped) then
            local hp = GetEntityHealth(ped)
            if prevHealth and hp < prevHealth then
                if GetGameTimer() < ignoreDamageUntil then
                    prevHealth = hp
                    goto continue
                end
                local damageAmount = prevHealth - hp
                local category, causeHash, attackerType, weaponHash = detectDamageCategory(ped, damageAmount)
                if category == "gunshot" or category == "shotgun" then markRecentGunshot(3500) end

                local _, bone = GetPedLastDamageBone(ped)
                local bodyPart = getBodyPartFromBone(bone or 0)

                if debugDamageInfoEnabled or Config.Debug then
                    local debugMsg = ("hash=%s attackerType=%s category=%s amount=%s bone=%s weapon=%s")
                        :format(tostring(causeHash), tostring(attackerType), category, damageAmount, tostring(bone), tostring(weaponHash))
                    debugDamageOutput(debugMsg)
                    debugPrint("damage detected: " .. debugMsg)
                end

                TriggerServerEvent('rp_wounds:server:onDamageDetected', {
                    damageAmount = damageAmount,
                    category = category,
                    bodyPart = bodyPart,
                    causeHash = causeHash,
                    attackerType = attackerType,
                    weaponHash = weaponHash
                })

                ClearEntityLastDamageEntity(ped)
                ClearPedLastDamageBone(ped)
                if type(ClearEntityLastWeaponDamage) == 'function' then
                    ClearEntityLastWeaponDamage(ped)
                end
            end
            prevHealth = hp
            ::continue::
        else
            prevHealth = nil
        end
    end
end)

RegisterCommand('debugdamageinfo', function()
    debugDamageInfoEnabled = not debugDamageInfoEnabled
    notify(("Damage debug is now %s"):format(debugDamageInfoEnabled and "^2ON^7" or "^1OFF^7"))
end, false)

RegisterCommand('debugmaxhp', function()
    local ped = PlayerPedId()
    if not DoesEntityExist(ped) then return end

    local currentHp = GetEntityHealth(ped)
    local maxHp = GetEntityMaxHealth(ped)
    local healthCore = type(GetAttributeCoreValue) == 'function' and GetAttributeCoreValue(ped, 0) or 'n/a'
    local msg = ("Current HP: %s | Max HP(native): %s | Health Core: %s | Base HP: %s | Last Applied Cap: %s"):format(currentHp, maxHp, tostring(healthCore), tostring(baseMaxHealth), tostring(lastAppliedHpCap))

    print(("[rp_wounds:maxhp] %s"):format(msg))
    notify(msg)
end, false)

RegisterCommand('debugmaxstamina', function()
    local playerId = PlayerId()
    local maxStamina = nil

    if type(GetPlayerMaxStamina) == 'function' then
        maxStamina = GetPlayerMaxStamina(playerId)
    end

    local staminaCore = type(GetAttributeCoreValue) == 'function' and GetAttributeCoreValue(PlayerPedId(), 1) or 'n/a'

    local msg
    if maxStamina then
        msg = ("Max Stamina(native): %s | Stamina Core: %s | Base Stamina: %s | Last Applied Cap: %s"):format(maxStamina, tostring(staminaCore), tostring(baseMaxStamina), lastAppliedStaminaCap)
    else
        msg = ("Max Stamina native unavailable. Stamina Core: %s | Base Stamina: %s | Last Applied Cap: %s"):format(tostring(staminaCore), tostring(baseMaxStamina), lastAppliedStaminaCap)
    end

    print(("[rp_wounds:maxstamina] %s"):format(msg))
    notify(msg)
end, false)

RegisterNetEvent('rp_wounds:client:notify', function(msg)
    notify(msg)
end)

RegisterNetEvent('rp_wounds:client:applyPenalties', function(data)
    local ped = PlayerPedId()
    if not DoesEntityExist(ped) then return end

    local hpReduction = math.max(0, math.min(Config.MaxTotalReductionPercent, data.hpReduction or data.hpPercent or 0))
    local staminaReduction = math.max(0, math.min(Config.MaxTotalReductionPercent, data.staminaReduction or data.staminaPercent or 0))

    baseMaxHealth = baseMaxHealth or GetEntityMaxHealth(ped)
    baseMaxStamina = baseMaxStamina or Config.DefaultMaxStamina

    local hpCap = math.floor(baseMaxHealth * (1.0 - (hpReduction / 100.0)))
    local staminaCap = math.floor(baseMaxStamina * (1.0 - (staminaReduction / 100.0)))

    local minStatPercent = Config.MinimumStatPercent or 25
    local minHp = math.floor(baseMaxHealth * (minStatPercent / 100.0))
    local minStamina = math.floor(baseMaxStamina * (minStatPercent / 100.0))

    hpCap = math.max(minHp, hpCap)
    staminaCap = math.max(minStamina, staminaCap)
    lastAppliedStaminaCap = staminaCap

    baseHealthCore = baseHealthCore or (type(GetAttributeCoreValue) == 'function' and GetAttributeCoreValue(ped, 0) or 100)
    baseStaminaCore = baseStaminaCore or (type(GetAttributeCoreValue) == 'function' and GetAttributeCoreValue(ped, 1) or 100)

    local healthCoreTarget = math.floor(baseHealthCore * (1.0 - (hpReduction / 100.0)))
    local staminaCoreTarget = math.floor(baseStaminaCore * (1.0 - (staminaReduction / 100.0)))
    local minCore = math.floor((Config.MinimumStatPercent or 25))

    healthCoreTarget = math.max(minCore, healthCoreTarget)
    staminaCoreTarget = math.max(minCore, staminaCoreTarget)

    SetEntityMaxHealth(ped, hpCap)
    if type(SetPedMaxHealth) == 'function' then
        SetPedMaxHealth(ped, hpCap)
    end
    lastAppliedHpCap = hpCap
    if GetEntityHealth(ped) > hpCap then
        ignoreDamageUntil = GetGameTimer() + 1200
        SetEntityHealth(ped, hpCap)
    end

    -- Native hash for RedM SetPlayerMaxStamina (best effort).
    Citizen.InvokeNative(0xC3D4B754C0E86B9E, PlayerId(), staminaCap)

    if type(SetAttributeCoreValue) == 'function' then
        SetAttributeCoreValue(ped, 0, healthCoreTarget)
        SetAttributeCoreValue(ped, 1, staminaCoreTarget)
    end

    debugPrint(("penalties applied: hp%%=%s stamina%%=%s hpCap=%s staminaCap=%s healthCore=%s staminaCore=%s")
        :format(data.hpReduction or data.hpPercent, data.staminaReduction or data.staminaPercent, hpCap, staminaCap, healthCoreTarget, staminaCoreTarget))
end)
