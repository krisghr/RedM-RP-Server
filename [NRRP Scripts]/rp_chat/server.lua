print("[RP_CHAT] server.lua loaded")

local VORPcore = exports.vorp_core:GetCore()
local DEBUG_CHAT = false

local RANGES = {
    lower = 3.0,
    low = 5.0,
    normal = 15.0,
    shout = 35.0,
	farshout = 40.0
}

local function Trim(str)
    return (str or ""):gsub("^%s*(.-)%s*$", "%1")
end

local function GetCharacterName(src)
    local User = VORPcore.getUser(src)
    if not User then return GetPlayerName(src) end

    local Character = User.getUsedCharacter
    if not Character then return GetPlayerName(src) end

    local firstname = Character.firstname or Character.firstName or ""
    local lastname = Character.lastname or Character.lastName or ""

    local fullName = Trim(firstname .. " " .. lastname)

    if fullName == "" then
        return GetPlayerName(src)
    end

    return fullName
end

local function GetBrightness(distance, maxRange)
    local t = distance / maxRange

    if t < 0.0 then t = 0.0 end
    if t > 1.0 then t = 1.0 end

    return 1.0 - (t * 0.5)
end

-- Speech parser:
local function BuildSpeechMessage(charName, verb, message, r, g, b, emoteR, emoteG, emoteB)
    local template = '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')">{0} ' .. verb .. ', </span>'
    local args = { charName }

    local index = 1
    local pos = 1

    while true do
        local startE, endE = message:find("%*", pos)

        if not startE then
            local remaining = Trim(message:sub(pos))

            if remaining ~= "" then
                template = template .. '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')">"{' .. index .. '}"</span>'
                table.insert(args, remaining)
            end

            break
        end

        local endE2 = message:find("%*", endE + 1)

        if not endE2 then
            local remaining = Trim(message:sub(pos))

            if remaining ~= "" then
                template = template .. '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')">"{' .. index .. '}"</span>'
                table.insert(args, remaining)
            end

            break
        end

        local before = Trim(message:sub(pos, startE - 1))
        local emote = Trim(message:sub(endE + 1, endE2 - 1))

        if before ~= "" then
            template = template .. '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')">"{' .. index .. '}" </span>'
            table.insert(args, before)
            index = index + 1
        end

        if emote ~= "" then
            template = template .. '<span style="color: rgb(' .. emoteR .. ',' .. emoteG .. ',' .. emoteB .. ')">{' .. index .. '} </span>'
            table.insert(args, emote)
            index = index + 1
        end

        pos = endE2 + 1
    end

    return {
        template = template,
        args = args
    }
end

-- /me parser:
local function BuildMeMessage(charName, message, r, g, b)
    local template = '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')">* {0}</span>'
    local args = { charName }

    local index = 1
    local pos = 1

    while true do
        local startQ, endQ = message:find('"', pos)

        if not startQ then
            local remaining = message:sub(pos)

            if remaining ~= "" then
                template = template .. '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')"> {' .. index .. '}</span>'
                table.insert(args, remaining)
            end

            break
        end

        local endQ2 = message:find('"', endQ + 1)

        if not endQ2 then
            local remaining = message:sub(pos)

            if remaining ~= "" then
                template = template .. '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')"> {' .. index .. '}</span>'
                table.insert(args, remaining)
            end

            break
        end

        local before = message:sub(pos, startQ - 1)
        local quoted = message:sub(endQ + 1, endQ2 - 1)

        if before ~= "" then
            template = template .. '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')"> {' .. index .. '}</span>'
            table.insert(args, before)
            index = index + 1
        end

        template = template .. '<span style="color: white">"{' .. index .. '}"</span>'
        table.insert(args, quoted)
        index = index + 1

        pos = endQ2 + 1
    end

    return {
        template = template,
        args = args
    }
end

-- /do parser:
local function BuildDoMessage(charName, message, r, g, b)
    local template = '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')">* </span>'
    local args = {}

    local index = 0
    local pos = 1

    while true do
        local startQ, endQ = message:find('"', pos)

        if not startQ then
            local remaining = message:sub(pos)

            if remaining ~= "" then
                template = template .. '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')">{' .. index .. '}</span>'
                table.insert(args, remaining)
                index = index + 1
            end

            break
        end

        local endQ2 = message:find('"', endQ + 1)

        if not endQ2 then
            local remaining = message:sub(pos)

            if remaining ~= "" then
                template = template .. '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')">{' .. index .. '}</span>'
                table.insert(args, remaining)
                index = index + 1
            end

            break
        end

        local before = message:sub(pos, startQ - 1)
        local quoted = message:sub(endQ + 1, endQ2 - 1)

        if before ~= "" then
            template = template .. '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')">{' .. index .. '}</span>'
            table.insert(args, before)
            index = index + 1
        end

        template = template .. '<span style="color: white">"{' .. index .. '}"</span>'
        table.insert(args, quoted)
        index = index + 1

        pos = endQ2 + 1
    end

    template = template .. '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')"> (( {' .. index .. '} ))</span>'
    table.insert(args, charName)

    return {
        template = template,
        args = args
    }
end

-- /to, /lowto, /shoutto parser:
local function SendTargetedProximityMessage(src, range, prefix, targetId, message)
    if not targetId or not GetPlayerName(targetId) then
        TriggerClientEvent('chat:addMessage', src, {
            color = { 180, 180, 180 },
            args = { "Invalid player ID." }
        })
        return
    end

    local srcPed = GetPlayerPed(src)
    if not srcPed or srcPed == 0 then return end

    local srcCoords = GetEntityCoords(srcPed)
    local charName = GetCharacterName(src)
    local targetName = GetCharacterName(targetId)

    for _, playerId in ipairs(GetPlayers()) do
        local receiverId = tonumber(playerId)
        local receiverPed = GetPlayerPed(receiverId)

        if receiverPed and receiverPed ~= 0 then
            local receiverCoords = GetEntityCoords(receiverPed)
            local distance = #(srcCoords - receiverCoords)

            if distance <= range then
                local brightness = GetBrightness(distance, range)

                local r = math.floor(255 * brightness)
                local g = math.floor(255 * brightness)
                local b = math.floor(255 * brightness)

                local emoteR = math.floor(197 * brightness)
                local emoteG = math.floor(164 * brightness)
                local emoteB = math.floor(195 * brightness)

                local lastChar = message:sub(-1)
                local verb = "says"

                if prefix == "LowTo" then
                    if lastChar == "?" then
                        verb = "asks quietly"
                    elseif lastChar == "!" then
                        verb = "quietly exclaims"
                    else
                        verb = "says quietly"
                    end
                elseif prefix == "ShoutTo" then
                    verb = "shouts"
                else
                    if lastChar == "?" then
                        verb = "asks"
                    elseif lastChar == "!" then
                        verb = "exclaims"
                    else
                        verb = "says"
                    end
                end

                verb = verb .. " (to " .. targetName .. ")"

                local text = BuildSpeechMessage(
                    charName,
                    verb,
                    message,
                    r, g, b,
                    emoteR, emoteG, emoteB
                )

                TriggerClientEvent('chat:addMessage', receiverId, text)
            end
        end
    end
end

-- /npc text parser:
local function ParseNpcCommand(rawCommand, commandLength)
    local input = rawCommand:sub(commandLength):gsub("^%s+", "")

    local npcName, message = input:match('^"(.-)"%s*(.+)$')

    if not npcName or not message then
        return nil, nil
    end

    return npcName, message
end

local function BuildNpcMeMessage(playerName, npcName, message, r, g, b)
    local template = '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')">* {0}</span>'
    local args = { npcName }

    local index = 1
    local pos = 1

    while true do
        local startQ, endQ = message:find('"', pos)

        if not startQ then
            local remaining = message:sub(pos)

            if remaining ~= "" then
                template = template .. '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')"> {' .. index .. '}</span>'
                table.insert(args, remaining)
                index = index + 1
            end

            break
        end

        local endQ2 = message:find('"', endQ + 1)

        if not endQ2 then
            local remaining = message:sub(pos)

            if remaining ~= "" then
                template = template .. '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')"> {' .. index .. '}</span>'
                table.insert(args, remaining)
                index = index + 1
            end

            break
        end

        local before = message:sub(pos, startQ - 1)
        local quoted = message:sub(endQ + 1, endQ2 - 1)

        if before ~= "" then
            template = template .. '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')"> {' .. index .. '}</span>'
            table.insert(args, before)
            index = index + 1
        end

        template = template .. '<span style="color: white">"{' .. index .. '}"</span>'
        table.insert(args, quoted)
        index = index + 1

        pos = endQ2 + 1
    end

    template = template .. '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')"> (( Played by {' .. index .. '}. ))</span>'
    table.insert(args, playerName)

    return {
        template = template,
        args = args
    }
end

local function BuildNpcDoMessage(playerName, npcName, message, r, g, b)
    local template = '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')">* </span>'
    local args = {}

    local index = 0
    local pos = 1

    while true do
        local startQ, endQ = message:find('"', pos)

        if not startQ then
            local remaining = message:sub(pos)

            if remaining ~= "" then
                template = template .. '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')">{' .. index .. '}</span>'
                table.insert(args, remaining)
                index = index + 1
            end

            break
        end

        local endQ2 = message:find('"', endQ + 1)

        if not endQ2 then
            local remaining = message:sub(pos)

            if remaining ~= "" then
                template = template .. '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')">{' .. index .. '}</span>'
                table.insert(args, remaining)
                index = index + 1
            end

            break
        end

        local before = message:sub(pos, startQ - 1)
        local quoted = message:sub(endQ + 1, endQ2 - 1)

        if before ~= "" then
            template = template .. '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')">{' .. index .. '}</span>'
            table.insert(args, before)
            index = index + 1
        end

        template = template .. '<span style="color: white">"{' .. index .. '}"</span>'
        table.insert(args, quoted)
        index = index + 1

        pos = endQ2 + 1
    end

    template = template ..
        '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')"> (( {'
        .. index .. '}, played by {' .. (index + 1) .. '}. ))</span>'

    table.insert(args, npcName)
    table.insert(args, playerName)

    return {
        template = template,
        args = args
    }
end

local function SendProximityMessage(src, range, prefix, message, mode)
    local srcPed = GetPlayerPed(src)
    if not srcPed or srcPed == 0 then return end

    local srcCoords = GetEntityCoords(srcPed)
    local charName = GetCharacterName(src)

    for _, playerId in ipairs(GetPlayers()) do
        local targetId = tonumber(playerId)
        local targetPed = GetPlayerPed(targetId)

        if targetPed and targetPed ~= 0 then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(srcCoords - targetCoords)

            if distance <= range then
                local brightness = GetBrightness(distance, range)
                local r, g, b
                local text

                if mode == "me" then
                    r = math.floor(197 * brightness)
                    g = math.floor(164 * brightness)
                    b = math.floor(195 * brightness)

                    text = BuildMeMessage(charName, message, r, g, b)

				elseif mode == "do" then
					r = math.floor(197 * brightness)
					g = math.floor(164 * brightness)
					b = math.floor(195 * brightness)

				text = BuildDoMessage(charName, message, r, g, b)
					
				elseif mode == "ooc" then
					r = math.floor(180 * brightness)
					g = math.floor(180 * brightness)
					b = math.floor(180 * brightness)

					local playerId = src

					text = {
						template = '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')">(( [{0}] {1}: {2} ))</span>',
						args = { playerId, charName, message }
					}
					
				elseif mode == "npcme" then
					r = math.floor(255 * brightness)
					g = math.floor(140 * brightness)
					b = math.floor(60 * brightness)

					text = BuildNpcMeMessage(
						message.playerName,
						message.npcName,
						message.message,
						r, g, b
					)

				elseif mode == "npcdo" then
					r = math.floor(255 * brightness)
					g = math.floor(140 * brightness)
					b = math.floor(60 * brightness)

					text = BuildNpcDoMessage(
						message.playerName,
						message.npcName,
						message.message,
						r, g, b
					)

                else
                    r = math.floor(255 * brightness)
                    g = math.floor(255 * brightness)
                    b = math.floor(255 * brightness)

                    local lastChar = message:sub(-1)
                    local verb = "states"

                    if prefix == "Low" then
                        if lastChar == "?" then
                            verb = "asks quietly"
                        elseif lastChar == "!" then
                            verb = "quietly exclaims"
                        else
                            verb = "says quietly"
                        end
                    elseif prefix == "Shout" then
                        verb = "shouts"
                    else
                        if lastChar == "?" then
                            verb = "asks"
                        elseif lastChar == "!" then
                            verb = "exclaims"
                        else
                            verb = "states"
                        end
                    end

                    local emoteR = math.floor(197 * brightness)
                    local emoteG = math.floor(164 * brightness)
                    local emoteB = math.floor(195 * brightness)

                    text = BuildSpeechMessage(charName, verb, message, r, g, b, emoteR, emoteG, emoteB)
                end

                if DEBUG_CHAT then
                    print(("[RP_CHAT] %s -> %s | %.2f / %.2f"):format(
                        GetPlayerName(src),
                        GetPlayerName(targetId),
                        distance,
                        range
                    ))
                end

                TriggerClientEvent('chat:addMessage', targetId, text)
            end
        end
    end
end

local function SaveCurrentCharacterCoords(src)
    local user = VORPcore.getUser(src)
    if not user then return false end

    local character = user.getUsedCharacter
    if not character then return false end

    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return false end

    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    local payload = json.encode({
        x = coords.x,
        y = coords.y,
        z = coords.z,
        heading = heading
    })

    character.SaveCharacterCoords(payload)

    return true
end

local function SendChangeCharLogoutMessage(src)
    local srcPed = GetPlayerPed(src)
    if not srcPed or srcPed == 0 then return end

    local srcCoords = GetEntityCoords(srcPed)
    local charName = GetCharacterName(src)

    for _, playerId in ipairs(GetPlayers()) do
        local targetId = tonumber(playerId)
        local targetPed = GetPlayerPed(targetId)

        if targetPed and targetPed ~= 0 then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(srcCoords - targetCoords)

            if distance <= RANGES.normal then
                TriggerClientEvent('chat:addMessage', targetId, {
                    template = '<span style="color: rgb(180, 180, 180)">(( * {0} has quit this character and logged out. ))</span>',
                    args = { charName }
                })
            end
        end
    end
end

local function CommandExists(commandName)
    local lowered = string.lower(commandName)

    for _, registeredCommand in ipairs(GetRegisteredCommands()) do
        if string.lower(registeredCommand.name) == lowered then
            return true
        end
    end

    return false
end

RegisterCommand("changechar", function(src)
    if src <= 0 then return end

    local saved = SaveCurrentCharacterCoords(src)
    if not saved then
        TriggerClientEvent('chat:addMessage', src, {
            color = { 255, 80, 80 },
            args = { '^1System', '^7Unable to change character right now.' }
        })
        return
    end

    SendChangeCharLogoutMessage(src)

    SetTimeout(250, function()
        DropPlayer(src, "Character changed.")
    end)
end, false)


-- Default / normal talking
RegisterServerEvent('chatMessage')

AddEventHandler('chatMessage', function(src, name, message)
    if string.sub(message, 1, 1) == "/" then

        local commandName = message:sub(2):match("^%S+")

        if commandName and not CommandExists(commandName) then
            CancelEvent()
            TriggerClientEvent('chat:addMessage', src, {
                args = { '^1System', '^7No such command exists.' }
            })
        end
        
        return
    end

    CancelEvent()
    SendProximityMessage(src, RANGES.normal, "Normal", message, "speech")
end)

-- /Low Command with /l Shorthand
RegisterCommand("low", function(src, args, rawCommand)
    local message = rawCommand:sub(5):gsub("^%s+", "")
    if message == "" then return end

    SendProximityMessage(src, RANGES.low, "Low", message, "speech")
end, false)

RegisterCommand("l", function(src, args, rawCommand)
    local message = rawCommand:sub(3):gsub("^%s+", "")
    if message == "" then return end

    SendProximityMessage(src, RANGES.low, "Low", message, "speech")
end, false)

-- /Shout Command with /s Shorthand
RegisterCommand("shout", function(src, args, rawCommand)
    local message = rawCommand:sub(7):gsub("^%s+", "")
    if message == "" then return end

    SendProximityMessage(src, RANGES.shout, "Shout", message, "speech")
end, false)

RegisterCommand("sh", function(src, args, rawCommand)
    local message = rawCommand:sub(3):gsub("^%s+", "")
    if message == "" then return end

    SendProximityMessage(src, RANGES.shout, "Shout", message, "speech")
end, false)

-- /Me Command
RegisterCommand("me", function(src, args, rawCommand)
    local message = rawCommand:sub(4):gsub("^%s+", "")
    if message == "" then return end

    SendProximityMessage(src, RANGES.normal, "Me", message, "me")
end, false)

-- /Do Command
RegisterCommand("do", function(src, args, rawCommand)
    local message = rawCommand:sub(4):gsub("^%s+", "")
    if message == "" then return end

    SendProximityMessage(src, RANGES.normal, "Do", message, "do")
end, false)

-- /b Command
RegisterCommand("b", function(src, args, rawCommand)
    local message = rawCommand:sub(3):gsub("^%s+", "")
    if message == "" then return end

    SendProximityMessage(src, RANGES.normal, "OOC", message, "ooc")
end, false)

-- /to Command and /t Shorthand
local function ParseToCommand(args)
    local targetId = tonumber(args[1])
    if not targetId then return nil, "" end

    table.remove(args, 1)
    local message = table.concat(args, " ")

    return targetId, message
end

RegisterCommand("to", function(src, args)
    local targetId, message = ParseToCommand(args)
    if not targetId or message == "" then return end

    SendTargetedProximityMessage(src, RANGES.normal, "To", targetId, message)
end, false)

RegisterCommand("t", function(src, args)
    local targetId, message = ParseToCommand(args)
    if not targetId or message == "" then return end

    SendTargetedProximityMessage(src, RANGES.normal, "To", targetId, message)
end, false)

-- /lowto Command and /lt Shorthand
RegisterCommand("lowto", function(src, args)
    local targetId, message = ParseToCommand(args)
    if not targetId or message == "" then return end

    SendTargetedProximityMessage(src, RANGES.low, "LowTo", targetId, message)
end, false)

RegisterCommand("lt", function(src, args)
    local targetId, message = ParseToCommand(args)
    if not targetId or message == "" then return end

    SendTargetedProximityMessage(src, RANGES.low, "LowTo", targetId, message)
end, false)

-- /shoutto Command and /st Shorthand
RegisterCommand("shoutto", function(src, args)
    local targetId, message = ParseToCommand(args)
    if not targetId or message == "" then return end

    SendTargetedProximityMessage(src, RANGES.shout, "ShoutTo", targetId, message)
end, false)

RegisterCommand("st", function(src, args)
    local targetId, message = ParseToCommand(args)
    if not targetId or message == "" then return end

    SendTargetedProximityMessage(src, RANGES.shout, "ShoutTo", targetId, message)
end, false)


-- npc commands

RegisterCommand("npcme", function(src, args, rawCommand)
    local npcName, message = ParseNpcCommand(rawCommand, 7)
    if not npcName then return end

    local charName = GetCharacterName(src)

    SendProximityMessage(src, RANGES.normal, "NpcMe", {
        npcName = npcName,
        message = message,
        playerName = charName
    }, "npcme")
end, false)

RegisterCommand("npcdo", function(src, args, rawCommand)
    local npcName, message = ParseNpcCommand(rawCommand, 7)
    if not npcName then return end

    local charName = GetCharacterName(src)

    SendProximityMessage(src, RANGES.normal, "NpcDo", {
        npcName = npcName,
        message = message,
        playerName = charName
    }, "npcdo")
end, false)
