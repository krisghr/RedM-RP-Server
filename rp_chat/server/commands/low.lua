RegisterCommand("low", function(src, args, rawCommand)
    local message = rawCommand:sub(5):gsub("^%s+", "")
    if message == "" then return end
    if RPChat.IsAutoLanguageEnabled(src) then
        RPChat.SendLanguageProximity(src, RPChat.RANGES.low, "Low", message)
        return
    end
    RPChat.SendProximityMessage(src, RPChat.RANGES.low, "Low", message, "speech")
end, false)

RegisterCommand("l", function(src, args, rawCommand)
    local message = rawCommand:sub(3):gsub("^%s+", "")
    if message == "" then return end
    if RPChat.IsAutoLanguageEnabled(src) then
        RPChat.SendLanguageProximity(src, RPChat.RANGES.low, "Low", message)
        return
    end
    RPChat.SendProximityMessage(src, RPChat.RANGES.low, "Low", message, "speech")
end, false)

RegisterCommand("lower", function(src, args, rawCommand)
    local message = rawCommand:sub(7):gsub("^%s+", "")
    if message == "" then return end
    if RPChat.IsAutoLanguageEnabled(src) then
        RPChat.SendLanguageProximity(src, RPChat.RANGES.lower, "Lower", message)
        return
    end
    RPChat.SendProximityMessage(src, RPChat.RANGES.lower, "Lower", message, "speech")
end, false)

RegisterCommand("lw", function(src, args, rawCommand)
    local message = rawCommand:sub(4):gsub("^%s+", "")
    if message == "" then return end
    if RPChat.IsAutoLanguageEnabled(src) then
        RPChat.SendLanguageProximity(src, RPChat.RANGES.lower, "Lower", message)
        return
    end
    RPChat.SendProximityMessage(src, RPChat.RANGES.lower, "Lower", message, "speech")
end, false)
