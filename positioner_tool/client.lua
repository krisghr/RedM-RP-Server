local editMode = false
local anchorCoords = nil
local lastSync = 0

local MOVE_STEP = 0.015
local VERTICAL_STEP = 0.01
local ROT_STEP = 1.0
local MAX_DISTANCE = 2.0
local SYNC_INTERVAL = 50

-- Controls
local KEY_W = 0x8FD015D8
local KEY_S = 0xD27782E3
local KEY_A = 0x7065027D
local KEY_D = 0xB4E465B4
local KEY_Q = 0xDE794E3E
local KEY_E = 0xCEFD9220
local KEY_SPACE = 0xD9D0E1C0
local KEY_CTRL = 0xDB096B85
local KEY_T = 0x9720FCEE

-- Remote players being edited
local remoteEditPositions = {}

-- Toggle edit mode
RegisterCommand("editpos", function()
    local ped = PlayerPedId()

    editMode = not editMode

    if editMode then
        anchorCoords = GetEntityCoords(ped)

        FreezeEntityPosition(ped, true)

        -- 🔴 ADD THIS
        LocalPlayer.state:set("editposActive", true, true)

        TriggerServerEvent("editpos:start", {
            x = anchorCoords.x,
            y = anchorCoords.y,
            z = anchorCoords.z
        })

        TriggerEvent("chat:addMessage", {
            args = { "EditPos", "Enabled. WASD move, Space/Ctrl up/down, Q/E rotate." }
        })

    else
        FreezeEntityPosition(ped, false)

        -- 🔴 ADD THIS
        LocalPlayer.state:set("editposActive", false, true)

        TriggerServerEvent("editpos:stop")

        anchorCoords = nil

        TriggerEvent("chat:addMessage", {
            args = { "EditPos", "Disabled." }
        })
    end
end, false)

-- Distance clamp
local function clampToDistance(anchor, newCoords, maxDistance)
    local dx = newCoords.x - anchor.x
    local dy = newCoords.y - anchor.y
    local dz = newCoords.z - anchor.z

    local dist = math.sqrt(dx * dx + dy * dy + dz * dz)

    if dist <= maxDistance then
        return newCoords
    end

    local scale = maxDistance / dist

    return vector3(
        anchor.x + dx * scale,
        anchor.y + dy * scale,
        anchor.z + dz * scale
    )
end

-- Sync position to server
local function syncPosition(ped)
    local now = GetGameTimer()

    if now - lastSync < SYNC_INTERVAL then return end
    lastSync = now

    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    TriggerServerEvent("editpos:update", {
        x = coords.x,
        y = coords.y,
        z = coords.z
    }, heading)
end

-- Main edit loop
CreateThread(function()
    while true do
        Wait(0)

        if editMode then
            local ped = PlayerPedId()

            if not DoesEntityExist(ped) then
                editMode = false
                anchorCoords = nil
                goto continue
            end

            -- Keep frozen
            FreezeEntityPosition(ped, true)

            -- Block movement controls
            DisableAllControlActions(0)
            EnableControlAction(0, KEY_T, true)

            local coords = GetEntityCoords(ped)
            local heading = GetEntityHeading(ped)

            -- Flat movement based on heading
            local rad = math.rad(heading)

            local forward = vector3(
                -math.sin(rad),
                math.cos(rad),
                0.0
            )

            local right = vector3(
                math.cos(rad),
                math.sin(rad),
                0.0
            )

            local horizontalCoords = coords
            local verticalChange = 0.0

            local moved = false
            local rotated = false

            -- Movement (NO Z CHANGE)
            if IsDisabledControlPressed(0, KEY_W) then
                horizontalCoords = horizontalCoords + forward * MOVE_STEP
                moved = true
            end

            if IsDisabledControlPressed(0, KEY_S) then
                horizontalCoords = horizontalCoords - forward * MOVE_STEP
                moved = true
            end

            if IsDisabledControlPressed(0, KEY_D) then
                horizontalCoords = horizontalCoords + right * MOVE_STEP
                moved = true
            end

            if IsDisabledControlPressed(0, KEY_A) then
                horizontalCoords = horizontalCoords - right * MOVE_STEP
                moved = true
            end

            -- Vertical ONLY here
            if IsDisabledControlPressed(0, KEY_SPACE) then
                verticalChange = verticalChange + VERTICAL_STEP
                moved = true
            end

            if IsDisabledControlPressed(0, KEY_CTRL) then
                verticalChange = verticalChange - VERTICAL_STEP
                moved = true
            end

            local newCoords = vector3(
                horizontalCoords.x,
                horizontalCoords.y,
                coords.z + verticalChange
            )

            -- Rotation
            if IsDisabledControlPressed(0, KEY_Q) then
                SetEntityHeading(ped, heading + ROT_STEP)
                rotated = true
            end

            if IsDisabledControlPressed(0, KEY_E) then
                SetEntityHeading(ped, heading - ROT_STEP)
                rotated = true
            end

            -- Apply movement locally
            if moved then
                if anchorCoords then
                    newCoords = clampToDistance(anchorCoords, newCoords, MAX_DISTANCE)
                end

                SetEntityCoordsNoOffset(
                    ped,
                    newCoords.x,
                    newCoords.y,
                    newCoords.z,
                    true,
                    true,
                    false
                )
            end

            -- Sync to server
            if moved or rotated then
                syncPosition(ped)
            end
        end

        ::continue::
    end
end)

-- Receive remote edit updates
RegisterNetEvent("editpos:applyRemotePosition", function(serverId, coords, heading, active)
    if serverId == GetPlayerServerId(PlayerId()) then return end

    if not active then
        remoteEditPositions[serverId] = nil
        return
    end

    remoteEditPositions[serverId] = {
        coords = vector3(coords.x, coords.y, coords.z),
        heading = heading
    }
end)

-- Apply remote edits every frame (fixes animation override issue)
CreateThread(function()
    while true do
        Wait(0)

        for serverId, data in pairs(remoteEditPositions) do
            local player = GetPlayerFromServerId(serverId)

            if player ~= -1 then
                local ped = GetPlayerPed(player)

                if ped and ped ~= 0 and DoesEntityExist(ped) then
                    SetEntityCoordsNoOffset(
                        ped,
                        data.coords.x,
                        data.coords.y,
                        data.coords.z,
                        false,
                        false,
                        false
                    )

                    SetEntityHeading(ped, data.heading)
                end
            end
        end
    end
end)