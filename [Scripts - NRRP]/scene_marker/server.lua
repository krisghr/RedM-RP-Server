local markers = {}
local nextId = 1

RegisterNetEvent('scene_marker:create', function(data)
    if type(data) ~= 'table' then return end

    local id = nextId
    nextId = nextId + 1

    local requestedDuration = tonumber(data.duration) or 300
    local finalDuration = requestedDuration == -1 and -1 or math.max(300, requestedDuration)

    markers[id] = {
        id = id,
        creatorId = source,
        creatorName = GetPlayerName(source) or ('ID ' .. tostring(source)),
        x = tonumber(data.x) or 0.0,
        y = tonumber(data.y) or 0.0,
        z = tonumber(data.z) or 0.0,
        text = tostring(data.text or ''),
        iconType = math.max(1, tonumber(data.iconType) or 1),
        colorType = math.max(1, tonumber(data.colorType) or 1),
        color = type(data.color) == 'table' and data.color or nil,
        duration = finalDuration
    }

    TriggerClientEvent('scene_marker:add', -1, markers[id])

    if markers[id].duration > 0 then
        SetTimeout(markers[id].duration * 1000, function()
            if markers[id] then
                markers[id] = nil
                TriggerClientEvent('scene_marker:remove', -1, id)
            end
        end)
    end
end)

RegisterNetEvent('scene_marker:requestAll', function()
    TriggerClientEvent('scene_marker:syncAll', source, markers)
end)


RegisterCommand('sceneremove', function(source, args)
    local markerId = tonumber(args[1])
    if not markerId or not markers[markerId] then return end
    markers[markerId] = nil
    TriggerClientEvent('scene_marker:remove', -1, markerId)
end, true)


local function isAdmin(source)
    return IsPlayerAceAllowed(source, 'group.admin') or IsPlayerAceAllowed(source, 'command.sceneremove')
end

RegisterNetEvent('scene_marker:whoNearest', function(coords)
    local src = source
    if not isAdmin(src) then
        TriggerClientEvent('scene_marker:whoResult', src, nil, 'You do not have permission for this command.')
        return
    end

    if type(coords) ~= 'table' then
        TriggerClientEvent('scene_marker:whoResult', src, nil, 'Invalid position data.')
        return
    end

    local px, py, pz = tonumber(coords.x) or 0.0, tonumber(coords.y) or 0.0, tonumber(coords.z) or 0.0
    local nearest, nearestDist

    for _, marker in pairs(markers) do
        local dx, dy, dz = marker.x - px, marker.y - py, marker.z - pz
        local dist = math.sqrt(dx * dx + dy * dy + dz * dz)
        if not nearestDist or dist < nearestDist then
            nearest = marker
            nearestDist = dist
        end
    end

    if nearest and nearestDist <= 8.0 then
        TriggerClientEvent('scene_marker:whoResult', src, nearest)
    else
        TriggerClientEvent('scene_marker:whoResult', src, nil, 'No scene marker within 8.0 units.')
    end
end)
