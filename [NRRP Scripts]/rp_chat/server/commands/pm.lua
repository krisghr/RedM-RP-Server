local function ParsePmCommand(args)
    local targetId = tonumber(args[1])
    if not targetId then return nil, "" end

    table.remove(args, 1)
    return targetId, table.concat(args, " ")
end

local function SendPmMessage(src, targetId, message)
    if not targetId or not GetPlayerName(targetId) then
        TriggerClientEvent('chat:addMessage', src, {
            color = { 180, 180, 180 },
            args = { "Invalid player ID." }
        })
        return
    end

    local senderName = RPChat.GetCharacterName(src)

    local pmText = {
        template = '<span style="color: rgb(255, 255, 0)">(( [{0}] {1}: {2} ))</span>',
        args = { src, senderName, message }
    }

    TriggerClientEvent('chat:addMessage', targetId, pmText)
    TriggerClientEvent('chat:addMessage', src, pmText)
end

RegisterCommand("pm", function(src, args)
    local targetId, message = ParsePmCommand(args)
    if not targetId or message == "" then return end

    SendPmMessage(src, targetId, message)
end, false)
