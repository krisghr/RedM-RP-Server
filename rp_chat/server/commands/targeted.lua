local function ParseToCommand(args)
    local targetId = tonumber(args[1])
    if not targetId then return nil, "" end
    table.remove(args, 1)
    return targetId, table.concat(args, " ")
end

local function HandleTargeted(src, range, prefix, args)
    local targetId, message = ParseToCommand(args)
    if not targetId or message == "" then return end

    if RPChat.IsAutoLanguageEnabled(src) then
        RPChat.SendLanguageTargeted(src, range, prefix, targetId, message)
        return
    end

    RPChat.SendTargetedProximityMessage(src, range, prefix, targetId, message)
end

RegisterCommand("to", function(src, args)
    HandleTargeted(src, RPChat.RANGES.normal, "To", args)
end, false)

RegisterCommand("t", function(src, args)
    HandleTargeted(src, RPChat.RANGES.normal, "To", args)
end, false)

RegisterCommand("lowto", function(src, args)
    HandleTargeted(src, RPChat.RANGES.low, "LowTo", args)
end, false)

RegisterCommand("lt", function(src, args)
    HandleTargeted(src, RPChat.RANGES.low, "LowTo", args)
end, false)

RegisterCommand("lowerto", function(src, args)
    HandleTargeted(src, RPChat.RANGES.lower, "LowerTo", args)
end, false)

RegisterCommand("lwto", function(src, args)
    HandleTargeted(src, RPChat.RANGES.lower, "LowerTo", args)
end, false)

RegisterCommand("shoutto", function(src, args)
    HandleTargeted(src, RPChat.RANGES.shout, "ShoutTo", args)
end, false)

RegisterCommand("st", function(src, args)
    HandleTargeted(src, RPChat.RANGES.shout, "ShoutTo", args)
end, false)
