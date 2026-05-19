function RPChat.CommandExists(commandName)
    local lowered = string.lower(commandName)
    for _, registeredCommand in ipairs(GetRegisteredCommands()) do
        if string.lower(registeredCommand.name) == lowered then
            return true
        end
    end
    return false
end

function RPChat.SaveCurrentCharacterCoords(src)
    local user = RPChat.VORPcore.getUser(src)
    if not user then return false end

    local character = user.getUsedCharacter
    if not character then return false end

    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return false end

    local coords = GetEntityCoords(ped)
    local payload = json.encode({ x = coords.x, y = coords.y, z = coords.z, heading = GetEntityHeading(ped) })
    character.SaveCharacterCoords(payload)
    return true
end

function RPChat.SendChangeCharLogoutMessage(src)
    local srcPed = GetPlayerPed(src)
    if not srcPed or srcPed == 0 then return end

    local srcCoords = GetEntityCoords(srcPed)
    local charName = RPChat.GetCharacterName(src)

    for _, playerId in ipairs(GetPlayers()) do
        local targetId = tonumber(playerId)
        local targetPed = GetPlayerPed(targetId)
        if targetPed and targetPed ~= 0 then
            if #(srcCoords - GetEntityCoords(targetPed)) <= RPChat.RANGES.normal then
                TriggerClientEvent('chat:addMessage', targetId, {
                    template = '<span style="color: rgb(180, 180, 180)">(( * {0} has quit this character and logged out. ))</span>',
                    args = { charName }
                })
            end
        end
    end
end
