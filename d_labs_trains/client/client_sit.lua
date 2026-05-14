Config.Seat = {
    { "PROP_HUMAN_PIANO", "" },
    { "PROP_PLAYER_SEAT_CHAIR_GENERIC", "" },
    { "PROP_VEHICHLE_SEAT_PASSENGER_TRAIN_TG", "" },
    { "PROP_VEHICHLE_SEAT_PASSENGER_TRAM", "" },
    { "PROP_VEHICLE_SEAT_PASSENGER_TRAIN_TABLE", "" },
    { "PROP_HUMAN_SEAT_CHAIR_TABLE_FAN_WHORE", "" },
    { "PROP_HUMAN_SEAT_CHAIR_THEATER", "" },
    { "PROP_HUMAN_SEAT_CHAIR_TRAIN", "" },
    { "PROP_HUMAN_SEAT_CHAIR_WHITTLE", "" },
    { "PROP_HUMAN_SEAT_CRATE_CLEAN_BOOTS", "" },
}

----------------------------------------------------------------------------
-- Helpers
----------------------------------------------------------------------------

local function findScenarioNear(coords, radius)
    local DataStruct = DataView.ArrayBuffer(256 * 4)
    local count = Citizen.InvokeNative(0x345EC3B7EBDE1CB5, coords, radius, DataStruct:Buffer(), 10)
    if not count or count == false or count == 0 then
        return nil
    end


    for i = 1, count do
        local scenario = DataStruct:GetInt32(8 * i)
        local hash = Citizen.InvokeNative(0xA92450B5AE687AAF, scenario)
        for _, v in pairs(Config.Seat) do
            if GetHashKey(v[1]) == hash then
                return scenario
            end
        end
    end
    return nil
end

local function findNearestSeatScenario()
    return findScenarioNear(GetEntityCoords(PlayerPedId()), 1.0)
end

local function toggleSit(targetEntity)
    local ped = PlayerPedId()
    if IsPedUsingAnyScenario(ped) then
        ClearPedTasks(ped)
        return
    end

    local scenario = findNearestSeatScenario()
    if not scenario and targetEntity and DoesEntityExist(targetEntity) then
        scenario = findScenarioNear(GetEntityCoords(targetEntity), 5.0)
    end

    if scenario then
        TaskUseScenarioPoint(ped, scenario, "", -1.0, true, false, 0, false, -1.0, true)
    end
end

----------------------------------------------------------------------------
-- Prompt-based sitting (default — when MetaTarget = false)
----------------------------------------------------------------------------

Citizen.CreateThread(function()
    while Config.Sitting and not Config.Server.MetaTarget do
        if IsPedInAnyTrain(PlayerPedId()) then
            local scenario = findNearestSeatScenario()
            if scenario then
                activePrompt(9)
                if pressPrompt(11) then
                    toggleSit()
                    Citizen.Wait(5000)
                end
            end
            Citizen.Wait(5)
        else
            Citizen.Wait(5000)
        end
    end
end)

local TARGET_ICON     = 'fas fa-chair'
local TARGET_DISTANCE = 2.0

Citizen.CreateThread(function()
    if not (Config.Sitting and Config.Server.MetaTarget) then return end
    Citizen.Wait(500)

    local models = {}
    for _, h in ipairs(Config.SEAT_PROP_HASHES or {}) do
        models[#models + 1] = h
    end
    if #models == 0 then return end

    exports.ox_target:addModel(models, {
        {
            name        = 'd_labs_trains_sit_down',
            label       = texts.prompt.sit,
            icon        = TARGET_ICON,
            distance    = TARGET_DISTANCE,
            canInteract = function()
                local ped = PlayerPedId()
                return IsPedInAnyTrain(ped) and not IsPedUsingAnyScenario(ped)
            end,
            onSelect    = function(data) toggleSit(data and data.entity) end,
        },
        {
            name        = 'd_labs_trains_stand_up',
            label       = texts.prompt.standUp,
            icon        = TARGET_ICON,
            distance    = TARGET_DISTANCE,
            canInteract = function()
                local ped = PlayerPedId()
                return IsPedInAnyTrain(ped) and IsPedUsingAnyScenario(ped)
            end,
            onSelect    = function(data) toggleSit(data and data.entity) end,
        },
    })
end)

Config.FakeDoor = {
    {
        door   = -295414714,
        inside = -692210960,
        slots  = {
            {
                promptOffset     = vec3(0.898, -3.443, 2.046),
                inOffset         = vec3(-0.121, -3.544, 2.048),
                inHeadingOffset  = 100.6440,
                outOffset        = vec3(0.823, -3.454, 2.048),
                outHeadingOffset = 285.9259,
            },
            {
                promptOffset     = vec3(0.721, -0.109, 2.044),
                inOffset         = vec3(-0.197, 0.088, 2.045),
                inHeadingOffset  = 274.7286,
                outOffset        = vec3(0.853, 0.032, 2.046),
                outHeadingOffset = 90.2765,
            },
            {
                promptOffset     = vec3(0.837, 3.499, 2.046),
                inOffset         = vec3(-0.053, 3.338, 2.046),
                inHeadingOffset  = 274.6169,
                outOffset        = vec3(0.868, 3.604, 2.045),
                outHeadingOffset = 88.5841,
            },
        },
    },
}

local FAKE_DOOR_PROMPT_DISTANCE = 1.5   
local FAKE_DOOR_TARGET_DISTANCE = 2.0
local FAKE_DOOR_TRAIN_RADIUS    = 8.0  

local function findDoorPair(hash)
    for _, p in ipairs(Config.FakeDoor or {}) do
        if p.door == hash then return p, 'door' end
        if p.inside == hash then return p, 'inside' end
    end
    return nil, nil
end

local function findNearestEntityByModel(hash, pool, pcoords, maxDist)
    local bestEnt, bestDist = nil, maxDist or 9999.0
    for _, ent in ipairs(pool) do
        if DoesEntityExist(ent) and GetEntityModel(ent) == hash then
            local d = #(pcoords - GetEntityCoords(ent))
            if d < bestDist then bestEnt, bestDist = ent, d end
        end
    end
    return bestEnt, bestDist
end

local function isInTrainContext()
    local ped = PlayerPedId()
    if IsPedInAnyTrain(ped) then return true end
    local pc       = GetEntityCoords(ped)
    local vehicles = GetGamePool('CVehicle')
    local objects  = GetGamePool('CObject')
    for _, p in ipairs(Config.FakeDoor or {}) do
        if findNearestEntityByModel(p.door,   vehicles, pc, FAKE_DOOR_TRAIN_RADIUS) then return true end
        if findNearestEntityByModel(p.inside, objects,  pc, FAKE_DOOR_TRAIN_RADIUS) then return true end
    end
    return false
end

local function getSlotPromptWorldPos(insideEnt, slot)
    local off = (slot and slot.promptOffset) or vec3(0.0, 0.0, 0.0)
    return GetOffsetFromEntityInWorldCoords(insideEnt, off.x, off.y, off.z)
end

local function findNearestSlot(pcoords, maxDist)
    local bestSlot, bestPair, bestInside, bestDist = nil, nil, nil, maxDist or 9999.0

    for _, pair in ipairs(Config.FakeDoor or {}) do
        if pair.slots and #pair.slots > 0 then
            local inside = findNearestEntityByModel(pair.inside, GetGamePool('CObject'), pcoords, 99999.0)
            if inside then
                for _, slot in ipairs(pair.slots) do
                    local anchor = getSlotPromptWorldPos(inside, slot)
                    local d = #(pcoords - anchor)
                    if d < bestDist then
                        bestSlot, bestPair, bestInside, bestDist = slot, pair, inside, d
                    end
                end
            end
        end
    end
    return bestSlot, bestPair, bestInside, bestDist
end

local function fadeWaitTeleport(coords, heading)
    local ped = PlayerPedId()
    DoScreenFadeOut(200)
    while not IsScreenFadedOut() do Citizen.Wait(0) end
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    if heading then SetEntityHeading(ped, heading) end
    Citizen.Wait(50)
    DoScreenFadeIn(300)
end

local function findRefEntity(pair, direction, anchorEnt)
    if not pair then return nil end
    local searchOrigin = (anchorEnt and DoesEntityExist(anchorEnt))
        and GetEntityCoords(anchorEnt)
        or GetEntityCoords(PlayerPedId())
    if direction == 'in' then
        return findNearestEntityByModel(pair.inside, GetGamePool('CObject'),  searchOrigin, 99999.0)
    else
        return findNearestEntityByModel(pair.door,   GetGamePool('CVehicle'), searchOrigin, 99999.0)
    end
end

local fakeDoorIsInside = false

local function teleportThroughDoor(pair, slot, direction, anchorEnt)
    if not (pair and slot) then return end
    -- All offsets in this script are defined in the INSIDE prop's local frame.
    local refEnt = findNearestEntityByModel(
        pair.inside,
        GetGamePool('CObject'),
        (anchorEnt and DoesEntityExist(anchorEnt)) and GetEntityCoords(anchorEnt) or GetEntityCoords(PlayerPedId()),
        99999.0
    )
    if not refEnt then return end

    local off, hoff
    if direction == 'in' then
        off  = slot.inOffset
        hoff = slot.inHeadingOffset or 0.0
    else
        off  = slot.outOffset
        hoff = slot.outHeadingOffset or 0.0
    end
    if not off then return end

    local dest = GetOffsetFromEntityInWorldCoords(refEnt, off.x, off.y, off.z)

    local pz = GetEntityCoords(PlayerPedId()).z
    dest = vec3(dest.x, dest.y, pz - 1.0)

    fadeWaitTeleport(dest, GetEntityHeading(refEnt) + hoff)

    fakeDoorIsInside = (direction == 'in')
end

Citizen.CreateThread(function()
    if not Config.Server.MetaTarget then return end
    if not Config.FakeDoor or #Config.FakeDoor == 0 then return end
    Citizen.Wait(500)

    local doorModels = {}
    for _, p in ipairs(Config.FakeDoor) do
        doorModels[#doorModels + 1] = p.door
    end

    exports.ox_target:addModel(doorModels, {
        {
            name        = 'd_labs_trains_fake_door_in',
            label       = texts.prompt.passDoorIn,
            icon        = 'fas fa-door-open',
            distance    = FAKE_DOOR_TARGET_DISTANCE,
            canInteract = function(entity)
                if not entity then return false end
                return not fakeDoorIsInside
            end,
            onSelect = function(data)
                local ent = data and data.entity
                local pair = ent and findDoorPair(GetEntityModel(ent))
                -- pick the slot whose promptOffset is closest to the player
                local slot = findNearestSlot(GetEntityCoords(PlayerPedId()), 99999.0)
                teleportThroughDoor(pair, slot, 'in', ent)
            end,
        },
        {
            name        = 'd_labs_trains_fake_door_out',
            label       = texts.prompt.passDoorOut,
            icon        = 'fas fa-door-closed',
            distance    = FAKE_DOOR_TARGET_DISTANCE,
            canInteract = function(entity)
                if not entity then return false end
                return fakeDoorIsInside
            end,
            onSelect = function(data)
                local ent = data and data.entity
                local pair = ent and findDoorPair(GetEntityModel(ent))
                local slot = findNearestSlot(GetEntityCoords(PlayerPedId()), 99999.0)
                teleportThroughDoor(pair, slot, 'out', ent)
            end,
        },
    })
end)

Citizen.CreateThread(function()
    while not activePrompt or not pressPrompt or not prompts or not prompts[15] do
        Citizen.Wait(50)
    end

    while true do
        if Config.Server.MetaTarget then
            Citizen.Wait(5000)
        elseif not isInTrainContext() then
            Citizen.Wait(800)
        else
            local pc = GetEntityCoords(PlayerPedId())
            local slot, pair, insideEnt = findNearestSlot(pc, FAKE_DOOR_PROMPT_DISTANCE)

            if slot then
                local labelTxt = fakeDoorIsInside and texts.prompt.passDoorOut or texts.prompt.passDoorIn
                if prompts[15] and prompts[15].key then
                    PromptSetText(prompts[15].key, CreateVarString(10, 'LITERAL_STRING', labelTxt))
                end
                activePrompt(12)
                if pressPrompt(15) then
                    teleportThroughDoor(pair, slot, fakeDoorIsInside and 'out' or 'in', insideEnt)
                end
                Citizen.Wait(0)
            else
                Citizen.Wait(400)
            end
        end
    end
end)

----------------------------------------------------------------------------
-- Suppress native "SIT E" prompt while in train (target mode only)
----------------------------------------------------------------------------

Citizen.CreateThread(function()
    local applied = false
    while true do
        Citizen.Wait(500)
        if Config.Sitting and Config.Server.MetaTarget then
            local ped = PlayerPedId()
            if IsPedInAnyTrain(ped) then
                if not applied then
                    SetPedConfigFlag(ped, 472, true)
                    applied = true
                end
            elseif applied then
                SetPedConfigFlag(ped, 472, false)
                applied = false
            end
        end
    end
end)
