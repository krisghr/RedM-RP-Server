RegisterCommand("low", function(src, args, rawCommand)
    local message = rawCommand:sub(5):gsub("^%s+", "")
    if message == "" then return end
    RPChat.SendProximityMessage(src, RPChat.RANGES.low, "Low", message, "speech")
end, false)

RegisterCommand("l", function(src, args, rawCommand)
    local message = rawCommand:sub(3):gsub("^%s+", "")
    if message == "" then return end
    RPChat.SendProximityMessage(src, RPChat.RANGES.low, "Low", message, "speech")
end, false)
