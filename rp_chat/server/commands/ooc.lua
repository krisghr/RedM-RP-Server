RegisterCommand("b", function(src, args, rawCommand)
    local message = rawCommand:sub(3):gsub("^%s+", "")
    if message == "" then return end
    RPChat.SendProximityMessage(src, RPChat.RANGES.normal, "OOC", message, "ooc")
end, false)
