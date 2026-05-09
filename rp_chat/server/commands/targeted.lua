local function ParseToCommand(args)
    local targetId = tonumber(args[1])
    if not targetId then return nil, "" end
    table.remove(args, 1)
    return targetId, table.concat(args, " ")
end

RegisterCommand("to", function(src, args)
    local targetId, message = ParseToCommand(args)
    if not targetId or message == "" then return end
    RPChat.SendTargetedProximityMessage(src, RPChat.RANGES.normal, "To", targetId, message)
end, false)

RegisterCommand("t", function(src, args)
    local targetId, message = ParseToCommand(args)
    if not targetId or message == "" then return end
    RPChat.SendTargetedProximityMessage(src, RPChat.RANGES.normal, "To", targetId, message)
end, false)

RegisterCommand("lowto", function(src, args)
    local targetId, message = ParseToCommand(args)
    if not targetId or message == "" then return end
    RPChat.SendTargetedProximityMessage(src, RPChat.RANGES.low, "LowTo", targetId, message)
end, false)

RegisterCommand("lt", function(src, args)
    local targetId, message = ParseToCommand(args)
    if not targetId or message == "" then return end
    RPChat.SendTargetedProximityMessage(src, RPChat.RANGES.low, "LowTo", targetId, message)
end, false)

RegisterCommand("lowerto", function(src, args)
    local targetId, message = ParseToCommand(args)
    if not targetId or message == "" then return end
    RPChat.SendTargetedProximityMessage(src, RPChat.RANGES.lower, "LowerTo", targetId, message)
end, false)

RegisterCommand("lwto", function(src, args)
    local targetId, message = ParseToCommand(args)
    if not targetId or message == "" then return end
    RPChat.SendTargetedProximityMessage(src, RPChat.RANGES.lower, "LowerTo", targetId, message)
end, false)


RegisterCommand("shoutto", function(src, args)
    local targetId, message = ParseToCommand(args)
    if not targetId or message == "" then return end
    RPChat.SendTargetedProximityMessage(src, RPChat.RANGES.shout, "ShoutTo", targetId, message)
end, false)

RegisterCommand("st", function(src, args)
    local targetId, message = ParseToCommand(args)
    if not targetId or message == "" then return end
    RPChat.SendTargetedProximityMessage(src, RPChat.RANGES.shout, "ShoutTo", targetId, message)
end, false)
