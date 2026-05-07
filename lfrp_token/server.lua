local activeLfrp = {}

RegisterCommand("lfrp", function(src, args)
    print("[LFRP SERVER] /lfrp used")

    local nickname = table.concat(args, " ")

    if nickname == "" then
        TriggerClientEvent("chat:addMessage", src, {
            args = { "LFRP", "Usage: /lfrp nickname" }
        })
        return
    end

    activeLfrp[src] = nickname

    -- Start the client-side loop
    TriggerClientEvent("lfrp:startTracking", src)

    -- Also request coords immediately
    TriggerClientEvent("lfrp:requestCoords", src)
end, false)

RegisterNetEvent("lfrp:sendCoords", function(coords)
    local src = source
    local nickname = activeLfrp[src]

    print("[LFRP SERVER] Got coords from", src)

    if not nickname then return end

    TriggerClientEvent("lfrp:createOrUpdateBlip", -1, src, nickname, coords)
end)

RegisterCommand("endlfrp", function(src)
    activeLfrp[src] = nil

    TriggerClientEvent("lfrp:stopTracking", src)
    TriggerClientEvent("lfrp:removeBlip", -1, src)
end, false)

AddEventHandler("playerDropped", function()
    local src = source

    activeLfrp[src] = nil
    TriggerClientEvent("lfrp:removeBlip", -1, src)
end)