Config = {}

Config.Debug = true
Config.Framework = 'vorp' -- currently supported: 'vorp'
Config.OwnershipMode = 'owner' -- 'owner' (only planter can manage) or 'shared'

Config.AntiSpamMs = 1200
Config.MaxInteractDistance = 2.25
Config.PromptKey = 0xCEFD9220 -- INPUT_CONTEXT_X

Config.ShowPlotMarkers = true
Config.PlotMarker = {
    type = 28,
    scale = vector3(0.22, 0.22, 0.22),
    color = { r = 120, g = 210, b = 120, a = 180 }
}

-- Future-facing: prevent farming in rectangular no-farm regions.
-- coords are 2D X/Y corners of an axis-aligned rectangle.
Config.NoFarmZones = {
    {
        id = 'valentine_town_core',
        min = vector2(-370.0, 720.0),
        max = vector2(-140.0, 900.0)
    }
}

Config.Farms = {
    {
        id = 'valentine_coop',
        label = 'Valentine Cooperative Field',
        center = vector3(-283.37, 792.46, 119.41),
        radius = 40.0,
        plots = {
            { id = 'v1', coords = vector3(-387.3406, 892.6253, 115.6945), heading = 0.0 },
            { id = 'v2', coords = vector3(-369.3982, 890.6702, 115.7124), heading = 0.0 },
            { id = 'v3', coords = vector3(-369.9306, 905.6257, 116.9287), heading = 0.0 }
        }
    }
}

Config.Crops = {
    corn = {
        label = 'Corn',
        growthTimeSeconds = 900,
        waterDecayPerMinute = 8,
        minWaterToGrow = 25,
        rewardItem = 'corn',
        rewardAmount = { min = 1, max = 3 },
        propsByStage = {
            seedling = `p_plantcorn01x`,
            sprout = `p_plantcorn01x`,
            growing = `p_plantcorn01x`,
            ready = `p_plantcorn01x`,
            withered = `p_plantcorn_dry01x`
        }
    },
    wheat = {
        label = 'Wheat',
        growthTimeSeconds = 600,
        waterDecayPerMinute = 10,
        minWaterToGrow = 30,
        rewardItem = 'wheat',
        rewardAmount = { min = 2, max = 4 },
        propsByStage = {
            seedling = `p_wheat01x`,
            sprout = `p_wheat01x`,
            growing = `p_wheat01x`,
            ready = `p_wheat01x`,
            withered = `p_wheat_dry01x`
        }
    }
}

Config.TickRateMs = 30000
