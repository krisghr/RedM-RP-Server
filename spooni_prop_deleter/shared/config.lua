Config = {}

Config.DevMode = false  -- use true to see the Zones perfect to setup!!
Config.DevModePrints = false -- use (in combination with Config.DevMode) if you need to print (F8 Console) objects in the current zone you are in

local glm = require "glm"

Config.Zones = {
    {
        name = "Test Zone 1", -- name of the zone
        thickness = 30, -- height
        point = glm.polygon.new(
            {
                vec3(1692.9720, 1515.1825, 146.7975),
                vec3(1704.1654, 1517.1525, 147.3378),
                vec3(1706.8220, 1504.2797, 147.2289),
                vec3(1695.7625, 1501.8347, 146.8122),
            }
        ),
        outerZone = nil, -- defines the outer zone. if nil, then it is generated automatically.
        outerZoneDistance = 200.0, -- size of the distance from the outer zone
        deleteAll = false, -- deletes all objects in the zone. 
        objects = {
            {
                model = `p_bucket03x`,
                coords = vec3(1696.617065,1510.103149,146.860840),
                distance = 0.1,
            },
            {
                model = `p_chairrustic05x`,
                coords = vec3(1696.220459,1510.834839,146.841904),
                distance = 0.1,
            },
            {
                model = `p_chair05x`,
                coords = vec3(1696.193359,1511.991333,146.861313),
                distance = 0.1,
            },
            {
                model = `p_chair_barrel04b`,
                coords = vec3(1696.008545,1512.880737,146.856064),
                distance = 0.1,
            },
            {
                model = `p_bucket03x`,
                coords = vec3(1696.617065,1510.103149,146.860840),
                distance = 0.1,
            },
            {
                model = `p_chairrustic05x`,
                coords = vec3(1696.220459,1510.834839,146.841904),
                distance = 0.1,
            },
            {
                model = `p_chair05x`,
                coords = vec3(1696.193359,1511.991333,146.861313),
                distance = 0.1,
            },
            {
                model = `p_chair_barrel04b`,
                coords = vec3(1696.008545,1512.880737,146.856064),
                distance = 0.1,
            },
            {
                model = `p_treestump02x`,
                coords = vec3(1694.044189,1514.516968,145.801254),
                distance = 0.1,
            },
            {
                model = `p_bottlemedicine14x`,
                coords = vec3(1702.295898,1510.230591,147.504974),
                distance = 0.1,
            },
            {
                model = `p_bottlemedicine08x`,
                coords = vec3(1702.298706,1510.109131,147.308701),
                distance = 0.1,
            },
            {
                model = `p_mugcoffee01x`,
                coords = vec3(1702.441895,1510.182617,147.308289),
                distance = 0.1,
            },
            {
                model = `p_stool08x`,
                coords = vec3(1702.356567,1510.192871,146.855850),
                distance = 0.1,
            },
            {
                model = `p_chair17x`,
                coords = vec3(1697.789185,1510.845215,146.861298),
                distance = 0.1,
            },
            {
                model = `p_bookbible01x`,
                coords = vec3(1697.391724,1511.233154,147.720673),
                distance = 0.1,
            },
        }
    },
    {
        name = "Test Zone 2", -- name of the zone
        thickness = 30, -- height
        point = glm.polygon.new(
            {
                vec3(-2423.80224609375, -2453.997802734375, 59.17021560668945),
                vec3(-2419.6220703125, -2452.68408203125, 59.17019653320312),
                vec3(-2418.694091796875, -2458.322509765625, 59.17019271850586),
                vec3(-2423.198974609375, -2458.956787109375, 59.17021560668945),
            }
        ),
        outerZone = nil, -- defines the outer zone. if nil, then it is generated automatically.
        outerZoneDistance = 200.0, -- size of the distance from the outer zone
        deleteAll = false, -- deletes all objects in the zone. 
        objects = { -- objects in the list will be deleted.
            {
                model = `p_haypile02x`,
                coords = vec3(-2421.014404, -2455.576416, 59.151508),
                distance = 2.0
            },
        },
    },
    {
        name = "Test Zone 3", -- name of the zone
        thickness = 30, -- height
        point = glm.polygon.new(
            {
                vec3(-2405.931884765625, -2475.120849609375, 59.17025375366211),
                vec3(-2404.94970703125, -2478.607177734375, 59.17025375366211),
                vec3(-2408.896240234375, -2478.99462890625, 59.17025375366211),
                vec3(-2409.012939453125, -2475.275146484375, 59.17025375366211),
            }
        ),
        outerZone = nil, -- defines the outer zone. if nil, then it is generated automatically.
        outerZoneDistance = 200.0, -- size of the distance from the outer zone
        deleteAll = false, -- deletes all objects in the zone. 
        objects = { -- objects in the list will be deleted.
	        {
                model = `p_haypile02x`,
                coords = vec3(-2406.086426,-2477.229492,59.151531),
                distance = 3.0
	        },
        },
    },
    {
        name = "Test Zone 4", -- name of the zone
        thickness = 30, -- height
        point = glm.polygon.new(
            {
                vec3(-2394.2939453125, -2449.80859375, 59.17025375366211),
                vec3(-2404.87353515625, -2454.964599609375, 59.17025375366211),
                vec3(-2395.721435546875, -2478.46826171875, 59.17025375366211),
                vec3(-2383.312744140625, -2475.328125, 59.17025375366211),
            }
        ),
        outerZone = glm.polygon.new(
            {
                vec3(-2379.6792, -2437.4609, 59.17025375366211),
                vec3(-2368.4719, -2478.2317, 59.17025375366211),
                vec3(-2399.7800, -2490.1370, 59.17025375366211),
                vec3(-2419.9543, -2456.3530, 59.17025375366211),
            }
        ), -- defines the outer zone. if nil, then it is generated automatically.
        outerZoneDistance = 200.0, -- size of the distance from the outer zone
        deleteAll = false, -- deletes all objects in the zone. 
        objects = { -- objects in the list will be deleted.
            {
                model = `p_rake03x`,
                coords = vec3(-2391.062012,-2463.952637,60.371635),
                distance = 1.0
            },
            {
                model = `mp005_s_cardt_knp`,
                coords = vec3(-2398.913086,-2469.836914,59.930000),
                distance = 1.0
            },
            {
                model = `p_lantern05x`,
                coords = vec3(-2399.306641,-2460.058838,61.375420),
                distance = 1.0
            },
            {
                model = `p_lantern05x`,
                coords = vec3(-2391.044678,-2468.174561,61.375961),
                distance = 1.0
            },
            {
                model = `p_door33x`,
                coords = vec3(-2391.706543,-2473.809082,59.170910),
                distance = 1.0
            },
            {
                model = `p_pitchfork01x`,
                coords = vec3(-2390.501465,-2474.106445,59.169605),
                distance = 1.0
            },
        },
    },
}