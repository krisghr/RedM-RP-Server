RegisterServerEvent('chatMessage')
AddEventHandler('chatMessage', function(src, name, message)
    if string.sub(message, 1, 1) == "/" then
        local commandName = message:sub(2):match("^%S+")
        if commandName and not RPChat.CommandExists(commandName) then
            CancelEvent()
            TriggerClientEvent('chat:addMessage', src, { args = { '^1System', '^7No such command exists.' } })
        end
        return
    end

    CancelEvent()
    RPChat.SendProximityMessage(src, RPChat.RANGES.normal, "Normal", message, "speech")
end)
