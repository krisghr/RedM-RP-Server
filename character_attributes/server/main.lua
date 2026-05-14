local function ensureTable()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS character_attributes (
            id INT NOT NULL AUTO_INCREMENT,
            owner_identifier VARCHAR(80) NOT NULL,
            character_name VARCHAR(120) NOT NULL,
            age INT NOT NULL,
            image_url TEXT,
            appearance_description TEXT,
            updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (id),
            UNIQUE KEY uq_owner_identifier (owner_identifier),
            KEY idx_character_name (character_name)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
end

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        ensureTable()
    end
end)

local function getIdentifier(src)
    local ids = GetPlayerIdentifiers(src)
    return ids[1]
end

RegisterNetEvent('character_attributes:save', function(payload)
    local src = source
    local identifier = getIdentifier(src)
    if not identifier then return end
    if type(payload) ~= 'table' then return end

    local characterName = tostring(payload.characterName or ''):sub(1, 120)
    local age = tonumber(payload.age) or 0
    local imageUrl = tostring(payload.imageUrl or ''):sub(1, 2000)
    local appearanceDescription = tostring(payload.appearanceDescription or ''):sub(1, 3000)

    if characterName == '' or age < 1 then
        TriggerClientEvent('character_attributes:notify', src, '^1Name and age are required.')
        return
    end

    MySQL.update.await([[
        INSERT INTO character_attributes (owner_identifier, character_name, age, image_url, appearance_description)
        VALUES (?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
            character_name = VALUES(character_name),
            age = VALUES(age),
            image_url = VALUES(image_url),
            appearance_description = VALUES(appearance_description)
    ]], { identifier, characterName, age, imageUrl, appearanceDescription })

    TriggerClientEvent('character_attributes:notify', src, '^2Attributes saved.')
end)

RegisterNetEvent('character_attributes:getOwn', function(requestId)
    local src = source
    local identifier = getIdentifier(src)
    local data = nil

    if identifier then
        data = MySQL.single.await('SELECT character_name, age, image_url, appearance_description FROM character_attributes WHERE owner_identifier = ? LIMIT 1', { identifier })
    end

    TriggerClientEvent('character_attributes:response', src, requestId, data)
end)

RegisterNetEvent('character_attributes:getByQuery', function(requestId, query)
    local src = source
    if not query or query == '' then
        TriggerClientEvent('character_attributes:response', src, requestId, nil)
        return
    end

    local target = nil
    local targetId = tonumber(query)

    if targetId and GetPlayerName(targetId) then
        local identifier = getIdentifier(targetId)
        if identifier then
            target = MySQL.single.await('SELECT character_name, age, image_url, appearance_description FROM character_attributes WHERE owner_identifier = ? LIMIT 1', { identifier })
        end
    end

    if not target then
        target = MySQL.single.await('SELECT character_name, age, image_url, appearance_description FROM character_attributes WHERE character_name = ? LIMIT 1', { query })
    end

    TriggerClientEvent('character_attributes:response', src, requestId, target)
end)
