RegisterCommand("npcme", function(src, args, rawCommand)
    local npcName, message = RPChat.ParseNpcCommand(rawCommand, 7)
    if not npcName then return end

    RPChat.SendProximityMessage(src, RPChat.RANGES.normal, "NpcMe", {
        npcName = npcName,
        message = message,
        playerName = RPChat.GetCharacterName(src)
    }, "npcme")
end, false)

RegisterCommand("npcdo", function(src, args, rawCommand)
    local npcName, message = RPChat.ParseNpcCommand(rawCommand, 7)
    if not npcName then return end

    RPChat.SendProximityMessage(src, RPChat.RANGES.normal, "NpcDo", {
        npcName = npcName,
        message = message,
        playerName = RPChat.GetCharacterName(src)
    }, "npcdo")
end, false)
