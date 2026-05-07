RegisterNetEvent("mosquito:server:resourceNameMismatch")
AddEventHandler("mosquito:server:resourceNameMismatch", function(resName)
    local src = source
    if Config.Debug then
        print("^1[mosquito-animations] Resource name mismatch! The resource name must be 'mosquito-animations'")
    end
    DropPlayer(src, "Resource name mismatch detected: " .. tostring(resName))
    if Config.Debug then
        print("^1Resource name mismatch, please ensure the resource is named ^7mosquito-animations.")
    end
end)

local playerAnimationProps = {}
local playerWalkAnimations = {}
local framework = string.lower(Config.Framework)

RegisterNetEvent("emotes:requestSharedEmote")
RegisterNetEvent("emotes:rejectSharedEmote")
RegisterNetEvent("emotes:acceptSharedEmote")
RegisterNetEvent("emotes:stopSharedEmote")

AddEventHandler("emotes:requestSharedEmote", function(player, emote)
    TriggerClientEvent("emotes:requestSharedEmote", player, source, emote)
end)

AddEventHandler("emotes:rejectSharedEmote", function(player, emote)
    TriggerClientEvent("emotes:rejectSharedEmote", player, source, emote)
end)

AddEventHandler("emotes:acceptSharedEmote", function(player, emote, partnerCoords, partnerHeading)
    TriggerClientEvent("emotes:acceptSharedEmote", player, source, emote, partnerCoords, partnerHeading)
end)

AddEventHandler("emotes:stopSharedEmote", function(player, emote)
    TriggerClientEvent("emotes:stopSharedEmote", player, source, emote)
end)

RegisterServerEvent("server:SetWalkStyle")
AddEventHandler("server:SetWalkStyle", function(base, style)
    TriggerClientEvent("client:SetWalkStyle", -1, source, base, style)
end)

function printTableRecursive(tbl, indent, color)
    if not Config.Debug or type(tbl) ~= "table" then
        return
    end

    local color = color or "^3"
    indent = indent or 0
    local prefix = string.rep("  ", indent)
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            print(prefix .. color .. tostring(k) .. "^7:")
            printTableRecursive(v, indent + 1)
        else
            print(prefix .. color .. tostring(k) .. "^7 = ^2" .. tostring(v) .. "^7")
        end
    end
end

CreateThread(function()
    local exists = exports.ghmattimysql:executeSync("SHOW TABLES LIKE 'mosquito_favorite_animations'")
    if not exists or #exists == 0 then
        exports.oxmysql:executeSync([[
            CREATE TABLE IF NOT EXISTS mosquito_favorite_animations (
                `identifier` VARCHAR(64) NOT NULL,
                PRIMARY KEY (`identifier`),
                `steamname` TEXT DEFAULT NULL,
                `favorites` JSON NOT NULL DEFAULT '[]',
                `walkanim` TEXT DEFAULT NULL,
                `menu_position` TEXT DEFAULT NULL
            )
        ]])
        if Config.Debug then
            print("^2[mosquito-animations] ^3MySQL table 'mosquito_favorite_animations' has been created successfully.^7")
        end
    else
        if Config.Debug then
            print("^1[mosquito-animations] ^3MySQL table 'mosquito_favorite_animations' already exists.^7")
        end
        local columns = exports.ghmattimysql:executeSync("SHOW COLUMNS FROM mosquito_favorite_animations LIKE 'menu_position'")
        if not columns or #columns == 0 then
            exports.ghmattimysql:executeSync("ALTER TABLE mosquito_favorite_animations ADD COLUMN `menu_position` TEXT DEFAULT NULL")
            if Config.Debug then
                print("^2[mosquito-animations] ^3Added 'menu_position' column to 'mosquito_favorite_animations' table.^7")
            end
        else
            if Config.Debug then
                print("^1[mosquito-animations] ^3Column 'menu_position' already exists in 'mosquito_favorite_animations' table.^7")
            end
        end
    end
end)

function GetPreferredIdentifier(src)
    local idTable = GetPlayerIdentifiers(src)
    local identifier

    for _, id in ipairs(idTable) do
        if id:match("^steam:") then
            identifier = id
            break
        elseif id:match("^discord:") then
            identifier = id
            break
        elseif id:match("^xbl:") then
            identifier = id
            break
        elseif id:match("^license:") then
            identifier = id
            break
        end
    end

    if not identifier and idTable[1] then
        identifier = idTable[1]
    end
    if Config.Debug then
        -- print("Selected identifier: " .. tostring(identifier))
    end
    return identifier
end

RegisterNetEvent("mosquito:Server:SaveQuickMenuPositionOffset")
AddEventHandler("mosquito:Server:SaveQuickMenuPositionOffset", function(positionOffset, scale, textScale, textOffset, font, maxBlendMoveRatio)
    local src = source
    local identifier = GetPreferredIdentifier(src)
    local result = exports.ghmattimysql:executeSync("SELECT menu_position FROM mosquito_favorite_animations WHERE identifier = @identifier", {
        ['@identifier'] = identifier
    })
    local menuPosTable = {}
    if result and #result > 0 and result[1].menu_position then
        menuPosTable = json.decode(result[1].menu_position) or {}
    end
    menuPosTable.MenuPositionOffset = positionOffset
    menuPosTable.MenuScale = scale
    menuPosTable.MenuTextScale = textScale
    menuPosTable.MenuTextOffset = textOffset
    menuPosTable.MenuFont = font
    menuPosTable.MaxBlendMoveRatio = tonumber(maxBlendMoveRatio) or tonumber(menuPosTable.MaxBlendMoveRatio) or tonumber(Config.MaxBlendMoveRatio) or tonumber(Config.AnimationWalkSpeed) or 1.5
    exports.ghmattimysql:executeSync([[
        INSERT INTO mosquito_favorite_animations (identifier, menu_position)
        VALUES (@identifier, @menu_position)
        ON DUPLICATE KEY UPDATE menu_position = @menu_position
    ]], {
        ['@identifier'] = identifier,
        ['@menu_position'] = json.encode(menuPosTable)
    })
    if Config.Debug then
        print("Saved quick menu position offset and scale for " .. identifier .. ": ", json.encode(menuPosTable))
    end
end)

RegisterNetEvent("mosquito:server:requestWalkAnim")
AddEventHandler("mosquito:server:requestWalkAnim", function(vorpCharId)
    local src = source
    local identifier = GetPreferredIdentifier(src)
    local result = exports.ghmattimysql:executeSync("SELECT walkanim FROM mosquito_favorite_animations WHERE identifier = @identifier", {
        ['@identifier'] = identifier
    })
    local charId
    if framework == "vorp" then
        if not vorpCharId then
            local VORP = exports.vorp_core:GetCore()
            local user = VORP.getUser(src)
            local character = user and user.getUsedCharacter or false
            if not character then
                if Config.Debug then
                    print('[mosquito_animations] ERROR: ^1Character not found!^7')
                end
                return
            end
            charId = character.charIdentifier
        else
            if Config.Debug then
                print("Using passed vorpCharId: " .. vorpCharId)
            end
            charId = vorpCharId
        end
    elseif framework == "rsg" then
        local RSGCore = exports['rsg-core']:GetCoreObject()
        local Player = RSGCore.Functions.GetPlayer(src)
        playerData = Player and Player.PlayerData or nil
        if not playerData then
            if Config.Debug then
                print('[mosquito_animations] ERROR: ^1Player data not found!^7')
            end
            return
        end
        -- print("Got player data: " .. json.encode(playerData))
        charId = playerData.citizenid
    else
        if Config.Debug then
            print('[mosquito_animations] ^1!! This framework is not supported !!^7')
        end
        return
    end
    charId = tostring(charId)
    local defaultBlendRatio = tonumber(Config.MaxBlendMoveRatio) or tonumber(Config.AnimationWalkSpeed) or 1.5

    local function normalizeWalkSettings(value)
        if type(value) == "table" then
            local anim = value.anim or value.walkanim or value.style or value.hash or "noanim"
            local blendRatio = tonumber(value.blendRatio) or tonumber(value.maxBlendMoveRatio) or defaultBlendRatio
            return tostring(anim), blendRatio
        end

        if type(value) == "string" and value ~= "" then
            return value, defaultBlendRatio
        end

        return "noanim", defaultBlendRatio
    end

    if not result or #result == 0 or result[1].walkanim == nil or result[1].walkanim == "" then
        TriggerClientEvent("mosquito:animations:setwalkanim", src, "noanim", true, false, defaultBlendRatio)
    else
        if Config.Debug then
            print("Walk Anim Table \n", result[1].walkanim)
        end
        local decodedWalkAnim = result[1].walkanim and json.decode(result[1].walkanim) or nil
        local walkAnimTable = (decodedWalkAnim and type(decodedWalkAnim) == "table") and decodedWalkAnim or result[1].walkanim
        local walkAnim = "noanim"
        local blendRatio = defaultBlendRatio
        if Config.WalkstyleSaveToCharacter then
            if walkAnimTable and walkAnimTable ~= "" then
                if type(walkAnimTable) ~= "table" then
                    walkAnimTable = {}
                    walkAnim = result[1].walkanim
                    walkAnimTable[charId] = { anim = walkAnim, blendRatio = defaultBlendRatio }
                    if Config.Debug then
                        print("Printing returned table for server ID: ^3" .. tostring(src) .. "^7 with identifier: ^3" .. tostring(identifier) .. "^7")
                        printTableRecursive(walkAnimTable, 1)
                    end
                else
                    walkAnim, blendRatio = normalizeWalkSettings(walkAnimTable[charId])
                    walkAnimTable[charId] = { anim = walkAnim, blendRatio = blendRatio }
                end
                exports.ghmattimysql:executeSync([[
                        UPDATE mosquito_favorite_animations
                        SET walkanim = @walkanim
                        WHERE identifier = @identifier
                    ]], {
                    ['@identifier'] = identifier,
                    ['@walkanim'] = json.encode(walkAnimTable)
                })
            end
            TriggerClientEvent("mosquito:animations:setwalkanim", src, walkAnim, true, false, blendRatio)
        else
            if walkAnimTable and walkAnimTable ~= "" then
                if type(walkAnimTable) == "table" then
                    if walkAnimTable.anim or walkAnimTable.blendRatio or walkAnimTable.maxBlendMoveRatio then
                        walkAnim, blendRatio = normalizeWalkSettings(walkAnimTable)
                    else
                        for _, v in pairs(walkAnimTable) do
                            walkAnim, blendRatio = normalizeWalkSettings(v)
                            break
                        end
                    end
                    exports.ghmattimysql:executeSync([[
                        UPDATE mosquito_favorite_animations
                        SET walkanim = @walkanim
                        WHERE identifier = @identifier
                    ]], {
                        ['@identifier'] = identifier,
                        ['@walkanim'] = json.encode({ anim = walkAnim, blendRatio = blendRatio })
                    })
                else
                    walkAnim, blendRatio = normalizeWalkSettings(walkAnimTable)
                end
                TriggerClientEvent("mosquito:animations:setwalkanim", src, walkAnim, true, false, blendRatio)
            else
                TriggerClientEvent("mosquito:animations:setwalkanim", src, "noanim", true, false, defaultBlendRatio)
            end
        end
    end
end)

RegisterNetEvent("mosquito:Server:ApplyWalkAnimToOthers")
AddEventHandler("mosquito:Server:ApplyWalkAnimToOthers", function(anim)
    local src = source
    TriggerClientEvent("mosquito:animations:applyToOtherPed", -1, src, anim)
end)

RegisterNetEvent("mosquito:Server:StorePlayersCurrentWalkAnim")
AddEventHandler("mosquito:Server:StorePlayersCurrentWalkAnim", function(anim, playerSrc)
    local src = playerSrc or source
    playerWalkAnimations[src] = anim
end)

RegisterNetEvent('mosquito:server:getFavoriteAnimations')
AddEventHandler('mosquito:server:getFavoriteAnimations', function(itDidntWork, _src)
    local src = _src or source
    local identifier = GetPreferredIdentifier(src)
    local result = exports.ghmattimysql:executeSync("SELECT favorites, menu_position FROM mosquito_favorite_animations WHERE identifier = @identifier", {
        ['@identifier'] = identifier
    })
    local tableToInsert = {}
    if itDidntWork then
        for k, v in pairs(Config.PresetFavoriteEmotes) do
            tableToInsert[tostring(k)] = { animation_command = v.animation_command, animation_type = v.animation_type }
        end
        local defaultMenuPos = {
            MenuScale = Config_QuickMenu and Config_QuickMenu.MenuScale or 0.8,
            MenuPositionOffset = Config_QuickMenu and Config_QuickMenu.MenuPositionOffset or { x = 0.0, y = 0.2 },
            MenuTextScale = Config_QuickMenu and Config_QuickMenu.MenuTextScale or 0.35,
            MenuTextOffset = Config_QuickMenu and Config_QuickMenu.MenuTextOffset or { x = 0.0, y = 0.0 },
            MenuFont = Config_QuickMenu and Config_QuickMenu.MenuFont or 30,
            MaxBlendMoveRatio = Config.MaxBlendMoveRatio or Config.AnimationWalkSpeed or 1.5
        }
        exports.ghmattimysql:executeSync([[
            INSERT INTO mosquito_favorite_animations (identifier, favorites, menu_position)
            VALUES (@identifier, @favorites, @menu_position)
            ON DUPLICATE KEY UPDATE favorites = @favorites, menu_position = @menu_position
        ]], {
            ['@identifier'] = identifier,
            ['@favorites'] = json.encode(tableToInsert),
            ['@menu_position'] = json.encode(defaultMenuPos)
        })
        Wait(300)
        TriggerClientEvent('mosquito:client:receiveFavoriteAnimations', src, true, false, tableToInsert, nil, nil, defaultMenuPos)
        return
    end
    if not result or #result == 0 then
        TriggerEvent('mosquito:server:getFavoriteAnimations', true, src)
        return
    end
    if result[1].favorites == nil or result[1].favorites == "" or result[1].favorites == "[]" then
        TriggerEvent('mosquito:server:getFavoriteAnimations', true, src)
        return
    end
    if result[1].menu_position == nil or result[1].menu_position == "" then
        TriggerEvent('mosquito:server:getFavoriteAnimations', true, src)
        return
    end

    local okFav, decodedFav = pcall(json.decode, result[1].favorites)
    local okMenu, decodedMenu = pcall(json.decode, result[1].menu_position)
    if okFav and type(decodedFav) == "table" and next(decodedFav) then
        local menuPosToSend = (okMenu and type(decodedMenu) == "table") and decodedMenu or {
            MenuScale = Config_QuickMenu and Config_QuickMenu.MenuScale or 0.8,
            MenuPositionOffset = Config_QuickMenu and Config_QuickMenu.MenuPositionOffset or { x = 0.0, y = 0.2 },
            MenuTextScale = Config_QuickMenu and Config_QuickMenu.MenuTextScale or 0.35,
            MenuTextOffset = Config_QuickMenu and Config_QuickMenu.MenuTextOffset or { x = 0.0, y = 0.0 },
            MenuFont = Config_QuickMenu and Config_QuickMenu.MenuFont or 30,
            MaxBlendMoveRatio = Config.MaxBlendMoveRatio or Config.AnimationWalkSpeed or 1.5
        }
        TriggerClientEvent('mosquito:client:receiveFavoriteAnimations', src, true, false, decodedFav, nil, nil, menuPosToSend)
    else
        TriggerEvent('mosquito:server:getFavoriteAnimations', true, src)
    end
end)

RegisterNetEvent('mosquito:server:favoriteNewAnimation')
AddEventHandler('mosquito:server:favoriteNewAnimation', function(index, animation_command, animation_type)
    local src = source
    local identifier = GetPreferredIdentifier(src)

    local result = exports.ghmattimysql:executeSync("SELECT favorites FROM mosquito_favorite_animations WHERE identifier = @identifier", {
        ['@identifier'] = identifier
    })

    local favorites = {}
    if result and result[1] and result[1].favorites then
        local ok, decoded = pcall(json.decode, result[1].favorites)
        if ok and type(decoded) == "table" then
            favorites = decoded
        end
    end

    local key
    if index ~= nil then
        local num = tonumber(index)
        if num then
            key = tostring(num)
        else
            key = tostring(index)
        end
    else
        local idx = 1
        while favorites[tostring(idx)] ~= nil do
            idx = idx + 1
        end
        key = tostring(idx)
    end

    favorites[key] = { animation_command = animation_command, animation_type = animation_type }

    exports.ghmattimysql:executeSync([[
        INSERT INTO mosquito_favorite_animations (identifier, favorites)
        VALUES (@identifier, @favorites)
        ON DUPLICATE KEY UPDATE favorites = @favorites
    ]], {
        ['@identifier'] = identifier,
        ['@favorites'] = json.encode(favorites)
    })
    if Config.Debug then
        print("Stored favorite at index " .. tostring(key) .. ": ", json.encode(favorites[key]))
    end
    TriggerClientEvent('mosquito:client:receiveFavoriteAnimations', src, true, true, favorites, animation_command, animation_type)
end)

RegisterNetEvent('mosquito:Server:animations:RemovePropFromNetworkedTable')
AddEventHandler('mosquito:Server:animations:RemovePropFromNetworkedTable', function(netId)
    local src = source
    if playerAnimationProps[src] then
        for i, id in pairs(playerAnimationProps[src]) do
            if id == netId then
                local entity = NetworkGetEntityFromNetworkId(netId)
                table.remove(playerAnimationProps[src], i)
                if Config.Debug then
                    print("Removing entity for " .. src .. " : " .. netId)
                end
                CreateThread(function()
                    Wait(1000)
                    if DoesEntityExist(entity) then
                        DeleteEntity(entity)
                        if Config.Debug then
                            print("^6Deleted entity for " .. src .. ": " .. netId)
                        end
                    end
                end)
                break
            end
        end
    end
end)

RegisterNetEvent('mosquito:Server:animations:AddPropToNetworkedTable')
AddEventHandler('mosquito:Server:animations:AddPropToNetworkedTable', function(netId)
    local src = source
    if not playerAnimationProps[src] then
        playerAnimationProps[src] = {}
    end
    table.insert(playerAnimationProps[src], netId)
    if Config.Debug then
        print("Adding entity for " .. src .. " : " .. netId)
    end
end)

RegisterNetEvent("mosquito:Server:animations:SaveWalkAnimToDB")
AddEventHandler("mosquito:Server:animations:SaveWalkAnimToDB", function(walkanim, blendRatio)
    local src = source
    local identifier = GetPreferredIdentifier(src)
    local safeBlendRatio = tonumber(blendRatio) or tonumber(Config.MaxBlendMoveRatio) or tonumber(Config.AnimationWalkSpeed) or 1.5
    safeBlendRatio = math.max(0.1, math.min(3.0, safeBlendRatio))
    local charId
    if Config.WalkstyleSaveToCharacter then
        if Config.Framework then
            if framework == "vorp" then
                local VORP = exports.vorp_core:GetCore()
                local user = VORP.getUser(src)
                local character = user and user.getUsedCharacter or false
                if not character then
                    if Config.Debug then
                        print('[mosquito_animations] ERROR: ^1Character not found!^7')
                    end
                    return
                end
                charId = character.charIdentifier
            elseif framework == "rsg" then
                local RSGCore = exports['rsg-core']:GetCoreObject()
                local Player = RSGCore.Functions.GetPlayer(src)
                playerData = Player and Player.PlayerData or nil
                if not playerData then
                    if Config.Debug then
                        print('[mosquito_animations] ERROR: ^1Player data not found!^7')
                    end
                    return
                end
                if Config.Debug then
                    print("Got player data: " .. json.encode(playerData))
                end
                charId = playerData.citizenid
            else
                if Config.Debug then
                    print('[mosquito_animations] ^1!! This framework is not supported !!^7')
                end
            end
            local walkAnimTable = {}
            local result = exports.ghmattimysql:executeSync("SELECT walkanim FROM mosquito_favorite_animations WHERE identifier = @identifier", {
                ['@identifier'] = identifier
            })
            local tempWalkAnimTable = {}
            if result and #result > 0 then
                walkAnimTable = json.decode(result[1].walkanim) or {}
                for k, v in pairs(walkAnimTable) do
                    tempWalkAnimTable[tonumber(k) ~= nil and tonumber(k) or k] = v
                end
                walkAnimTable = tempWalkAnimTable
            else
                walkAnimTable = {}
            end
            if type(walkAnimTable) ~= "table" then
                walkAnimTable = {}
                walkAnimTable[charId] = { anim = result[1].walkanim, blendRatio = safeBlendRatio }
            end
            walkAnimTable[charId] = { anim = walkanim, blendRatio = safeBlendRatio }
            local updatedWalkAnimTable = {}
            for k, v in pairs(walkAnimTable) do
                if Config.Debug then
                    local walkAnimName = type(v) == "table" and v.anim or tostring(v)
                    local walkBlend = type(v) == "table" and (tonumber(v.blendRatio) or safeBlendRatio) or safeBlendRatio
                    print("Character ID: " .. tostring(k) .. " => Walk Animation: " .. tostring(walkAnimName) .. " | BlendRatio: " .. tostring(walkBlend))
                end
                if type(v) == "table" then
                    updatedWalkAnimTable[tostring(k)] = {
                        anim = v.anim or walkanim,
                        blendRatio = tonumber(v.blendRatio) or safeBlendRatio
                    }
                else
                    updatedWalkAnimTable[tostring(k)] = {
                        anim = v,
                        blendRatio = safeBlendRatio
                    }
                end
            end
            exports.ghmattimysql:executeSync([[
                INSERT INTO mosquito_favorite_animations (identifier, walkanim)
                VALUES (@identifier, @walkanim)
                ON DUPLICATE KEY UPDATE walkanim = @walkanim
            ]], {
                ['@identifier'] = identifier,
                ['@walkanim'] = json.encode(updatedWalkAnimTable)
            })
        end
    else
        exports.ghmattimysql:executeSync([[
            INSERT INTO mosquito_favorite_animations (identifier, walkanim)
            VALUES (@identifier, @walkanim)
            ON DUPLICATE KEY UPDATE walkanim = @walkanim
        ]], {
            ['@identifier'] = identifier,
            ['@walkanim'] = json.encode({ anim = walkanim, blendRatio = safeBlendRatio })
        })
    end
    if Config.Debug then
        print("Saved walk animation for " .. identifier .. ": " .. tostring(walkanim) .. " | BlendRatio: " .. tostring(safeBlendRatio))
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    if playerAnimationProps[src] then
        for _, netId in pairs(playerAnimationProps[src]) do
            if Config.Debug then
                print("researching entity: " .. netId)
            end
            if netId and type(netId) == "number" then
                local entity = NetworkGetEntityFromNetworkId(netId)
                if DoesEntityExist(entity) then
                    if Config.Debug then
                        print("Deleting entity for " .. src .. ": " .. netId)
                    end
                    DeleteEntity(entity)
                end
            end
        end
        playerAnimationProps[src] = nil
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for src, props in pairs(playerAnimationProps) do
        for _, netId in pairs(props) do
            if netId and type(netId) == "number" then
                local entity = NetworkGetEntityFromNetworkId(netId)
                if DoesEntityExist(entity) then
                    if Config.Debug then
                        print("Deleting entity on resource stop: " .. netId)
                    end
                    DeleteEntity(entity)
                end
            end
        end
    end
    playerAnimationProps = {}
end)

RegisterNetEvent("mosquito:server:createscenariopoint")
AddEventHandler("mosquito:server:createscenariopoint", function(scenarioName, coords, heading)
    local src = source
    TriggerClientEvent("mosquito:client:createscenariopoint", src, scenarioName, coords, heading)
end)
