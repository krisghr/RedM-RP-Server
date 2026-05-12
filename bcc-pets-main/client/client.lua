local recentlySpawned = 0
local currentPetPed = nil
local ActivePets = {}
local ActivePetModes = {}
local sleep = 500
local SellPrice = 0
local targetSelectionActive = false
local targetSelectionPet = nil
local targetSelectionUntil = 0
local targetSelectionTeleport = false
local petMoveTarget = nil
local petPlacementConfig = (Config and Config.PetPlacement) or {}

-- MenuAPI
TriggerEvent("menuapi:getData",function(call)
    MenuData = call
end)
AddEventHandler('menuapi:closemenu', function() end)

-- VORP
local VORPcore = {}
TriggerEvent("getCore", function(core)
    VORPcore = core
end)

-- VORP Util
local VORPutils = {}
TriggerEvent("getUtils", function(utils)
    VORPutils = utils
end)

-- Functions
function SetPetAttributes(entity)
    -- | SET_ATTRIBUTE_POINTS | --
    Citizen.InvokeNative( 0x09A59688C26D88DF, entity, 0, 1100 )
    Citizen.InvokeNative( 0x09A59688C26D88DF, entity, 1, 1100 )
    Citizen.InvokeNative( 0x09A59688C26D88DF, entity, 2, 1100 )
    -- | ADD_ATTRIBUTE_POINTS | --
    Citizen.InvokeNative( 0x75415EE0CB583760, entity, 0, 1100 )
    Citizen.InvokeNative( 0x75415EE0CB583760, entity, 1, 1100 )
    Citizen.InvokeNative( 0x75415EE0CB583760, entity, 2, 1100 )
    -- | SET_ATTRIBUTE_BASE_RANK | --
    Citizen.InvokeNative( 0x5DA12E025D47D4E5, entity, 0, 10 )
    Citizen.InvokeNative( 0x5DA12E025D47D4E5, entity, 1, 10 )
    Citizen.InvokeNative( 0x5DA12E025D47D4E5, entity, 2, 10 )
    -- | SET_ATTRIBUTE_BONUS_RANK | --
    Citizen.InvokeNative( 0x920F9488BD115EFB, entity, 0, 10 )
    Citizen.InvokeNative( 0x920F9488BD115EFB, entity, 1, 10 )
    Citizen.InvokeNative( 0x920F9488BD115EFB, entity, 2, 10 )
    -- | SET_ATTRIBUTE_OVERPOWER_AMOUNT | --
    Citizen.InvokeNative( 0xF6A7C08DF2E28B28, entity, 0, 5000.0, false )
    Citizen.InvokeNative( 0xF6A7C08DF2E28B28, entity, 1, 5000.0, false )
    Citizen.InvokeNative( 0xF6A7C08DF2E28B28, entity, 2, 5000.0, false )
end

function SetPetBehavior(petPed)
	SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), GetHashKey('PLAYER'))
	SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), 143493179)
	SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -2040077242)
	SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), 1222652248)
	SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), 1077299173)
	SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -887307738)
	SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -1998572072)
	SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -661858713)
	SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), 1232372459)
	SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -1836932466)
	SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), 1878159675)
	SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), 1078461828)
	SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -1535431934)
	SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), 1862763509)
	SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -1663301869)
	SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -1448293989)
	SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -1201903818)
	SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -886193798)
	SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -1996978098)
	SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), 555364152)
	SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -2020052692)
	SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), 707888648)
	SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), 378397108)
	SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -350651841)
	SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -1538724068)
	SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), 1030835986)
	SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -1919885972)
	SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -1976316465)
	SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), 841021282)
	SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), 889541022)
	SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -1329647920)
	SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -319516747)
	SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -767591988)
	SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -989642646)
	SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), 1986610512)
	SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -1683752762)
end

function FollowOwner(Pet, PlayerPedId, isInShop)
	TaskFollowToOffsetOfEntity(Pet, PlayerPedId, 0.0, -1.5, 0.0, 1.0, -1,  Config.PetAttributes.FollowDistance * 100000000, 1, 1, 0, 0, 1)
	if isInShop then
		Citizen.InvokeNative(0x489FFCCCE7392B55, Pet, PlayerPedId)
	end
end

function LeadOwner(Pet, PlayerPedId)
	local playerCoords = GetEntityCoords(PlayerPedId)
	local forward = GetEntityForwardVector(PlayerPedId)
	local desiredLeadDistance = 6.0 -- keep pet in the 4-8 meter lead band
	local targetCoords = vector3(playerCoords.x + (forward.x * desiredLeadDistance), playerCoords.y + (forward.y * desiredLeadDistance), playerCoords.z)
	local petCoords = GetEntityCoords(Pet)
	local distToTarget = #(petCoords - targetCoords)

	if distToTarget > 1.25 then
		TaskGoToCoordAnyMeans(Pet, targetCoords.x, targetCoords.y, targetCoords.z, 3.0, 0, false, 0, 0.0)
	end
end

local function StartPetScenarioWithFallback(petPed, scenarios)
	for _, scenario in ipairs(scenarios) do
		ClearPedTasksImmediately(petPed)
		TaskStartScenarioInPlace(petPed, GetHashKey(scenario), -1, true, false, false, false)
		Wait(250)
		if IsPedUsingAnyScenario(petPed) then
			return true
		end
	end
	return false
end

local function GetClosestActivePet()
	local playerCoords = GetEntityCoords(PlayerPedId())
	local closestPet = nil
	local closestDistance = nil

	for _, pet in pairs(ActivePets) do
		if DoesEntityExist(pet) then
			local petCoords = GetEntityCoords(pet)
			local dist = #(playerCoords - petCoords)
			if closestDistance == nil or dist < closestDistance then
				closestDistance = dist
				closestPet = pet
			end
		end
	end

	return closestPet, closestDistance
end


local function TeleportPetToWaypoint()
	local closestPet, distance = GetClosestActivePet()
	if closestPet == nil then
		VORPcore.NotifyRightTip(_U("NoPetNearby"), 4000)
		return
	end

	if distance > 25.0 then
		VORPcore.NotifyRightTip(_U("PetTooFar"), 4000)
		return
	end

	ClearPedTasksImmediately(closestPet)
	FreezeEntityPosition(closestPet, false)
	RemovePedFromGroup(closestPet)
	targetSelectionActive = true
	targetSelectionPet = closestPet
	targetSelectionTeleport = true
	targetSelectionUntil = GetGameTimer() + (petPlacementConfig.selectionDurationMs or 15000)
	VORPcore.NotifyRightTip("Aim at the ground and left click to place pet.", 5000)
end

local function RotationToDirection(rotation)
	local rotZ = math.rad(rotation.z)
	local rotX = math.rad(rotation.x)
	local cosX = math.abs(math.cos(rotX))
	return vector3(-math.sin(rotZ) * cosX, math.cos(rotZ) * cosX, math.sin(rotX))
end

local function RaycastFromCamera(maxDistance)
	local camRot = GetGameplayCamRot(2)
	local camCoord = GetGameplayCamCoord()
	local direction = RotationToDirection(camRot)
	local destination = camCoord + (direction * maxDistance)
	local shapeTest = StartShapeTestRay(camCoord.x, camCoord.y, camCoord.z, destination.x, destination.y, destination.z, 17, PlayerPedId(), 7)
	local _, hit, endCoords = GetShapeTestResult(shapeTest)
	if hit == 1 then
		return true, endCoords
	end
	return false, destination
end

local function FacePetRelativeToPlayer(petPed, faceAway)
	local petCoords = GetEntityCoords(petPed)
	local playerCoords = GetEntityCoords(PlayerPedId())
	local directionX = playerCoords.x - petCoords.x
	local directionY = playerCoords.y - petCoords.y
	local heading = GetHeadingFromVector_2d(directionX, directionY)

	if faceAway then
		heading = (heading + 180.0) % 360.0
	end

	FreezeEntityPosition(petPed, true)
	TaskStandStill(petPed, -1)
	SetEntityHeading(petPed, heading)
end

local function HandlePetCommand(action)
	local closestPet, distance = GetClosestActivePet()
	if closestPet == nil then
		VORPcore.NotifyRightTip(_U("NoPetNearby"), 4000)
		return
	end

	if distance > 25.0 then
		VORPcore.NotifyRightTip(_U("PetTooFar"), 4000)
		return
	end

	ClearPedTasksImmediately(closestPet)
	if action ~= "leadahead" then
		ActivePetModes[closestPet] = nil
	end
	if action == "sit" then
		FreezeEntityPosition(closestPet, false)
		SetPedAsGroupMember(closestPet, GetPedGroupIndex(PlayerPedId()))
		TaskStartScenarioInPlace(closestPet, GetHashKey("WORLD_ANIMAL_DOG_SITTING"), -1, true, false, false, false)
		VORPcore.NotifyRightTip(_U("PetSit"), 4000)
	elseif action == "stay" then
		RemovePedFromGroup(closestPet)
		TaskStandStill(closestPet, -1)
		FreezeEntityPosition(closestPet, true)
		VORPcore.NotifyRightTip(_U("PetStay"), 4000)
	elseif action == "follow" then
		FreezeEntityPosition(closestPet, false)
		SetPedAsGroupMember(closestPet, GetPedGroupIndex(PlayerPedId()))
		FollowOwner(closestPet, PlayerPedId(), false)
		VORPcore.NotifyRightTip(_U("PetFollow"), 4000)
	elseif action == "laydown" then
		FreezeEntityPosition(closestPet, false)
		SetPedAsGroupMember(closestPet, GetPedGroupIndex(PlayerPedId()))
		local didLayDown = StartPetScenarioWithFallback(closestPet, {
			"WORLD_ANIMAL_DOG_LYING_DOWN",
			"WORLD_ANIMAL_DOG_SLEEPING_GROUND",
			"WORLD_ANIMAL_DOG_SLEEPING"
		})
		if didLayDown then
			VORPcore.NotifyRightTip(_U("PetLayDown"), 4000)
		else
			VORPcore.NotifyRightTip(_U("PetLayDownFailed"), 4000)
		end
	elseif action == "leadahead" then
		FreezeEntityPosition(closestPet, false)
		RemovePedFromGroup(closestPet)
		ActivePetModes[closestPet] = "leadahead"
		LeadOwner(closestPet, PlayerPedId())
		VORPcore.NotifyRightTip(_U("PetLeadAhead"), 4000)
	elseif action == "faceme" then
		FacePetRelativeToPlayer(closestPet, false)
		VORPcore.NotifyRightTip("Pet is facing you.", 4000)
	elseif action == "faceaway" then
		FacePetRelativeToPlayer(closestPet, true)
		VORPcore.NotifyRightTip("Pet is facing away from you.", 4000)
	elseif action == "gothere" then
		FreezeEntityPosition(closestPet, false)
		RemovePedFromGroup(closestPet)
		targetSelectionActive = true
		targetSelectionPet = closestPet
		targetSelectionTeleport = false
		targetSelectionUntil = GetGameTimer() + (petPlacementConfig.selectionDurationMs or 15000)
		VORPcore.NotifyRightTip("Aim at the ground and left click to set pet destination.", 5000)
	end
end

CreateThread(function()
	while true do
		if not targetSelectionActive then
			Wait(250)
		else
			Wait(0)
			if targetSelectionPet == nil or not DoesEntityExist(targetSelectionPet) or GetGameTimer() > targetSelectionUntil then
				targetSelectionActive = false
				targetSelectionPet = nil
				targetSelectionTeleport = false
				VORPcore.NotifyRightTip("Pet placement cancelled.", 3000)
			else
				local hasHit, targetCoords = RaycastFromCamera(petPlacementConfig.maxSelectionDistance or 75.0)
				DrawMarker(-1795314153, targetCoords.x, targetCoords.y, targetCoords.z + 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, petPlacementConfig.markerScale or 0.35, petPlacementConfig.markerScale or 0.35, petPlacementConfig.markerScale or 0.35, 255, 170, 0, 200, false, true, 2, false, nil, nil, false)
				if IsControlJustPressed(0, 0x07CE1E61) and hasHit then
					ClearPedTasksImmediately(targetSelectionPet)
					if targetSelectionTeleport then
						FreezeEntityPosition(targetSelectionPet, false)
						local foundGround, groundZ = GetGroundZAndNormalFor_3dCoord(targetCoords.x, targetCoords.y, targetCoords.z + 2.0)
						local safeZ = (foundGround and groundZ or targetCoords.z) + 0.45
						SetEntityCoordsNoOffset(targetSelectionPet, targetCoords.x, targetCoords.y, safeZ, false, false, true)
						TaskStandStill(targetSelectionPet, -1)
						FreezeEntityPosition(targetSelectionPet, true)
						VORPcore.NotifyRightTip("Pet teleported to selected location.", 4000)
					else
						TaskGoToCoordAnyMeans(targetSelectionPet, targetCoords.x, targetCoords.y, targetCoords.z, 2.0, 0, false, 0, 0.0)
						petMoveTarget = { pet = targetSelectionPet, coords = vector3(targetCoords.x, targetCoords.y, targetCoords.z) }
						VORPcore.NotifyRightTip("Pet moving to selected location.", 4000)
					end
					targetSelectionActive = false
					targetSelectionPet = nil
					targetSelectionTeleport = false
				end
			end
		end
	end
end)

CreateThread(function()
	while true do
		if petMoveTarget == nil then
			Wait(250)
		else
			Wait(250)
			if not DoesEntityExist(petMoveTarget.pet) then
				petMoveTarget = nil
			else
				local petCoords = GetEntityCoords(petMoveTarget.pet)
				local distance = #(petCoords - petMoveTarget.coords)
				if distance <= 1.5 then
					ClearPedTasksImmediately(petMoveTarget.pet)
					TaskStandStill(petMoveTarget.pet, -1)
					FreezeEntityPosition(petMoveTarget.pet, true)
					petMoveTarget = nil
				end
			end
		end
	end
end)

function SpawnAnimal(model, player, x, y, z, h, skin, PlayerPedId, isdead, isshop, petid)
	currentPetPed = CreatePed(model, x, y, z, h, 1, 1 )
	SET_PED_OUTFIT_PRESET( currentPetPed, skin )
	SET_BLIP_TYPE( currentPetPed )

	if Config.PetAttributes.Invincible then
		SetEntityInvincible(currentPetPed, true)
	end

	SetPetAttributes(currentPetPed)
	SetPetBehavior(currentPetPed)
	SetPedAsGroupMember(currentPetPed, GetPedGroupIndex(PlayerPedId))

	while (GetScriptTaskStatus(currentPetPed, 0x4924437d) ~= 8) do
		Wait(1000)
	end

	FollowOwner(currentPetPed, player, isshop)

	if isdead and Config.PetAttributes.Invincible == false then
		TriggerEvent("vorp:TipRight", _U("petHealed"))
	end
	ActivePets[petid] = currentPetPed
end

function BuyPetMenu(shopName, ShopID)
    MenuData.CloseAll()
    local elements = {}
	for _,v in pairs(Config.Pets) do
		elements[#elements+1] = {label = v[1].Text.." - "..v[1].Param.Price, value = v[1].Param, desc = v[1].Desc}
	end
    Wait(1000)
    elements[#elements+1] = {label = "Close Pet Shop", value = "close", desc = ""}
    MenuData.Open('default', GetCurrentResourceName(), 'pet_purchase',{
        title    = shopName,
        subtext  = "Purchase pets",
        align    = "top-right",
        elements = elements,
    },
    function(data, menu)
        if data.current.value then
			if data.current.value ~= "close" then
				TriggerServerEvent('bcc-pets:buydog', data.current.value, ShopID)
				menu.close()
			else
				ClearPedTasks(PlayerPedId())
				menu.close()
			end
        end
    end,
    function(data, menu)
        ClearPedTasks(PlayerPedId())
        menu.close()
    end)
end

function SellPetMenu()
    MenuData.CloseAll()
    local elements = {}
    local MenuNumber = 1
	VORPcore.RpcCall("GetPlayersPets", function(result)
		if result then
			for _,v in pairs(result) do
				if Config.AllowMultipleTrades then
					if v.called == 0 then
						SellPrice = math.ceil(Config.Pets[v.dog][1].Param.Price / Config.SellPercentage)
						elements[MenuNumber] = {label = Config.Pets[v.dog][1].Text.." - $"..SellPrice, value = "sell", value2 = v.petid, value3 = SellPrice, desc = "", info = v.dog}
						MenuNumber = MenuNumber + 1
					end
				else
					if v.called == 0 and v.transfered == 0 then
						SellPrice = math.ceil(Config.Pets[v.dog][1].Param.Price / Config.SellPercentage)
						elements[MenuNumber] = {label = Config.Pets[v.dog][1].Text.." - $"..SellPrice, value = "sell", value2 = v.petid, value3 = SellPrice, desc = "", info = v.dog}
						MenuNumber = MenuNumber + 1
					end
				end
			end
		end
	end)
    Wait(1000)
    elements[#elements+1] = {label = "Close Pet menu", value = "close", desc = ""}
    MenuData.Open('default', GetCurrentResourceName(), 'pet_select',{
        title    = "Pet menu",
        subtext  = "Sell your pets",
        align    = "top-right",
        elements = elements,
    },
    function(data, menu)
        if data.current.value then
            if data.current.value == "sell" then
				TriggerServerEvent("bcc-pets:sellpet", data.current.value2, data.current.value3)
				ClearPedTasks(PlayerPedId())
				menu.close()
			else
                ClearPedTasks(PlayerPedId())
                menu.close()
            end
        end
    end,
    function(data, menu)
		ClearPedTasks(PlayerPedId())
        menu.close()
    end)
end

function CallPetMenu()
    MenuData.CloseAll()
    local elements = {}
	local timer = 1000
	if Config.PetMenu.animation then
		if not IsPedOnMount(PlayerPedId()) then
			TaskStartScenarioInPlace(PlayerPedId(), GetHashKey("WORLD_HUMAN_WRITE_NOTEBOOK"), -1, true, false, false, false)
		end
	end
	local MenuNumber = 1
	VORPcore.RpcCall("GetPlayersPets", function(result)
		if result then
			for _,v in pairs(result) do
				if v.called == 1 then
					elements[MenuNumber] = {label = Config.Pets[v.dog][1].Text.." - Out", value = "call", value2 = v, desc = "", info = v.dog}
					MenuNumber = MenuNumber + 1
				else
					elements[MenuNumber] = {label = Config.Pets[v.dog][1].Text.." - Home", value = "call", value2 = v, desc = "", info = v.dog}
					MenuNumber = MenuNumber + 1
				end
			end
		end
	end)
    Wait(timer + 500)
    elements[#elements+1] = {label = "Close Pet menu", value = "close", desc = ""}
    MenuData.Open('default', GetCurrentResourceName(), 'pet_select',{
        title    = "Pet menu",
        subtext  = "Manage your pets",
        align    = "top-right",
        elements = elements,
    },
    function(data, menu)
        if data.current.value then
            if data.current.value == "call" then
				menu.close()
				PetManagement(data.current.value2)
			else
                ClearPedTasks(PlayerPedId())
                menu.close()
            end
        end
    end,
    function(data, menu)
		ClearPedTasks(PlayerPedId())
        menu.close()
    end)
end

function VetPetMenu(ShopName, ShopID)
    MenuData.CloseAll()
    local elements = {}
	if Config.Shops[ShopID].JobLock.purchasing then
		VORPcore.RpcCall("GetPlayerJob", function(result)
			if result then
				for _,v in pairs(Config.Shops[ShopID].JobLock.jobs) do
					if tostring(result) == v then
						elements[#elements+1] = {label = "Buy Pet", value = "buy", desc = ""}
						break
					end
				end
			end
		end)
	else
		elements[#elements+1] = {label = "Buy Pet", value = "buy", desc = ""}
	end
	Wait(100)
	if Config.Shops[ShopID].JobLock.selling then
		VORPcore.RpcCall("GetPlayerJob", function(result)
			if result then
				for _,v in pairs(Config.Shops[ShopID].JobLock.jobs) do
					if tostring(result) == v then
						elements[#elements+1] = {label = "Sell Pet", value = "sell", desc = ""}
						break
					end
				end
			end
		end)
	else
		elements[#elements+1] = {label = "Sell Pet", value = "sell", desc = ""}
	end
	Wait(100)
    elements[#elements+1] = {label = "Close Pet Shop", value = "close", desc = ""}
    MenuData.Open('default', GetCurrentResourceName(), 'pet_purchase',{
        title    = ShopName,
        subtext  = "Vet menu",
        align    = "top-right",
        elements = elements,
    },
    function(data, menu)
        if data.current.value then
			if data.current.value == "buy" then
				BuyPetMenu(ShopName, ShopID)
			elseif data.current.value == "sell" then
				SellPetMenu()
			else
				ClearPedTasks(PlayerPedId())
				menu.close()
			end
        end
    end,
    function(data, menu)
        ClearPedTasks(PlayerPedId())
        menu.close()
    end)
end

function PetManagement(PetDataTable)
    MenuData.CloseAll()
    local elements = {}
	if PetDataTable.called == 1 then
		elements[1] = {label = "Send pet home", value = "home", desc = ""}
	else
		elements[1] = {label = "Call pet", value = "call", desc = ""}
	end
	if PetDataTable.transfered ~= 1 then
		elements[#elements+1] = {label = "Transfer Ownership", value = "transfer", desc = ""}
	end
    elements[#elements+1] = {label = "Close Pet menu", value = "close", desc = ""}
    MenuData.Open('default', GetCurrentResourceName(), 'pet_select',{
        title    = "Pet menu",
        subtext  = "Manage your pets",
        align    = "top-right",
        elements = elements,
    },
    function(data, menu)
        if data.current.value then
            if data.current.value == "call" then
				ClearPedTasks(PlayerPedId())
				menu.close()
				TriggerServerEvent('bcc-pets:callpet', PetDataTable.petid)
			elseif data.current.value == "home" then
				if ActivePets[PetDataTable.petid] then
					ClearPedTasks(PlayerPedId())
					menu.close()
					DeleteEntity(ActivePets[PetDataTable.petid])
					TriggerServerEvent('bcc-pets:server:putawaypet', PetDataTable.petid)
				else
					VORPcore.NotifyRightTip(_U("PetNotOut"),4000)
				end
			elseif data.current.value == "transfer" then
				menu.close()
				TriggerEvent('bcc-pets:transferpetinput', PetDataTable.petid)
			else
                ClearPedTasks(PlayerPedId())
                menu.close()
            end
        end
    end,
    function(data, menu)
        ClearPedTasks(PlayerPedId())
        menu.close()
    end)
end

function SET_BLIP_TYPE (animal)
	return Citizen.InvokeNative(0x23f74c2fda6e7c61, -1749618580, animal)
end

function SET_ANIMAL_TUNING_BOOL_PARAM (animal, p1, p2)
	return Citizen.InvokeNative( 0x9FF1E042FA597187, animal, p1, p2 )
end

function SET_PED_DEFAULT_OUTFIT (dog)
	return Citizen.InvokeNative( 0x283978A15512B2FE, dog, true )
end

function SET_PED_OUTFIT_PRESET (dog, preset)
	return Citizen.InvokeNative( 0x77FF8D35EEC6BBC4, dog, preset, 0 )
end

-- Threads
CreateThread(function()
	while true do
		for _, pet in pairs(ActivePets) do
			if DoesEntityExist(pet) and ActivePetModes[pet] == "leadahead" then
				RemovePedFromGroup(pet)
				LeadOwner(pet, PlayerPedId())
			end
		end
		Wait(500)
	end
end)

CreateThread(function()
	for _, v in pairs(Config.Shops) do
		if v.Blip.active then
			local blip = VORPutils.Blips:SetBlip(v.Name, v.Blip.sprite, v.Blip.scale, v.Blip.coords.x, v.Blip.coords.y, v.Blip.coords.z)
		end
		if v.Ped.active then
			local ped = VORPutils.Peds:Create(v.Ped.modelhash, v.Ped.coords.x, v.Ped.coords.y, v.Ped.coords.z, v.Ped.coords.w, 'world', false)
			if v.Ped.frozen then
				ped:Freeze()
			end
			if v.Ped.invincible then
				ped:Invincible()
			end
		end
    end
	local PetStores = VORPutils.Prompts:SetupPromptGroup()
    local PetStoresPrompt = PetStores:RegisterPrompt(Config.ShopsPromptText, Config.ShopsPromptKey, 1, 1, false, 'hold', {timedeventhash = "SHORT_TIMED_EVENT"})
    while true do
        sleep = 1000
        local coords = GetEntityCoords(PlayerPedId())
            for k, v in pairs(Config.Shops) do
                local dist = #(coords - v.Coords)
                if dist <= 10 then
                    sleep = 5
                end
                if dist < Config.ShopsPromptDistance then
                    PetStores:ShowGroup(v.Name)
					ShopName = v.Name
					ShopID = k
                end
            end
        if PetStoresPrompt:HasCompleted() then
			VetPetMenu(ShopName, ShopID)
        end
        Wait(sleep)
    end
end)

-- Events
RegisterNetEvent('bcc-pets:transferpetinput', function(petid)
	local button = "Confirm"
	local placeholder = "Insert Person's ID #"
    TriggerEvent("vorpinputs:getInput", button, placeholder, function(result)
        if result ~= "" or result then -- making sure its not empty or nil
            TriggerServerEvent('bcc-pets:transferownership', result, petid)
			ClearPedTasks(PlayerPedId())
        else
			ClearPedTasks(PlayerPedId())
			VORPcore.NotifyRightTip(_U("IncorrectID"),4000)
        end
    end)
end)

RegisterNetEvent('bcc-pets:removedog', function (petid)
	if ActivePets[petid] then
		ActivePetModes[ActivePets[petid]] = nil
		DeleteEntity(ActivePets[petid])
	end
end)

RegisterNetEvent('bcc-pets:spawndog', function (dog, skin, isInShop, petid, ShopID)
	local player = PlayerPedId()
	local model = GetHashKey(dog)
	local x, y, z, w, heading, b

	-- Set initial pet location
	if isInShop then
		x, y, z, heading = -373.302, 786.904, 116.169, 273.18
	else
		x, y, z = table.unpack( GetOffsetFromEntityInWorldCoords( player, 0.0, -5.0, 0.3 ) )
		_, b = GetGroundZAndNormalFor_3dCoord( x, y, z + 10 )
	end

	RequestModel( model )

	while not HasModelLoaded( model ) do
		Wait(500)
	end

	if isInShop then
		x, y, z, w = table.unpack(Config.Shops[ShopID].Spawndog)
		SpawnAnimal(model, player, x, y, z, w, skin, PlayerPedId(), false, true, petid)
	else
		if EntityIsDead then
			SpawnAnimal(model, player, x, y, b, heading, skin, PlayerPedId(), true, false, petid)
		else
			SpawnAnimal(model, player, x, y, b, heading, skin, PlayerPedId(), false, false, petid)
		end
	end
end)

RegisterNetEvent('bcc-pets:openpetmenu', function()
	CallPetMenu()
end)

RegisterCommand("sit", function()
	HandlePetCommand("sit")
end, false)

RegisterCommand("stay", function()
	HandlePetCommand("stay")
end, false)

RegisterCommand("followpet", function()
	HandlePetCommand("follow")
end, false)

RegisterCommand("laydown", function()
	HandlePetCommand("laydown")
end, false)

RegisterCommand("leadpet", function()
	HandlePetCommand("leadahead")
end, false)

RegisterCommand("faceme", function()
	HandlePetCommand("faceme")
end, false)

RegisterCommand("faceaway", function()
	HandlePetCommand("faceaway")
end, false)

RegisterCommand("gothere", function()
	HandlePetCommand("gothere")
end, false)

RegisterCommand(petPlacementConfig.command or "petplacement", function()
	TeleportPetToWaypoint()
end, false)

RegisterNetEvent("bcc-pets:client:chatcommand", function(action)
	if action == "sit" or action == "stay" or action == "follow" or action == "laydown" or action == "leadahead" or action == "faceme" or action == "faceaway" then
		HandlePetCommand(action)
	end
end)


AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
	for k,_ in pairs(ActivePets) do
		ActivePetModes[ActivePets[k]] = nil
		DeleteEntity(ActivePets[k])
	end
end)