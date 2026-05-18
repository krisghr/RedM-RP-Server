RegisterCommand("me", function(src, args, rawCommand)
    local message = rawCommand:sub(4):gsub("^%s+", "")
    if message == "" then return end
    RPChat.SendProximityMessage(src, RPChat.RANGES.normal, "Me", message, "me")
end, false)

RegisterCommand("do", function(src, args, rawCommand)
    local message = rawCommand:sub(4):gsub("^%s+", "")
    if message == "" then return end
    RPChat.SendProximityMessage(src, RPChat.RANGES.normal, "Do", message, "do")
end, false)

RegisterCommand("cme", function(src, args, rawCommand)
    local message = rawCommand:sub(5):gsub("^%s+", "")
    if message == "" then return end
    RPChat.SendProximityMessage(src, RPChat.RANGES.normal, "CombatMe", message, "cme")
end, false)