local isJailUiOpen = false

local function Debug(message)
    if Config.Debug then
        print(('[nrrp-police][client] %s'):format(message))
    end
end

local function SetUiOpen(state)
    isJailUiOpen = state
    SetNuiFocus(state, state)
    SetNuiFocusKeepInput(false)
end

RegisterNetEvent('nrrp-police:client:teleport', function(coords)
    if type(coords) ~= 'table' then
        return
    end

    local ped = PlayerPedId()
    if not ped or ped == 0 then
        return
    end

    local x = coords.x or coords[1]
    local y = coords.y or coords[2]
    local z = coords.z or coords[3]
    local w = coords.w or coords[4] or 0.0

    if not x or not y or not z then
        return
    end

    SetEntityCoords(ped, x + 0.0, y + 0.0, z + 0.0, false, false, false, true)
    SetEntityHeading(ped, w + 0.0)
    Debug(('Teleported to %.2f %.2f %.2f'):format(x, y, z))
end)

RegisterNetEvent('nrrp-police:client:openJailUi', function(payload)
    SetUiOpen(true)
    SendNUIMessage({
        action = 'openJailUi',
        payload = payload or {}
    })
end)

RegisterNUICallback('submitJailForm', function(data, cb)
    TriggerServerEvent('nrrp-police:server:submitJailForm', data)
    cb({ ok = true })
end)

RegisterNUICallback('closeJailUi', function(_, cb)
    SetUiOpen(false)
    SendNUIMessage({ action = 'closeJailUi' })
    cb({ ok = true })
end)

RegisterNetEvent('nrrp-police:client:closeJailUi', function()
    if not isJailUiOpen then
        return
    end

    SetUiOpen(false)
    SendNUIMessage({ action = 'closeJailUi' })
end)