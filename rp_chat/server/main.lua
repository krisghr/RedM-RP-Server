print("[RP_CHAT] server/main.lua loaded")

AddEventHandler('playerDropped', function()
    local src = source
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
