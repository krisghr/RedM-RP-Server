local requestCounter = 0
local pending = {}

local function setNui(open, mode, data)
    SetNuiFocus(open, open)
    SendNUIMessage({
        action = open and 'open' or 'close',
        mode = mode,
        data = data
    })
end

RegisterNetEvent('character_attributes:response', function(requestId, data)
    local resolver = pending[requestId]
    if not resolver then return end
    pending[requestId] = nil
    resolver(data)
end)

local function requestServer(eventName, payload)
    requestCounter = requestCounter + 1
    local requestId = requestCounter
    local p = promise.new()

    pending[requestId] = function(data)
        p:resolve(data)
    end

    TriggerServerEvent(eventName, requestId, payload)
    return Citizen.Await(p)
end

RegisterCommand('setattributes', function()
    local existing = requestServer('character_attributes:getOwn', nil)
    setNui(true, 'set', {
        characterName = existing and existing.character_name or GetPlayerName(PlayerId()),
        age = existing and existing.age or '',
        imageUrl = existing and existing.image_url or '',
        appearanceDescription = existing and existing.appearance_description or ''
    })
end, false)

RegisterCommand('examine', function(_, args)
    local query = table.concat(args, ' ')
    if query == '' then
        TriggerEvent('chat:addMessage', { color = { 255, 220, 80 }, args = { '^3Usage:^7 /examine <character name or server id>' } })
        return
    end

    local data = requestServer('character_attributes:getByQuery', query)
    if not data then
        TriggerEvent('chat:addMessage', { color = { 255, 80, 80 }, args = { '^1No saved attributes found for that name/ID.' } })
        return
    end

    setNui(true, 'view', {
        characterName = data.character_name,
        age = data.age,
        imageUrl = data.image_url,
        appearanceDescription = data.appearance_description
    })
end, false)

RegisterNUICallback('close', function(_, cb)
    setNui(false)
    cb({ ok = true })
end)

RegisterNUICallback('save', function(data, cb)
    TriggerServerEvent('character_attributes:save', data)
    cb({ ok = true })
end)

RegisterNetEvent('character_attributes:notify', function(message)
    TriggerEvent('chat:addMessage', {
        color = { 80, 200, 120 },
        args = { message }
    })
end)
