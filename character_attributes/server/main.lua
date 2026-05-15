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

local VORPcore = nil
pcall(function()
    VORPcore = exports.vorp_core:GetCore()
end)

local function trim(str)
    return (str or ""):gsub("^%s*(.-)%s*$", "%1")
end

local function getCharacterName(src)
    if VORPcore and VORPcore.getUser then
        local user = VORPcore.getUser(src)
        if user then
            local character = user.getUsedCharacter
            if character then
                local first = character.firstname or character.firstName or ""
                local last = character.lastname or character.lastName or ""
                local full = trim(first .. " " .. last)
                if full ~= "" then
                    return full
                end
            end
        end
    end

    return GetPlayerName(src)
end

local function htmlEntityDecode(s)
    if type(s) ~= 'string' then return s end
    s = s:gsub('&amp;', '&')
    s = s:gsub('&quot;', '"')
    s = s:gsub('&#39;', "'")
    s = s:gsub('&lt;', '<')
    s = s:gsub('&gt;', '>')
    return s
end

local function tryExtractOgImage(body)
    if type(body) ~= 'string' then return nil end

    local patterns = {
        '<meta%s+property=["\']og:image["\']%s+content=["\']([^"\']+)["\']',
        '<meta%s+content=["\']([^"\']+)["\']%s+property=["\']og:image["\']',
        '<meta%s+name=["\']twitter:image["\']%s+content=["\']([^"\']+)["\']'
    }

    for _, p in ipairs(patterns) do
        local hit = body:match(p)
        if hit and hit:match('^https?://') then
            return htmlEntityDecode(hit)
        end
    end

    return nil
end

local function isDirectImageLike(url)
    if type(url) ~= 'string' then return false end
    if url:match('%.jpe?g([%?&#].*)?$') or url:match('%.png([%?&#].*)?$') or url:match('%.webp([%?&#].*)?$') or url:match('%.gif([%?&#].*)?$') or url:match('%.bmp([%?&#].*)?$') then
        return true
    end
    if url:match('^https?://cdn%.discordapp%.com/attachments/') or url:match('^https?://media%.discordapp%.net/attachments/') then
        return true
    end
    return false
end

local function resolveImgur(url)
    local id = url:match('^https?://imgur%.com/([%w]+)$') or url:match('^https?://m%.imgur%.com/([%w]+)$')
    if id then
        return ('https://i.imgur.com/%s.jpg'):format(id)
    end
    return nil
end

local function resolveImageUrl(inputUrl)
    if type(inputUrl) ~= 'string' or inputUrl == '' then return '' end

    local resolved = resolveImgur(inputUrl) or inputUrl
    if isDirectImageLike(resolved) then
        return resolved
    end

    local p = promise.new()
    PerformHttpRequest(resolved, function(statusCode, body)
        local finalUrl = resolved
        if statusCode and statusCode >= 200 and statusCode < 400 and type(body) == 'string' then
            if body:find('<html', 1, true) or body:find('<meta', 1, true) then
                local og = tryExtractOgImage(body)
                if og then finalUrl = og end
            end
        end
        p:resolve(finalUrl)
    end, 'GET', '', {
        ['User-Agent'] = 'Mozilla/5.0',
        ['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8'
    })

    return Citizen.Await(p)
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

    imageUrl = resolveImageUrl(imageUrl)

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
        if data and data.image_url and data.image_url ~= '' then
            data.image_url = resolveImageUrl(data.image_url)
        end
    end

    if not data then
        data = {
            character_name = getCharacterName(src),
            age = '',
            image_url = '',
            appearance_description = ''
        }
    elseif not data.character_name or data.character_name == '' then
        data.character_name = getCharacterName(src)
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

    if target and target.image_url and target.image_url ~= '' then
        target.image_url = resolveImageUrl(target.image_url)
    end

    TriggerClientEvent('character_attributes:response', src, requestId, target)
end)
