local FarmState = {}
local DB_TABLE = 'farming_plots'
local PlayerCooldown = {}

local function notify(src, message)
    local frameworkNotified = false

    if FrameworkServer and FrameworkServer.Notify then
        frameworkNotified = pcall(FrameworkServer.Notify, src, message)
    end

    if not frameworkNotified then
        TriggerClientEvent('farming:client:notify', src, message)
    end
end

local function savePlotState(farmId, plotId, state)
    MySQL.update.await(([[
        INSERT INTO %s (farm_id, plot_id, crop, planted_at, water, fertilizer, stage, owner_character_id, last_updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
            crop = VALUES(crop),
            planted_at = VALUES(planted_at),
            water = VALUES(water),
            fertilizer = VALUES(fertilizer),
            stage = VALUES(stage),
            owner_character_id = VALUES(owner_character_id),
            last_updated_at = VALUES(last_updated_at)
    ]]):format(DB_TABLE), {
        farmId, plotId, state.crop, state.plantedAt, state.water, state.fertilizer, state.stage, state.ownerCharacterId, state.lastUpdatedAt
    })
end

local function getFarmAndPlotConfig(farmId, plotId)
    for _, farm in ipairs(Config.Farms) do
        if farm.id == farmId then
            for _, plot in ipairs(farm.plots) do
                if plot.id == plotId then
                    return farm, plot
                end
            end
        end
    end

    return nil, nil
end

local function getPlotState(farmId, plotId)
    if not FarmState[farmId] then return nil end
    return FarmState[farmId][plotId]
end

local function isOwnerOrShared(src, plot)
    if Config.OwnershipMode == 'shared' then
        return true
    end

    local charId = FrameworkServer and FrameworkServer.GetCharacterId and FrameworkServer.GetCharacterId(src)
    if not charId then return false end

    return tonumber(plot.ownerCharacterId) == tonumber(charId)
end

local function resetPlot(plot)
    plot.crop = nil
    plot.plantedAt = nil
    plot.water = 0
    plot.fertilizer = 0
    plot.stage = 'empty'
    plot.ownerCharacterId = nil
    plot.lastUpdatedAt = os.time()
end


local function isInsideNoFarmZone(coords)
    for _, zone in ipairs(Config.NoFarmZones or {}) do
        local minX = math.min(zone.min.x, zone.max.x)
        local maxX = math.max(zone.min.x, zone.max.x)
        local minY = math.min(zone.min.y, zone.max.y)
        local maxY = math.max(zone.min.y, zone.max.y)

        if coords.x >= minX and coords.x <= maxX and coords.y >= minY and coords.y <= maxY then
            return true, zone.id
        end
    end

    return false, nil
end

local function canInteract(src, farmId, plotId)
    local now = GetGameTimer()
    local untilTime = PlayerCooldown[src] or 0
    if now < untilTime then
        return false, 'Slow down a bit.'
    end

    local farmCfg, plotCfg = getFarmAndPlotConfig(farmId, plotId)
    if not farmCfg or not plotCfg then
        return false, 'Invalid farm or plot.'
    end

    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then
        return false, 'Player not ready.'
    end

    local pcoords = GetEntityCoords(ped)
    if #(pcoords - plotCfg.coords) > Config.MaxInteractDistance + 0.5 then
        return false, 'You are too far from this plot.'
    end

    PlayerCooldown[src] = now + Config.AntiSpamMs
    return true
end

local function bootstrapFarmState()
    for _, farm in ipairs(Config.Farms) do
        FarmState[farm.id] = FarmState[farm.id] or {}
        for _, plot in ipairs(farm.plots) do
            FarmState[farm.id][plot.id] = {
                crop = nil, plantedAt = nil, water = 0, fertilizer = 0,
                stage = 'empty', ownerCharacterId = nil, lastUpdatedAt = os.time()
            }
        end
    end
end

local function loadFarmStateFromDb()
    local rows = MySQL.query.await(([[SELECT farm_id, plot_id, crop, planted_at, water, fertilizer, stage, owner_character_id, last_updated_at FROM %s]]):format(DB_TABLE)) or {}
    for _, row in ipairs(rows) do
        local plot = getPlotState(row.farm_id, row.plot_id)
        if plot then
            plot.crop = row.crop
            plot.plantedAt = row.planted_at
            plot.water = tonumber(row.water) or 0
            plot.fertilizer = tonumber(row.fertilizer) or 0
            plot.stage = row.stage or 'empty'
            plot.ownerCharacterId = row.owner_character_id
            plot.lastUpdatedAt = row.last_updated_at or os.time()
        end
    end
end

local function updateGrowthCycle()
    local now = os.time()
    for _, farm in ipairs(Config.Farms) do
        for _, plotCfg in ipairs(farm.plots) do
            local state = getPlotState(farm.id, plotCfg.id)
            if state and state.crop and state.plantedAt then
                local cropCfg = Config.Crops[state.crop]
                if cropCfg then
                    local elapsed = now - state.plantedAt
                    local deltaSeconds = math.max(0, now - (state.lastUpdatedAt or now))
                    local waterDrain = (deltaSeconds / 60) * cropCfg.waterDecayPerMinute
                    state.water = math.max(0, state.water - waterDrain)
                    local progress = math.min(1.0, elapsed / cropCfg.growthTimeSeconds)
                    local meetsWaterReq = state.water >= cropCfg.minWaterToGrow

                    if not meetsWaterReq and progress < 1.0 then state.stage = 'withered'
                    elseif progress >= 1.0 then state.stage = meetsWaterReq and 'ready' or 'withered'
                    elseif progress >= 0.66 then state.stage = 'growing'
                    elseif progress >= 0.33 then state.stage = 'sprout'
                    else state.stage = 'seedling' end

                    state.lastUpdatedAt = now
                    savePlotState(farm.id, plotCfg.id, state)
                end
            end
        end
    end
end

RegisterNetEvent('farming:server:requestState', function()
    TriggerClientEvent('farming:client:syncState', source, FarmState)
end)

RegisterNetEvent('farming:server:interact', function(action, farmId, plotId)
    local src = source
    local ok, reason = canInteract(src, farmId, plotId)
    if not ok then
        notify(src, reason)
        return
    end

    local plot = getPlotState(farmId, plotId)
    if not plot then
        notify(src, 'Invalid farm or plot.')
        return
    end

    if action == 'plant' then
        local _, plotCfg = getFarmAndPlotConfig(farmId, plotId)
        local blocked, zoneId = isInsideNoFarmZone(plotCfg.coords)
        if blocked then
            notify(src, ('Farming is blocked in this zone (%s).'):format(zoneId or 'no_farm'))
            return
        end
        if plot.stage ~= 'empty' then
            notify(src, 'That plot is already in use.')
            return
        end

        local defaultCrop = next(Config.Crops)
        local cropCfg = Config.Crops[defaultCrop]
        if not cropCfg then
            notify(src, 'No crops configured.')
            return
        end

        plot.crop = defaultCrop
        plot.plantedAt = os.time()
        plot.water = 75
        plot.fertilizer = 0
        plot.stage = 'seedling'
        plot.lastUpdatedAt = os.time()
        plot.ownerCharacterId = FrameworkServer and FrameworkServer.GetCharacterId and FrameworkServer.GetCharacterId(src) or nil

        savePlotState(farmId, plotId, plot)
        notify(src, ('Planted %s.'):format(cropCfg.label))
        TriggerClientEvent('farming:client:syncState', -1, FarmState)
        return
    end

    if action == 'water' then
        if plot.stage == 'empty' then
            notify(src, 'Nothing is planted there.')
            return
        end

        if not isOwnerOrShared(src, plot) then
            notify(src, 'You do not own this crop.')
            return
        end

        plot.water = math.min(100, plot.water + 20)
        plot.lastUpdatedAt = os.time()
        savePlotState(farmId, plotId, plot)

        notify(src, ('Watered plot %s (+%d).'):format(plotId, 20))
        TriggerClientEvent('farming:client:syncState', -1, FarmState)
        return
    end

    if action == 'harvest' then
        if plot.stage ~= 'ready' or not plot.crop then
            notify(src, 'That crop is not ready yet.')
            return
        end

        if not isOwnerOrShared(src, plot) then
            notify(src, 'You do not own this crop.')
            return
        end

        local cropCfg = Config.Crops[plot.crop]
        if not cropCfg then
            notify(src, 'Crop config missing.')
            return
        end

        local amount = math.random(cropCfg.rewardAmount.min, cropCfg.rewardAmount.max)
        if FrameworkServer and FrameworkServer.AddItem then
            FrameworkServer.AddItem(src, cropCfg.rewardItem, amount, {})
        end

        notify(src, ('Harvested %dx %s.'):format(amount, cropCfg.label))
        resetPlot(plot)
        savePlotState(farmId, plotId, plot)
        TriggerClientEvent('farming:client:syncState', -1, FarmState)
        return
    end

    notify(src, 'Invalid action.')
end)

AddEventHandler('playerDropped', function()
    PlayerCooldown[source] = nil
end)

CreateThread(function()
    bootstrapFarmState()
    MySQL.query.await(([[
        CREATE TABLE IF NOT EXISTS %s (
            farm_id VARCHAR(64) NOT NULL,
            plot_id VARCHAR(64) NOT NULL,
            crop VARCHAR(64) NULL,
            planted_at INT NULL,
            water DECIMAL(10,2) NOT NULL DEFAULT 0,
            fertilizer DECIMAL(10,2) NOT NULL DEFAULT 0,
            stage VARCHAR(32) NOT NULL DEFAULT 'empty',
            owner_character_id VARCHAR(64) NULL,
            last_updated_at INT NOT NULL,
            PRIMARY KEY (farm_id, plot_id)
        )
    ]]):format(DB_TABLE))

    loadFarmStateFromDb()
    TriggerClientEvent('farming:client:syncState', -1, FarmState)

    while true do
        Wait(Config.TickRateMs)
        updateGrowthCycle()
        TriggerClientEvent('farming:client:syncState', -1, FarmState)
    end
end)
