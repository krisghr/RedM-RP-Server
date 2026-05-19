local FarmState = {}
local PlotProps = {}

local function debugPrint(message)
    if Config.Debug then
        print(('[farming_system] %s'):format(message))
    end
end

local function notify(message)
    if FrameworkClient and FrameworkClient.Notify then
        local ok = pcall(FrameworkClient.Notify, message)
        if ok then
            return
        end
    end

    print(('[farming] %s'):format(message))
end

local function getFarmPlotConfig(farmId, plotId)
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

local function getDesiredModelHash(plotState)
    if not plotState or not plotState.crop then
        return nil
    end

    local cropCfg = Config.Crops[plotState.crop]
    if not cropCfg or not cropCfg.propsByStage then
        return nil
    end

    return cropCfg.propsByStage[plotState.stage]
end

local function deletePlotProp(farmId, plotId)
    local key = ('%s:%s'):format(farmId, plotId)
    local object = PlotProps[key]
    if object and DoesEntityExist(object) then
        DeleteEntity(object)
    end
    PlotProps[key] = nil
end

local function spawnPlotProp(farmId, plotId, modelHash)
    local _, plotCfg = getFarmPlotConfig(farmId, plotId)
    if not plotCfg or not modelHash then
        return
    end

    local key = ('%s:%s'):format(farmId, plotId)
    local current = PlotProps[key]

    if current and DoesEntityExist(current) and GetEntityModel(current) == modelHash then
        return
    end

    deletePlotProp(farmId, plotId)

    RequestModel(modelHash)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(modelHash) and GetGameTimer() < timeout do
        Wait(10)
    end

    if not HasModelLoaded(modelHash) then
        debugPrint(('Failed to load model for %s:%s'):format(farmId, plotId))
        return
    end

    local obj = CreateObject(modelHash, plotCfg.coords.x, plotCfg.coords.y, plotCfg.coords.z - 1.0, false, false, false)
    if obj and obj ~= 0 then
        SetEntityHeading(obj, plotCfg.heading or 0.0)
        FreezeEntityPosition(obj, true)
        SetEntityAsMissionEntity(obj, true, true)
        PlotProps[key] = obj
    end

    SetModelAsNoLongerNeeded(modelHash)
end


local function drawPlotMarker(coords)
    if not Config.ShowPlotMarkers then
        return
    end

    local marker = Config.PlotMarker
    if not marker then
        return
    end

    DrawMarker(
        marker.type or 28,
        coords.x, coords.y, coords.z - 0.95,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        marker.scale.x, marker.scale.y, marker.scale.z,
        marker.color.r, marker.color.g, marker.color.b, marker.color.a,
        false, false, 2, false, nil, nil, false
    )
end

local function syncPlotProps()
    for farmId, farmPlots in pairs(FarmState) do
        for plotId, state in pairs(farmPlots) do
            local modelHash = getDesiredModelHash(state)
            if modelHash then
                spawnPlotProp(farmId, plotId, modelHash)
            else
                deletePlotProp(farmId, plotId)
            end
        end
    end
end

RegisterNetEvent('farming:client:notify', function(message)
    notify(message)
end)

RegisterNetEvent('farming:client:syncState', function(state)
    FarmState = state or {}
    syncPlotProps()
end)

RegisterCommand('farm_state', function()
    debugPrint(json.encode(FarmState))
end)

CreateThread(function()
    Wait(3000)
    TriggerServerEvent('farming:server:requestState')
end)

CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local pcoords = GetEntityCoords(ped)

        for _, farm in ipairs(Config.Farms) do
            if #(pcoords - farm.center) <= farm.radius then
                for _, plot in ipairs(farm.plots) do
                    local dist = #(pcoords - plot.coords)
                    if dist <= 20.0 then
                        sleep = 0
                        drawPlotMarker(plot.coords)
                    end

                    if dist <= Config.MaxInteractDistance then
                        sleep = 0

                        local plotState = FarmState[farm.id] and FarmState[farm.id][plot.id]
                        local helpText = 'Plant (H)'
                        local action = 'plant'

                        if plotState and plotState.stage and plotState.stage ~= 'empty' then
                            if plotState.stage == 'ready' then
                                helpText = 'Harvest (H)'
                                action = 'harvest'
                            else
                                helpText = 'Water (H)'
                                action = 'water'
                            end
                        end

                        local onScreen, sx, sy = GetScreenCoordFromWorldCoord(plot.coords.x, plot.coords.y, plot.coords.z + 1.0)
                        if onScreen then
                            SetTextScale(0.35, 0.35)
                            SetTextFontForCurrentCommand(1)
                            SetTextColour(255, 255, 255, 215)
                            SetTextCentre(true)
                            DisplayText(CreateVarString(10, 'LITERAL_STRING', helpText), sx, sy)
                        end

                        if IsControlJustPressed(0, Config.PromptKey) then
                            TriggerServerEvent('farming:server:interact', action, farm.id, plot.id)
                        end
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end

    for key, obj in pairs(PlotProps) do
        if obj and DoesEntityExist(obj) then
            DeleteEntity(obj)
        end
        PlotProps[key] = nil
    end
end)
