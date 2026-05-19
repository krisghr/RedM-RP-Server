local DoorStates = {}

local function Debug(message)
    if Config.Debug then
        print(('[nrrp-police:client] %s'):format(message))
    end
end

local function TeleportToVector4(coords)
    if not coords then
        return
    end

    local ped = PlayerPedId()
    SetEntityCoords(ped, coords.x or coords[1] or 0.0, coords.y or coords[2] or 0.0, coords.z or coords[3] or 0.0, false, false, false, false)
    SetEntityHeading(ped, coords.w or coords[4] or 0.0)
end

RegisterNetEvent('nrrp-police:client:teleport', function(coords)
    TeleportToVector4(coords)
end)

RegisterNetEvent('nrrp-police:client:setDoorLocked', function(cellId, locked)
    DoorStates[tostring(cellId)] = locked and true or false

    -- TODO: Apply the correct RedM door lock native/export here once each cell has a doorHash.
    -- This event is intentionally isolated so server-specific door code can be added safely.
    -- Common implementations register a door by hash/coords and then set its locked state.
    Debug(('Cell %s door marked %s'):format(cellId, locked and 'locked' or 'unlocked'))
end)

RegisterNetEvent('nrrp-police:client:syncDoorStates', function(states)
    DoorStates = {}

    for cellId, locked in pairs(states or {}) do
        DoorStates[tostring(cellId)] = locked and true or false
        TriggerEvent('nrrp-police:client:setDoorLocked', cellId, locked)
    end
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    TriggerServerEvent('nrrp-police:server:requestDoorSync')
end)
