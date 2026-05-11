Config = {}

Config.Framework = "vorp" -- Look at server/framework.lua to adjust it to your needs ("vorp" and "rsg" are added by default)
Config.Locale = "en" -- Used locale for translation (add your own files to locale/languages/) // Remember to name the file the same as the abbreviation used in this variable

Config.PopulationNPCs = { -- The list of NPCs that are placed to populate the area
    { model = "a_c_cat_01", modelOutfit = 3, position = vector4(-811.5399780273438, -1270.3499755859375, 49.2000015258789, 155), playScenario = "WORLD_ANIMAL_CAT_RESTING", collision = false, streamingRange = 30.0 },
	{ model = "a_c_cat_01", modelOutfit = 2, position = vector4(-815.40966796875, -1265.8109130859375, 47.74847106933594, -105.00000762939453), playScenario = "WORLD_ANIMAL_CAT_SITTING", collision = false, streamingRange = 30.0 },
	{ model = "a_c_cat_01", modelOutfit = 1, position = vector4(-809.25, -1268.43994140625, 47.2116325378418, -137.31671142578125), playScenario = "WORLD_ANIMAL_CAT_EATING", collision = false, streamingRange = 30.0 },
	{ model = "a_c_cat_01", modelOutfit = 2, position = vector4(-812.9299926757812, -1267.0799560546875, 47.23999862670898, 1.99999964237213), playScenario = "WORLD_ANIMAL_CAT_RESTING", collision = false, streamingRange = 30.0 },
	{ model = "a_c_chicken_01", modelOutfit = 0, position = vector4(-723.56884765625, -1294.40234375, 43.72498516845703, 52.27612686157226), playScenario = "WORLD_ANIMAL_CHICKEN_EATING", collision = false, streamingRange = 200.0 },
	{ model = "a_c_cat_01", modelOutfit = 1, position = vector4(-727.25, -1300.780029296875, 46.14999847412109, 85.18761444091797), playScenario = "WORLD_ANIMAL_CAT_SITTING", collision = false, streamingRange = 200.0 },
	{ model = "a_c_rat_01", modelOutfit = 1, position = vector4(-740.77001953125, -1324.9173583984375, 43.86584945678711, 69.10554504394531), playScenario = "WORLD_ANIMAL_RAT_EATING", collision = true, streamingRange = 30.0 },
	{ model = "a_m_m_blwtownfolk_01", modelOutfit = 4, position = vector4(-807.8309326171875, -1222.415771484375, 42.58917617797851, -126.27631378173828), playScenario = "WORLD_HUMAN_BROOM", collision = true, streamingRange = 200.0 },
	{ model = "a_m_m_blwtownfolk_01", modelOutfit = 17, position = vector4(-734.39697265625, -1315.351806640625, 43.73444366455078, -122.99999237060547), playScenario = "WORLD_HUMAN_BROOM", collision = true, streamingRange = 200.0 },
	{ model = "a_c_dogchesbayretriever_01", modelOutfit = 1, position = vector4(-760.3200073242188, -1324.8699951171875, 42.72493896484375, -50.99998092651367), playScenario = "WORLD_ANIMAL_DOG_SITTING", collision = false, streamingRange = 30.0 },
	{ model = "a_c_alligator_01", modelOutfit = 1, position = vector4(-795.1900024414062, -1223.8699951171875, 35.19999847412109, 4.99999952316284), playScenario = false, collision = true, streamingRange = 20.0 },
	{ model = "a_c_rat_01", modelOutfit = 2, position = vector4(-770.8497924804688, -1215.0791015625, 34.62999862670898, -168.4935760498047), playScenario = "WORLD_ANIMAL_RAT_EATING", collision = true, streamingRange = 30.0 },
	{ model = "a_c_rat_01", modelOutfit = 2, position = vector4(-807.4, -1213.1300048828125, 36.43593048095703, -89.9999771118164), playScenario = "WORLD_ANIMAL_RAT_EATING", collision = true, streamingRange = 30.0 },
	{ model = "a_c_rat_01", modelOutfit = 1, position = vector4(-793.8736572265625, -1202.9239501953125, 36.61204711914062, 50), playScenario = false, collision = true, streamingRange = 30.0 },
	{ model = "a_c_rat_01", modelOutfit = 1, position = vector4(-780.660400390625, -1314.9000244140625, 42.62599862670898, -50), playScenario = "WORLD_ANIMAL_RAT_EATING", collision = true, streamingRange = 30.0 },
	{ model = "a_c_pig_01", modelOutfit = 1, position = vector4(-944.6199951171875, -1321.949951171875, 52.7260954284668, 26.99999809265136), playScenario = "WORLD_ANIMAL_PIG_GRAZING", collision = false, streamingRange = 30.0 },
	{ model = "a_c_pig_01", modelOutfit = 2, position = vector4(-945.3410034179688, -1324.274169921875, 52.69613098144531, 131.8378143310547), playScenario = "WORLD_ANIMAL_PIG_ROLL_MUD", collision = false, streamingRange = 30.0 },
	{ model = "a_c_pig_01", modelOutfit = 3, position = vector4(-942.8599853515625, -1328.1700439453125, 52.68515609741211, 173.99998474121094), playScenario = "WORLD_ANIMAL_PIG_SLEEPING", collision = false, streamingRange = 30.0 },
	{ model = "a_c_seagull_01", modelOutfit = 2, position = vector4(-724.47998046875, -1251.0699462890625, 45.68, 37.99576187133789), playScenario = "WORLD_ANIMAL_SEAGULL_ON_PERCH", collision = false, streamingRange = 200.0 }
}

Config.Vault = {
	KeypadPositionRange = 1.0, -- Range for using the vaults keypad
	KeypadUseKey = 0xA1ABB953, -- Key for using the vaults keypad
	
	KeyChangeJobs = false, -- Do you want to job-lock the function to change the vaults code (* Button on the keypad)? (false to deactivate or a table containing job-name and rank, like {["bankbw"]=0, ["sheriffbw"] = 0})
	AlarmManagementJobs = false, -- Do you want to job-lock the function to reset the vaults alarm (# Button on the keypad)? (false to deactivate or a table containing job-name and rank, like {["bankbw"]=0, ["sheriffbw"] = 0})
	AlarmPositions = {
		{-850.653564453125, -1234.110595703125, 45.2377700805664}, -- Bank-Office
		{-845.2830200195312, -1235.56494140625, 51.18049240112305}, -- Bank Outside
	},
	AlarmDuration = 600 -- Duration of the alarms sound in seconds
}