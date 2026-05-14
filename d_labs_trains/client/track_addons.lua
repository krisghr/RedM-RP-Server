local RailroadSwitchSpooni = {
    -- new spooni01
    [1] = {coords = vec3(-948.539978, -636.039978, 72.040001), Index = -705539859, switch = 3, default = 0},
    [2] = {coords = vec3(-1049.660034, -613.780029, 75.739998), Index = -705539859, switch = 4, default = 1},
    -- spooni02
    [3] = {coords = vec3(-1008.159973, -699.150024, 65.419998), Index = -1940325321, switch = 1, default = 0},
    [4] = {coords = vec3(-1007.859985, -1001.849976, 60.419998), Index = -1940325321, switch = 2, default = 1},
    [5] = {coords = vec3(-953.760010, -1110.369995, 52.209999), Index = -1940325321, switch = 3, default = 0},
    -- trains_old_west01
	[6] = {coords = vec3(-1627.420044, -2326.340088, 44.330002), Index = -988268728, switch = 2, default = 1},
    -- trains_old_west02
    [7] = {coords = vec3(-2510.020020, -2372.770020, 60.020000), Index = -1763976500, switch = 2, default = 1},
    -- spooni03
    [8] = {coords = vec3(-1062.650024, -1087.280029, 60.799999), Index = 1983893509, switch = 1, default = 1},
    -- freight_group fix
    [9] = {coords = vec3(-1307.260010, -291.260010, 100.098000), Index = -705539859, switch = 5, default = 0},
    [10] = {coords = vec3(-1375.640015, -137.359009, 100.038002), Index = -705539859, switch = 6, default = 1},
}

local state = GetResourceState("spooni_railroad")

if Config.SpooniMap or state then
    for _, extraSwitch in pairs(RailroadSwitchSpooni) do
		extraSwitch.text = 'spooni '..tostring(_)
        table.insert(Config.RailroadSwitch, extraSwitch)
    end
end

