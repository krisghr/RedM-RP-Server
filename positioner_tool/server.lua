local anchors = {}

RegisterNetEvent("editpos:start", function(coords)
    local src = source
    anchors[src] = coords
end)

RegisterNetEvent("editpos:stop", function()
    local src = source
    anchors[src] = nil
	TriggerClientEvent("editpos:applyRemotePosition", -1, src, { x = 0.0, y = 0.0, z = 0.0 }, 0.0, false)
end)

RegisterNetEvent("editpos:update", function(coords, heading)


    local src = source
    local ped = GetPlayerPed(src)

    if not ped or ped == 0 then return end

    local anchor = anchors[src]
    if not anchor then return end

    local dx = coords.x - anchor.x
    local dy = coords.y - anchor.y
    local dz = coords.z - anchor.z
    local dist = math.sqrt(dx * dx + dy * dy + dz * dz)

    if dist > 2.0 then
        return
    end

    SetEntityCoordsNoOffset(
        ped,
        coords.x,
        coords.y,
        coords.z,
        true,
        true,
        false
    )

    SetEntityHeading(ped, heading)

    TriggerClientEvent("editpos:applyRemotePosition", -1, src, coords, heading, true)
end)

AddEventHandler("playerDropped", function()
    anchors[source] = nil
end)