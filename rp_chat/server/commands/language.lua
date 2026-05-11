local function GetLanguageVerb(prefix, message, targeted)
    local lastChar = message:sub(-1)
    local verb

    if prefix == "Low" or prefix == "LowTo" then
        verb = (lastChar == "?" and "asks quietly") or (lastChar == "!" and "quietly exclaims") or "says quietly"
    elseif prefix == "Lower" or prefix == "LowerTo" then
        verb = (lastChar == "?" and "asks quietly") or (lastChar == "!" and "quietly exclaims") or "whispers"
    elseif prefix == "Shout" or prefix == "ShoutTo" then
        verb = (lastChar == "?" and "asks loudly") or (lastChar == "!" and "exclaims") or "shouts"
    else
        verb = (lastChar == "?" and "asks") or (lastChar == "!" and "exclaims") or (targeted and "says" or "states")
    end

    return verb
end

local function GetLanguageTag(src)
    local language = RPChat.GetPlayerLanguage(src)
    if not language or language == "" then
        return nil
    end

   local safeLanguage = language:gsub("<", "&lt;"):gsub(">", "&gt;")
    return safeLanguage
end

local function SendLanguageProximity(src, range, prefix, message)
    local languageTag = GetLanguageTag(src)
    if not languageTag then
        TriggerClientEvent('chat:addMessage', src, {
            color = { 180, 180, 180 },
            args = { "Language", "Set one first with /setlanguage <language>." }
        })
        return
    end

    local srcPed = GetPlayerPed(src)
    if not srcPed or srcPed == 0 then return end

    local srcCoords = GetEntityCoords(srcPed)
    local charName = RPChat.GetCharacterName(src)
    local verb = GetLanguageVerb(prefix, message, false) .. " in " .. languageTag

    for _, playerId in ipairs(GetPlayers()) do
        local targetId = tonumber(playerId)
        local targetPed = GetPlayerPed(targetId)
        if targetPed and targetPed ~= 0 then
            local distance = #(srcCoords - GetEntityCoords(targetPed))
            if distance <= range then
                local brightness = RPChat.GetBrightness(distance, range)
                local r, g, b = math.floor(255 * brightness), math.floor(255 * brightness), math.floor(255 * brightness)
                local emoteR, emoteG, emoteB = math.floor(197 * brightness), math.floor(164 * brightness), math.floor(195 * brightness)

                TriggerClientEvent('chat:addMessage', targetId,
                    RPChat.BuildSpeechMessage(charName, nil, nil, verb, message, r, g, b, emoteR, emoteG, emoteB)
                )
            end
        end
    end
end

local function SendLanguageTargeted(src, range, prefix, targetId, message)
    if not targetId or not GetPlayerName(targetId) then
        TriggerClientEvent('chat:addMessage', src, { color = { 180, 180, 180 }, args = { "Invalid player ID." } })
        return
    end

    local languageTag = GetLanguageTag(src)
    if not languageTag then
        TriggerClientEvent('chat:addMessage', src, {
            color = { 180, 180, 180 },
            args = { "Language", "Set one first with /setlanguage <language>." }
        })
        return
    end

    local srcPed = GetPlayerPed(src)
    if not srcPed or srcPed == 0 then return end
    local srcCoords = GetEntityCoords(srcPed)
    local charName = RPChat.GetCharacterName(src)
    local targetName = RPChat.GetCharacterName(targetId)

    local verb = GetLanguageVerb(prefix, message, true) .. " in " .. languageTag .. " (to " .. targetName .. ")"

    for _, playerId in ipairs(GetPlayers()) do
        local receiverId = tonumber(playerId)
        local receiverPed = GetPlayerPed(receiverId)
        if receiverPed and receiverPed ~= 0 then
            local distance = #(srcCoords - GetEntityCoords(receiverPed))
            if distance <= range then
                local brightness = RPChat.GetBrightness(distance, range)
                local r, g, b = math.floor(255 * brightness), math.floor(255 * brightness), math.floor(255 * brightness)
                local emoteR, emoteG, emoteB = math.floor(197 * brightness), math.floor(164 * brightness), math.floor(195 * brightness)

                TriggerClientEvent('chat:addMessage', receiverId,
                    RPChat.BuildSpeechMessage(charName, nil, nil, verb, message, r, g, b, emoteR, emoteG, emoteB)
                )
            end
        end
    end
end

RegisterCommand("setlanguage", function(src, args)
    src = tonumber(src)
    if not src then return end

    local language = RPChat.Trim(table.concat(args or {}, " ")):sub(1, 40)
    if language == "" then
        RPChat.ClearPlayerLanguage(src)
        TriggerClientEvent('chat:addMessage', src, {
            color = { 180, 180, 180 },
            args = { "Language", "Language cleared. Use command again to clear." }
        })
        return
    end

    RPChat.SetPlayerLanguage(src, language)
    TriggerClientEvent('chat:addMessage', src, {
        color = { 180, 180, 180 },
        args = { "Language", ("Language set to <%s>."):format(language) }
    })
end, false)

RegisterCommand("lang", function(src, args, rawCommand)
    src = tonumber(src)
    if not src then return end

    local message = rawCommand:sub(6):gsub("^%s+", "")
    if message == "" then return end
    SendLanguageProximity(src, RPChat.RANGES.normal, "Normal", message)
end, false)

RegisterCommand("langlow", function(src, args, rawCommand)
    local message = rawCommand:sub(9):gsub("^%s+", "")
    if message == "" then return end
    SendLanguageProximity(src, RPChat.RANGES.low, "Low", message)
end, false)

RegisterCommand("langlower", function(src, args, rawCommand)
    local message = rawCommand:sub(11):gsub("^%s+", "")
    if message == "" then return end
    SendLanguageProximity(src, RPChat.RANGES.lower, "Lower", message)
end, false)

RegisterCommand("langshout", function(src, args, rawCommand)
    local message = rawCommand:sub(11):gsub("^%s+", "")
    if message == "" then return end
    SendLanguageProximity(src, RPChat.RANGES.shout, "Shout", message)
end, false)

RegisterCommand("langto", function(src, args)
    src = tonumber(src)
    if not src then return end

    local targetId = tonumber(args[1])
    if not targetId then return end
    table.remove(args, 1)
    local message = table.concat(args, " ")
    if message == "" then return end

    SendLanguageTargeted(src, RPChat.RANGES.normal, "To", targetId, message)
end, false)

RegisterCommand("langlowto", function(src, args)
    src = tonumber(src)
    if not src then return end

    local targetId = tonumber(args[1])
    if not targetId then return end
    table.remove(args, 1)
    local message = table.concat(args, " ")
    if message == "" then return end

    SendLanguageTargeted(src, RPChat.RANGES.low, "LowTo", targetId, message)
end, false)

RegisterCommand("langlowerto", function(src, args)
    src = tonumber(src)
    if not src then return end

    local targetId = tonumber(args[1])
    if not targetId then return end
    table.remove(args, 1)
    local message = table.concat(args, " ")
    if message == "" then return end

    SendLanguageTargeted(src, RPChat.RANGES.lower, "LowerTo", targetId, message)
end, false)

RegisterCommand("langshoutto", function(src, args)
    src = tonumber(src)
    if not src then return end

    local targetId = tonumber(args[1])
    if not targetId then return end
    table.remove(args, 1)
    local message = table.concat(args, " ")
    if message == "" then return end

    SendLanguageTargeted(src, RPChat.RANGES.shout, "ShoutTo", targetId, message)
end, false)