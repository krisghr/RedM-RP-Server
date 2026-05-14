Config.RailroadSwitch = {
	[1] = {coords = vec3(-4951.810059, -3083.800049, -18.432350), Index = -1467515357, switch = 5, default = 1},
	[2] = {coords = vec3(-4916.560059, -3009.530029, -19.181700), Index = -1467515357, switch = 0, default = 0}, 
	[3] = {coords = vec3(-2214.409912, -2519.540039, 64.876297), Index = -1763976500, switch = 1, default = 0},

	[4] = {coords = vec3(1529.939941, 467.528992, 89.380096), Index = -760570040, switch = 1, default = 0},
	[5] = {coords = vec3(1407.040039, -150.350998, 92.394096), Index = -760570040, switch = 2, default = 1},
	[6] = {coords = vec3(2464.550049, -1475.739990, 45.139702), Index = -760570040, switch = 5, default = 0}, 

	[7] = {coords = vec3(2748.469971, -1434.329956, 45.019199), Index = -1242669618, switch = 1, default = 1},
	[8] = {coords = vec3(2654.199951, -1477.180054, 44.931549), Index = -1242669618, switch = 2, default = 0}, 
	[9] = {coords = vec3(2624.159912, -1477.199951, 45.153500), Index = -1242669618, switch = 3, default = 0},

	[10] = {coords = vec3(1692.859985, 544.328979, 97.763603), Index = 1499637393, switch = 1, default = 0}, 
	[11] = {coords = vec3(1481.540039, 648.330994, 91.457298), Index = 1499637393, switch = 2, default = 1},
	[12] = {coords = vec3(613.963013, 683.593018, 114.516998), Index = 1499637393, switch = 3, default = 0}, 
	[13] = {coords = vec3(357.959015, 596.374023, 114.842003), Index = 1499637393, switch = 4, default = 1},
	[14] = {coords = vec3(31.404600, -29.329599, 102.485001), Index = 1499637393, switch = 5, default = 0}, 
	[15] = {coords = vec3(-281.054993, -319.609497, 88.183098), Index = -705539859, switch = 2, default = 0}, 
	[16] = {coords = vec3(-884.841980, -625.794983, 71.362099), Index = -705539859, switch = 3, default = 0},
	[17] = {coords = vec3(-1307.260010, -291.260010, 100.096001), Index = -705539859, switch = 4, default = 0},
	[18] = {coords = vec3(-1375.640015, -137.358002, 100.036003), Index = -705539859, switch = 5, default = 1},
	[19] = {coords = vec3(556.650024, 1725.989990, 186.968002), Index = -705539859, switch = 7, default = 1},
	[20] = {coords = vec3(610.219971, 1662.170044, 186.542999), Index = -705539859, switch = 8, default = 0},
	[21] = {coords = vec3(2260.229980, 1953.540039, 182.067001), Index = -705539859, switch = 9, default = 1},
	[22] = {coords = vec3(3032.639893, 1482.219971, 48.736801), Index = -705539859, switch = 10, default = 1},
	[23] = {coords = vec3(2873.649902, 1199.609985, 44.211201), Index = -705539859, switch = 11, default = 0}, 
	[24] = {coords = vec3(2659.790039, -435.710999, 42.565899), Index = -705539859, switch = 13, default = 0}, 
	[25] = {coords = vec3(2855.280029, -1314.739990, 45.115700), Index = -705539859, switch = 15, default = 1},
	[26] = {coords = vec3(2842.429932, -1330.060059, 45.173801), Index = -705539859, switch = 16, default = 0},
	[27] = {coords = vec3(2765.399902, -1421.540039, 45.102551), Index = -705539859, switch = 17, default = 1},
	[28] = {coords = vec3(2588.540039, -1482.189941, 45.224098), Index = -705539859, switch = 18, default = 0},
	[29] = {coords = vec3(2520.459961, -1482.189941, 45.125401), Index = -705539859, switch = 19, default = 1}, 
	[30] = {coords = vec3(2461.610107, -1484.839966, 44.969501), Index = -705539859, switch = 26, default = 1},
	[31] = {coords = vec3(69.619400, -375.174011, 90.069099), Index = -705539859, switch = 1, default = 1},
	[32] = {coords = vec3(2940.860107, 1374.449951, 43.085899), Index = -154412807, switch = 1, default = 0},
 	[33] = {coords = vec3(2885.570068, 1227.619995, 43.845001), Index = -154412807, switch = 2, default = 1},
	[34] = {coords = vec3(-4848.950195, -3086.330078, -16.587500), Index = -1763976500, switch = 6, default = 1},
}

for _, extraSwitch in pairs(RailroadSwitch.Extra) do
    table.insert(Config.RailroadSwitch, extraSwitch)
end



