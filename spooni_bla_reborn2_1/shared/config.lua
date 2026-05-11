Config = {}

Config.DevMode = false  -- use true to see the Zones perfect to setup!!

local glm = require "glm"

Config.Zones = {
    {
        name = "bw2_1", -- name of the zone
        thickness = 40, -- height
        point = glm.polygon.new(
            {
                vec3(-853.0784301757812, -1225.02783203125, 42.48),
                vec3(-853.0430297851562, -1222.99938964845, 42.48),
                vec3(-851.4368896484375, -1223.02978515625, 42.48),
                vec3(-851.4747924804688, -1224.49938964843, 42.48),
            }
        ),
        outerZone = nil, -- defines the outer zone. if nil, then it is generated automatically.
        outerZoneDistance = 120.0, -- size of the distance from the outer zone
        deleteAll = false, -- deletes all objects in the zone. 
        objects = { -- objects in the list will be deleted.
            {
                model = `mp005_s_awb_cr`,
                coords = vec3(-852.358215,-1223.754028,43.450001),
                distance = 5.0
            },
        },
    },
     {
        name = "bw2_2", -- name of the zone
        thickness = 40, -- height
        point = glm.polygon.new(
            {
                vec3(-845.5059204101562, -1182.8936767578125, 42.98),
                vec3(-843.2038574218750, -1182.7655029296875, 42.98),
                vec3(-843.3109741210938, -1184.6219482421875, 42.98),
                vec3(-845.1417236328125, -1184.6546630859375, 42.98),
            }
        ),
        outerZone = nil, -- defines the outer zone. if nil, then it is generated automatically.
        outerZoneDistance = 120.0, -- size of the distance from the outer zone
        deleteAll = false, -- deletes all objects in the zone. 
        objects = { -- objects in the list will be deleted.
            {
                model = `mp005_s_cardt_qus`,
                coords = vec3(-844.307617,-1183.770996,43.381001),
                distance = 5.0
            },
        },
    },
}