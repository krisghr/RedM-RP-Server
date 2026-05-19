local function GetLanguageVerb(prefix, message, targeted)
    local lastChar = message:sub(-1)
    if prefix == "Low" or prefix == "LowTo" then
        return (lastChar == "?" and "asks quietly") or (lastChar == "!" and "quietly exclaims") or "says quietly"
    elseif prefix == "Lower" or prefix == "LowerTo" then
        return (lastChar == "?" and "asks quietly") or (lastChar == "!" and "quietly exclaims") or "whispers"
    elseif prefix == "Shout" or prefix == "ShoutTo" then
        return (lastChar == "?" and "asks loudly") or (lastChar == "!" and "exclaims") or "shouts"
    end
    return (lastChar == "?" and "asks") or (lastChar == "!" and "exclaims") or (targeted and "says" or "states")
end

local function GetLanguageTag(src)
    local language = RPChat.GetPlayerLanguage(src)
    if not language or language == "" then return nil end
    return language:gsub("<", "&lt;"):gsub(">", "&gt;")
end

function RPChat.SendLanguageProximity(src, range, prefix, message)
    local languageTag = GetLanguageTag(src)
    if not languageTag then
        TriggerClientEvent('chat:addMessage', src, { color = {180,180,180}, args = {"Language", "Set one first with /setlanguage <language>."} })
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
        if targetPed and targetPed ~= 0 and #(srcCoords - GetEntityCoords(targetPed)) <= range then
            local brightness = RPChat.GetBrightness(#(srcCoords - GetEntityCoords(targetPed)), range)
            local r,g,b = math.floor(255*brightness), math.floor(255*brightness), math.floor(255*brightness)
            local er,eg,eb = math.floor(197*brightness), math.floor(164*brightness), math.floor(195*brightness)
            TriggerClientEvent('chat:addMessage', targetId, RPChat.BuildSpeechMessage(charName, nil, nil, verb, message, r, g, b, er, eg, eb))
        end
    end
end

function RPChat.SendLanguageTargeted(src, range, prefix, targetId, message)
    if not targetId or not GetPlayerName(targetId) then
        TriggerClientEvent('chat:addMessage', src, { color = {180,180,180}, args = {"Invalid player ID."} })
        return
    end
    local languageTag = GetLanguageTag(src)
    if not languageTag then
        TriggerClientEvent('chat:addMessage', src, { color = {180,180,180}, args = {"Language", "Set one first with /setlanguage <language>."} })
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
        if receiverPed and receiverPed ~= 0 and #(srcCoords - GetEntityCoords(receiverPed)) <= range then
            local brightness = RPChat.GetBrightness(#(srcCoords - GetEntityCoords(receiverPed)), range)
            local r,g,b = math.floor(255*brightness), math.floor(255*brightness), math.floor(255*brightness)
            local er,eg,eb = math.floor(197*brightness), math.floor(164*brightness), math.floor(195*brightness)
            TriggerClientEvent('chat:addMessage', receiverId, RPChat.BuildSpeechMessage(charName, nil, nil, verb, message, r, g, b, er, eg, eb))
        end
    end
end

local function HandleLanguageProximity(src, range, prefix, rawCommand, commandLength)
    local message = rawCommand:sub(commandLength):gsub("^%s+", "")
    if message == "" then return end
    RPChat.SendLanguageProximity(src, range, prefix, message)
end

local function HandleLanguageTargeted(src, range, prefix, args)
    local targetId = tonumber(args[1])
    if not targetId then return end
    table.remove(args, 1)
    local message = table.concat(args, " ")
    if message == "" then return end
    RPChat.SendLanguageTargeted(src, range, prefix, targetId, message)
end

RegisterCommand("setlanguage", function(src, args)
    src = tonumber(src); if not src then return end
    local language = RPChat.Trim(table.concat(args or {}, " ")):sub(1, 40)
    if language == "" then
        RPChat.ClearPlayerLanguage(src)
        TriggerClientEvent('chat:addMessage', src, { color = {180,180,180}, args = {"Language", "Language cleared. /lang will now use your normal speech."} })
        return
    end
    RPChat.SetPlayerLanguage(src, language)
    TriggerClientEvent('chat:addMessage', src, { color = {180,180,180}, args = {"Language", ("Language set to %s."):format(language)} })
end, false)

RegisterCommand("autolang", function(src)
    src = tonumber(src); if not src then return end
    local nextState = not RPChat.IsAutoLanguageEnabled(src)
    RPChat.SetAutoLanguage(src, nextState)
    TriggerClientEvent('chat:addMessage', src, { color = {180,180,180}, args = {"Language", nextState and "Auto-language enabled." or "Auto-language disabled."} })
end, false)

RegisterCommand("lang", function(src, args, rawCommand)
    HandleLanguageProximity(src, RPChat.RANGES.normal, "Normal", rawCommand, 6)
end, false)

RegisterCommand("langlow", function(src, args, rawCommand)
    HandleLanguageProximity(src, RPChat.RANGES.low, "Low", rawCommand, 9)
end, false)

RegisterCommand("langl", function(src, args, rawCommand)
    HandleLanguageProximity(src, RPChat.RANGES.low, "Low", rawCommand, 7)
end, false)

RegisterCommand("langlower", function(src, args, rawCommand)
    HandleLanguageProximity(src, RPChat.RANGES.lower, "Lower", rawCommand, 11)
end, false)

RegisterCommand("langlw", function(src, args, rawCommand)
    HandleLanguageProximity(src, RPChat.RANGES.lower, "Lower", rawCommand, 8)
end, false)

RegisterCommand("langshout", function(src, args, rawCommand)
    HandleLanguageProximity(src, RPChat.RANGES.shout, "Shout", rawCommand, 11)
end, false)

RegisterCommand("langsh", function(src, args, rawCommand)
    HandleLanguageProximity(src, RPChat.RANGES.shout, "Shout", rawCommand, 8)
end, false)

RegisterCommand("langto", function(src, args)
    HandleLanguageTargeted(src, RPChat.RANGES.normal, "To", args)
end, false)

RegisterCommand("langlowto", function(src, args)
    HandleLanguageTargeted(src, RPChat.RANGES.low, "LowTo", args)
end, false)

RegisterCommand("langlt", function(src, args)
    HandleLanguageTargeted(src, RPChat.RANGES.low, "LowTo", args)
end, false)

RegisterCommand("langlowerto", function(src, args)
    HandleLanguageTargeted(src, RPChat.RANGES.lower, "LowerTo", args)
end, false)

RegisterCommand("langlwt", function(src, args)
    HandleLanguageTargeted(src, RPChat.RANGES.lower, "LowerTo", args)
end, false)

RegisterCommand("langshoutto", function(src, args)
    HandleLanguageTargeted(src, RPChat.RANGES.shout, "ShoutTo", args)
end, false)

RegisterCommand("langsht", function(src, args)
    HandleLanguageTargeted(src, RPChat.RANGES.shout, "ShoutTo", args)
end, false)
