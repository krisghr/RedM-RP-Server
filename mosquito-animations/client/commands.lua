if Config.RegularVORPMenuCommand then
	RegisterCommand(Config.RegularVORPMenuCommand, function()
		MenuData.CloseAll()
		openAnimationMenu()
	end, false)
end

RegisterCommand(Config.EmoteCommand, EmoteCommand)
RegisterCommand(Config.ScenarioCommand, ScenarioCommand)
RegisterCommand(Config.NativeEmoteCommand, NativeEmoteCommand)
if Config.SitLedgeCommand then
	RegisterCommand(Config.SitLedgeCommand, sitLedgeCommand)
end
if Config.SitBehindCommand then
	RegisterCommand(Config.SitBehindCommand, sitBehindCommand)
end


RegisterCommand("PlayAnimation", function(source, args, rawCommand)
	local dict = args[1]
	local name = args[2]
	local flag = tonumber(args[3]) or 1
	if not DoesAnimDictExist(dict) then
		return
	end

	RequestAnimDict(dict)

	while not HasAnimDictLoaded(dict) do
		Wait(0)
	end

	local ped = PlayerPedId()
	local ikFlag = tonumber(args[4]) or 0
	local Filter = args[5] or ""

	TaskPlayAnim(ped, dict, name, 1.0, -1.0, duration or -1, flag, 0.0, false, ikFlag, false, Filter, false)

	RemoveAnimDict(dict)
end, false)

local Scenarios = {
	"GENERIC_SEAT_BENCH_SCENARIO",
	"GENERIC_SEAT_CHAIR_SCENARIO",
	"GENERIC_SEAT_CHAIR_TABLE_SCENARIO",
	"MP_LOBBY_PROP_HUMAN_SEAT_BENCH_PORCH_DRINKING",
	"MP_LOBBY_PROP_HUMAN_SEAT_BENCH_PORCH_SMOKING",
	"MP_LOBBY_PROP_HUMAN_SEAT_CHAIR",
	"MP_LOBBY_PROP_HUMAN_SEAT_CHAIR_KNIFE_BADASS",
	"MP_LOBBY_PROP_HUMAN_SEAT_CHAIR_WHITTLE",
	"PROP_CAMP_FIRE_SEAT_CHAIR",
	"PROP_HUMAN_CAMP_FIRE_SEAT_BOX",
	"PROP_HUMAN_SEAT_BENCH_CONCERTINA",
	"PROP_HUMAN_SEAT_BENCH_FIDDLE", -- female
	"PROP_HUMAN_SEAT_BENCH_JAW_HARP",
	"PROP_HUMAN_SEAT_BENCH_MANDOLIN",
	"PROP_HUMAN_SEAT_CHAIR_BANJO",
	"PROP_HUMAN_SEAT_CHAIR_CLEAN_SADDLE",
	"PROP_HUMAN_SEAT_CHAIR_CRAB_TRAP",
	"PROP_HUMAN_SEAT_CHAIR_CIGAR",
	"PROP_HUMAN_SEAT_CHAIR_GROOMING_GROSS",
	"PROP_HUMAN_SEAT_CHAIR_GROOMING_POSH",
	"PROP_HUMAN_SEAT_CHAIR_GUITAR",
	"PROP_HUMAN_SEAT_CHAIR_KNITTING",
	"PROP_HUMAN_SEAT_CHAIR_PORCH",
	"PROP_HUMAN_SEAT_CHAIR_READING",
	"PROP_HUMAN_SEAT_CHAIR_TABLE_DRINKING"
}

local FemaleCompatibleScenarios = {
	"GENERIC_SEAT_BENCH_SCENARIO",
	"GENERIC_SEAT_CHAIR_TABLE_SCENARIO",
	"MP_LOBBY_PROP_HUMAN_SEAT_BENCH_PORCH_DRINKING",
	"MP_LOBBY_PROP_HUMAN_SEAT_BENCH_PORCH_SMOKING",
	"MP_LOBBY_PROP_HUMAN_SEAT_CHAIR",
	"MP_LOBBY_PROP_HUMAN_SEAT_CHAIR_KNIFE_BADASS",
	"MP_LOBBY_PROP_HUMAN_SEAT_CHAIR_WHITTLE",
	"PROP_CAMP_FIRE_SEAT_CHAIR",
	"PROP_HUMAN_CAMP_FIRE_SEAT_BOX",
	"PROP_HUMAN_SEAT_BENCH_FIDDLE",
	"PROP_HUMAN_SEAT_CHAIR_CLEAN_SADDLE",
	"PROP_HUMAN_SEAT_CHAIR_GROOMING_POSH",
	"PROP_HUMAN_SEAT_CHAIR_KNITTING",
	"PROP_HUMAN_SEAT_CHAIR_PORCH",
	"PROP_HUMAN_SEAT_CHAIR_READING",
	"PROP_HUMAN_SEAT_CHAIR_TABLE_DRINKING"
}

local MaleCompatibleScenarios = {
	"EA_WORLD_HUMAN_PICKAXE_NEW_WORKING",
	"GENERIC_SEAT_BENCH_SCENARIO",
	"GENERIC_SEAT_CHAIR_SCENARIO",
	"GENERIC_SEAT_CHAIR_TABLE_SCENARIO",
	"MP_LOBBY_PROP_HUMAN_SEAT_BENCH_PORCH_DRINKING",
	"MP_LOBBY_PROP_HUMAN_SEAT_BENCH_PORCH_SMOKING",
	"MP_LOBBY_PROP_HUMAN_SEAT_CHAIR",
	"MP_LOBBY_PROP_HUMAN_SEAT_CHAIR_KNIFE_BADASS",
	"MP_LOBBY_PROP_HUMAN_SEAT_CHAIR_WHITTLE",
	"PROP_CAMP_FIRE_SEAT_CHAIR",
	"PROP_HUMAN_CAMP_FIRE_SEAT_BOX",
	"PROP_HUMAN_SEAT_BENCH_CONCERTINA",
	"PROP_HUMAN_SEAT_BENCH_JAW_HARP",
	"PROP_HUMAN_SEAT_BENCH_MANDOLIN",
	"PROP_HUMAN_SEAT_CHAIR_BANJO",
	"PROP_HUMAN_SEAT_CHAIR_CLEAN_SADDLE",
	"PROP_HUMAN_SEAT_CHAIR_CRAB_TRAP",
	"PROP_HUMAN_SEAT_CHAIR_CIGAR",
	"PROP_HUMAN_SEAT_CHAIR_GROOMING_GROSS",
	"PROP_HUMAN_SEAT_CHAIR_GUITAR",
	"PROP_HUMAN_SEAT_CHAIR_PORCH",
	"PROP_HUMAN_SEAT_CHAIR_TABLE_DRINKING"
}

local function ResetPlayerPosition()
	local ped = PlayerPedId()
	if IsPedUsingAnyScenario(ped) then
		ClearPedTasks(ped)
		PlaceObjectOnGroundProperly(PlayerPedId())
	end
end

local function ResetThreadIfStopped(scenario)
	local ped = PlayerPedId()
	local scenarioHash = GetHashKey(scenario)
	CreateThread(function()
		while true do
			if IsPedUsingThisScenario(ped, scenarioHash) then
				Wait(0)
			else
				ClearPedTasks(ped)
				PlaceObjectOnGroundProperly(ped)
				return
			end
		end
	end)
end

function IsWeaponModel(modelHash)
	-- List of known weapon model hashes
	local weaponModels = {
		GetHashKey("w_dis_pis_mauser01"),
		GetHashKey("w_dis_pis_semiauto01"),
		GetHashKey("w_dis_pistol_derringer01"),
		GetHashKey("w_dis_pis_volcanic01"),
		GetHashKey("w_dis_rep_carbine01_1"),
		GetHashKey("w_dis_rep_henry01"),
		GetHashKey("w_dis_rep_pumpaction01"),
		GetHashKey("w_dis_rep_winchester01"),
		GetHashKey("w_dis_rev_cattleman01_2"),
		GetHashKey("w_dis_rev_doubleaction01"),
		GetHashKey("w_dis_rev_lemat01"),
		GetHashKey("w_dis_rev_schofield01"),
		GetHashKey("w_dis_rif_blunderbuss01"),
		GetHashKey("w_dis_rif_boltaction01"),
		GetHashKey("w_dis_rif_buffalo01"),
		GetHashKey("w_dis_rif_carcano01"),
		GetHashKey("w_dis_rif_elephant01"),
		GetHashKey("w_dis_rif_rollingblock01"),
		GetHashKey("w_dis_rif_springfield01"),
		GetHashKey("w_dis_sho_doublebarrel01"),
		GetHashKey("w_dis_sho_pumpaction01"),
		GetHashKey("w_dis_sho_repeating01"),
		GetHashKey("w_dis_sho_sawed01"),
		GetHashKey("w_dis_sho_semiauto01"),

		GetHashKey("w_electricfielddetector01"),
		GetHashKey("w_leftshoulder_strap01"),
		GetHashKey("w_melee_brassknuckles01"),
		GetHashKey("w_melee_tomahawk01"),
		GetHashKey("w_melee_tomahawk02"),
		GetHashKey("w_melee_tomahawk03"),
		GetHashKey("w_melee_tomahawk04"),
		GetHashKey("w_mp_bowarrow_arrow_tracking"),

		GetHashKey("w_pistol_m189902"),
		GetHashKey("w_pistol_mauser01"),
		GetHashKey("w_pistol_mauser02"),
		GetHashKey("w_pistol_semiauto01"),
		GetHashKey("w_pistol_volcanic01"),
		GetHashKey("w_pistol_volcanic03"),
		GetHashKey("w_repeater_carbine01"),
		GetHashKey("w_repeater_evans01"),
		GetHashKey("w_repeater_henry01"),
		GetHashKey("w_repeater_pumpaction01"),
		GetHashKey("w_repeater_winchester01"),
		GetHashKey("w_repeater_winchester03"),
		GetHashKey("w_revolver_cattleman01"),
		GetHashKey("w_revolver_cattleman02"),
		GetHashKey("w_revolver_cattleman03"),
		GetHashKey("w_revolver_doubleaction01"),
		GetHashKey("w_revolver_doubleaction02"),
		GetHashKey("w_revolver_doubleaction03"),
		GetHashKey("w_revolver_doubleaction04"),
		GetHashKey("w_revolver_doubleaction06"),
		GetHashKey("w_revolver_lemat01"),
		GetHashKey("w_revolver_navy01"),
		GetHashKey("w_revolver_navy02"),
		GetHashKey("w_revolver_schofield01"),
		GetHashKey("w_revolver_schofield02"),
		GetHashKey("w_revolver_schofield03"),
		GetHashKey("w_revolver_schofield04"),
		GetHashKey("w_revolver_schofield05"),
		GetHashKey("w_rifle_boltaction01"),
		GetHashKey("w_rifle_boltaction03"),
		GetHashKey("w_rifle_carcano01"),
		GetHashKey("w_rifle_rollingblock01"),
		GetHashKey("w_rifle_rollingblock02"),
		GetHashKey("w_rifle_springfield01"),
		GetHashKey("w_shotgun_doublebarrel01"),
		GetHashKey("w_shotgun_doublebarrel02"),
		GetHashKey("w_shotgun_pumpaction01"),
		GetHashKey("w_shotgun_pumpaction03"),
		GetHashKey("w_shotgun_repeating01"),
		GetHashKey("w_shotgun_sawed01"),
		GetHashKey("w_shotgun_sawed03"),
		GetHashKey("w_shotgun_semiauto01"),
		GetHashKey("w_stick_dynamite01"),
		GetHashKey("w_throw_dynamite01"),
		GetHashKey("w_throw_lantern01"),
		GetHashKey("w_throw_molotov01"),
		GetHashKey("w_throw_poisonbottle01")
	}

	for _, weaponHash in ipairs(weaponModels) do
		if modelHash == weaponHash then
			return true
		end
	end

	return false
end

function RemoveAllAttachedProps(ped)
	local attachedObjects = GetGamePool('CObject') -- Get all objects in the game
	for _, object in ipairs(attachedObjects) do
		if IsEntityAttachedToEntity(object, ped) then
			local modelHash = GetEntityModel(object) -- Get the object's model hash
			if IsWeaponModel(modelHash) then
				print(string.format("Skipping weapon object: %s", modelHash))
			else
				print(string.format("Removing non-weapon object: %s", modelHash))
				DetachEntity(object, true, true)
				DeleteObject(object)
			end
		end
	end
end

RegisterCommand("removeprops", function()
	local playerPed = PlayerPedId()
	RemoveAllAttachedProps(playerPed)
	print("All attached props removed from your player.")
end)

if Config.Debug then
	RegisterCommand('ec', function()
		local ped = PlayerPedId()
		ClearPedTasks(ped)
		if IsPedUsingAnyScenario(ped) then
			Citizen.InvokeNative(0xFCCC886EDE3C63EC, ped, false, true, true)
		end
	end, false)
end
