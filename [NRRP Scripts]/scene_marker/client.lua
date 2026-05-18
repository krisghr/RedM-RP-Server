local markers = {}
local activeSceneMessages = {}

local iconOptions = {
    { label = 'Question Mark', markerType = 0x94FDAE17 }
}

local colorOptions = {
    { label = 'White', color = { 255, 255, 255 } },
    { label = 'Red', color = { 230, 65, 65 } },
    { label = 'Green', color = { 60, 190, 90 } },
    { label = 'Blue', color = { 75, 150, 255 } },
    { label = 'Yellow', color = { 230, 190, 60 } }
}



local function parseRgb(rgb)
    if type(rgb) ~= 'string' then return nil end
    local r, g, b = rgb:match('^(%d+),(%d+),(%d+)$')
    r, g, b = tonumber(r), tonumber(g), tonumber(b)
    if not r or not g or not b then return nil end
    return { math.max(0, math.min(255, r)), math.max(0, math.min(255, g)), math.max(0, math.min(255, b)) }
end

local function getGroundZ(x, y, z)
    local _, groundZ = GetGroundZFor_3dCoord(x, y, z + 1.0, false)
    return groundZ or z
end

local function drawWorldText(x, y, z, text, scale, r, g, b, a)
    local str = CreateVarString(10, 'LITERAL_STRING', text)
    SetDrawOrigin(x, y, z, 0)
    SetTextScale(scale, scale)
    SetTextColor(r, g, b, a)
    SetTextCentre(true)
    DisplayText(str, 0.0, 0.0)
    ClearDrawOrigin()
end

local function drawPlacementMarker(x, y, z, markerType, color)
    local drawZ = getGroundZ(x, y, z)

    DrawMarker(markerType, x, y, drawZ, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.75, 0.75, 0.75, color[1], color[2], color[3], 96, 0, 0, 2, 0, 0, 0, 0)
end

local function setNui(open)
    SetNuiFocus(open, open)
    SendNUIMessage({ action = open and 'open' or 'close', icons = iconOptions, colors = colorOptions })
end

RegisterCommand('scenemarker', function()
    setNui(true)
end)

RegisterNUICallback('close', function(_, cb)
    setNui(false)
    cb('ok')
end)

RegisterNUICallback('submit', function(data, cb)
    local coords = GetEntityCoords(PlayerPedId())

    TriggerServerEvent('scene_marker:create', {
        x = coords.x,
        y = coords.y,
        z = coords.z,
        text = tostring(data.text or ''),
        iconType = tonumber(data.iconType) or 1,
        colorType = tonumber(data.colorType) or 1,
        color = parseRgb(data.colorRgb),
        duration = tonumber(data.duration) or 300
    })

    setNui(false)
    cb('ok')
end)

RegisterNetEvent('scene_marker:syncAll', function(serverMarkers)
    if type(serverMarkers) ~= 'table' then
        markers = {}
        return
    end

    markers = serverMarkers
end)

RegisterNetEvent('scene_marker:add', function(marker)
    if type(marker) ~= 'table' or marker.id == nil then return end
    markers[marker.id] = marker
end)

RegisterNetEvent('scene_marker:remove', function(id)
    markers[id] = nil
    activeSceneMessages[id] = nil
end)

CreateThread(function()
    TriggerServerEvent('scene_marker:requestAll')

    while true do
        local sleep = 650
        local playerCoords = GetEntityCoords(PlayerPedId())

        if type(markers) ~= 'table' then
            markers = {}
        end

        for _, marker in pairs(markers) do
            local icon = iconOptions[marker.iconType] or iconOptions[1]
            local colorData = colorOptions[marker.colorType] or colorOptions[1]
            local activeColor = marker.color or colorData.color
            local r, g, b = table.unpack(activeColor)
            local markerPos = vector3(marker.x, marker.y, marker.z)
            local distance = #(playerCoords - markerPos)

            if distance < 66.0 then
                sleep = 0
                local drawZ = getGroundZ(marker.x, marker.y, marker.z)
                drawPlacementMarker(marker.x, marker.y, drawZ, icon.markerType, activeColor)
            end

            if distance < 0.5 then
                sleep = 0
                if not activeSceneMessages[marker.id] then
                    activeSceneMessages[marker.id] = true
                    TriggerEvent('chat:addMessage', {
                        color = { 240, 120, 120 },
                        multiline = true,
                        args = { '* ' .. marker.text }
                    })
                end
            else
                activeSceneMessages[marker.id] = nil
            end
        end

        Wait(sleep)
    end
end)


RegisterCommand('scenewho', function()
    local coords = GetEntityCoords(PlayerPedId())
    TriggerServerEvent('scene_marker:whoNearest', { x = coords.x, y = coords.y, z = coords.z })
end)

RegisterNetEvent('scene_marker:whoResult', function(marker, errorMessage)
    if errorMessage then
        TriggerEvent('chat:addMessage', {
            color = { 255, 180, 120 },
            args = { '[Scene Admin]', errorMessage }
        })
        return
    end

    if marker then
        TriggerEvent('chat:addMessage', {
            color = { 255, 220, 120 },
            args = { '[Scene Admin]', ('Marker #' .. marker.id .. ' placed by ' .. (marker.creatorName or 'Unknown') .. ' (ID ' .. tostring(marker.creatorId or '?') .. ')') }
        })
    end
end)
