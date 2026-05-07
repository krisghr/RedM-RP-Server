RegisterServerEvent('chatMessage')
local VORPcore = exports.vorp_core:GetCore()

AddEventHandler('chatMessage', function(source, name, message)
    CancelEvent()

    local charName = GetPlayerName(source)

    local User = VORPcore.getUser(source)
    if User then
        local Character = User.getUsedCharacter
        if Character then
            charName = Character.firstname .. " " .. Character.lastname
        end
    end

    TriggerClientEvent('chat:addMessage', -1, {
        args = { charName, message }
    })
end)