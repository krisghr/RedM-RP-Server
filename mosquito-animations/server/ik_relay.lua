-- server/ik_relay.lua
-- Simple rate-limited relay in case you choose events instead of state bags.

local last = {}

RegisterNetEvent("mosqIk:update")
AddEventHandler("mosqIk:update", function(active, x, y, z)
    local src = source
    local now = os.clock()
    -- 20 Hz cap
    if last[src] and (now - last[src]) < (1.0 / 20.0) then return end
    last[src] = now

    -- Sanity clamp to a reasonable range
    if type(x) ~= "number" or type(y) ~= "number" or type(z) ~= "number" then
        x, y, z = nil, nil, nil
    end
    TriggerClientEvent("mosqIk:recv", -1, src, active and true or false, x, y, z)
end)

AddEventHandler("playerDropped", function()
    local src = source
    TriggerClientEvent("mosqIk:recv", -1, src, false, nil, nil, nil)
    last[src] = nil
end)
