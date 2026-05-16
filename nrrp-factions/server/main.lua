local VorpCore = {}
TriggerEvent('getCore', function(core)
    VorpCore = core
end)

local function getCharacterFromSource(src)
    local user = VorpCore.getUser(src)
    if not user then
        return nil, nil
    end

    local character = user.getUsedCharacter
    if not character then
        return nil, nil
    end

    return user, character
end

local function decodePermissions(raw)
    if not raw or raw == '' then
        return {}
    end

    local ok, result = pcall(json.decode, raw)
    if ok and type(result) == 'table' then
        return result
    end

    return {}
end

local function tableHasKey(tableObj, key)
    return tableObj and tableObj[key] == true
end


local pendingFactionDelete = {}

local function isAdmin(src)
    if src == 0 then
        return true
    end

    local _, character = getCharacterFromSource(src)
    if character then
        if Config.AdminGroups and Config.AdminGroups[character.group] then
            return true
        end

        if Config.AdminJobs and Config.AdminJobs[character.job] then
            return true
        end
    end

    if IsPlayerAceAllowed(src, 'faction.admin') or IsPlayerAceAllowed(src, 'group.admin') then
        return true
    end

    return false
end

local function factionByName(name)
    return MySQL.single.await('SELECT id, name, type, status FROM factions WHERE LOWER(name) = LOWER(?) LIMIT 1', { name })
end

local function sendFactionMessage(src, color, text)
    TriggerClientEvent('chat:addMessage', src, { args = { color, text } })
end

local function ensureSchema()
    MySQL.query.await([[CREATE TABLE IF NOT EXISTS factions (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(64) NOT NULL UNIQUE,
        type VARCHAR(32) NOT NULL,
        charter TEXT,
        founded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        status VARCHAR(16) NOT NULL DEFAULT 'active'
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])

    MySQL.query.await([[CREATE TABLE IF NOT EXISTS faction_roles (
        id INT AUTO_INCREMENT PRIMARY KEY,
        faction_id INT NOT NULL,
        name VARCHAR(64) NOT NULL,
        rank_weight INT NOT NULL,
        permissions_json TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE KEY uniq_role_name (faction_id, name),
        FOREIGN KEY (faction_id) REFERENCES factions(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])

    MySQL.query.await([[CREATE TABLE IF NOT EXISTS faction_members (
        id INT AUTO_INCREMENT PRIMARY KEY,
        faction_id INT NOT NULL,
        character_id INT NOT NULL,
        role_id INT NOT NULL,
        joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        is_active TINYINT(1) NOT NULL DEFAULT 1,
        UNIQUE KEY uniq_character_faction (faction_id, character_id),
        FOREIGN KEY (faction_id) REFERENCES factions(id) ON DELETE CASCADE,
        FOREIGN KEY (role_id) REFERENCES faction_roles(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])

    MySQL.query.await([[CREATE TABLE IF NOT EXISTS faction_reputation (
        faction_id INT PRIMARY KEY,
        legitimacy INT NOT NULL DEFAULT 0,
        force INT NOT NULL DEFAULT 0,
        wealth INT NOT NULL DEFAULT 0,
        intel INT NOT NULL DEFAULT 0,
        culture INT NOT NULL DEFAULT 0,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (faction_id) REFERENCES factions(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])

    MySQL.query.await([[CREATE TABLE IF NOT EXISTS faction_ledger (
        id INT AUTO_INCREMENT PRIMARY KEY,
        faction_id INT NOT NULL,
        amount INT NOT NULL,
        reason VARCHAR(128) NOT NULL,
        source_type VARCHAR(32) NOT NULL,
        created_by INT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (faction_id) REFERENCES factions(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])

    MySQL.query.await([[CREATE TABLE IF NOT EXISTS faction_activity (
        id INT AUTO_INCREMENT PRIMARY KEY,
        faction_id INT NOT NULL,
        activity_type VARCHAR(32) NOT NULL,
        points INT NOT NULL DEFAULT 1,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (faction_id) REFERENCES factions(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])
end

local function ensureFactionDefaults(factionId)
    local rep = Config.ReputationDefaults
    MySQL.query.await(
        'INSERT IGNORE INTO faction_reputation (faction_id, legitimacy, force, wealth, intel, culture) VALUES (?, ?, ?, ?, ?, ?)',
        { factionId, rep.legitimacy, rep.force, rep.wealth, rep.intel, rep.culture }
    )

    local leaderPerms = json.encode(Config.Capabilities)
    local recruitPerms = json.encode({})

    local leaderId = MySQL.insert.await(
        'INSERT IGNORE INTO faction_roles (faction_id, name, rank_weight, permissions_json) VALUES (?, ?, ?, ?)',
        { factionId, Config.LeaderRoleName, 100, leaderPerms }
    )

    if not leaderId or leaderId == 0 then
        local roleRow = MySQL.single.await('SELECT id FROM faction_roles WHERE faction_id = ? AND name = ?', { factionId, Config.LeaderRoleName })
        leaderId = roleRow and roleRow.id or nil
    end

    MySQL.insert.await(
        'INSERT IGNORE INTO faction_roles (faction_id, name, rank_weight, permissions_json) VALUES (?, ?, ?, ?)',
        { factionId, Config.RecruitRoleName, 1, recruitPerms }
    )

    return leaderId
end

local function getMemberContext(charIdentifier)
    return MySQL.single.await([[
        SELECT fm.faction_id, fm.role_id, fr.rank_weight, fr.permissions_json
        FROM faction_members fm
        INNER JOIN faction_roles fr ON fr.id = fm.role_id
        WHERE fm.character_id = ? AND fm.is_active = 1
        LIMIT 1
    ]], { charIdentifier })
end

local function hasCapability(charIdentifier, capability)
    local ctx = getMemberContext(charIdentifier)
    if not ctx then
        return false, nil
    end

    local permissions = decodePermissions(ctx.permissions_json)
    return tableHasKey(permissions, capability), ctx
end

local function factionBalance(factionId)
    local row = MySQL.single.await('SELECT COALESCE(SUM(amount), 0) AS balance FROM faction_ledger WHERE faction_id = ?', { factionId })
    return row and row.balance or 0
end

RegisterCommand('faction_create', function(source, args)
    local _, character = getCharacterFromSource(source)
    if not character then
        return
    end

    local factionName = table.concat(args, ' ')
    if factionName == '' or #factionName > Config.MaxNameLength then
        TriggerClientEvent('chat:addMessage', source, { args = { '^1Faction', ('Invalid name. 1-%s characters.'):format(Config.MaxNameLength) } })
        return
    end

    local charId = character.charIdentifier
    if getMemberContext(charId) then
        TriggerClientEvent('chat:addMessage', source, { args = { '^1Faction', 'You are already in a faction.' } })
        return
    end

    local factionId = MySQL.insert.await('INSERT INTO factions (name, type, charter) VALUES (?, ?, ?)', { factionName, 'unofficial', '' })
    if not factionId then
        TriggerClientEvent('chat:addMessage', source, { args = { '^1Faction', 'Faction creation failed.' } })
        return
    end

    local leaderRoleId = ensureFactionDefaults(factionId)
    if leaderRoleId then
        MySQL.insert.await('INSERT INTO faction_members (faction_id, character_id, role_id) VALUES (?, ?, ?)', { factionId, charId, leaderRoleId })
        if Config.StartingTreasury ~= 0 then
            MySQL.insert.await('INSERT INTO faction_ledger (faction_id, amount, reason, source_type, created_by) VALUES (?, ?, ?, ?, ?)', { factionId, Config.StartingTreasury, 'Initial treasury', 'system', charId })
        end
    end

    TriggerClientEvent('chat:addMessage', source, { args = { '^2Faction', ('Faction created: %s'):format(factionName) } })
    TriggerClientEvent('chat:addMessage', source, { args = { '^3Faction', ('Confirmation: You are now the leader of %s. Use /faction_invite <id> to recruit.'):format(factionName) } })
end)

RegisterCommand('faction_invite', function(source, args)
    local _, character = getCharacterFromSource(source)
    if not character then
        return
    end

    local targetId = tonumber(args[1])
    if not targetId then
        return
    end

    local ok, ctx = hasCapability(character.charIdentifier, 'invite_member')
    if not ok then
        TriggerClientEvent('chat:addMessage', source, { args = { '^1Faction', 'You do not have invite permission.' } })
        return
    end

    local _, targetCharacter = getCharacterFromSource(targetId)
    if not targetCharacter then
        return
    end

    if getMemberContext(targetCharacter.charIdentifier) then
        TriggerClientEvent('chat:addMessage', source, { args = { '^1Faction', 'Target is already in a faction.' } })
        return
    end

    local recruitRole = MySQL.single.await('SELECT id FROM faction_roles WHERE faction_id = ? AND name = ? LIMIT 1', { ctx.faction_id, Config.RecruitRoleName })
    if not recruitRole then
        return
    end

    MySQL.insert.await('INSERT INTO faction_members (faction_id, character_id, role_id) VALUES (?, ?, ?)', { ctx.faction_id, targetCharacter.charIdentifier, recruitRole.id })
    TriggerClientEvent('chat:addMessage', source, { args = { '^2Faction', ('Invited player %s into faction.'):format(targetId) } })
    TriggerClientEvent('chat:addMessage', targetId, { args = { '^2Faction', 'You have joined a faction as Recruit.' } })
end)

RegisterCommand('faction_deposit', function(source, args)
    local _, character = getCharacterFromSource(source)
    local amount = tonumber(args[1])
    if not character or not amount or amount <= 0 then
        return
    end

    local ok, ctx = hasCapability(character.charIdentifier, 'deposit_funds')
    if not ok then
        TriggerClientEvent('chat:addMessage', source, { args = { '^1Faction', 'You do not have deposit permission.' } })
        return
    end

    local money = character.money
    if money < amount then
        TriggerClientEvent('chat:addMessage', source, { args = { '^1Faction', 'Not enough cash.' } })
        return
    end

    character.removeCurrency(0, amount)
    MySQL.insert.await('INSERT INTO faction_ledger (faction_id, amount, reason, source_type, created_by) VALUES (?, ?, ?, ?, ?)', { ctx.faction_id, amount, 'Member deposit', 'player', character.charIdentifier })
    TriggerClientEvent('chat:addMessage', source, { args = { '^2Faction', ('Deposited $%s'):format(amount) } })
end)

RegisterCommand('faction_withdraw', function(source, args)
    local _, character = getCharacterFromSource(source)
    local amount = tonumber(args[1])
    if not character or not amount or amount <= 0 then
        return
    end

    local ok, ctx = hasCapability(character.charIdentifier, 'withdraw_funds')
    if not ok then
        TriggerClientEvent('chat:addMessage', source, { args = { '^1Faction', 'You do not have withdraw permission.' } })
        return
    end

    local balance = factionBalance(ctx.faction_id)
    if balance < amount then
        TriggerClientEvent('chat:addMessage', source, { args = { '^1Faction', 'Faction treasury lacks funds.' } })
        return
    end

    MySQL.insert.await('INSERT INTO faction_ledger (faction_id, amount, reason, source_type, created_by) VALUES (?, ?, ?, ?, ?)', { ctx.faction_id, -amount, 'Leader withdrawal', 'player', character.charIdentifier })
    character.addCurrency(0, amount)
    TriggerClientEvent('chat:addMessage', source, { args = { '^2Faction', ('Withdrew $%s'):format(amount) } })
end)


RegisterCommand('factioninfo', function(source)
    local _, character = getCharacterFromSource(source)
    if not character then
        sendFactionMessage(source, '^1Faction', 'Character not loaded yet. Try again in a moment.')
        return
    end

    local row = MySQL.single.await([[
        SELECT f.id, f.name, f.type, f.status, f.founded_at,
               fr.name AS role_name, fr.rank_weight,
               rep.legitimacy, rep.force, rep.wealth, rep.intel, rep.culture
        FROM faction_members fm
        INNER JOIN factions f ON f.id = fm.faction_id
        INNER JOIN faction_roles fr ON fr.id = fm.role_id
        LEFT JOIN faction_reputation rep ON rep.faction_id = f.id
        WHERE fm.character_id = ? AND fm.is_active = 1
        LIMIT 1
    ]], { character.charIdentifier })

    if not row then
        TriggerClientEvent('chat:addMessage', source, { args = { '^1Faction', 'You are not currently in a faction.' } })
        return
    end

    local balance = factionBalance(row.id)
    local founded = tostring(row.founded_at or 'unknown')

    TriggerClientEvent('chat:addMessage', source, { args = { '^2Faction', ('Faction: %s (#%s) | Type: %s | Status: %s'):format(row.name, row.id, row.type, row.status) } })
    TriggerClientEvent('chat:addMessage', source, { args = { '^2Faction', ('Role: %s (rank %s) | Founded: %s'):format(row.role_name, row.rank_weight, founded) } })
    TriggerClientEvent('chat:addMessage', source, { args = { '^2Faction', ('Treasury: $%s | Rep L/F/W/I/C: %s/%s/%s/%s/%s'):format(balance, row.legitimacy or 0, row.force or 0, row.wealth or 0, row.intel or 0, row.culture or 0) } })
end)

RegisterCommand('faction_balance', function(source)
    local _, character = getCharacterFromSource(source)
    if not character then
        return
    end

    local ctx = getMemberContext(character.charIdentifier)
    if not ctx then
        return
    end

    local balance = factionBalance(ctx.faction_id)
    TriggerClientEvent('chat:addMessage', source, { args = { '^2Faction', ('Treasury balance: $%s'):format(balance) } })
end)

RegisterCommand('faction_activity', function(source, args)
    local _, character = getCharacterFromSource(source)
    if not character then
        return
    end

    local activityType = tostring(args[1] or '')
    local points = tonumber(args[2]) or 1
    local ctx = getMemberContext(character.charIdentifier)

    if activityType == '' or not ctx then
        return
    end

    MySQL.insert.await('INSERT INTO faction_activity (faction_id, activity_type, points) VALUES (?, ?, ?)', { ctx.faction_id, activityType, points })
    TriggerClientEvent('chat:addMessage', source, { args = { '^2Faction', ('Logged activity %s x%s'):format(activityType, points) } })
end)


RegisterCommand('factionlist', function(source)
    if not isAdmin(source) then
        sendFactionMessage(source, '^1Faction', 'Admin only command.')
        return
    end

    local rows = MySQL.query.await('SELECT id, name, type, status FROM factions ORDER BY name ASC') or {}
    if #rows == 0 then
        sendFactionMessage(source, '^1Faction', 'No factions found.')
        return
    end

    sendFactionMessage(source, '^3Faction', ('Listing %s faction(s):'):format(#rows))
    for _, row in ipairs(rows) do
        sendFactionMessage(source, '^2Faction', ('- %s (#%s) | Type: %s | Status: %s'):format(row.name, row.id, row.type, row.status))
    end
end, false)

RegisterCommand('factiondelete', function(source, args)
    if not isAdmin(source) then
        sendFactionMessage(source, '^1Faction', 'Admin only command.')
        return
    end

    local factionName = tostring(args[1] or '')
    local confirm = tostring(args[2] or '')

    if factionName == '' then
        sendFactionMessage(source, '^1Faction', 'Usage: /factiondelete <name> [CONFIRM]')
        return
    end

    local faction = factionByName(factionName)
    if not faction then
        sendFactionMessage(source, '^1Faction', ('Faction not found: %s'):format(factionName))
        pendingFactionDelete[source] = nil
        return
    end

    if confirm ~= 'CONFIRM' then
        pendingFactionDelete[source] = { id = faction.id, name = faction.name }
        sendFactionMessage(source, '^3Faction', ('Delete requested for "%s". Run /factiondelete %s CONFIRM to permanently delete it.'):format(faction.name, faction.name))
        return
    end

    local pending = pendingFactionDelete[source]
    if not pending or pending.id ~= faction.id then
        sendFactionMessage(source, '^1Faction', ('Confirmation mismatch. First run /factiondelete %s, then repeat with CONFIRM.'):format(faction.name))
        return
    end

    local affected = MySQL.update.await('DELETE FROM factions WHERE id = ?', { faction.id })
    pendingFactionDelete[source] = nil

    if affected and affected > 0 then
        sendFactionMessage(source, '^2Faction', ('Faction deleted: %s (#%s)'):format(faction.name, faction.id))
    else
        sendFactionMessage(source, '^1Faction', 'Deletion failed.')
    end
end, false)

local function applyDailyReputationTick()
    local rows = MySQL.query.await([[
        SELECT faction_id, activity_type, SUM(points) AS total_points
        FROM faction_activity
        WHERE created_at >= (NOW() - INTERVAL 1 DAY)
        GROUP BY faction_id, activity_type
    ]])

    local aggregate = {}
    for _, row in ipairs(rows or {}) do
        local profile = Config.ReputationSources[row.activity_type]
        if profile then
            aggregate[row.faction_id] = aggregate[row.faction_id] or { legitimacy = 0, force = 0, wealth = 0, intel = 0, culture = 0 }
            for stat, value in pairs(profile) do
                aggregate[row.faction_id][stat] = aggregate[row.faction_id][stat] + (value * row.total_points)
            end
        end
    end

    for factionId, changes in pairs(aggregate) do
        MySQL.update.await([[
            UPDATE faction_reputation
            SET legitimacy = legitimacy + ?, force = force + ?, wealth = wealth + ?, intel = intel + ?, culture = culture + ?
            WHERE faction_id = ?
        ]], { changes.legitimacy, changes.force, changes.wealth, changes.intel, changes.culture, factionId })
    end
end

CreateThread(function()
    ensureSchema()
    while true do
        Wait(Config.DailyReputationTickMinutes * 60 * 1000)
        applyDailyReputationTick()
    end
end)
