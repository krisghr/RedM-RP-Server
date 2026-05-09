function RPChat.BuildDoMessage(charName, message, r, g, b)
    local template = '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')">* </span>'
    local args = {}
    local index = 0
    local pos = 1

    while true do
        local startQ, endQ = message:find('"', pos)
        if not startQ then
            local remaining = message:sub(pos)
            if remaining ~= "" then
                template, index = RPChat.AppendSlashFormatted(template, args, index, remaining, 'color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')')
            end
            break
        end

        local endQ2 = message:find('"', endQ + 1)
        if not endQ2 then
            local remaining = message:sub(pos)
            if remaining ~= "" then
                template, index = RPChat.AppendSlashFormatted(template, args, index, remaining, 'color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')')
            end
            break
        end

        local before = message:sub(pos, startQ - 1)
        local quoted = message:sub(endQ + 1, endQ2 - 1)

        if before ~= "" then
            template, index = RPChat.AppendSlashFormatted(template, args, index, before, 'color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')')
        end

        template = template .. '<span style="color: white">"</span>'
        template, index = RPChat.AppendSlashFormatted(template, args, index, quoted, 'color: white')
        template = template .. '<span style="color: white">"</span>'
        pos = endQ2 + 1
    end

    template = template .. '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')"> (( {' .. index .. '} ))</span>'
    table.insert(args, charName)
    return { template = template, args = args }
end

function RPChat.ParseNpcCommand(rawCommand, commandLength)
    local input = rawCommand:sub(commandLength):gsub("^%s+", "")
    local npcName, message = input:match('^"(.-)"%s*(.+)$')
    if not npcName or not message then return nil, nil end
    return npcName, message
end

function RPChat.BuildNpcMeMessage(playerName, npcName, message, r, g, b)
    local base = RPChat.BuildMeMessage(npcName, message, r, g, b)
    base.template = base.template .. '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')"> (( Played by {' .. (#base.args) .. '}. ))</span>'
    table.insert(base.args, playerName)
    return base
end

function RPChat.BuildNpcDoMessage(playerName, npcName, message, r, g, b)
    local text = RPChat.BuildDoMessage(npcName, message, r, g, b)
    text.template = text.template:gsub('%(%( {%d+} %)%)', '(( {' .. (#text.args) .. '}, played by {' .. (#text.args + 1) .. '}. ))')
    table.insert(text.args, playerName)
    return text
end

function RPChat.SendTargetedProximityMessage(src, range, prefix, targetId, message)
    if not targetId or not GetPlayerName(targetId) then
        TriggerClientEvent('chat:addMessage', src, { color = { 180, 180, 180 }, args = { "Invalid player ID." } })
        return
    end

    local srcPed = GetPlayerPed(src)
    if not srcPed or srcPed == 0 then return end

    local srcCoords = GetEntityCoords(srcPed)
    local charName = RPChat.GetCharacterName(src)
    local targetName = RPChat.GetCharacterName(targetId)

    for _, playerId in ipairs(GetPlayers()) do
        local receiverId = tonumber(playerId)
        local receiverPed = GetPlayerPed(receiverId)
        if receiverPed and receiverPed ~= 0 then
            local distance = #(srcCoords - GetEntityCoords(receiverPed))
            if distance <= range then
                local brightness = RPChat.GetBrightness(distance, range)
                local r, g, b = math.floor(255 * brightness), math.floor(255 * brightness), math.floor(255 * brightness)
                local emoteR, emoteG, emoteB = math.floor(197 * brightness), math.floor(164 * brightness), math.floor(195 * brightness)

                local lastChar = message:sub(-1)
                local verb = "says"
                if prefix == "LowTo" then
                    verb = (lastChar == "?" and "asks quietly") or (lastChar == "!" and "quietly exclaims") or "says quietly"
                elseif prefix == "LowerTo" then
                    verb = "whispers"
                elseif prefix == "ShoutTo" then
                    verb = "shouts"
                else
                    verb = (lastChar == "?" and "asks") or (lastChar == "!" and "exclaims") or "says"
                end

                verb = verb .. " (to " .. targetName .. ")"
                TriggerClientEvent('chat:addMessage', receiverId, RPChat.BuildSpeechMessage(charName, verb, message, r, g, b, emoteR, emoteG, emoteB))
            end
        end
    end
end

function RPChat.SendProximityMessage(src, range, prefix, message, mode)
    local srcPed = GetPlayerPed(src)
    if not srcPed or srcPed == 0 then return end
    local srcCoords = GetEntityCoords(srcPed)
    local charName = RPChat.GetCharacterName(src)

    for _, playerId in ipairs(GetPlayers()) do
        local targetId = tonumber(playerId)
        local targetPed = GetPlayerPed(targetId)
        if targetPed and targetPed ~= 0 then
            local distance = #(srcCoords - GetEntityCoords(targetPed))
            if distance <= range then
                local brightness = RPChat.GetBrightness(distance, range)
                local text
                if mode == "me" then
                    text = RPChat.BuildMeMessage(charName, message, math.floor(197 * brightness), math.floor(164 * brightness), math.floor(195 * brightness))
                elseif mode == "do" then
                    text = RPChat.BuildDoMessage(charName, message, math.floor(197 * brightness), math.floor(164 * brightness), math.floor(195 * brightness))
                elseif mode == "ooc" then
                    local r, g, b = math.floor(180 * brightness), math.floor(180 * brightness), math.floor(180 * brightness)
                    text = { template = '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')">(( [{0}] {1}: {2} ))</span>', args = { src, charName, message } }
                elseif mode == "npcme" then
                    text = RPChat.BuildNpcMeMessage(message.playerName, message.npcName, message.message, math.floor(255 * brightness), math.floor(140 * brightness), math.floor(60 * brightness))
                elseif mode == "npcdo" then
                    text = RPChat.BuildNpcDoMessage(message.playerName, message.npcName, message.message, math.floor(255 * brightness), math.floor(140 * brightness), math.floor(60 * brightness))
                else
                    local r, g, b = math.floor(255 * brightness), math.floor(255 * brightness), math.floor(255 * brightness)
                    local lastChar = message:sub(-1)
                    local verb = "states"
                    if prefix == "Low" then
                        verb = (lastChar == "?" and "asks quietly") or (lastChar == "!" and "quietly exclaims") or "says quietly"
                    elseif prefix == "Lower" then
                        verb = "whispers"
                    elseif prefix == "Shout" then
                        verb = "shouts"
                    else
                        verb = (lastChar == "?" and "asks") or (lastChar == "!" and "exclaims") or "states"
                    end
                    text = RPChat.BuildSpeechMessage(charName, verb, message, r, g, b, math.floor(197 * brightness), math.floor(164 * brightness), math.floor(195 * brightness))
                end
                TriggerClientEvent('chat:addMessage', targetId, text)
            end
        end
    end
end