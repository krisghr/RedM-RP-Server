RegisterCommand("shout", function(src, args, rawCommand)
    local message = rawCommand:sub(7):gsub("^%s+", "")
    if message == "" then return end
    if RPChat.IsAutoLanguageEnabled(src) then
        RPChat.SendLanguageProximity(src, RPChat.RANGES.shout, "Shout", message)
        return
    end
    RPChat.SendProximityMessage(src, RPChat.RANGES.shout, "Shout", message, "speech")
end, false)

RegisterCommand("sh", function(src, args, rawCommand)
    local message = rawCommand:sub(3):gsub("^%s+", "")
    if message == "" then return end
    if RPChat.IsAutoLanguageEnabled(src) then
        RPChat.SendLanguageProximity(src, RPChat.RANGES.shout, "Shout", message)
        return
    end
    RPChat.SendProximityMessage(src, RPChat.RANGES.shout, "Shout", message, "speech")
end, false)