 
Config = {}

Config.Debug = {
	print = false,
	control = false,
	cancel = false,
}
 
-- 									If "DEBUG" control and cancel is enabled, the overheat train 
-- 									option is disabled and you can 
--									use the up arrow keys to select maximum speed and 
-- 									use the down arrow key to instantly stop again.
-- 									and the boiler can't overheat

Config.Server = { 
	Language = 'en',				-- the language that is used in Config.Texts
	NotifCustom = false,			-- if you want to use custom notifications in client_open.lua
	CustomFramework = false,    	-- dif the framework doesn't load correctly it can be set here manually
	NewFramework = false,			-- http://www.d-labs.site/docs/advantages/framework
	AutoInsertSQL = true,			-- the database should be set automatically 
	MetaTarget = false, 			-- true = use target (auto-detected - currently supported: ox_target), jdi do client_open.lua pro více informaci
	logs = false, 					-- webhook: false = off, 'https://...' = single webhook, {'https://...', 'https://...'} = multiple webhooks
}

Config.CustomStash = false

Config.job = {
    name = false,    		-- The job(s) allowed to access the faction. If set to "false", any job can perform the job. Can be a {'train_job', 'train_job_2'},
    bossGrade = 0,             		-- Grade that will have access to refining and management reporting. (It is one rank higher, so if you set this number to 3 and the job also has rank 4, both will have access.)
	managmentSystem = true,	
	-- if you want the trains to work without shopping and just spawn, all boss functions will also be moved so that anyone who has a job can do them 

	-- 	The following is disabled. 
	-- 	- buying/selling trains 
	-- 	- train upgrades (all in the base) 
	-- 	- the ability to rename the train
		
	-- 	change 
	-- 	- Trains spawn straight away without having to deal with whether it is in the world or not
}

Config.HUD = {
	trainHudScale = 70, 					-- %  hud size
	trainHUDposition = 'bottom-middle',  	-- bottom-middle / bottom-left / bottom-right / middle-right / top-right / top-left / top-middle / left-middle
	opacity = 1.0,							-- Opacity train HUD
	menuPos = 'top-right',					-- menu location
	hudTick = 200, 							-- HUD update rate / the lower the value, the smoother the animations. Lowering it is not recommended, as it may cause stuttering.
	new = true,
}

Config.Ring = {                     -- 3D ring style 
    marker = 0x6903B113,            -- https://github.com/femga/rdr3_discoveries/blob/abb136bdaa71f18fc8a683b0b7d5699b7f4820f6/graphics/markers/marker_types.lua#L6
    scale = vec3(1.0,1.0,1.0),      -- Scale XYZ
    r = 120,                        -- [0 - 255]
    g = 0,                          -- [0 - 255]
    b = 0,                          -- [0 - 255]
    a = 100,                        -- [0 - 255]
}     

Config.Switch = {
	-- A 3D marker that will appear on the switch at the moment of operation
	Ring = {                     		-- 3D ring style 
		enable = true,
		marker = 0x94FDAE17,            -- https://github.com/femga/rdr3_discoveries/blob/abb136bdaa71f18fc8a683b0b7d5699b7f4820f6/graphics/markers/marker_types.lua#L6
		scale = vec3(1.0,1.0,1.0),      -- Scale XYZ
		r = 120,                        -- [0 - 255]
		g = 0,                          -- [0 - 255]
		b = 0,                          -- [0 - 255]
		a = 100,   
	},
	allowCycle = true, -- whether you want to be able to choose from nearby turnpipes; otherwise, the nearest one will be selected
}

Config.PromptDistance = 2.5

Config.DeleteTrainAfterDrop = false 	-- if you want the game that spawned the train to be removed from the world as a safety feature after the player falls 

-- list of keys here: https://github.com/mja00/redm-shit/blob/master/nuiweaponspawner/config.lua

Config.Prompt = {
	menu = 0xE30CD707, 				-- R
	sit =  0xCEFD9220,				-- E
	boiler = 0xE30CD707, 			-- R
	timetable = 0xE30CD707, 		-- R
	editTimetable = 0xF3830D8E,		-- J
	submitTelegram = 0xE30CD707, 	-- R
	openStash = 0xE30CD707,			-- R
	wagonBox = 0xF3830D8E,			-- J
	grabBox = 0xE30CD707,			-- R
	leftSwitch = 0xA65EBAB4,		-- Left Arrow
	rightSwitch = 0xDEB34313,		-- Right Arrow
	lockSpeed = 0xE30CD707, 		-- R
	relight = 0xD9D0E1C0,			-- Space
	whistle = 0x07CE1E61,			-- MOUSE1
	switchCycle = 0x05CA7C52,		-- Down Arrow
	loadCoal = 0x4BC9DABB,			-- N
}

Config.whistle = {
	enable = true, 						-- If it is false, it will use the default whistle function from RDR2
	whistleSequence = 'ACKNOWLEDGE' 	-- ACKNOWLEDGE, BACKING_UP, CROSSING, DANGER, MOVING, NEXT_STATION, PASSING
}

Config.Economics = {
	pricePerTow = 20,				-- $	-- The cost to retrieve the train from impound. Set to false to disable this feature.
	percentageSale = 60,			-- %  	-- The percentage of the purchase price refunded to the player when they sell the train (including upgrades).
	coalThrowingTime = {10000,10000},     -- s    -- The interval (in seconds) for how often coal needs to be thrown into the furnace.
	coalForThrowing = {0,0}, 		-- pcs  -- The approximate amount of coal consumed per throw (in pieces).
	coalTankMax = 200,				-- pcs  -- Maximum coal that the locomotive tender (per-train tank) can hold.
	coalLoadPerAction = 10,			-- pcs  -- How many coal pieces move from the player's inventory into the train tank per loading interaction.
	percentOverheat = 90, 			-- % 	-- The percentage of maximum speed at which the engine begins to overheat.
	overheatingLogic = 'low',		-- 'low' / 'medium' / 'high' -- The tolerance for overheating: 'low' (low tolerance), 'medium' (medium tolerance), or 'high' (high tolerance).
}

Config.WorldLore = {
	year = '1899',					-- the year shown next to timetable dates
	dateFormat = 'MM-DD',			-- order of date parts on the noticeboard: 'MM-DD' or 'DD-MM'
	yearPosition = 'after',			-- where year appears relative to the date: 'before' or 'after'
	SpeedUnitsMPH = true, 			-- KM/H or MPH
	currencySymbol = '$',			-- emblems of currency
}

Config.Sitting = true				-- if you want the script to replace the logic of sitting on the train
Config.PermissionDrive = false 		-- leave "true" if you want to prevent any person without a job from driving the train 
Config.StashLockOnJob = true		-- if can stash open only job 

Config.Item = {
	fuel = 'coal', 					-- name of item for train fuel
	cooling = 'water',				-- the name on the item to cooling, if you put "false" the item will not be required
}

-- it is always necessary to write what the upgrade does from the original train (the upgrade is not multiplied)
Config.Upgrade = {
	[1] = {
		stash = {maxweight = 100000, slots = 5},  	-- for REDEMRP_reboot is determined only by the maxweight // for VORP it is determined only by the slots 
		overheatingIncrease = false,
		speedIncrease = false,
		price = 100									-- upgrade price
	},
	[2] = {
		stash = {maxweight = 200000, slots = 20}, 
		overheatingIncrease = false,
		speedIncrease = 10, 		
		percentPrice = 10,  						-- % percentage of the original train price
	},
	[3] = {
		stash = {maxweight = 300000, slots = 10},  
		overheatingIncrease = 10,					-- %  // how much the chances of overheating are reduced
		speedIncrease = 20, 						-- MPH / Km/h
		percentPrice = 10,  		
	},
	[4] = {
		stash = {maxweight = 200000, slots = 20},
		overheatingIncrease = 10, 
		speedIncrease = 30, 	
		coalTankMax = 100, -- Config.Economics + coalTankMax
		percentPrice = 20,  		
	},
}

Config.Train = {
	[1] = {
		label = 'Locomotive', 		-- model name  
		model = 0x3260CE89,			-- model hash
		maxSpeed = 67, 				-- the maximum speed is 108 KM and 67 MPH
		stash = {maxweight = 500000, slots = 2}, -- for REDEMRP_reboot is determined only by the maxweight // for VORP it is determined only by the slots 
		price = 50, 				-- price
	},
	[2] = {
		label = 'SAE train',
		model = 0x3D72571D,
		maxSpeed = 30,
		stash = {maxweight = 100000, slots = 5}, 
		price = 200, 
	},
	[3] = {
		label = 'Lannahechee train',
		model = 0x0392C83A,
		maxSpeed = 30,
		stash = {maxweight = 100000, slots = 5},  
		price = 200, 
	},
	[4] = {
		label = 'CUR train',
		model = 0x4C9CCB22,
		maxSpeed = 30,
		stash = {maxweight = 100000, slots = 5}, 
		price = 200, 
	},
	[5] = {
		label = 'Special train',
		model = 519580241,
		maxSpeed = 30,
		stash = {maxweight = 100000, slots = 5}, 
		price = 200, 
	},
	[6] = {
		label = 'Coal train',
		model = 214708080,
		maxSpeed = 30,
		stash = {maxweight = 100000, slots = 5}, 
		price = 200, 
	},
	[7] = {
		label = 'Armored train',
		model = 218350989,
		maxSpeed = 30,
		stash = {maxweight = 100000, slots = 5}, 
		price = 200, 
	},
	[8] = {
		label = 'Bayou train',
		model = 0x5AA369CA,
		maxSpeed = 30,
		stash = {maxweight = 100000, slots = 5}, 
		price = 200, 
	},
	[9] = {
		label = 'Cornwall',
		model = 0x487B2BE7,
		maxSpeed = 30,
		stash = {maxweight = 100000, slots = 5}, 
		price = 200, 
	},
	[10] = {
		label = 'Pacific Union',
		model = 0xDA2EDE2F,
		maxSpeed = 30,
		stash = {maxweight = 100000, slots = 5}, 
		price = 200, 
	},
	[11] = {
		label = 'SAE Travel Train',
		model = 0x3ADC4DA9,
		maxSpeed = 30,
		stash = {maxweight = 100000, slots = 5}, 
		price = 200, 
	},
	[12] = {
		label = 'SAE Luxury Transport',
		model = 3442244769,
		maxSpeed = 30,
		stash = {maxweight = 100000, slots = 5}, 
		price = 200, 
	},
}

Config.Handcar = true				-- if you want to see the handcard in the menu 

Config.editTimetable = true			-- possibility to edit all boards in management

Config.Managment = { -- if you set false, disable this option -- Config.Managment = false
	[1] = vector4(-179.6730, 648.0475, 113.5711, 216.5815),
}

Config.allTimetable = {  -- if you set false, disable this option -- Config.allTimetable = false
	[1] = vector4(2692.5627, -1453.5532, 46.2691, 24.9977),
}

Config.Work = {						-- if you put -Config.Work = false- you disable the option to do import
	BoxMaxNumber = 3,  				-- how many boxes are spawned
	paymentForBox = false,			-- payment after delivery of each box
	distanceMultiplier = 1.1, 		-- 1.0. is off // price increase according to distance / If money (money = {0.1,0.2},) is less than 1, make it less than 1 and vice versa.
	forBossMoney = 0.5, 			-- the money the player receives from the contract * forBossMoney = is added to the boss menu
}

Config.TrainStations = {
	Valentine = {
		PosName = "Valentine",
		Model = "U_M_M_RhdTrainStationWorker_01", 
		Pos = vector4(-163.2767, 638.3493, 114.0909,149.3567),
		blip = {bliphash = -250506368, name = 'Train Station'}, -- if you want to disable blip, set 0 or false // other possible blips can be found here: (( https://github.com/femga/rdr3_discoveries/tree/22fa3103a803fb1a70feb61137ae08db3b09c192/useful_info_from_rpfs/textures/blips ))
		SellPoint = {
			money = {1,5}, 				-- minimum/maximum for base price + distance is added
			coords = vector3(-174.9261, 626.3090, 114.0321),
			spawnBox = vector4(-167.4731, 631.2678, 114.0821, 117.0369),
		},
		timetable = vector4(-178.5973, 623.1332, 114.0321, 40.5996) -- if you want to disable blip, set false
	},
	Saint_Denise = {
		PosName = "Saint Denise",
		Model = "U_M_M_RhdTrainStationWorker_01", 
		Pos = vector4(2734.3938, -1438.6351, 46.1782, 192.0867), 
		blip = {bliphash = -250506368, name = 'Train Station'},
		SellPoint = {
			money = {1,5},
			coords = vector3(2712.1125, -1449.0399, 46.2531),
			spawnBox = vector4(2721.4529, -1446.0479, 46.2798, 97.9693),
		},
		timetable = vector4(2690.4521, -1448.9301, 46.2728, 215.4100)
	},
	Armadillo = {
		PosName = "Armadillo",
		Model = "u_m_m_blwtrainstationworker_01", 
		Pos = vector4(-3746.0771, -2596.9485, -13.2609, 166.7392), 
		blip = {bliphash = -250506368, name = 'Train Station'},
		SellPoint = {
			money = {1,5},
			coords = vector3(-3734.4517, -2597.3787, -12.9171),
			spawnBox = vector4(-3739.3689, -2592.8030, -13.2276, 292.3721),
		},
		timetable = vector4(-3733.6855, -2605.9827, -12.9317, 293.8493)
	},
	Anesburg = {
		PosName = "Anesburg",
		Model = "s_m_m_trainstationworker_01", 
		Pos = vector4(2955.8801, 1287.0972, 44.6563, 220.9325), 
		blip = {bliphash = -250506368, name = 'Train Station'},
		SellPoint = {
			money = {1,5},
			coords = vector3(2939.9321, 1280.5576, 44.6376),
			spawnBox = vector4(2949.6519, 1279.9341, 44.6809, 93.8822),
		},
		timetable = vector4(2930.2139, 1279.9497, 44.6529, 247.6525)
	},
	Benedict = {
		PosName = "Benedict",
		Model = "u_m_o_rigtrainstationworker_01", 
		Pos = vector4(-5230.0562, -3466.9624, -20.5042, 93.4671), 
		blip = {bliphash = -250506368, name = 'Train Station'},
		SellPoint = {
			money = {1,5},
			coords = vector3(-5227.5034, -3470.6296, -20.565),
			spawnBox = vector4(-5230.0435, -3457.4919, -21.3746, 91.1455),
		},
		timetable = vector4(-5230.9536, -3470.7217, -20.5644, 269.7726)
	},
	Rhodes = {
		PosName = "Rhodes",
		Model = "U_M_M_RhdTrainStationWorker_01", 
		Pos = vector4(1212.7292, -1292.5000, 76.9095, 229.6887), 
		blip = {bliphash = -250506368, name = 'Train Station'},
		SellPoint = {
			money = {1,5},
			coords = vector3(1220.9806, -1286.0581, 76.8995),
			spawnBox = vector4(1219.7407, -1298.0535, 76.9489, 230.9606),
		},
		timetable = vector4(1233.8535, -1293.7489, 76.9034, 312.8377)
	},
	Wallace = {
		PosName = "Wallace",
		Model = "U_M_M_RhdTrainStationWorker_01", 
		Pos = vector4(-1312.0027, 391.8457, 95.3806, 357.4991), 
		blip = {bliphash = -250506368, name = 'Train Station'},
		SellPoint = {
			money = {1,5},
			coords = vector3(-1294.2218, 413.7724, 94.9545),
			spawnBox = vector4(-1314.4458, 385.1604, 95.5980, 153.9305),
		},
		timetable = vector4(-1300.7246, 402.8132, 95.3839, 154.6300)
	},
	McFarlane = {
		PosName = "McFarlane",
		Model = "U_M_M_RhdTrainStationWorker_01", 
		Pos = vector4(-2501.9470, -2415.8293, 60.5870, 129.5028), 
		blip = {bliphash = -250506368, name = 'Train Station'},
		SellPoint = {
			money = {1,5},
			coords = vector3(-2494.2217, -2424.3801, 60.5994),
			spawnBox = vector4(-2502.3276, -2409.6223, 60.2026, 330.1398),
		},
		timetable = false
	},
	emerald = {
		PosName = "Emerald",
		Model = "u_m_o_rigtrainstationworker_01", 
		Pos = vector4(1525.9584, 447.3514, 90.7307, 247.1653), 
		blip = {bliphash = -250506368, name = 'Train Station'},
		SellPoint = {
			money = {1,5}, 		
			coords = vector3(1521.1963, 446.7019, 90.7307),
			spawnBox = vector4(1524.0227, 457.1273, 89.8633, 25.4772),
		},
		timetable = vector4(1519.3899, 441.0817, 90.7307, 276.8301)
	},
	riggs = {
		PosName = "Riggs Station",
		Model = "u_m_o_rigtrainstationworker_01", 
		Pos = vector4(-1099.2311, -578.5135, 82.4543, 323.9911), 
		blip = {bliphash = -250506368, name = 'Train Station'},
		SellPoint = {
			money = {1,5}, 		
			coords = vector3(-1092.7881, -573.4484, 85.5800),
			spawnBox = vector4(-1103.6278, -572.0865, 82.5061, 345.9977),
		},
		timetable = vector4(-1096.3286, -572.1810, 82.4459, 243.5255)
	},
}

Config.SEAT_PROP_HASHES = { -- (Model Hash)
    -810403717,
    876732623,
    -636146522,
    -570390444,
    1240962201, -- piano
}

Config.Texts = {
	['en'] = {
		TurnAround = '↪️ Turn Train',
		RemoveTrain = '🛖 Park Train',
		CancelMenu = '🔴 Cancel Job',
		trainList = '🚂 Train List',
		towLabel = '⚙️ Towed Trains',
		MenuTelegram  = '💼 Delivery',
		handcar = '🛞 Handcar',		
		bossMoney = 'Money in cash',
		bossMoneyDesc = 'Click to withdraw money',
		money = 'Money',
		TrainMenuTitle = 'Trains',
		SelectTrainDesc = 'Press to Select',
		upgrade = 'Upgrade',
		sellPrice = 'Selling Price:',
		stageZero = 'Stage 0 (No Upgrade)',
		activeStage = 'Active',
		stage = 'Stage',
		noUpgrade = 'Basic state without any upgrade',
		managmentTittle = 'Train Management',
		manageTimetable = 'Edit Timetables',
		manageDesc = 'Press to Select',
		stash = 'Stash',
		slots = 'Slots',
		model = 'Model',
		price = 'Price',
		speed = 'Speed',
		overheatedReducing = 'Overheat Resistance', 
		timetable = 'Timetables',
		renameTrain = 'Rename Train',
		sellTrain = 'Sell Train',
		buyTrain = 'Buy Train',
		upgradeTrain = 'Upgrade Train',
		allTimetable = 'All Timetables',
		allTimetableDesc = 'Select a station to see the departure board',
	
		log = {
			tow = 'Pulled from tow',
			trainOut = 'Train pulled out',
			park = 'Train parked',
			buy = 'Train purchased',
			sell = 'Train served',
			rename = 'Train renamed',
			upgrade = 'Upgraded train',
		},		
		notif = {
			noMoney = "You don't have enough money",
			noBoss = 'You don’t have the required permissions',
			renameError = 'You didn’t enter a valid value',
			noEmployee = 'What are you doing? I’m not giving you the train',
			noTrainFound = 'No train nearby',
			workCancel = 'You canceled the job',
			workHaveError = 'This train already has a job',
			upgradeError = 'You already have this upgrade',
			fuelRemove = '%d coal has been removed',
			noFuel = 'You don’t have the required fuel %d',
			overheat = 'The train has overheated, you need to cool it down',
			noCooling = 'You don’t have the items to cool it down',
			cooling = 'Cooling the train engine',
			Swapped = 'Switch changed',
			NoSwitch = 'No switch in sight',
			noJobForStash = 'You don’t have the required keys to open',
			trainIsOut = 'The train is already out',
			noJobTimetable = 'You do not have the necessary permissions for this manipulation',
			workCancelError = 'Could not cancel shipment',
			boxLoaded = 'You loaded the box',
			boxUnloaded = 'You unloaded the box',
			noBoxInHand = 'Where did you leave the box?',
			bossNoMoney = 'There is no money to withdraw',
			deleteTrainWork = 'The contract has been cancelled',
			noWorkCancel = 'There are no orders for the train',
			deliveryError = "You're not near any trains",
			noTrainInMenu = 'All trains are on tow or you have to buy them',
			noTrainInTow = 'no train is in tow',
		},
		nui = {
			emptyWatermark = 'Empty',
			date = 'Date',
			time = 'Time',
			content = 'From Station - To Station',
			price = 'Ticket Price',
			addRow = 'Add',
			save = 'Save',
			editRow = 'Add',
			repeatDaily = 'Repeat Daily',
			placeholderContent = 'Enter description',
			placeholderPrice = 'Enter price',
			trainPrice = 'Price',
			trainSpeed = 'Speed',
			trainStash = 'Capacity',
			trainSize = 'Stash Size',
			buyButton = 'Buy',
			sendButton = 'Confirm',
			placeholder = 'Train name',
		},
		prompt = {
			descOpenMenu = 'Train Station',
			openMenu = 'Open',
			descTimetable = 'Train Noticeboard',
			descTimetableAll = 'Large Train Noticeboard',
			descManagment = 'Train Management',
			relight = 'Relight',
			lockSpeed = 'Lock Speed',
			unlockSpeed = 'Unlock Speed',
			leftSwitch = 'Left',
			rightSwitch = 'Right',
			descTrainStash = 'Train Storage',
			openStash = 'Open Storage',
			bag = 'Take/Place Bags',
			bagSubmit = 'Submit Bags',
			descPostOffice = 'Post Office',	
			descBoiler = 'Train Boiler',
			timetableInteraction = 'Open List', 
			timetableOpen = 'View Noticeboard',
			editTimetable = 'Edit Noticeboard',
			repairBoiler = 'Cool Down',
			sit = 'Seat',
			descSit = 'Chair',
			box = 'Box',
			boxDesc = 'Cargo for the train',
			putUp = 'Pick up',
			whistle = 'Use whistle',
			loadCoal = 'Load Coal',
			descLoadCoal = 'Locomotive Tender',
			loadCoalNotif = 'Coal loaded: %s/%s',
			loadCoalFail = 'Cannot load coal (no coal in inventory or tank full).',
			loadCoalOccupied = 'The train must be secured — someone is at the controls.',
			passDoorIn  = 'Step inside',
			passDoorOut = 'Step outside',
			descFakeDoor = 'Door',
		},
	},
	['cs'] = {
		TurnAround = '↪️ Otočit vlak',
		RemoveTrain = '🛖 Zaparkovat vlak',
		CancelMenu = '🔴 Zrušit úkol',
		trainList = '🚂 Seznam vlaků',
		towLabel = '⚙️ Odtažené vlaky',
		MenuTelegram  = '💼 Doručení',
		handcar = '🛞 Ruční vozík',
		bossMoney = 'Peníze v kase',
		bossMoneyDesc = 'Klikněte pro vyběr peněz',
		money = 'Peníze',
		TrainMenuTitle = 'Vlaky',
		SelectTrainDesc = 'Stiskněte pro výběr',
		upgrade = 'Vylepšení',
		sellPrice = 'Prodejní cena:',
		stageZero = 'Fáze 0 (Bez vylepšení)',
		activeStage = 'Aktivní',
		stage = 'Fáze',
		noUpgrade = 'Základní stav bez vylepšení',
		managmentTittle = 'Správa vlaků',
		manageTimetable = 'Upravit jízdní řády',
		manageDesc = 'Stiskněte pro výběr',
		stash = 'Úložiště',
		slots = 'Sloty',
		model = 'Model',
		price = 'Cena',
		speed = 'Rychlost',
		overheatedReducing = 'Odolnost proti přehřátí',
		timetable = 'Jízdní řády',
		renameTrain = 'Přejmenovat vlak',
		sellTrain = 'Prodat vlak',
		buyTrain = 'Koupit vlak',
		upgradeTrain = 'Vylepšit vlak',
		allTimetable = 'Všechny jízdní řády',
		allTimetableDesc = 'Vyberte stanici pro zobrazení odjezdů',

		log = {
			tow = 'Vytaženo z odtahu',
			trainOut = 'Vlak vytažen',
			park = 'Vlak zaparkovaný',
			buy = 'Vlak koupený',
			sell = 'Vlak podaný',
			rename = 'Vlak přejmenovaný',
			upgrade = 'Vylepšil vlak',
		},


		notif = {
			noMoney = "Nemáte dostatek peněz",
			noBoss = 'Nemáte potřebná oprávnění',
			renameError = 'Nezadali jste platnou hodnotu',
			noEmployee = 'Co děláte? Nedám vám vlak',
			noTrainFound = 'V blízkosti není žádný vlak',
			workCancel = 'Zrušili jste úkol',
			workHaveError = 'Tento vlak již má úkol',
			upgradeError = 'Toto vylepšení již máte',
			fuelRemove = 'Bylo odebráno %d uhlí',
			noFuel = 'Nemáte potřebné palivo %d',
			overheat = 'Vlak se přehřál, musíte ho ochladit',
			noCooling = 'Nemáte potřebné předměty na ochlazení',
			cooling = 'Ochlazování motoru vlaku',
			Swapped = 'Přepínač změněn',
			NoSwitch = 'Žádný přepínač na dohled',
			noJobForStash = 'Nemáte potřebné klíče k otevření',
			trainIsOut = 'Vlak je již venku',
			noJobTimetable = 'Nemáte potřebná oprávnění pro tuto manipulaci',
			workCancelError = 'Nepodařilo se zrušit zásilku',
			boxLoaded = 'Naložili jste bednu',
			boxUnloaded = 'Vyložili jste bednu',
			noBoxInHand = 'Kde jsi zapoměl krabici?',
			bossNoMoney = 'Žadné peníze pro vyběr tu nejsou',
			deliveryError = 'Nejsi blízko žadného vlaku',
			deleteTrainWork = 'tento vlak veze zakázku, nejdřív ji musí zrušit',
			noWorkCancel = 'Na vlak není žadná zakázka',
			noTrainInMenu = 'Všechny vlaky jsou na vleku nebo si je musíte koupit',
			noTrainInTow = 'Žadný vlak není na odtahu',
		},
		nui = {
			emptyWatermark = 'Prázdné',
			date = 'Datum',
			time = 'Čas',
			content = 'Ze stanice - Do stanice',
			price = 'Cena jízdenky',
			addRow = 'Přidat',
			save = 'Uložit',
			editRow = 'Přidat',
			repeatDaily = 'Opakovat denně',
			placeholderContent = 'Zadejte popis',
			placeholderPrice = 'Zadejte cenu',
			trainPrice = 'Cena',
			trainSpeed = 'Rychlost',
			trainStash = 'Kapacita',
			trainSize = 'Velikost úložiště',
			buyButton = 'Koupit',
			sendButton = 'Potvrdit',
			placeholder = 'Název vlaku',
		},
		prompt = {
			descOpenMenu = 'Vlakové nádraží',
			openMenu = 'Otevřít',
			descTimetable = 'Vlaková vývěska',
			descTimetableAll = 'Velká vlaková vývěska',
			descManagment = 'Správa vlaků',
			relight = 'Znovu zapálit',
			lockSpeed = 'Uzamknout rychlost',
			unlockSpeed = 'Odemknout rychlost',
			leftSwitch = 'Doleva',
			rightSwitch = 'Doprava',
			descTrainStash = 'Úložiště vlaku',
			openStash = 'Otevřít úložiště',
			bag = 'Vezmi/Polož tašky',
			bagSubmit = 'Odevzdat tašky',
			descPostOffice = 'Pošta',
			descBoiler = 'Kotel vlaku',
			timetableInteraction = 'Otevřít seznam',
			timetableOpen = 'Zobrazit vývěsku',
			editTimetable = 'Upravit vývěsku',
			repairBoiler = 'Ochladit',
			sit = 'Sednout si',
			descSit = 'Židle',
			box = 'Bedna',
			boxDesc = 'Náklad do vlaku',
			putUp = 'Zvednout',
			whistle = 'Použít píštalu',
			loadCoal = 'Naložit uhlí',
			descLoadCoal = 'Zásobník lokomotivy',
			loadCoalNotif = 'Uhlí naloženo: %s/%s',
			loadCoalFail = 'Nelze naložit uhlí (chybí v inventáři nebo je zásobník plný).',
			loadCoalOccupied = 'Vlak musí být zajištěn — někdo je u řízení.',
			passDoorIn  = 'Dovnitř',
			passDoorOut = 'Ven',
			descFakeDoor = 'Dveře',
		},
	},
	
}


Config.SpooniMap = false
-- if you have a map spoiler, the map will be loaded automatically, this function is a backup if the file load fails.

-- ╔════════════════════════════════╗
-- ║   Thank you for purchasing     ║
-- ║          at D-Labs!            ║
-- ║         Visit us at:           ║
-- ║  https://discord.gg/zKBgmBPmyd ║
-- ╚════════════════════════════════╝