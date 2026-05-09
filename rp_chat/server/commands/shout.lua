RegisterCommand("shout", function(src, args, rawCommand)
    local message = rawCommand:sub(7):gsub("^%s+", "")
    if message == "" then return end
    RPChat.SendProximityMessage(src, RPChat.RANGES.shout, "Shout", message, "speech")
end, false)

RegisterCommand("s", function(src, args, rawCommand)
    local message = rawCommand:sub(3):gsub("^%s+", "")
    if message == "" then return end
    RPChat.SendProximityMessage(src, RPChat.RANGES.shout, "Shout", message, "speech")
end, false)
