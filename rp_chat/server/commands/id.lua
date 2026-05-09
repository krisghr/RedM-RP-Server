RegisterCommand("id", function(src, args)
    local query = RPChat.Trim(table.concat(args or {}, " "))

    if query == "" then
        TriggerClientEvent("chat:addMessage", src, {
            args = { "SYSTEM", "Usage: /id <character name>" }
        })
        return
    end

    local normalizedQuery = string.lower(query)
    local matches = {}

    for _, playerId in ipairs(GetPlayers()) do
        local id = tonumber(playerId)
        local charName = RPChat.GetCharacterName(id)

        if charName and string.find(string.lower(charName), normalizedQuery, 1, true) then
            table.insert(matches, {
                id = id,
                name = charName
            })
        end
    end

    if #matches == 0 then
        TriggerClientEvent("chat:addMessage", src, {
            args = { ('No online characters found matching: "%s"'):format(query) }
        })
        return
    end

    table.sort(matches, function(a, b)
        return a.id < b.id
    end)

    for _, match in ipairs(matches) do
        TriggerClientEvent("chat:addMessage", src, {
            args = { ("[%d] %s"):format(match.id, match.name) }
        })
    end
end, false)
