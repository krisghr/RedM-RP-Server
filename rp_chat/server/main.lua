print("[RP_CHAT] server/main.lua loaded")

AddEventHandler('playerDropped', function()
    local src = source
    RPChat.ClearPlayerLanguage(src)
    local srcPed = GetPlayerPed(src)
    if not srcPed or srcPed == 0 then return end

    local srcCoords = GetEntityCoords(srcPed)
    local charName = RPChat.GetCharacterName(src)

    for _, playerId in ipairs(GetPlayers()) do
        local targetId = tonumber(playerId)
        if targetId and targetId ~= src then
            local targetPed = GetPlayerPed(targetId)
            if targetPed and targetPed ~= 0 then
                if #(srcCoords - GetEntityCoords(targetPed)) <= RPChat.RANGES.normal then
                    TriggerClientEvent('chat:addMessage', targetId, {
                        template = '<span style="color: rgb(180, 180, 180)">(( {0} has disconnected. ))</span>',
                        args = { charName }
                    })
                end
            end
        end
    end
end)

RegisterNetEvent("rp_chat:setAccent", function(accentText, accentColor)
    local src = source
    accentText = RPChat.Trim(tostring(accentText or "")):sub(1, 80)
    accentColor = tostring(accentColor or "255,255,255")

    if not accentColor:match('^%d+,%d+,%d+$') then
        accentColor = "255,255,255"
    end

    local r, g, b = accentColor:match('^(%d+),(%d+),(%d+)$')
    r, g, b = tonumber(r) or 255, tonumber(g) or 255, tonumber(b) or 255
    r = math.max(0, math.min(255, r))
    g = math.max(0, math.min(255, g))
    b = math.max(0, math.min(255, b))

    local state = Player(src).state
    state:set("accentText", accentText, true)
    state:set("accentColor", string.format("%d,%d,%d", r, g, b), true)

    TriggerClientEvent('chat:addMessage', src, {
        color = { 180, 180, 180 },
        args = { "Accent", accentText == "" and "Accent cleared." or "Accent updated." }
    })
end)