local resourceName = GetCurrentResourceName()
local debugmode = Config.Debug
local lastUsedSittingScenario = nil

if resourceName ~= "mosquito-animations" then
	print("^1[mosquito-animations] Resource name mismatch! The resource name must be 'mosquito-animations'")
	TriggerServerEvent('mosquito:server:resourceNameMismatch', resourceName)
end

Config.Emotes = {}

for _, v in ipairs(Config.AnimationsToInclude) do
	if Config.Animations[v] then
		Config.Emotes[v] = Config.Animations[v]
	end
end

for k, v in pairs(Config.AddEmotes) do
	Config.Emotes[k] = v
end


CurrentEmote = nil
CurrentScenario = nil

LastUsedScenario = nil

CurrentlyEmoting = false
CurrentlySitting = false
CurrentSittingType = nil
CurrentlySittingOnVehicle = false
CurrentOriginCoords = nil

local CurrentSeatEntity = nil
local CurrentBaseEntity = nil

local isAttachedToOther = false
local SharedEmoteRequest
local once = false
local onlyOnce = false
local inthere = false
local isHandsUp = false
local askedOnce = false
local AcceptText = string.format(Config.SharedEmoteAcceptText, Config.SharedEmoteAcceptControl)
local RejectText = string.format(Config.SharedEmoteRejectText, Config.SharedEmoteRejectControl)

local AnimationStartTime = nil
local AnimationKey = nil

local function IsEditPosActive()
	return LocalPlayer
		and LocalPlayer.state
		and LocalPlayer.state.editposActive == true
end

Config.Emotes["mapopen"] = {
	type = "prop",
	name = "Open Map",
	prop = {
		model = "s_twofoldmap01x_us",
		bone = "PH_R_Hand",
		position = vector3(0.0, 0.0, 0.0),
		rotation = vector3(0.0, 0.0, 0.0),
		anim = {
			dict = "mech_inspection@two_fold_map@satchel",
			name = "enter_prop",
			looped = false,
			freeze = true,
		},
		-- delay = 300
	},
	animation = {
		dict = "mech_inspection@two_fold_map@satchel",
		name = "enter",
		flag = 26,
		blendin = 3.0
	}
}

Config.Emotes["mapclose"] = {
	type = "prop",
	name = "Close Map",
	prop = {
		model = "s_twofoldmap01x_us",
		bone = "PH_R_Hand",
		position = vector3(0.0, 0.0, 0.0),
		rotation = vector3(0.0, 0.0, 0.0),
		anim = {
			dict = "mech_inspection@two_fold_map@satchel",
			name = "exit_prop",
			looped = false,
			freeze = true,
		},
		-- delay = 300
	},
	animation = {
		dict = "mech_inspection@two_fold_map@satchel",
		name = "exit",
		flag = 28,
		blendin = 3.0,
		blendout = 2.0,
		duration = 3700,
		upperBody = true,
	}
}


local WalkStyleBases = {
	"algie",
	"angry_female",
	"arthur_healthy",
	"casual",
	"default",
	"default_female",
	"free_slave_01",
	"free_slave_02",
	"gold_panner",
	"guard_lantern",
	"john_marston",
	"lilly_millet",
	"lone_prisoner",
	"lost_Man",
	"murfree",
	"old_female",
	"primate",
	"rally",
	"waiter",
	"war_veteran",
}

local WalkStyles = {
	"action",
	"agitated",
	"angry",
	"brace",
	"bucking_high",
	"carry_pitchfork",
	"cautious",
	"chain_gang_catchup",
	"chain_gang_legs",
	"chain_gang_normal",
	"combat",
	"cower_known",
	"cry",
	"default",
	"default_brave",
	"default_nervous",
	"dehydrated_unarmed",
	"depressed",
	"directional_nervous",
	"incombat_low_intensity_longarm",
	"incombat_zero_intensity",
	"injured_general",
	"injured_left_arm",
	"injured_left_leg",
	"injured_right_arm",
	"injured_right_leg",
	"injured_torso",
	"intimidate",
	"intimidated_on_feet",
	"intimidated_on_feet_reaction",
	"lost_man_normal",
	"marston_cautious",
	"moderate_drunk",
	"nervous",
	"normal",
	"normal_basic_idle",
	"normal_town",
	"panic",
	"piss_pot_a",
	"piss_pot_b",
	"rally_sad",
	"sad",
	"scared",
	"searching_high_energy_indirect",
	"searching_low_energy_indirect",
	"shocked",
	"slightly drunk",
	"snow",
	"spool",
	"stealth",
	"very_drunk",
}

RegisterNetEvent("emotes:requestSharedEmote")
RegisterNetEvent("emotes:rejectSharedEmote")
RegisterNetEvent("emotes:acceptSharedEmote")
RegisterNetEvent("emotes:stopSharedEmote")

function DisplayDebugText(text, x, y, r, g, b, a, shadow, duration, endTime)
	local x, y, r, g, b, a = x or 0.5, y or 0.5, r or 255, g or 255, b or 255, a or 255
	local shadow = shadow == true
	if shadow then
		SetTextScale(0.45, 0.45)
		SetTextFontForCurrentCommand(23)
		SetTextColor(0, 0, 0, a - 75)
		SetTextCentre(1)
		DisplayText(CreateVarString(10, "LITERAL_STRING", text), x + 0.001, y + 0.001)
	end

	SetTextScale(0.45, 0.45)
	SetTextFontForCurrentCommand(23)
	SetTextColor(r, g, b, a)
	SetTextCentre(1)
	DisplayText(CreateVarString(10, "LITERAL_STRING", text), x, y)

	if duration and duration > 0 then
		local endTime = endTime or GetGameTimer() + duration
		if endTime - GetGameTimer() > 0 then
			DisplayDebugText(text, x, y, r, g, b, a, shadow, duration, endTime)
		end
	end
end

function printTableRecursive(tbl, indent, color)
	local color = color or "^3"
	indent = indent or 0
	local prefix = string.rep("  ", indent)
	for k, v in pairs(tbl) do
		if type(v) == "table" then
			print(prefix .. color .. tostring(k) .. "^7:")
			printTableRecursive(v, indent + 1)
		else
			print(prefix .. color .. tostring(k) .. "^7 = ^2" .. tostring(v) .. "^7")
		end
	end
end

RegisterCommand("addemote", function(source, args, rawCommand)
	local index = args[1]
	local emoteName = args[2]
	local emoteType = args[3] or "emote"
	if not emoteName then
		print("Usage: /addemote [index] [emote_name] [emote_type]")
		return
	end
	TriggerServerEvent('mosquito:server:favoriteNewAnimation', index, emoteName, emoteType)
end)

local function clearCurrentlyEmoting()
	CreateThread(function()
		Wait(50)
		CurrentlyEmoting = false
	end)
end

local function setCurrentlyEmoting()
	CreateThread(function()
		Wait(50)
		if CurrentEmote then
			CurrentlyEmoting = true
		end
	end)
end

function NativeEmoteCommand(source, args, rawCommand)
	if CurrentEmote then
		StopUsingEmote()
		Wait(100)
	end
	local ped = PlayerPedId()
	local emoteKey = args[1]
	if not emoteKey or not Config.NativeEmotes[emoteKey] then
		for k, v in pairs(Config.NativeEmotes) do
			print(k, "-", v.name)
		end
		return
	end

	local emoteData = Config.NativeEmotes[emoteKey]
	local emoteHash = GetHashKey(emoteData.emote)
	local playbackMode = tonumber(args[2]) or 0
	TaskPlayEmoteWithHash(
		ped,
		0,
		playbackMode,
		emoteHash,
		1,
		0,
		0,
		0,
		0
	)
end

function GetCompatibleAnim(ped, anim)
	if anim and anim.variants then
		for _, variant in ipairs(anim.variants) do
			if variant.isCompatible(ped) then
				return variant
			end
		end
	else
		return anim
	end
end

function PlayAnimation(ped, anim)
	anim = GetCompatibleAnim(ped, anim)
	if not anim then
		return
	end
	if not DoesAnimDictExist(anim.dict) then
		--print("Invalid animation dictionary: " .. anim.dict)
		return
	end

	RequestAnimDict(anim.dict)

	while not HasAnimDictLoaded(anim.dict) do
		Wait(0)
	end
	local filter = ""
	if anim.filter == false then
		filter = false
	elseif anim.filter == nil then
		filter = ""
	else
		filter = anim.filter
	end
	TaskPlayAnim(ped, anim.dict, anim.name, anim.blendin or 4.0, anim.blendout or 2.5, anim.duration or -1, anim.flag, 0.0, false, anim.upperBody and (1 << 16) or nil, false, filter, false)

	RemoveAnimDict(anim.dict)
end

function StopAnimation(ped, anim)
	anim = GetCompatibleAnim(ped, anim)

	StopAnimTask(ped, anim.dict, anim.name, 1.0)
	once = false
	-- if anim.flag == 1 then
	-- 	FreezeEntityPosition(ped, false)
	-- end
end

function CreateProp(oldProp, isSameProp)
	local ped = PlayerPedId()
	if not CurrentEmote or type(CurrentEmote) ~= "table" or type(CurrentEmote.prop) ~= "table" or not CurrentEmote.prop.model then
		return false
	end

	RequestModel(CurrentEmote.prop.model)
	while not HasModelLoaded(CurrentEmote.prop.model) do Wait(0) end
	CurrentEmote.prop.handle = CreateObjectNoOffset(GetHashKey(CurrentEmote.prop.model), 0.0, 0.0, 0.0, true, false, false, false)
	NetworkRequestControlOfEntity(CurrentEmote.prop.handle)
	local shouldHaveCollision = CurrentEmote.prop.collision == true
	SetEntityCollision(CurrentEmote.prop.handle, shouldHaveCollision, shouldHaveCollision)
	SetEntityVisible(CurrentEmote.prop.handle, false)
	local handle = CurrentEmote.prop.handle
	if handle ~= "" then
		if DoesEntityExist(handle) then
			TriggerServerEvent('mosquito:Server:animations:AddPropToNetworkedTable', NetworkGetNetworkIdFromEntity(handle))
		end
	end
	CreateThread(function()
		local emote = CurrentEmote
		if type(emote) ~= "table" or type(emote.prop) ~= "table" then
			return
		end
		local prop = emote.prop
		Wait(prop.delay or 0)
		if CurrentEmote and CurrentEmote == emote and prop and prop.handle and CurrentEmote.prop and prop.handle == CurrentEmote.prop.handle and DoesEntityExist(prop.handle) then
			SetEntityVisible(CurrentEmote.prop.handle, true)
		else
		end
	end)
	return CurrentEmote.prop.handle ~= 0 and DoesEntityExist(CurrentEmote.prop.handle)
end

local function PlaceStationaryProp(ped, prop)
	if not ped or ped == 0 or type(prop) ~= "table" then
		return
	end

	local handle = prop.handle
	if not handle or handle == 0 or not DoesEntityExist(handle) then
		return
	end

	if IsEntityAttached(handle) then
		DetachEntity(handle, true, true)
	end

	local offset = prop.position or vector3(0.0, 0.0, 0.0)
	local rot = prop.rotation or vector3(0.0, 0.0, 0.0)
	local pedCoords = GetEntityCoords(ped)
	local pedHeading = GetEntityHeading(ped)

	local worldPos = GetOffsetFromCoordAndHeadingInWorldCoords(
		pedCoords.x, pedCoords.y, pedCoords.z,
		pedHeading,
		offset.x, offset.y, offset.z
	)

	local finalRotX = rot.x or 0.0
	local finalRotY = rot.y or 0.0
	local finalRotZ = (rot.z or 0.0) + pedHeading
	local shouldHaveCollision = prop.collision == true

	SetEntityCoordsNoOffset(handle, worldPos.x, worldPos.y, worldPos.z, false, false, false)
	if prop.snaptoground then
		PlaceObjectOnGroundProperly(handle)
	else
		SetEntityRotation(handle, finalRotX, finalRotY, finalRotZ, 2, true)
	end
	SetEntityCollision(handle, shouldHaveCollision, shouldHaveCollision)
end

function AttachProp(ped)
	if CurrentEmote and CurrentEmote.prop and CurrentEmote.prop.stationary then
		PlaceStationaryProp(ped, CurrentEmote.prop)
		return
	end

	local handle = CurrentEmote.prop.handle
	local bone = CurrentEmote.prop.bone
	local position = CurrentEmote.prop.position
	local rotation = CurrentEmote.prop.rotation

	if type(bone) == "string" then
		bone = GetEntityBoneIndexByName(ped, bone)
	end

	local shouldHaveCollision = CurrentEmote.prop.collision == true
	AttachEntityToEntity(handle, ped, bone, position, rotation, false, false, shouldHaveCollision, false, 0, true, false, false)
end

function AnimateProp(prop, dict, anim, looped, freeze)
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do Wait(0) end
	if IsEntityAttached(prop) then
		DetachEntity(prop, true, true)
	end
	FreezeEntityPosition(prop, false)
	local played = PlayEntityAnim(
		prop,
		anim,
		dict,
		8.0, -- speed
		looped, -- looped
		freeze, -- stay in last frame
		false, -- p6
		-1.0, -- delta
		0 -- bitset
	)
end

local entityEnumerator = {
	__gc = function(enum)
		if enum.destructor and enum.handle then
			enum.destructor(enum.handle)
		end
		enum.destructor = nil
		enum.handle = nil
	end
}

function EnumerateEntities(firstFunc, nextFunc, endFunc)
	return coroutine.wrap(function()
		local iter, id = firstFunc()

		if not id or id == 0 then
			endFunc(iter)
			return
		end

		local enum = { handle = iter, destructor = endFunc }
		setmetatable(enum, entityEnumerator)

		local next = true
		repeat
			coroutine.yield(id)
			next, id = nextFunc(iter)
		until not next

		enum.destructor, enum.handle = nil, nil
		endFunc(iter)
	end)
end

function EnumeratePeds()
	return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

function GetClosestPedInRange()
	local myPed = PlayerPedId()
	local myPos = GetEntityCoords(myPed)

	local minDist, closestPed

	for ped in EnumeratePeds() do
		if myPed ~= ped then
			local theirPos = GetEntityCoords(ped)
			local distance = #(myPos - theirPos)

			if distance < Config.SharedEmoteRange and (not minDist or distance < minDist) then
				minDist = distance
				closestPed = ped
			end
		end
	end

	return closestPed
end

local function IsPedInGeneralDirectionOfPlayer(playerPed, targetPed, facingDotThreshold)
	if not playerPed or playerPed == 0 or not targetPed or targetPed == 0 then
		return false
	end

	local playerCoords = GetEntityCoords(playerPed)
	local targetCoords = GetEntityCoords(targetPed)
	local directionToTarget = vector3(targetCoords.x - playerCoords.x, targetCoords.y - playerCoords.y, 0.0)
	local distance2D = math.sqrt((directionToTarget.x * directionToTarget.x) + (directionToTarget.y * directionToTarget.y))
	if distance2D <= 0.001 then
		return true
	end

	directionToTarget = vector3(directionToTarget.x / distance2D, directionToTarget.y / distance2D, 0.0)
	local forward = GetEntityForwardVector(playerPed)
	local forward2D = vector3(forward.x, forward.y, 0.0)
	local forwardLen = math.sqrt((forward2D.x * forward2D.x) + (forward2D.y * forward2D.y))
	if forwardLen <= 0.001 then
		return false
	end

	forward2D = vector3(forward2D.x / forwardLen, forward2D.y / forwardLen, 0.0)
	local dot = (forward2D.x * directionToTarget.x) + (forward2D.y * directionToTarget.y)
	local threshold = facingDotThreshold or 0.2
	return dot >= threshold
end

local function GetClosestPedInRangeInFront()
	local myPed = PlayerPedId()
	local myPos = GetEntityCoords(myPed)
	local minDist, closestPed

	for ped in EnumeratePeds() do
		if myPed ~= ped then
			local theirPos = GetEntityCoords(ped)
			local distance = #(myPos - theirPos)
			if distance < Config.SharedEmoteRange and IsPedInGeneralDirectionOfPlayer(myPed, ped, 0.2) then
				if not minDist or distance < minDist then
					minDist = distance
					closestPed = ped
				end
			end
		end
	end

	return closestPed
end

function GetPlayerFromPed(ped)
	for _, player in ipairs(GetActivePlayers()) do
		if GetPlayerPed(player) == ped then
			return player
		end
	end
end

function GetUserInput(windowTitle, textType, defaultText, maxInputLength)
	local resourceName = string.upper(GetCurrentResourceName())
	local textEntry = resourceName .. "_WINDOW_TITLE"
	if windowTitle == nil then
		windowTitle = "Enter:"
	end
	AddTextEntry(textEntry, windowTitle)

	DisplayOnscreenKeyboard(textType or 2, textEntry, "", defaultText or "", "", "", "", maxInputLength or 30)
	Wait(0)
	while true do
		local keyboardStatus = UpdateOnscreenKeyboard();
		if keyboardStatus == 3 then
			return nil
		elseif keyboardStatus == 2 then
			return nil
		elseif keyboardStatus == 1 then
			return GetOnscreenKeyboardResult()
		else
			Wait(0)
		end
	end
end

function GetPlayerServerIdFromPed(ped)
	return GetPlayerServerId(GetPlayerFromPed(ped))
end

function GetPlayerPedFromServerId(serverId)
	return GetPlayerPed(GetPlayerFromServerId(serverId))
end

function GetPlayerNameFromServerId(serverId)
	return GetPlayerName(GetPlayerFromServerId(serverId))
end

function TeleportToPartner(ped, partner, emote)
	local offset = emote.partner.offset or vector3(0.0, 0.0, 0.0)
	local rot = emote.partner.rotation or vector3(0.0, 0.0, 0.0)

	local partnerCoords = GetEntityCoords(partner)
	local partnerHeading = GetEntityHeading(partner)

	local worldPos = GetOffsetFromCoordAndHeadingInWorldCoords(
		partnerCoords.x, partnerCoords.y, partnerCoords.z,
		partnerHeading,
		offset.x, offset.y, offset.z
	)

	local finalRotX = rot.x or 0.0
	local finalRotY = rot.y or 0.0
	local finalRotZ = (rot.z or 0.0) + partnerHeading + 180.0


	SetEntityCoordsNoOffset(ped, worldPos.x, worldPos.y, worldPos.z, false, false, false)
	SetEntityHeading(ped, finalRotZ)
end

function DrawText2D(x, y, text, color, center, scale, font)
	local color = color or { 255, 255, 255, 255 }
	local alphaFactor = color[4] and color[4] / 255 or 1
	SetTextScale(scale and scale[1] or 0.35, scale and scale[2] or 0.35)
	SetTextFontForCurrentCommand(font or 23)
	SetTextColor(0, 0, 0, math.ceil(alphaFactor * 255))
	SetTextCentre(center or 0)
	local cleanText = text:gsub("~[^~]+~", "")
	DisplayText(CreateVarString(10, "LITERAL_STRING", "~COLOR_BLACK~" .. cleanText), x + 0.001, y + 0.0015)

	SetTextScale(scale and scale[1] or 0.35, scale and scale[2] or 0.35)
	SetTextFontForCurrentCommand(font or 23)
	if color and type(color) == "table" and #color >= 3 then
		SetTextColor(color[1], color[2], color[3], math.ceil(alphaFactor * 255))
	else
		SetTextColor(255, 255, 255, math.ceil(alphaFactor * 255))
	end
	SetTextCentre(center or 0)
	DisplayText(CreateVarString(10, "LITERAL_STRING", text), x, y)
end

function DrawText3D(x, y, z, text)
	local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(x, y, z)
	DrawText2D(screenX, screenY, text, nil, 1, { 0.35, 0.35 }, 23)
end

function ShowNotification(text, duration)
	mosquito.notify.right_tip(text, duration or 5000)
end

local freezeThreadActive = false
local durationThreadActive = false
local currentEmoteThreadRunning = false
local currentEmoteThreadToken = 0

local function IsTruthy(value)
	return value == true
end

local function IsEmoteNonInterruptible(emote)
	if type(emote) ~= "table" then
		return false
	end

	return IsTruthy(emote.nonInterruptible)
end

local function IsEmoteInterruptible(emote)
	if type(emote) ~= "table" then
		return false
	end

	return IsTruthy(emote.interruptible)
end

local function ResolveActiveWalkBlendRatio()
	local customRatio = tonumber(maxBlendMoveRatio)
	if not customRatio then
		customRatio = tonumber(Config.MaxBlendMoveRatio) or 1.0
	end

	if customRatio < 1.0 then
		return customRatio
	end

	if math.abs(customRatio - 1.0) > 0.0001 then
		return customRatio
	end

	local resolvedRatio = nil

	local function consider(ratio)
		ratio = tonumber(ratio)
		if not ratio then
			return
		end
		if not resolvedRatio or ratio < resolvedRatio then
			resolvedRatio = ratio
		end
	end

	if CurrentEmote then
		consider(Config.AnimationWalkSpeed)
	end

	if isHandsUp then
		consider(Config.HandsUpWalkSpeed)
	end

	if EmoteDirectionalState and (EmoteDirectionalState.isPointing or EmoteDirectionalState.isActive) then
		consider(Config.PointingWalkSpeed)
	end

	return resolvedRatio
end

local function ApplyGlobalWalkBlendRatioIfNeeded(ped)
	if not ShouldApplyCustomWalkBlendRatio(ped) then
		return
	end

	local ratio = ResolveActiveWalkBlendRatio()
	if ratio then
		SetPedMaxMoveBlendRatio(ped, ratio)
	end
end

local function StartCurrentEmoteRuntimeThread()
	if currentEmoteThreadRunning or not CurrentEmote then
		return
	end

	currentEmoteThreadRunning = true
	currentEmoteThreadToken = currentEmoteThreadToken + 1
	local token = currentEmoteThreadToken

	CreateThread(function()
		local LastAnimTime = nil
		local wasMoving = false
		local runtimePlaybackStarted = false
		local freezeApplied = false
		local sharedAnimStopDetectedAt = nil
		local forcedStopDetectedAt = nil
		local nonInterruptibleBlockedDetectedAt = nil
		local emoteStartedAt = GetGameTimer()
		local stopAtTime = nil
		local trackedPropHandle = nil

		while currentEmoteThreadToken == token and CurrentEmote do
			local ped = PlayerPedId()
			local emote = CurrentEmote
			local anim = emote and emote.animation

			if not anim then
				break
			end
			local victimPed = anim.victim and emote.partner and emote.partner.ped
			local sharedWalking = (emote.partner and emote.partner.ped and anim.walking) or nil
			if sharedWalking then
				local victimAnim = (not victimPed and emote.partner) and emote.partner.animation or nil
				local isPedMoving = IsPedStill(victimPed or ped) == false
				if isPedMoving and not wasMoving then
					runtimePlaybackStarted = false
					StopAnimation(ped, anim)
					if victimAnim and emote.partner and emote.partner.ped then
						StopAnimation(emote.partner.ped, victimAnim)
						victimAnim.name = victimAnim.walkingName or victimAnim.name
						victimAnim.flag = victimAnim.walkingFlag or victimAnim.flag
						victimAnim.dict = victimAnim.walkingDict or victimAnim.dict
					end
					anim.flag = anim.walkingFlag or anim.flag
					anim.name = anim.walkingName or anim.name
					anim.dict = anim.walkingDict or anim.dict
					wasMoving = true
				elseif not isPedMoving and wasMoving then
					runtimePlaybackStarted = false
					StopAnimation(ped, anim)
					if victimAnim and emote.partner and emote.partner.ped then
						StopAnimation(emote.partner.ped, victimAnim)
						victimAnim.name = victimAnim.stoppedName or victimAnim.name
						victimAnim.flag = victimAnim.stoppedFlag or victimAnim.flag
						victimAnim.dict = victimAnim.stoppedDict or victimAnim.dict
					end
					anim.name = anim.stoppedName or anim.name
					anim.flag = anim.stoppedFlag or anim.flag
					anim.dict = anim.stoppedDict or anim.dict
					wasMoving = false
				end
			end

			local isPlayingAnim = IsEntityPlayingAnim(ped, anim.dict, anim.name, 3)
			
			if IsEditPosActive() then
				isPlayingAnim = true
			end
			
			local sharedPartnerPed = emote.partner and emote.partner.ped or nil
			local sharedPartnerAnim = emote.partner and emote.partner.animation or nil
			local isSharedEmote = sharedPartnerPed ~= nil and sharedPartnerAnim ~= nil
			local partnerExists = isSharedEmote and DoesEntityExist(sharedPartnerPed) or false
			local partnerPlaying = isSharedEmote and partnerExists and IsEntityPlayingAnim(sharedPartnerPed, sharedPartnerAnim.dict, sharedPartnerAnim.name, 3) or false
			local emoteIsNonInterruptible = not isPlayingAnim and IsEmoteNonInterruptible(emote)
			local emoteIsInterruptible = (not emoteIsNonInterruptible) and IsEmoteInterruptible(emote)
			local canReplayNonInterruptible = true
			if emoteIsNonInterruptible and type(ShouldAnimBeNotInturrupted) == "function" then
				local ok, shouldContinue = pcall(ShouldAnimBeNotInturrupted, ped, emote)
				canReplayNonInterruptible = ok and shouldContinue == true
			end

			if emoteIsNonInterruptible then
				if not canReplayNonInterruptible then
					if not nonInterruptibleBlockedDetectedAt then
						nonInterruptibleBlockedDetectedAt = GetGameTimer()
					elseif GetGameTimer() - nonInterruptibleBlockedDetectedAt > 250 then
						StopUsingEmote()
						break
					end
				else
					nonInterruptibleBlockedDetectedAt = nil
				end
				if canReplayNonInterruptible and runtimePlaybackStarted and not isPlayingAnim then
					PlayAnimation(ped, anim)
				end
				if canReplayNonInterruptible and isSharedEmote and runtimePlaybackStarted and partnerExists and not partnerPlaying then
					PlayAnimation(sharedPartnerPed, sharedPartnerAnim)
				end
				sharedAnimStopDetectedAt = nil
				forcedStopDetectedAt = nil
			elseif emoteIsInterruptible and runtimePlaybackStarted then
				nonInterruptibleBlockedDetectedAt = nil
				local shouldInterruptInterruptible = false
				if type(ShouldAnimBeInturrupted) == "function" then
					local ok, shouldInterrupt = pcall(ShouldAnimBeInturrupted, ped, emote)
					shouldInterruptInterruptible = ok and shouldInterrupt == true
				end
				if shouldInterruptInterruptible then
					StopUsingEmote()
					break
				end
				local shouldForceStop = not isPlayingAnim or (isSharedEmote and (not partnerExists or not partnerPlaying))
				if shouldForceStop then
					if not forcedStopDetectedAt then
						forcedStopDetectedAt = GetGameTimer()
					elseif GetGameTimer() - forcedStopDetectedAt > 250 then
						StopUsingEmote()
						break
					end
				else
					forcedStopDetectedAt = nil
				end
				sharedAnimStopDetectedAt = nil
			elseif isSharedEmote and runtimePlaybackStarted then
				if not partnerExists or not isPlayingAnim or not partnerPlaying then
					if not sharedAnimStopDetectedAt then
						sharedAnimStopDetectedAt = GetGameTimer()
					elseif GetGameTimer() - sharedAnimStopDetectedAt > 250 then
						StopUsingEmote()
						break
					end
				else
					sharedAnimStopDetectedAt = nil
				end
				forcedStopDetectedAt = nil
				nonInterruptibleBlockedDetectedAt = nil
			else
				sharedAnimStopDetectedAt = nil
				forcedStopDetectedAt = nil
				nonInterruptibleBlockedDetectedAt = nil
			end

			if (anim.repeating or anim.keepPlaying == true) and not isPlayingAnim and (not emoteIsNonInterruptible or canReplayNonInterruptible) then
				PlayAnimation(ped, anim)
				runtimePlaybackStarted = true
				once = true
				if not victimPed and emote.partner and emote.partner.ped then
					local victimAnim = emote.partner.animation
					PlayAnimation(emote.partner.ped, victimAnim)
				end
			elseif not runtimePlaybackStarted then
				PlayAnimation(ped, anim)
				if not victimPed and emote.partner and emote.partner.ped then
					local victimAnim = emote.partner.animation
					PlayAnimation(emote.partner.ped, victimAnim)
				end
				runtimePlaybackStarted = true
				once = true
			end

			if (anim.flag == 4 or anim.flag == 28) and not emoteIsNonInterruptible then
				if not LastAnimTime then
					LastAnimTime = GetGameTimer()
					AnimStoppedDetected = false
				end

				if isPlayingAnim then
					LastAnimTime = GetGameTimer()
					AnimStoppedDetected = false
				else
					local elapsed = GetGameTimer() - LastAnimTime
					if elapsed > 250 and not AnimStoppedDetected then
						AnimStoppedDetected = true
						StopUsingEmote()
					end
				end
			end

			if emote == CurrentEmote and anim.freezeAt and anim.freezeAt > 0 and not freezeApplied then
				if (GetGameTimer() - emoteStartedAt) >= anim.freezeAt then
					SetEntityAnimSpeed(ped, anim.dict, anim.name, 0.0)
					freezeApplied = true
				end
			end

			if emote == CurrentEmote and emote.prop then
				local shouldHaveCollision = emote.prop.collision == true
				if not (emote.prop.handle and DoesEntityExist(emote.prop.handle)) then
					CreateProp()
					if emote.prop.stationary then
						PlaceStationaryProp(ped, emote.prop)
					end
					SetEntityAsMissionEntity(emote.prop.handle, true, true)
					if emote.prop and emote.prop.handle and DoesEntityExist(emote.prop.handle) then
						SetEntityCollision(emote.prop.handle, shouldHaveCollision, shouldHaveCollision)
						if emote.prop.anim and emote.prop.anim.name and emote.prop.anim.dict then
							local prop = emote.prop.handle
							local dict = emote.prop.anim.dict
							local animName = emote.prop.anim.name
							local looped = emote.prop.anim.looped or false
							local freeze = emote.prop.anim.freeze or true
							AnimateProp(prop, dict, animName, looped, freeze)
						end
					else
						if debugmode then
							print("Prop handle does not exist or entity does not exist for animation.")
						end
					end
				elseif DoesEntityExist(emote.prop.handle) then
					SetEntityCollision(emote.prop.handle, shouldHaveCollision, shouldHaveCollision)
					if emote.prop.stationary then
						if IsEntityAttached(emote.prop.handle) then
							PlaceStationaryProp(ped, emote.prop)
						end
					elseif not IsEntityAttachedToEntity(emote.prop.handle, ped) then
						AttachProp(ped)
					end
				end
			end

			if emote == CurrentEmote and anim.duration and anim.duration > 0 then
				local currentHandle = emote.prop and emote.prop.handle or nil
				if not stopAtTime or trackedPropHandle ~= currentHandle then
					stopAtTime = GetGameTimer() + anim.duration
					trackedPropHandle = currentHandle
				elseif GetGameTimer() >= stopAtTime then
					if CurrentEmote == emote and (not emote.prop or emote.prop.handle == trackedPropHandle) then
						StopUsingEmote()
					end
					stopAtTime = nil
				end
			end

			Wait(0)
		end

		currentEmoteThreadRunning = false
	end)
end


function StartUsingEmote(name)
	if not CanPlayerStartAnim() then
		return
	end
	if CurrentEmote then
		StopUsingEmote(true)
	end

	local emote = Config.Emotes[name]
	if IsPedOnMount(PlayerPedId()) and emote and emote.animation and emote.animation.flag <= 5 then
		local allowedAnimations = { "letteropen1", "letterclose1", "mapopen", "mapclose" }
		local isAllowed = false
		for _, allowedAnim in ipairs(allowedAnimations) do
			if emote.animation.name == allowedAnim then
				isAllowed = true
				break
			end
		end
		if not isAllowed then
			return
		end
	end
	if not emote then
		ShowNotification("Invalid emote: " .. name)
		return
	end

	if not emote.name then
		emote.name = name
	end

	if emote.partner then
		SendSharedEmoteRequest(emote)
	else
		CurrentEmote = emote
		setCurrentlyEmoting()
		AnimationStartTime = GetGameTimer()
		AnimationKey = name
		once = false
		StartCurrentEmoteRuntimeThread()
	end
end

local function PlacePedOnGroundProperlySafe(pedEntity)
	if not pedEntity or pedEntity == 0 or not DoesEntityExist(pedEntity) then
		return
	end

	local coords = GetEntityCoords(pedEntity)
	local heading = GetEntityHeading(pedEntity)
	local foundGround, groundZ = GetGroundZAndNormalFor_3dCoord(coords.x, coords.y, coords.z + 1.0)
	if not foundGround then
		foundGround, groundZ = GetGroundZAndNormalFor_3dCoord(coords.x, coords.y, coords.z + 5.0)
	end
	if not foundGround then
		foundGround, groundZ = GetGroundZAndNormalFor_3dCoord(coords.x, coords.y, coords.z + 15.0)
	end

	if foundGround then
		SetEntityCoordsNoOffset(pedEntity, coords.x, coords.y, groundZ, false, false, false)
	end
	SetEntityHeading(pedEntity, heading)
end

function StopUsingEmote(replace)
	if not CurrentEmote then
		return
	end

	local emote = CurrentEmote
	currentEmoteThreadToken = currentEmoteThreadToken + 1
	currentEmoteThreadRunning = false

	if AnimationStartTime and AnimationKey then
		local duration = GetGameTimer() - AnimationStartTime
		local durationSeconds = duration / 1000
		if debugmode then
			print(string.format("player animation key %s which lasted %.2fs", AnimationKey, durationSeconds))
		end
		AnimationStartTime = nil
		AnimationKey = nil
	end

	CurrentEmote = nil
	clearCurrentlyEmoting()
	local playerPed = PlayerPedId()
	if isAttachedToOther and IsEntityAttachedToAnyPed(playerPed) then
		DetachEntity(playerPed)
		isAttachedToOther = false
	end
	SetEntityCollision(playerPed, true, true)
	CreateThread(function()
		Wait(100)
		FreezeEntityPosition(playerPed, false)
	end)

	local ped = playerPed

	if emote.animation then
		StopAnimation(ped, emote.animation)
	end

	if emote.prop then
		if DoesEntityExist(emote.prop.handle) then
			TriggerServerEvent('mosquito:Server:animations:RemovePropFromNetworkedTable', NetworkGetNetworkIdFromEntity(emote.prop.handle))
		end
		DetachEntity(emote.prop.handle)
		if not emote.prop.donterase then
			DeleteObject(emote.prop.handle)
		end
	end

	if emote.partner then
		local sharedDontAttach = emote.partner.animation and emote.partner.animation.dontAttach == true
		if IsPedAPlayer(emote.partner.ped) then
			TriggerServerEvent("emotes:stopSharedEmote", GetPlayerServerIdFromPed(emote.partner.ped), emote)
		else
			local partnerPed = emote.partner.ped
			FreezeEntityPosition(emote.partner.ped, false)
			SetEntityCollision(emote.partner.ped, true, true)
			if IsEntityAttachedToAnyPed(emote.partner.ped) then
				DetachEntity(emote.partner.ped)
			end
			StopAnimation(emote.partner.ped, emote.partner.animation)
			if not sharedDontAttach then
				CreateThread(function()
					Wait(100)
					PlacePedOnGroundProperlySafe(partnerPed)
				end)
			end
		end
	end
end

function DrawSharedEmoteRequestText()
	local player = GetPlayerFromServerId(SharedEmoteRequest.player)
	local pos = GetEntityCoords(GetPlayerPed(player))
	DrawText3D(pos.x, pos.y, pos.z, string.format(Config.SharedEmoteRequestWantsToUseText, tostring(SharedEmoteRequest.player), SharedEmoteRequest.emote.name, math.floor((SharedEmoteRequest.expires - GetSystemTime()) / 1000)))
end

function SendSharedEmoteRequest(emote)
	local playerPed = PlayerPedId()
	local closestPed = GetClosestPedInRangeInFront()

	if not closestPed then
		local nearbyPed = GetClosestPedInRange()
		if nearbyPed then
			mosquito.notify.right_tip("You are not facing any ped.")
		else
			mosquito.notify.right_tip(Config.SharedEmoteNobodyNearbyText)
		end
		return
	end

	emote.partner.ped = closestPed

	if IsPedAPlayer(closestPed) then
		TriggerServerEvent("emotes:requestSharedEmote", GetPlayerServerIdFromPed(closestPed), emote)
		mosquito.notify.right_tip(string.format(Config.SharedEmoteRequestSentText, GetPlayerServerIdFromPed(closestPed)))
	elseif Config.SharedEmoteOnPeds and closestPed and closestPed > -1 then
		ClearPedTasksImmediately(closestPed)
		ClearPedSecondaryTask(closestPed)
		NetworkRequestControlOfEntity(closestPed)
		SetEntityCollision(closestPed, false, true)
		FreezeEntityPosition(closestPed, true)
		local pos = emote.partner.offset or vector4(0.0, 0.0, 0.0, 0.0)
		if emote.partner.boneZalign then
			local playerBone = GetEntityBoneIndexByName(playerPed, emote.partner.boneZalign.player)
			local partnerBone = GetEntityBoneIndexByName(closestPed, emote.partner.boneZalign.partner)
			local playerBonePos = GetWorldPositionOfEntityBone(playerPed, playerBone)
			local partnerBonePos = GetWorldPositionOfEntityBone(closestPed, partnerBone)
			local boneZDiff = playerBonePos.z - partnerBonePos.z
			local posZ = pos.z + (boneZDiff < 0 and boneZDiff or -boneZDiff)
			if playerBone > 0 and partnerBone > 0 then
				pos = vector4(pos.x, pos.y, posZ, pos.w)
			end
		end
		local boneIndex = emote.partner.attatchToPedBone and GetEntityBoneIndexByName(playerPed, emote.partner.attatchToPedBone) or 11816
		if emote.partner.animation.dontAttach then
			TeleportToPartner(closestPed, playerPed, emote)
		else
			AttachEntityToEntity(closestPed, playerPed, boneIndex, pos.x, pos.y, pos.z, rot and rot.x, rot and rot.y, rot and rot.z or pos.w, false, true, false, true, 2, true)
		end
		PlayAnimation(closestPed, emote.partner.animation)
		CurrentEmote = emote
		setCurrentlyEmoting()
		AnimationStartTime = GetGameTimer()
		AnimationKey = emote.name or "shared_emote_with_ped"
		once = false
		StartCurrentEmoteRuntimeThread()
	else
		mosquito.notify.right_tip(Config.SharedEmoteInvalidTargetText)
		return
	end
end

function AcceptSharedEmoteRequest()
	local playerPed = PlayerPedId()
	local partner = GetPlayerPedFromServerId(SharedEmoteRequest.player)
	local partnerCoords = GetEntityCoords(partner)
	TriggerServerEvent("emotes:acceptSharedEmote", SharedEmoteRequest.player, SharedEmoteRequest.emote, partnerCoords)
	NetworkRequestControlOfEntity(partner)
	FreezeEntityPosition(playerPed, true)
	SetEntityCollision(playerPed, false, true)
	local pos = SharedEmoteRequest.emote.partner.offset or vector4(0.0, 0.0, 0.0, 0.0)
	local rot = SharedEmoteRequest.emote.partner.rotation or nil
	if SharedEmoteRequest.emote.partner.boneZalign then
		local playerBone = GetEntityBoneIndexByName(playerPed, SharedEmoteRequest.emote.partner.boneZalign.player)
		local partnerBone = GetEntityBoneIndexByName(partner, SharedEmoteRequest.emote.partner.boneZalign.partner)
		local playerBonePos = GetWorldPositionOfEntityBone(playerPed, playerBone)
		local partnerBonePos = GetWorldPositionOfEntityBone(partner, partnerBone)
		local boneZDiff = playerBonePos.z - partnerBonePos.z
		local posZ = pos.z + (boneZDiff < 0 and boneZDiff or -boneZDiff)
		if playerBone > 0 and partnerBone > 0 then
			pos = vector4(pos.x, pos.y, posZ, pos.w)
		end
	end
	local boneIndex = SharedEmoteRequest.emote.partner.attatchToPedBone and GetEntityBoneIndexByName(playerPed, SharedEmoteRequest.emote.partner.attatchToPedBone) or 11816
	if SharedEmoteRequest.emote.partner.animation.dontAttach then
		TeleportToPartner(playerPed, partner, SharedEmoteRequest.emote)
	else
		AttachEntityToEntity(playerPed, partner, boneIndex, pos.x, pos.y, pos.z, rot and rot.x, rot and rot.y, rot and rot.z or pos.w, false, true, false, true, 2, true)
	end
	isAttachedToOther = true
	local emote = SharedEmoteRequest.emote.partner
	emote.name = SharedEmoteRequest.emote.name
	emote.nonInterruptible = SharedEmoteRequest.emote.nonInterruptible
	emote.interruptible = SharedEmoteRequest.emote.interruptible
	emote.partner = { ped = partner }

	SharedEmoteRequest = nil
	CurrentEmote = emote
	for i = 1, 3 do
		mosquito.notify.right_tip(" ")
	end
	setCurrentlyEmoting()
	-- Track animation start
	AnimationStartTime = GetGameTimer()
	AnimationKey = emote.name or "accepted_shared_emote"
	once = false
	StartCurrentEmoteRuntimeThread()
end

function RejectSharedEmoteRequest()
	TriggerServerEvent("emotes:rejectSharedEmote", SharedEmoteRequest.player, SharedEmoteRequest.emote)
	SharedEmoteRequest = nil
	for i = 1, 3 do
		mosquito.notify.right_tip(" ")
	end
end

function StopCurrentScenario(ped, clearTasks)
	ped = ped or PlayerPedId()
	if not CurrentScenario then
		return false
	end

	if clearTasks then
		ClearPedTasks(ped)
	end

	if IsPedUsingAnyScenario(ped) then
		Citizen.InvokeNative(0xFCCC886EDE3C63EC, ped, false, true, true)
		HidePedWeapons(ped, 2, 1)
		ClearPedSecondaryTask(ped)
	end

	CurrentScenario = nil
	return true
end

function ScenarioCommand(source, args, rawCommand)
	local ped = PlayerPedId()
	if not ped and not CanPlayerStartScenario() then
		return
	end
	if not args[1] then
		StopCurrentScenario(ped, true)
		return
	end
	local key = args[1]
	if Config and Config.Scenarios and Config.Scenarios[key] then
		if IsPedOnMount(ped) then
			return
		end
		if CurrentScenario then
			StopCurrentScenario(ped, true)
			ClearPedTasksImmediately(ped)
		end
		TaskStartScenarioInPlace(ped, GetHashKey(Config.Scenarios[key].scenario), -1, true)
		CurrentScenario = key
	else
		ShowNotification("Invalid scenario key: " .. key)
	end
end

function EmoteCommand(source, args, raw)
	if args[1] then
		if Config.Emotes[args[1]] then
			local emote = Config.Emotes[args[1]]
			if emote.dogemote then
				if not IsPedHuman(PlayerPedId()) then
					StartUsingEmote(args[1])
				else
					return
				end
			else
				if IsPedHuman(PlayerPedId()) == 1 then
					StartUsingEmote(args[1])
				end
			end
		else
			ShowNotification("Emote not found: " .. args[1])
		end
	else
		StopUsingEmote()
	end
end

function GetEmotes()
	local soloEmotes = {}
	local sharedEmotes = {}
	local propEmotes = {}

	for emote, info in pairs(Config.Emotes) do
		if info.type == "solo" then
			table.insert(soloEmotes, { name = info.name, command = emote })
		elseif info.type == "shared" then
			table.insert(sharedEmotes, { name = info.name, command = emote })
		elseif info.type == "prop" then
			table.insert(propEmotes, { name = info.name, command = emote })
		end
	end

	table.sort(soloEmotes, function(a, b) return a.name < b.name end)
	table.sort(sharedEmotes, function(a, b) return a.name < b.name end)
	table.sort(propEmotes, function(a, b) return a.name < b.name end)

	return {
		{ name = "Solo Emotes",   emotes = soloEmotes },
		{ name = "Shared Emotes", emotes = sharedEmotes },
		{ name = "Prop Emotes",   emotes = propEmotes },
	}
end

function GetEmotesAsJson()
	return json.encode(GetEmotes())
end

exports("getEmotes", GetEmotes)
exports("getEmotesAsJson", GetEmotesAsJson)

AddEventHandler("emotes:requestSharedEmote", function(player, emote)
	SharedEmoteRequest = { player = player, emote = emote, expires = GetSystemTime() + Config.SharedEmoteTimeout }
end)

AddEventHandler("emotes:rejectSharedEmote", function(player, emote)
	mosquito.notify.right_tip(string.format(Config.SharedEmoteHasBeenRejectedText, tostring(player)))
end)

AddEventHandler("emotes:acceptSharedEmote", function(player, emote, partnerCoords)
	local ped = PlayerPedId()
	SetEntityCoordsNoOffset(ped, partnerCoords.x, partnerCoords.y, partnerCoords.z)
	CurrentEmote = emote
	setCurrentlyEmoting()
	AnimationStartTime = GetGameTimer()
	AnimationKey = emote.name or "initiated_shared_emote"
	once = false
	StartCurrentEmoteRuntimeThread()
end)

local function IsMatchingSharedStopEvent(currentEmote, incomingEmote)
	if not currentEmote or not incomingEmote then
		return false
	end

	if currentEmote.name and incomingEmote.name and currentEmote.name == incomingEmote.name then
		return true
	end

	local currentAnim = currentEmote.animation
	local incomingAnim = incomingEmote.animation
	if currentAnim and incomingAnim and currentAnim.dict and incomingAnim.dict and currentAnim.name and incomingAnim.name then
		return currentAnim.dict == incomingAnim.dict and currentAnim.name == incomingAnim.name
	end

	return false
end

RegisterNetEvent("mosquito:client:SyncPlayerCollision")
AddEventHandler("mosquito:client:SyncPlayerCollision", function(src, collision)
	if not src then
		if debugmode then
			print("src is invalid")
		end
		return
	end
	local srcPlayerId = GetPlayerFromServerId(src)
	if not srcPlayerId or srcPlayerId < 1 then
		if debugmode then
			print("Player Id Doesn't exist for player server id: ", src)
		end
	end
	local srcPedId = GetPlayerPed(srcPlayerId)
	if srcPedId and srcPedId > 0 then
		SetEntityCollision(ped, collision, collision)
	else
		if debugmode then
			print("Player is too far to sync collision")
		end
	end
end)

AddEventHandler("emotes:stopSharedEmote", function(player, emote)
	if not CurrentEmote then
		return
	end

	if emote and not IsMatchingSharedStopEvent(CurrentEmote, emote) then
		if debugmode then
			print(string.format("Ignored stale stopSharedEmote event. Current=%s Incoming=%s", tostring(CurrentEmote.name), tostring(emote.name)))
		end
		return
	end

	StopUsingEmote()
end)

local handsUpAnimDict = 'script_proc@robberies@shop@rhodes@gunsmith@inside_upstairs'
local handsUpAnimName = 'handsup_register_owner'

function handleCancelControl(ped)
	if IsControlJustPressed(0, Config.CancelControl) and not IsEntityPlayingAnim(ped, handsUpAnimDict, handsUpAnimName, 3) then
		if not isHandsUp then
			if CurrentEmote then
				StopUsingEmote()
				if IsPedUsingAnyScenario(ped) then
					Citizen.InvokeNative(0xFCCC886EDE3C63EC, ped, false, true, true)
				end
			elseif state.isPointing then
				StopPointing()
			elseif CurrentlySitting then
				stopInteraction(ped)
				StopInteraction(ped)
			elseif Config.CancelControlClearsPedTasks then
				ClearPedTasks(ped)
				HidePedWeapons(ped, 2, 1)
				if IsPedUsingAnyScenario(ped) then
					Citizen.InvokeNative(0xFCCC886EDE3C63EC, ped, false, true, true)
				end
			end
		end
		if CurrentScenario then
			StopCurrentScenario(ped, true)
		end
	end
end

local function handleSharedEmoteRequest()
	if SharedEmoteRequest then
		if SharedEmoteRequest.expires <= GetSystemTime() then
			RejectSharedEmoteRequest()
		else
			DrawSharedEmoteRequestText()
			if not askedOnce then
				if Config.SharedEmoteMustAccept then
					mosquito.notify.right_tip(AcceptText, Config.SharedEmoteTimeout)
					mosquito.notify.right_tip(RejectText, Config.SharedEmoteTimeout)
				end
				askedOnce = true
			end

			DisableControlAction(0, Config.SharedEmoteAcceptControl, true)
			DisableControlAction(0, Config.SharedEmoteRejectControl, true)

			if IsDisabledControlJustPressed(0, Config.SharedEmoteAcceptControl) or Config.SharedEmoteMustAccept == false then
				if CurrentEmote then
					StopUsingEmote()
				end
				AcceptSharedEmoteRequest()
			elseif IsDisabledControlJustPressed(0, Config.SharedEmoteRejectControl) then
				RejectSharedEmoteRequest()
			end
		end
	else
		if askedOnce then
			askedOnce = false
			for i = 1, 3 do
				mosquito.notify.right_tip(" ")
			end
		end
	end
end

local function handleAnimationState(ped)
	if CurrentEmote then
		local anim = CurrentEmote.animation
		local sharedWalking = (CurrentEmote.partner and CurrentEmote.partner.ped and anim.walking) or nil
		if sharedWalking then
			local isPedMoving = IsPedStill(anim.victim and CurrentEmote.partner.ped or ped) == false
			if isPedMoving and not wasMoving then
				StopAnimation(ped, anim)
				anim.flag = anim.walkingFlag
				anim.name = anim.walkingName
				wasMoving = true
			elseif not isPedMoving and wasMoving then
				StopAnimation(ped, anim)
				anim.name = anim.stoppedName
				anim.flag = anim.stoppedFlag
				wasMoving = false
			end
		end
		local isPlayingAnim = IsEntityPlayingAnim(ped, anim.dict, anim.name, 3)
		if (anim.repeating or anim.keepPlaying == true) and not isPlayingAnim then
			PlayAnimation(ped, anim)
		elseif not once then
			PlayAnimation(ped, anim)
			once = true
		end

		if anim.flag == 4 or anim.flag == 28 then
			if not LastAnimTime then
				LastAnimTime = GetGameTimer()
				AnimStoppedDetected = false
			end

			if isPlayingAnim then
				LastAnimTime = GetGameTimer()
				AnimStoppedDetected = false
			else
				local elapsed = GetGameTimer() - LastAnimTime
				if elapsed > 250 and not AnimStoppedDetected then
					AnimStoppedDetected = true
					StopUsingEmote()
				end
			end
		end
	else
		LastAnimTime = nil
	end
end

local sitBehindPrompt = nil
local sitBehindPromptCreated = false

local sitLedgePrompt = nil
local sitLedgePromptCreated = false

function deleteSitBehindPrompt()
	UiPromptSetVisible(sitBehindPrompt, false)
	UiPromptSetEnabled(sitBehindPrompt, false)
	UiPromptDelete(sitBehindPrompt)
	sitBehindPrompt = nil
	sitBehindPromptCreated = false
end

function createSitBehindPrompt()
	if sitBehindPromptCreated then
		deleteSitBehindPrompt()
	end
	sitBehindPrompt = UiPromptRegisterBegin()
	local UsingKeyboard = IsUsingKeyboardAndMouse() == 1
	local promptControl = UsingKeyboard and Config.SitBehindControl.Keyboard or Config.SitBehindControl.Controller
	UiPromptSetControlAction(sitBehindPrompt, GetHashKey(promptControl))
	UiPromptSetText(sitBehindPrompt, CreateVarString(10, "LITERAL_STRING", Config.SitBehindPromptText))
	UiPromptSetEnabled(sitBehindPrompt, true)
	UiPromptSetVisible(sitBehindPrompt, true)
	UiPromptSetStandardMode(sitBehindPrompt, true)
	UiPromptRegisterEnd(sitBehindPrompt)
	sitBehindPromptCreated = true
end

function deleteSitLedgePrompt()
	UiPromptSetVisible(sitLedgePrompt, false)
	UiPromptSetEnabled(sitLedgePrompt, false)
	UiPromptDelete(sitLedgePrompt)
	sitLedgePrompt = nil
	sitLedgePromptCreated = false
end

function createSitLedgePrompt()
	if sitLedgePromptCreated then
		deleteSitLedgePrompt()
	end
	sitLedgePrompt = UiPromptRegisterBegin()
	local UsingKeyboard = IsUsingKeyboardAndMouse() == 1
	local promptControl = UsingKeyboard and Config.SitLedgeControl.Keyboard or Config.SitLedgeControl.Controller
	UiPromptSetControlAction(sitLedgePrompt, GetHashKey(promptControl))
	UiPromptSetText(sitLedgePrompt, CreateVarString(10, "LITERAL_STRING", Config.SitLedgePromptText))
	UiPromptSetEnabled(sitLedgePrompt, true)
	UiPromptSetVisible(sitLedgePrompt, true)
	UiPromptSetStandardMode(sitLedgePrompt, true)
	UiPromptRegisterEnd(sitLedgePrompt)
	sitLedgePromptCreated = true
end

local function ledgeSittingHandler(ped)
	if emoteMenuOpen then
		if not sitLedgePromptCreated then
			createSitLedgePrompt()
		end
		local UsingKeyboard = IsUsingKeyboardAndMouse() == 1
		local promptControl = UsingKeyboard and Config.SitLedgeControl.Keyboard or Config.SitLedgeControl.Controller

		local isControlPressed = IsControlJustPressed(0, GetHashKey(promptControl)) or IsDisabledControlJustPressed(0, GetHashKey(promptControl))
		if UiPromptHasStandardModeCompleted(sitLedgePrompt) or isControlPressed then
			emoteMenuOpen = false
			sitLedgeCommand()
		end
	else
		if sitLedgePromptCreated then
			deleteSitLedgePrompt()
		end
	end
end

local function behindSittingHandler(ped)
	if emoteMenuOpen then
		if not sitBehindPromptCreated then
			createSitBehindPrompt()
		end
		local UsingKeyboard = IsUsingKeyboardAndMouse() == 1
		local promptControl = UsingKeyboard and Config.SitBehindControl.Keyboard or Config.SitBehindControl.Controller

		local isControlPressed = IsControlJustPressed(0, GetHashKey(promptControl)) or IsDisabledControlJustPressed(0, GetHashKey(promptControl))
		if UiPromptHasStandardModeCompleted(sitBehindPrompt) or isControlPressed then
			emoteMenuOpen = false
			sitBehindCommand()
		end
	else
		if sitBehindPromptCreated then
			deleteSitBehindPrompt()
		end
	end
end

local function PauseMenuAnimation()
	if CurrentEmote then
		if CurrentEmote.animation.dict ~= "mech_inspection@letter@satchel" and CurrentEmote.animation.dict ~= "mech_inspection@two_fold_map@satchel" then
			return
		end
	end
	if (CurrentlySitting or CurrentlyInteracting or CurrentScenario or CurrentInteraction) then
		return
	end
	if (wasOpen or IsControlJustPressed(0, 0xE31C6A41) or IsPauseMenuActive()) then
		local ped = PlayerPedId()
		local paused = IsPauseMenuActive()
		local radarHidden = IsRadarHidden()
		local radarPreferenceOn = IsRadarPreferenceSwitchedOn()
		local radarHiddenByScript = IsRadarHiddenByScript() == 1
		local inFirstPerson = IsInFullFirstPersonMode()
		local _, currentWeaponHash = GetCurrentPedWeapon(ped, true)
		local isWeaponKit = IsWeaponKit(currentWeaponHash)
		local ADS = IsFirstPersonAimCamActive()
		local cam = GetRenderingCam()
		local isDead = IsPedDeadOrDying(ped)
		local CinematicMode = IsInCinematicMode() == 1
		local CinematicCamRendering = IsCinematicCamRendering() == 1
		local Cinematic = CinematicMode and CinematicCamRendering
		local ms = GetControlHowLongAgo()
		local afk = ms > 160000
		local CinematicNotAfk = Cinematic and not afk or IsControlPressed(0, 0x620A6C5E)

		if (isWeaponKit == 0 or isWeaponKit == false) and cam == -1 and not ADS and not isDead then
			if paused then
				if not wasOpen then
					wasOpen = true
					paperOpened = true
					SetCurrentPedWeapon(PlayerPedId(), GetHashKey('WEAPON_UNARMED'), true)
					ExecuteCommand(Config.EmoteCommand .. " letteropen1")
					local time = GetGameTimer()
					CreateThread(function()
						while GetGameTimer() - time < 2000 do
							DisableAllControlActions(0)
							Wait(0)
						end
					end)
				end
			elseif not paused and (radarPreferenceOn and radarHidden and not radarHiddenByScript) and not CinematicNotAfk then
				if not wasOpen then
					wasOpen = true
					mapOpened = true
					SetCurrentPedWeapon(PlayerPedId(), GetHashKey('WEAPON_UNARMED'), true)
					ExecuteCommand(Config.EmoteCommand .. " mapopen")
				end
			else
				if wasOpen then
					wasOpen = false
					if paperOpened then
						paperOpened = false
						ExecuteCommand(Config.EmoteCommand .. " letterclose1")
					elseif mapOpened then
						mapOpened = false
						ExecuteCommand(Config.EmoteCommand .. " mapclose")
					end
				end
			end
		end
	end
end

CreateThread(function()
	Wait(1000)
	TriggerEvent("chat:addSuggestion", "/emote", "Use an emote", {
		{ name = "emote", help = "Emote to use, or omit to cancel the current emote" }
	})
	TriggerEvent("chat:addSuggestion", "/e", "Use an emote", {
		{ name = "emote", help = "Emote to use, or omit to cancel the current emote" }
	})
	TriggerEvent("chat:addSuggestion", "/emoteSwitch", "Make emote uninterruptable", {
		{ name = "", help = "Switch between interruptable and uninterruptable" }
	})
	while true do
		local ped = PlayerPedId()

		handleSharedEmoteRequest()

		local UsingKeyboard = IsUsingKeyboardAndMouse() == 1

		if UsingKeyboard and emotesPerPage ~= Config_QuickMenu.EmotesPerPage["keyboard"] then
			emotesPerPage = Config_QuickMenu.EmotesPerPage["keyboard"]
		elseif not UsingKeyboard and emotesPerPage ~= Config_QuickMenu.EmotesPerPage["controller"] then
			emotesPerPage = Config_QuickMenu.EmotesPerPage["controller"]
		end

		IsUsingController = not UsingKeyboard

		if Config_QuickMenu.Enabled and not vorpMenuOpen then
			QuickEmoteMenuHandler()
		end
		if Config.CancelControl then
			handleCancelControl(ped)
		end
		if Config.HandsUpControl then
			handsUpControl(ped)
		end
		if Config.PauseMenuAndMapAnimations then
			PauseMenuAnimation()
		end
		if Config.Pointing then
			UpdatePointing(ped)
		end
		ApplyGlobalWalkBlendRatioIfNeeded(ped)
		if Config.EnableRegularVORPMenu and Config.RegularVORPMenuKeybind and type(Config.RegularVORPMenuKeybind) == "table" and not emoteMenuOpen then
			handleMenuKeybind()
		end
		if Config_InteractionMenu.EnableInteractionMenu then
			handleInteractionMenu(ped)
		end
		if Config.SitBehindPromptEnabled then
			ledgeSittingHandler(ped)
		end
		if Config.SitLedgePromptEnabled then
			behindSittingHandler(ped)
		end
		Wait(0)
	end
end)

if Config.LeaningRailingFeatureEnabled then
	CreateThread(function()
		local waitTime = 1000
		while true do
			Wait(waitTime)
			local playerPed = PlayerPedId()
			local playerCoords = GetEntityCoords(playerPed)
			local forwardVector = GetEntityForwardVector(playerPed)
			local closestProp = nil
			local closestDist = 2.0

			local allowedModelHashes = {}
			for _, propModel in ipairs(Config.RailingProps) do
				table.insert(allowedModelHashes, GetHashKey(propModel))
			end

			local entities = GetEntitiesInRadius(playerCoords.x, playerCoords.y, playerCoords.z, 2.0, 3, true, allowedModelHashes)

			for i = 1, #entities do
				local obj = entities[i]
				if DoesEntityExist(obj) then
					local objCoords = GetEntityCoords(obj)
					local toObj = objCoords - playerCoords
					local dist = #(toObj)
					local dot = (forwardVector.x * toObj.x + forwardVector.y * toObj.y + forwardVector.z * toObj.z) / (dist + 0.001)
					if dot > 0.5 then
						closestDist = dist
						closestProp = obj
						break
					end
				end
			end

			if closestProp then
				CreateThread(function()
					local startTime = GetGameTimer()
					local interacted = false
					while GetGameTimer() - startTime < waitTime do
						if DoesEntityExist(closestProp) then
							local coords = GetEntityCoords(closestProp)
							DrawText3D(coords.x, coords.y, coords.z + 1.0, "Press [E] to interact with prop")
							if IsControlJustPressed(0, 0xCEFD9220) then -- [E] key
								interacted = true
								local ped = PlayerPedId()
								local pedCoords = GetEntityCoords(ped)
								local dir = vector3(coords.x - pedCoords.x, coords.y - pedCoords.y, coords.z - pedCoords.z)
								local dist = #(dir)
								if dist > 0 then
									dir = dir / dist
								end
								local target = vector3(
									coords.x - dir.x * 0.7,
									coords.y - dir.y * 0.7,
									coords.z
								)
								TaskGoStraightToCoord(ped, target.x, target.y, target.z, 1.0, 2000, 0.0, 0.0)
								Wait(2000)
								TaskTurnPedToFaceEntity(ped, closestProp, 1000, 1.0, 1.0, 1.0)
								Wait(1000)
								-- Show 3D text for options
								local optionActive = true
								while optionActive do
									if DoesEntityExist(closestProp) then
										local optCoords = GetEntityCoords(closestProp)
										local pedCoords = GetEntityCoords(ped)
										local dist = #(optCoords - pedCoords)
										if dist > 2.0 then
											optionActive = false
											break
										end
										DrawText3D(optCoords.x, optCoords.y, optCoords.z + 1.1, "Press [1] for Low, [2] for High")
										DisableControlAction(0, 0x52D29063, true) -- [1] key
										DisableControlAction(0, 0x1CE6D9EB, true) -- [2] key
										DisableControlAction(0, 0x156F7119, true) -- [ESC] key
										if IsDisabledControlJustPressed(0, 0x52D29063) then -- [1] key
											ExecuteCommand("s leanrailing")
											optionActive = false
											break
										elseif IsDisabledControlJustPressed(0, 0x1CE6D9EB) then -- [2] key
											ExecuteCommand("s leanfencehigh")
											optionActive = false
											break
										elseif IsDisabledControlJustPressed(0, 0x156F7119) then -- [ESC] key to cancel
											optionActive = false
											break
										end
									else
										break
									end
									Wait(0)
								end
								break
							end
						else
							break
						end
						Wait(0)
					end
				end)
			end
		end
	end)
end

function handsUpControl(ped)
	local animDict = 'script_proc@robberies@shop@rhodes@gunsmith@inside_upstairs'
	local animName = 'handsup_register_owner'
	local isPressed
	local isAlive = not IsEntityDead(ped)
	local inputActive = IsInputDisabled(0)
	local OptionType = IsUsingController and "Controller" or "Keyboard"
	local isPressed = IsControlJustPressed(0, Config.HandsUpControl[OptionType]) and not CurrentlyEmoting
	if IsEntityPlayingAnim(ped, animDict, animName, 3) then
		if not isHandsUp then
			isHandsUp = true
		end
	else
		if isHandsUp then
			isHandsUp = false
		end
	end

	if isPressed and inputActive and isAlive then
		SetCurrentPedWeapon(ped, joaat('WEAPON_UNARMED'), true)
		DisablePlayerFiring(ped, true)

		if IsEntityPlayingAnim(ped, animDict, animName, 3) then
			ClearPedSecondaryTask(ped)
		elseif not IsEntityPlayingAnim(ped, animDict, animName, 3) then
			if not HasAnimDictLoaded(animDict) then
				RequestAnimDict(animDict)
				while not HasAnimDictLoaded(animDict) do
					Wait(0)
				end
			end

			TaskPlayAnim(ped, animDict, animName, 1.0, -1.0, -1, 30, 0, true, (1 << 16), false, "arms_filter", false)
			RemoveAnimDict(animDict)
		end
	end
end

CreateThread(function()
	Wait(3000)
	local scenariosCount = 0
	local emotesCount = 0
	local nativeEmotesCount = 0
	for k, v in pairs(Config.Scenarios) do
		scenariosCount = scenariosCount + 1
	end
	for k, v in pairs(Config.Emotes) do
		emotesCount = emotesCount + 1
	end
	for k, v in pairs(Config.NativeEmotes) do
		nativeEmotesCount = nativeEmotesCount + 1
	end
	local total = emotesCount + nativeEmotesCount + scenariosCount
end)

local leavePrompt = nil
local leavePromptCreated = false

function deleteLeavePrompt()
	if leavePrompt then
		UiPromptSetVisible(leavePrompt, false)
		UiPromptSetEnabled(leavePrompt, false)
		UiPromptDelete(leavePrompt)
		leavePrompt = nil
		leavePromptCreated = false
	end
end

function createLeavePrompt(text)
	if leavePromptCreated then
		deleteLeavePrompt()
	end
	leavePrompt = UiPromptRegisterBegin()
	UiPromptSetControlAction(leavePrompt, GetHashKey("INPUT_MELEE_ATTACK"))
	UiPromptSetText(leavePrompt, CreateVarString(10, "LITERAL_STRING", text or "Leave"))
	UiPromptSetEnabled(leavePrompt, true)
	UiPromptSetVisible(leavePrompt, true)
	UiPromptSetStandardMode(leavePrompt, true)
	UiPromptRegisterEnd(leavePrompt)
	leavePromptCreated = true
end

-- 2048 is ragdolled horses and horses, 1024 is horses alone, 4 is peds alone, 8 is peds ragdolled and peds,
local intersect_flag_enum = {
	World = 1,
	Vehicles = 2,
	Peds = 4,
	Ragdolls = 8,
	Objects = 16,
	Pickup = 32,
	Glass = 64,
	River = 128,
	Foliage = 256
}

local SittingEntityIntersectionFlags = intersect_flag_enum.Objects + intersect_flag_enum.World + intersect_flag_enum.Glass + intersect_flag_enum.Vehicles
local wallCheckIntersectionFlags = SittingEntityIntersectionFlags + 1024 + 2048 + 4 + 8

ResolveSittingBaseEntity = function() end

local function CheckWallBetweenCoords(coords, sCoords, ped, rayCount)
	local requestedRayCount = tonumber(rayCount) or 1
	local normalizedRayCount = math.max(1, math.floor(requestedRayCount))
	if normalizedRayCount % 2 == 0 then
		normalizedRayCount = normalizedRayCount + 1
	end

	local direction = vector3(sCoords.x - coords.x, sCoords.y - coords.y, 0.0)
	local directionMagnitude = #(direction)
	if directionMagnitude <= 0.001 then
		local fwd = GetEntityForwardVector(ped)
		direction = vector3(fwd.x, fwd.y, 0.0)
		directionMagnitude = #(direction)
	end
	if directionMagnitude > 0.001 then
		direction = direction / directionMagnitude
	else
		direction = vector3(1.0, 0.0, 0.0)
	end

	local rightVector = vector3(-direction.y, direction.x, 0.0)
	local sideSteps = math.floor(normalizedRayCount / 2)
	local maxLateralOffset = 0.3
	local raysToDraw = {}
	local hitDetected = false

	for i = -sideSteps, sideSteps do
		local lateralOffset = 0.0
		if sideSteps > 0 then
			lateralOffset = (i / sideSteps) * maxLateralOffset
		end
		local offset = rightVector * lateralOffset
		local rayHeight = sCoords.z + 0.2
		local rayStart = vector3(coords.x, coords.y, rayHeight)
		local rayEnd = vector3(sCoords.x + offset.x, sCoords.y + offset.y, rayHeight)
		local retval, hit, hitCoords, surfaceNormal, entityHit = GetShapeTestResult(StartShapeTestRay(rayStart.x, rayStart.y, rayStart.z, rayEnd.x, rayEnd.y, rayEnd.z, wallCheckIntersectionFlags, ped, 4))
		hit = hit and hit ~= 0
		hitDetected = hit

		if debugmode then
			table.insert(raysToDraw, {
				start = rayStart,
				finish = rayEnd,
				hit = hit
			})
		end
	end

	if debugmode and #raysToDraw > 0 then
		CreateThread(function()
			local startTime = GetGameTimer()
			local duration = 10000
			while GetGameTimer() - startTime < duration do
				for _, rayData in ipairs(raysToDraw) do
					local color = rayData.hit and { r = 255, g = 0, b = 255 } or { r = 0, g = 255, b = 255 }
					DrawLine(rayData.start.x, rayData.start.y, rayData.start.z, rayData.finish.x, rayData.finish.y, rayData.finish.z, color.r, color.g, color.b, 255)
				end
				Wait(0)
			end
		end)
	end

	return hitDetected
end

function startDrawingMarker(coordsTable, samples, selected_index, sittingIndexOffset, E, main)
	local startTime = GetGameTimer()
	local duration = 10000
	local posEIndex = math.min(selected_index + E, #coordsTable)
	local negEIndex = math.max(selected_index - E, 1)
	CreateThread(function()
		while GetGameTimer() - startTime < duration do
			for i, coords in ipairs(coordsTable) do
				local rgb = { r = main and 255 or 0, g = 0, b = main and 0 or 255 }
				if i == selected_index then
					rgb = { r = 255, g = 255, b = 255 }
				elseif i == selected_index - sittingIndexOffset then
					rgb = { r = 0, g = 255, b = 0 }
				elseif i == negEIndex or i == posEIndex then
					rgb = { r = 255, g = 255, b = 0 }
				end
				DrawMarker(0x50638AB9, coords.x, coords.y, coords.z + 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.03, 0.03, 0.03, rgb.r, rgb.g, rgb.b, 50, false, true, 2, nil, nil, false)
			end
			Wait(0)
		end
	end)
end

local function IsVehicleSafeForSitting(baseEntity, seatEntity)
	if not baseEntity or not DoesEntityExist(baseEntity) then
		return false
	end

	if GetEntityType(baseEntity) ~= 2 then
		return false
	end

	if not IsVehicleOnAllWheels(baseEntity) then
		return false
	end

	local rotation = GetEntityRotation(baseEntity, 2)
	local pitch = math.abs(rotation.x)
	local roll = math.abs(rotation.y)
	if pitch > 25.0 or roll > 20.0 then
		return false
	end

	if seatEntity and seatEntity ~= 0 and seatEntity ~= baseEntity then
		if not DoesEntityExist(seatEntity) then
			return false
		end
	end

	return true
end

local function CheckSittingEntityStability()
	if not CurrentlySittingOnVehicle then
		return false
	end

	if CurrentSeatEntity then
		if not DoesEntityExist(CurrentSeatEntity) then
			return true
		end
	end

	if CurrentBaseEntity then
		if not DoesEntityExist(CurrentBaseEntity) then
			return true
		end

		local currentRotation = GetEntityRotation(CurrentBaseEntity, 2)
		local pitch = math.abs(currentRotation.x)
		local roll = math.abs(currentRotation.y)

		if pitch > 25.0 or roll > 20.0 then
			print("Vehicle tipped over - triggering fall. Pitch:", pitch, "Roll:", roll)
			return true
		end
		local onFire = IsVehicleOnFire(CurrentBaseEntity)
		onFire = onFire and onFire ~= 0 or false
		if onFire then
			print("Vehicle is on fire - triggering fall.")
			return true
		end
	end

	return false
end

function groundZAt(ped, x, y, z)
	local retval, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(StartShapeTestRay(x, y, z + 0.5, x, y, z - 100.0, SittingEntityIntersectionFlags, ped, 4))
	local entityHitType = GetEntityType(entityHit)
	return (hit and endCoords.z or z), entityHitType, entityHit and entityHit ~= 0 and entityHit or nil
end

function stopInteraction(ped, originCoords)
	local sittingType = CurrentSittingType
	local currentPedCoords = GetEntityCoords(ped)
	local coords = originCoords or CurrentOriginCoords or currentPedCoords
	CurrentlySitting = false
	CurrentSittingType = nil
	CurrentlySittingOnVehicle = false
	CurrentOriginCoords = nil

	CurrentSeatEntity = nil
	CurrentBaseEntity = nil

	ClearPedTasks(ped, 1, true)
	ClearPedSecondaryTask(ped)
	HidePedWeapons(ped, 2, 1)
	if IsEntityAttached(ped) then
		DetachEntity(ped, true, true)
	end
	if coords then
		local currentCoords = GetEntityCoords(ped)
		local fwdVector = GetEntityForwardVector(ped)
		local distFromOrigin = #(vector3(currentPedCoords.x, currentPedCoords.y, currentPedCoords.z) - vector3(coords.x, coords.y, coords.z))
		local doTeleport = (sittingType == "ledge" and Config.SitLedgeTeleport) or (sittingType == "behind" and Config.SitBehindTeleport)
		local baseEntity = ResolveSittingBaseEntity(ped, nil)
		local isOnTrainOrVehicle = baseEntity and GetEntityType(baseEntity) == 2 or false

		if distFromOrigin < 3.5 and doTeleport then
			SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, true)
			SetPedDesiredHeading(ped, coords.w)
			SetEntityHeading(ped, coords.w)
		elseif sittingType == "ledge" and isOnTrainOrVehicle then
			local slightlyBackedUpCoords = vector3(currentPedCoords.x - fwdVector.x * 0.3, currentPedCoords.y - fwdVector.y * 0.3, currentPedCoords.z + 0.5)
			local wallHit = CheckWallBetweenCoords(currentCoords, slightlyBackedUpCoords, ped)
			if not wallHit then
				ClearPedTasksImmediately(ped, true, true)
				SetEntityCoordsNoOffset(ped, slightlyBackedUpCoords.x, slightlyBackedUpCoords.y, slightlyBackedUpCoords.z, false, true)
			else
				mosquito.notify.right_tip("~COLOR_RED~Wall blocked teleport path.~q~")
			end
		elseif sittingType == "behind" and isOnTrainOrVehicle then
			local slightlyForwardCoords = vector3(currentPedCoords.x + fwdVector.x * 0.3, currentPedCoords.y + fwdVector.y * 0.3, currentPedCoords.z + 0.5)
			local wallHit = CheckWallBetweenCoords(currentCoords, slightlyForwardCoords, ped)
			if not wallHit then
				ClearPedTasksImmediately(ped, true, true)
				SetEntityCoordsNoOffset(ped, slightlyForwardCoords.x, slightlyForwardCoords.y, slightlyForwardCoords.z, false, true)
			else
				mosquito.notify.right_tip("~COLOR_RED~Wall blocked teleport path.~q~")
			end
		end
	end
end

function startLeavePromptWatcher(pedEntity, scenarioHash, originCoords, duration, sitBehind, isInAVehicle, tooHighForIntroAnim)
	CreateThread(function()
		local scenarioStartTime = GetGameTimer()
		local gameTime = GetGameTimer()
		local timeTilBreak = 500 -- if we don't detect the player using the scenario for this long, we assume they got up without using the prompt
		local timesUp = false
		local pressed = false
		local isDead = false
		local isUsingScenario = IsPedUsingScenarioHash(pedEntity, scenarioHash)
		while DoesEntityExist(pedEntity) and (not isDead and isDead ~= 0) and CurrentlySitting do
			gameTime = GetGameTimer()
			isUsingScenario = IsPedUsingScenarioHash(pedEntity, scenarioHash)
			isUsingScenario = isUsingScenario and isUsingScenario ~= 0
			isDead = IsPedDeadOrDying(pedEntity)

			if CheckSittingEntityStability() then
				deleteLeavePrompt()
				local currentCoords = GetEntityCoords(pedEntity)
				SetEntityCoordsNoOffset(pedEntity, currentCoords.x, currentCoords.y, currentCoords.z, false, true)
				ClearPedTasks(pedEntity, 1, true)
				ClearPedSecondaryTask(pedEntity)
				HidePedWeapons(pedEntity, 2, 1)
				pressed = true
			end

			timesUp = gameTime - scenarioStartTime > timeTilBreak
			if isUsingScenario then
				if not leavePromptCreated and (gameTime - scenarioStartTime) >= duration and not pressed then
					createLeavePrompt("Leave")
				end

				if leavePromptCreated and (UiPromptHasStandardModeCompleted(leavePrompt) or IsControlJustPressed(0, GetHashKey("INPUT_MELEE_ATTACK")) or IsDisabledControlJustPressed(0, GetHashKey("INPUT_MELEE_ATTACK"))) then
					deleteLeavePrompt()
					if isInAVehicle or (sitBehind and Config.SitBehindInstantTeleport.exit) or (not sitBehind and Config.SitLedgeInstantTeleport.exit) or (tooHighForIntroAnim) then
						local currentCoords = GetEntityCoords(pedEntity)
						SetEntityCoordsNoOffset(pedEntity, currentCoords.x, currentCoords.y, currentCoords.z, false, true)
					end
					ClearPedTasks(pedEntity, 1, true)
					ClearPedSecondaryTask(pedEntity)
					HidePedWeapons(pedEntity, 2, 1)
					pressed = true
				end
			else
				if leavePromptCreated then
					deleteLeavePrompt()
				end
				if timesUp and not isUsingScenario then
					break
				end
			end
			Wait(0)
		end
		deleteLeavePrompt()
		stopInteraction(pedEntity, originCoords)
		StopInteraction(ped)
	end)
end

function IsEntityAVehicle(entityTypesHit, entitiesHit, amountTolerate)
	local vehicleCount = 0
	local entityPopularity = {}
	for i, entityType in ipairs(entityTypesHit) do
		if entityType == 2 then
			if DoesEntityExist(entitiesHit[i]) then
				entityPopularity[entitiesHit[i]] = (entityPopularity[entitiesHit[i]] or 0) + 1
			end
			vehicleCount = vehicleCount + 1
		end
	end
	local mostCommonEntity = nil
	local maxCount = 0
	for entity, count in pairs(entityPopularity) do
		if count > maxCount then
			maxCount = count
			mostCommonEntity = entity
		end
	end
	return (vehicleCount >= amountTolerate), mostCommonEntity
end

function GetEntityUnderPed(ped)
	local coords = GetEntityCoords(ped)
	local rayStart = vector3(coords.x, coords.y, coords.z + 0.2)
	local rayEnd = vector3(coords.x, coords.y, coords.z - 2.0)
	local _, hit, _, _, entityHit = GetShapeTestResult(StartShapeTestRay(
		rayStart.x,
		rayStart.y,
		rayStart.z,
		rayEnd.x,
		rayEnd.y,
		rayEnd.z,
		SittingEntityIntersectionFlags,
		ped,
		4
	))

	if hit and entityHit and entityHit ~= 0 then
		return entityHit
	end

	return nil
end

function IsPlayerInVehicleViaNative(ped)
	if IsPedInAnyVehicle(ped, false) then
		return true
	end
	if IsPedInAnyBoat(ped) then
		return true
	end
	if IsPedInAnyTrain(ped) then
		return true
	end
	return false
end

ResolveSittingBaseEntity = function(ped, fallbackEntity)
	if fallbackEntity and fallbackEntity ~= 0 and GetEntityType(fallbackEntity) == 2 then
		return fallbackEntity
	end

	local entity = GetEntityUnderPed(ped) or fallbackEntity
	if entity and entity ~= 0 then
		if GetEntityType(entity) == 2 then
			return entity
		end

		if IsEntityAttached(entity) then
			local attachedTo = GetEntityAttachedTo(entity)
			if attachedTo and attachedTo ~= 0 and GetEntityType(attachedTo) == 2 then
				return attachedTo
			end
		end

		return entity
	end

	if IsPlayerInVehicleViaNative(ped) then
		local vehicle = GetVehiclePedIsIn(ped, false)
		if vehicle and vehicle ~= 0 then
			return vehicle
		end
	end

	return nil
end

function TryAttachPedToSeatEntity(ped, seatEntity, fallbackEntity)
	local baseEntity = ResolveSittingBaseEntity(ped, fallbackEntity)
	if not baseEntity or baseEntity == 0 or GetEntityType(baseEntity) ~= 2 then
		return false
	end

	local targetEntity = seatEntity
	if not (targetEntity and DoesEntityExist(targetEntity)) then
		targetEntity = baseEntity
	end

	local targetCoords = GetEntityCoords(targetEntity)
	local targetHeading = GetEntityHeading(targetEntity)
	local baseHeading = GetEntityHeading(baseEntity)
	local offset = GetOffsetFromEntityGivenWorldCoords(baseEntity, targetCoords.x, targetCoords.y, targetCoords.z)
	local headingOffset = targetHeading - baseHeading

	AttachEntityToEntity(ped, baseEntity, 0, offset.x, offset.y, offset.z, 0.0, 0.0, headingOffset, false, true, false, true, 2, true)

	CurrentSeatEntity = (seatEntity and DoesEntityExist(seatEntity)) and seatEntity or nil
	CurrentBaseEntity = baseEntity

	if targetEntity == baseEntity then
		if debugmode then
			print("Attach target entity is the same as base entity.")
			print("Attach fallback: using baseEntity as target.")
		end
	else
		if debugmode then
			print("Attach targetEntity:", targetEntity, "targetCoords:", targetCoords, "targetHeading:", targetHeading)
			print("baseEntity:", baseEntity, "baseCoords:", GetEntityCoords(baseEntity), "baseHeading:", baseHeading)
		end
	end
	if math.abs(offset.x) < 0.001 and math.abs(offset.y) < 0.001 and math.abs(offset.z) < 0.001 then
		if debugmode then
			print("Attach offset is near zero; target likely shares base origin or seatEntity was invalid.")
		end
	end
	if debugmode then
		print("Attached ped to entity:", baseEntity, "with offset:", offset, "and headingOffset:", headingOffset)
	end
	return true
end

local function DisplayAngle(offsetted_angle)
	CreateThread(function()
		local startingTime = GetGameTimer()
		local duration = 3000
		local text = "offsetted_angle is   " .. tostring(offsetted_angle)
		while GetGameTimer() < startingTime + duration do
			DisplayDebugText(text, 0.5, 0.9)
			Wait(0)
		end
	end)
end


local function NormalizeHeadingAngle(angle)
	local normalized = tonumber(angle) or 0.0
	normalized = normalized % 360.0
	if normalized < 0.0 then
		normalized = normalized + 360.0
	end
	return normalized
end

local function HeadingToForwardVector(heading)
	local rad = math.rad(heading)
	return vector3(-math.sin(rad), math.cos(rad), 0.0)
end

local function ForwardVectorToHeading(vec)
	return NormalizeHeadingAngle(math.deg(math.atan(-vec.x, vec.y)))
end

local function CollectDirectionalLedgeSamples(ped, originCoords, sampleHeading, samples, zHere)
	local headingForward = HeadingToForwardVector(sampleHeading)
	local directionalCoords = {}
	local directionalDrops = {}
	local directionalLedgeStartDist = nil
	local directionalSelectedIndex = 1
	local directionalMaxDrop = 0.0

	for i, d in ipairs(samples) do
		local sxDir = originCoords.x + headingForward.x * d
		local syDir = originCoords.y + headingForward.y * d
		local szDir = groundZAt(ped, sxDir, syDir, originCoords.z)
		local dropDir = zHere - szDir
		table.insert(directionalCoords, { x = sxDir, y = syDir, z = szDir })
		table.insert(directionalDrops, dropDir)
		if dropDir > directionalMaxDrop then
			directionalMaxDrop = dropDir
		end
		if dropDir > 0.3 and not directionalLedgeStartDist then
			directionalLedgeStartDist = d
			directionalSelectedIndex = i
		end
	end

	local directionalLedgeIndex = math.max(1, directionalSelectedIndex - 1)
	local directionalLedgeCoords = directionalCoords[directionalLedgeIndex]
	return {
		heading = sampleHeading,
		coords = directionalCoords,
		drops = directionalDrops,
		selectedIndex = directionalSelectedIndex,
		ledgeStartDist = directionalLedgeStartDist,
		maxDrop = directionalMaxDrop,
		ledgeCoords = directionalLedgeCoords
	}
end

local function RunMultiAngleLedgeSweep(ped, baseHeading, offsettedAngle, numberOfAnglesToSample, originCoords, samples, zHere, playerForward)
	local clampedSampleCount = math.max(1, math.floor(tonumber(numberOfAnglesToSample) or 1))
	if clampedSampleCount % 2 == 0 then
		clampedSampleCount = clampedSampleCount + 1
	end

	local halfSteps = math.floor(clampedSampleCount / 2)
	local maxOffset = offsettedAngle / 2.0
	local headingStep = halfSteps > 0 and (maxOffset / halfSteps) or 0.0
	local sweeps = {}
	local ledgePoints = {}

	for angleStep = -halfSteps, halfSteps do
		local sampleHeading = NormalizeHeadingAngle(baseHeading + (headingStep * angleStep))
		local sweep = CollectDirectionalLedgeSamples(ped, originCoords, sampleHeading, samples, zHere)
		table.insert(sweeps, sweep)
		if sweep.ledgeCoords and sweep.maxDrop > 0.3 then
			table.insert(ledgePoints, sweep.ledgeCoords)
		end
	end

	local resolvedHeading = nil
	if #ledgePoints >= 2 then
		local pairA = nil
		local pairB = nil
		local maxDistSq = -1.0
		for i = 1, #ledgePoints - 1 do
			for j = i + 1, #ledgePoints do
				local dx = ledgePoints[j].x - ledgePoints[i].x
				local dy = ledgePoints[j].y - ledgePoints[i].y
				local distSq = (dx * dx) + (dy * dy)
				if distSq > maxDistSq then
					maxDistSq = distSq
					pairA = ledgePoints[i]
					pairB = ledgePoints[j]
				end
			end
		end

		if pairA and pairB and maxDistSq > 0.000001 then
			local ledgeSpan = vector3(pairB.x - pairA.x, pairB.y - pairA.y, 0.0)
			local spanLength = #(ledgeSpan)
			if spanLength > 0.001 then
				local tangent = ledgeSpan / spanLength
				local normalA = vector3(-tangent.y, tangent.x, 0.0)
				local normalB = vector3(tangent.y, -tangent.x, 0.0)
				local dotA = (normalA.x * playerForward.x) + (normalA.y * playerForward.y)
				local dotB = (normalB.x * playerForward.x) + (normalB.y * playerForward.y)
				resolvedHeading = ForwardVectorToHeading(dotB > dotA and normalB or normalA)
			end
		end
	end

	return sweeps, resolvedHeading
end

local function Clamp(v, lo, hi)
	return math.max(lo, math.min(hi, v))
end

local function ComputeOffsetAngleDynamic(distanceMeters, desiredWidthMeters, minAngle, maxAngle)
	local d = math.max(distanceMeters, 0.15)
	local halfW = desiredWidthMeters * 0.5
	local angle = math.deg(2.0 * math.atan(halfW / d))
	return Clamp(angle, minAngle or 10.0, maxAngle or 150.0)
end

local function AnalyzeMultiAngleSweepForLedgeGeometry(sweeps, originCoords, baseHeading, numberOfAnglesToSample)
	if not sweeps or #sweeps == 0 then
		return nil
	end

	local leftmostSweep = nil
	local rightmostSweep = nil
	local leftmostIdx = nil
	local rightmostIdx = nil
	local allValidSweeps = {}

	-- Find all sweeps with valid ledges
	for idx, sweep in ipairs(sweeps) do
		if sweep and sweep.ledgeCoords and sweep.maxDrop > 0.3 then
			table.insert(allValidSweeps, { index = idx, sweep = sweep })
			if not leftmostSweep then
				leftmostSweep = sweep
				leftmostIdx = idx
			end
			rightmostSweep = sweep -- last one processed is rightmost
			rightmostIdx = idx
		end
	end

	if #allValidSweeps < 2 then
		return nil
	end

	-- Calculate distances to left and right ledge points
	local originVec = originCoords
	-- Convert table coordinates to vector3 for arithmetic
	local leftPoint = vector3(
		allValidSweeps[1].sweep.ledgeCoords.x,
		allValidSweeps[1].sweep.ledgeCoords.y,
		allValidSweeps[1].sweep.ledgeCoords.z
	)
	local rightPoint = vector3(
		allValidSweeps[#allValidSweeps].sweep.ledgeCoords.x,
		allValidSweeps[#allValidSweeps].sweep.ledgeCoords.y,
		allValidSweeps[#allValidSweeps].sweep.ledgeCoords.z
	)

	local leftDist = #(leftPoint - originVec)
	local rightDist = #(rightPoint - originVec)
	local distanceDelta = math.abs(leftDist - rightDist)
	local isConsistent = distanceDelta < 0.4 -- tunable threshold: consistent if within 0.4 units

	-- Calculate the actual angle spanned by left and right points
	local ledgeSpan = rightPoint - leftPoint
	local spanLength = #(ledgeSpan)
	local observedLedgeAngle = nil

	if spanLength > 0.05 then
		-- Angle to each point from player
		local dirToLeft = (leftPoint - originVec)
		local dirToRight = (rightPoint - originVec)
		local leftHeading = ForwardVectorToHeading(vector3(dirToLeft.x, dirToLeft.y, 0))
		local rightHeading = ForwardVectorToHeading(vector3(dirToRight.x, dirToRight.y, 0))
		observedLedgeAngle = math.abs(rightHeading - leftHeading)
		if observedLedgeAngle > 180 then
			observedLedgeAngle = 360 - observedLedgeAngle
		end
	end

	return {
		leftPoint = leftPoint,
		rightPoint = rightPoint,
		leftDist = leftDist,
		rightDist = rightDist,
		distanceDelta = distanceDelta,
		isConsistent = isConsistent,
		validSweepCount = #allValidSweeps,
		spanLength = spanLength,
		observedLedgeAngle = observedLedgeAngle
	}
end

local function BuildPerpendicularHeadingFromSweepLine(sweeps, playerForward)
	if not sweeps or #sweeps == 0 then
		return nil
	end

	local points = {}
	for _, sweep in ipairs(sweeps) do
		if sweep and sweep.ledgeCoords and sweep.maxDrop > 0.3 then
			table.insert(points, vector3(sweep.ledgeCoords.x, sweep.ledgeCoords.y, 0.0))
		end
	end

	if #points < 2 then
		return nil
	end

	local cx, cy = 0.0, 0.0
	for _, p in ipairs(points) do
		cx = cx + p.x
		cy = cy + p.y
	end
	cx = cx / #points
	cy = cy / #points

	local xx, xy, yy = 0.0, 0.0, 0.0
	for _, p in ipairs(points) do
		local dx = p.x - cx
		local dy = p.y - cy
		xx = xx + (dx * dx)
		xy = xy + (dx * dy)
		yy = yy + (dy * dy)
	end

	local trace = xx + yy
	local det = (xx * yy) - (xy * xy)
	local disc = math.max(0.0, (trace * trace * 0.25) - det)
	local lambda = (trace * 0.5) + math.sqrt(disc)

	local vx, vy
	if math.abs(xy) > 0.000001 then
		vx = lambda - yy
		vy = xy
	elseif xx >= yy then
		vx, vy = 1.0, 0.0
	else
		vx, vy = 0.0, 1.0
	end

	local tangentLen = math.sqrt((vx * vx) + (vy * vy))
	if tangentLen <= 0.000001 then
		return nil
	end

	local tangent = vector3(vx / tangentLen, vy / tangentLen, 0.0)
	local normalA = vector3(-tangent.y, tangent.x, 0.0)
	local normalB = vector3(tangent.y, -tangent.x, 0.0)
	local dotA = (normalA.x * playerForward.x) + (normalA.y * playerForward.y)
	local dotB = (normalB.x * playerForward.x) + (normalB.y * playerForward.y)
	local selectedNormal = dotB > dotA and normalB or normalA

	local minProj, maxProj = math.huge, -math.huge
	for _, p in ipairs(points) do
		local proj = ((p.x - cx) * tangent.x) + ((p.y - cy) * tangent.y)
		if proj < minProj then
			minProj = proj
		end
		if proj > maxProj then
			maxProj = proj
		end
	end

	return {
		perpendicularHeading = ForwardVectorToHeading(selectedNormal),
		tangent = tangent,
		normal = selectedNormal,
		validPointCount = #points,
		spanLength = math.max(0.0, maxProj - minProj)
	}
end

function sitLedgeCommand(source, args, rawCommand)
	if not CanStartSeatInteraction() then
		return
	end
	local scenarioName = (args and args[1]) or "WORLD_HUMAN_SEAT_LEDGE"
	local scenarioHash = GetHashKey(scenarioName)
	local ped = PlayerPedId()
	local coords = GetEntityCoords(ped)
	local heading = GetEntityHeading(ped)
	local E = 2               -- E for epsilon, absolute value for the distance from the seating point to check the delta between +E and -E for validating the ledge
	local f = GetEntityForwardVector(ped)
	local j = 0.1             -- jumps
	local c = coords - f * 0.35
	local sc = 20             -- sample count
	local sittingIndexOffset = 4 -- how many jumps back from the detected ledge start to place the sitting position

	if CurrentlySitting or CurrentlySittingOnVehicle or CurrentOriginCoords or Currentinteraction then
		mosquito.notify.right_tip("You are already sitting. Stop Emote to reset seating.")
		return
	else
		ClearPedTasks(ped, 1, true)
		ClearPedSecondaryTask(ped)
		HidePedWeapons(ped, 2, 1)
	end

	local zHere = groundZAt(ped, c.x, c.y, c.z)
	local samples = {}
	local entityTypesHit = {}
	local entitiesHit = {}
	for i = 1, sc do
		table.insert(samples, i * j)
	end

	local drops = {}
	local storedCoords = {}
	local ledgeStartDist = nil
	local maxDrop = 0
	local selected_index = 1

	for i, d in ipairs(samples) do
		local sx = c.x + f.x * d
		local sy = c.y + f.y * d
		local sz, entityType, entity = groundZAt(ped, sx, sy, c.z)
		local drop = zHere - sz
		table.insert(storedCoords, { x = sx, y = sy, z = sz })
		table.insert(drops, drop)
		table.insert(entityTypesHit, entityType)
		table.insert(entitiesHit, entity)
		if drop > maxDrop then
			maxDrop = drop
		end

		if drop > 0.3 and not ledgeStartDist then
			ledgeStartDist = d
			selected_index = i
		end
	end
	if not ledgeStartDist or maxDrop < 0.3 then
		mosquito.notify.right_tip("No ledge detected in front of the player.")
		return
	end
	local satOnAVehicle, mostCommonEntity = IsEntityAVehicle(entityTypesHit, entitiesHit, 1)
	local baseEntity = ResolveSittingBaseEntity(ped, mostCommonEntity)
	local isOnTrainOrVehicle = baseEntity and GetEntityType(baseEntity) == 2 or false
	if debugmode then
		print("satOnAVehicle:", satOnAVehicle, "mostCommonEntity:", mostCommonEntity, "baseEntity:", baseEntity, "baseType:", baseEntity and GetEntityType(baseEntity) or "nil")
	end
	local maxedOutIndex = math.max(math.min((selected_index - sittingIndexOffset), #storedCoords), 1)
	local selectedCoords = storedCoords[maxedOutIndex]
	local seatEntity = entitiesHit[maxedOutIndex]
	local sx, sy, sz = selectedCoords.x, selectedCoords.y, selectedCoords.z
	local pedGroundZ = groundZAt(ped, coords.x, coords.y, coords.z)
	local seatGroundDelta = math.abs(sz - pedGroundZ)


	local ledge_index = math.max(1, selected_index - 1)
	local ledge_coords = storedCoords[ledge_index]

	print("^1 ledge_coords:", ledge_coords, "^7")

	-- ===== FIRST PASS: WIDE VISUAL SWEEP FOR LEDGE GEOMETRY ANALYSIS =====
	local number_of_angles_to_sample = 10
	local max_angle_at_ledge = 150.0
	local ledgeDistMeters = samples[selected_index] or (selected_index * j)
	local desiredWidthMeters = 0.5 -- tune: 0.8 tight, 1.2 medium, 1.6 wide
	local initial_offsetted_angle = ComputeOffsetAngleDynamic(ledgeDistMeters, desiredWidthMeters, 10.0, max_angle_at_ledge)

	if debugmode then
		DisplayAngle(initial_offsetted_angle)
		print(string.format("^3[SitLedge PASS 1] Initial angle sweep: %.2f° over %d angles^7", initial_offsetted_angle, number_of_angles_to_sample))
	end

	local multiAngleSweeps, resolvedSweepHeading = RunMultiAngleLedgeSweep(
		ped,
		heading,
		initial_offsetted_angle,
		number_of_angles_to_sample,
		c,
		samples,
		zHere,
		f
	)

	-- Draw FIRST sweep ledge points visually (debug) — blue markers
	-- if debugmode then
	-- 	for _, sweep in ipairs(multiAngleSweeps or {}) do
	-- 		if sweep and sweep.ledgeCoords then
	-- 			startDrawingMarker({ sweep.ledgeCoords }, samples, -1, -1, 0)
	-- 		end
	-- 	end
	-- end

	-- Analyze the geometry to find consistent left/right ledge points
	local geometryAnalysis = AnalyzeMultiAngleSweepForLedgeGeometry(multiAngleSweeps, c, heading, number_of_angles_to_sample)

	if geometryAnalysis and debugmode then
		print(string.format(
			"^2[Ledge Geometry] Left dist=%.3f, Right dist=%.3f, Delta=%.3f, Consistent=%s, Span=%.3f, ObservedAngle=%s^7",
			geometryAnalysis.leftDist,
			geometryAnalysis.rightDist,
			geometryAnalysis.distanceDelta,
			tostring(geometryAnalysis.isConsistent),
			geometryAnalysis.spanLength or 0,
			geometryAnalysis.observedLedgeAngle and string.format("%.2f°", geometryAnalysis.observedLedgeAngle) or "nil"
		))
	end

	-- ===== SECOND PASS: REFINED SWEEP USING OBSERVED LEDGE GEOMETRY =====
	local refined_offsetted_angle = initial_offsetted_angle
	if geometryAnalysis and geometryAnalysis.isConsistent and geometryAnalysis.observedLedgeAngle then
		-- Use the observed angle with a small margin for safety
		refined_offsetted_angle = math.min(max_angle_at_ledge, geometryAnalysis.observedLedgeAngle * 1.2)
		if debugmode then
			print(string.format("^5[SitLedge PASS 2] Refined angle from geometry: %.2f°^7", refined_offsetted_angle))
		end
	end

	local multiAngleSweeps2, resolvedSweepHeading2 = RunMultiAngleLedgeSweep(
		ped,
		heading,
		refined_offsetted_angle,
		number_of_angles_to_sample,
		c,
		samples,
		zHere,
		f
	)
	local pass2LineInfo = BuildPerpendicularHeadingFromSweepLine(multiAngleSweeps2, f)

	-- Draw SECOND sweep ledge points visually (debug)
	if debugmode then
		for _, sweep in ipairs(multiAngleSweeps2 or {}) do
			if sweep and sweep.ledgeCoords then
				startDrawingMarker({ sweep.ledgeCoords }, samples, 1, 0, 0)
			end
		end
	end

	-- NOTE: Both sweeps are VISUAL ONLY for now. Heading stays as original unless explicitly changed above.
	-- To activate heading override, uncomment the lines below:
	-- if resolvedSweepHeading2 then
	--     heading = resolvedSweepHeading2
	-- end

	if seatGroundDelta > 0.35 then
		if debugmode then
			print(string.format("SitLedge blocked: selected seat Z too far from ped ground (delta=%.3f, limit=0.350)", seatGroundDelta))
		end
		mosquito.notify.right_tip("No suitable ledge detected in front of the player.")
		return
	end
	if debugmode then
		startDrawingMarker(storedCoords, samples, selected_index, sittingIndexOffset, E, true)
	end
	local posEIndex = math.min(selected_index + E, #storedCoords)
	local negEIndex = math.max(selected_index - E, 1)
	local delta = math.abs(storedCoords[negEIndex].z - storedCoords[posEIndex].z)
	local sCoords = vector3(sx, sy, sz)
	local forwardCoords = vector3(sCoords.x + 0.8 * f.x, sCoords.y + 0.8 * f.y, sCoords.z + 0.25)
	local hit = CheckWallBetweenCoords(coords, forwardCoords, ped, 9)
	local minDeltaForHeadingAlign = 0.30
	local maxDeltaForHeadingAlign = 4.50
	local forwardSweepPass = delta >= minDeltaForHeadingAlign and delta <= maxDeltaForHeadingAlign and not hit
	local sweepGeometryPass = pass2LineInfo and pass2LineInfo.validPointCount >= 3 and pass2LineInfo.spanLength >= 0.25
	if forwardSweepPass and sweepGeometryPass then
		heading = pass2LineInfo.perpendicularHeading
		if debugmode then
			print(string.format("SitLedge pass2 heading applied: heading=%.2f points=%d span=%.3f", heading, pass2LineInfo.validPointCount, pass2LineInfo.spanLength))
		end
	elseif debugmode then
		print(string.format("SitLedge pass2 heading skipped: forwardPass=%s geomPass=%s delta=%.3f hit=%s", tostring(forwardSweepPass), tostring(sweepGeometryPass), delta, tostring(hit)))
	end
	if debugmode then
		print(string.format("SitLedge diagnostics (ignored blockers): delta=%.3f wallHit=%s", delta, tostring(hit)))
	end
	if isOnTrainOrVehicle then
		mosquito.notify.right_tip("~COLOR_GOLD~Vehicle seating detected.~q~")

		if not IsVehicleSafeForSitting(baseEntity, seatEntity) then
			mosquito.notify.right_tip("~COLOR_RED~Vehicle is not safe for sitting.~q~")
			return
		end

		if TryAttachPedToSeatEntity(ped, seatEntity, baseEntity) then
			CurrentlySittingOnVehicle = true
			SetPedDesiredHeading(ped, heading)
			SetEntityHeading(ped, heading)
			TaskStartScenarioAtPosition(ped, scenarioHash, sCoords.x, sCoords.y, sCoords.z, heading, -1, false, true)
			local originCoords = vector4(coords.x, coords.y, coords.z, heading)
			CurrentlySitting = true
			CurrentSittingType = "ledge"
			CurrentOriginCoords = originCoords
			startLeavePromptWatcher(ped, scenarioHash, originCoords, 2500, false, true, false)
		else
			mosquito.notify.right_tip("~COLOR_RED~Failed to attach to vehicle.~q~")
		end
	else
		SetPedDesiredHeading(ped, heading)
		SetEntityHeading(ped, heading)
		TaskStartScenarioAtPosition(ped, scenarioHash, sCoords.x, sCoords.y, sCoords.z, heading, -1, not Config.SitLedgeInstantTeleport.enter, true)
		local originCoords = vector4(coords.x, coords.y, coords.z, heading)
		CurrentlySitting = true
		CurrentSittingType = "ledge"
		CurrentOriginCoords = originCoords
		startLeavePromptWatcher(ped, scenarioHash, originCoords, 2500, false, false, false)
	end
end

local function FindSitBehindScenarioEntryByName(scenarioName)
	if not scenarioName or scenarioName == "" then
		return nil
	end
	for _, scenarioEntry in ipairs(Config.SitBehindScenarios or {}) do
		if type(scenarioEntry) == "table" and scenarioEntry.scenario == scenarioName then
			return scenarioEntry
		end
	end
	return nil
end

function IsSitBehindScenarioAllowedForPed(scenarioName, ped, sexRestriction)
	ped = ped or PlayerPedId()
	if not scenarioName or scenarioName == "" then
		return true
	end

	local requiredSex = sexRestriction
	if not requiredSex then
		local scenarioEntry = FindSitBehindScenarioEntryByName(scenarioName)
		requiredSex = scenarioEntry and scenarioEntry.sex or nil
	end

	if requiredSex == "female" then
		return IsPedHumanFemale(ped)
	end

	if requiredSex == "male" then
		return IsPedHumanMale(ped)
	end

	return true
end

local function NormalizeSitOffset(offset)
	if type(offset) == "vector3" then
		return offset
	end
	if type(offset) == "table" then
		return vector3(tonumber(offset.x) or 0.0, tonumber(offset.y) or 0.0, tonumber(offset.z) or 0.0)
	end
	return vector3(0.0, 0.0, 0.0)
end

local function ResolveSitBehindScenarioData(rawScenarioArg)
	local defaultScenario = (lastUsedSittingScenario or "GENERIC_SEAT_BENCH_SCENARIO")
	if not rawScenarioArg then
		return defaultScenario, vector3(0.0, 0.0, 0.0)
	end

	local numericIndex = tonumber(rawScenarioArg)
	if numericIndex and Config.SitBehindScenarios and Config.SitBehindScenarios[numericIndex] then
		local entry = Config.SitBehindScenarios[numericIndex]
		return (entry and entry.scenario) or defaultScenario, NormalizeSitOffset(entry and entry.offset)
	end

	return tostring(rawScenarioArg), vector3(0.0, 0.0, 0.0)
end

function ExecuteSitInteraction(interactionKey)
	if not Config.SitInteractionEntries then
		return false
	end

	local interaction = Config.SitInteractionEntries[interactionKey]
	if not interaction then
		return false
	end

	if interaction.command == "behind" and not IsSitBehindScenarioAllowedForPed(interaction.scenario, nil, interaction.sex) then
		mosquito.notify.right_tip("~COLOR_RED~This sit scenario is not available for your character.~q~")
		return false
	end

	if interaction.command == "ledge" then
		sitLedgeCommand(nil, { interaction.scenario, interaction.offset })
	else
		sitBehindCommand(nil, { interaction.scenario, 0.0, interaction.offset })
	end

	return true
end

function sitBehindCommand(source, args, rawCommand)
	if not CanStartSeatInteraction() then
		return
	end
	local scenarioName, configuredOffset = ResolveSitBehindScenarioData(args and args[1])
	if not IsSitBehindScenarioAllowedForPed(scenarioName) then
		mosquito.notify.right_tip("~COLOR_RED~This sit scenario is not available for your character.~q~")
		return
	end
	local finalOffset = args and args[2] and tonumber(args[2]) or 0.0
	local manualOffset = (args and args[3]) or nil
	if debugmode then
		print("configuredOffset:", configuredOffset, "finalOffset:", finalOffset, "manualOffset:", manualOffset)
	end
	local xyzOffset = NormalizeSitOffset(manualOffset or configuredOffset)
	if debugmode then
		print("Using xyzOffset for seating position:", xyzOffset)
	end
	local scenarioHash = GetHashKey(scenarioName)
	local ped = PlayerPedId()
	local coords = GetEntityCoords(ped)
	local heading = GetEntityHeading(ped)
	local E = 4
	local f = GetEntityForwardVector(ped)
	local j = 0.05
	local c = coords
	local sc = 30
	local sittingIndexOffset = 8
	if CurrentlySitting or CurrentlySittingOnVehicle or CurrentOriginCoords or Currentinteraction then
		mosquito.notify.right_tip("You are already sitting. Stop Emote to reset seating.")
		return
	else
		ClearPedTasks(ped, 1, true)
		ClearPedSecondaryTask(ped)
		HidePedWeapons(ped, 2, 1)
	end
	if CurrentOriginCoords then
		SetEntityCoordsNoOffset(ped, CurrentOriginCoords.x, CurrentOriginCoords.y, CurrentOriginCoords.z)
		SetPedDesiredHeading(ped, CurrentOriginCoords.w)
		SetEntityHeading(ped, CurrentOriginCoords.w)
		CurrentOriginCoords = nil
	end

	local zHere = groundZAt(ped, c.x, c.y, c.z)
	local samples = {}
	for i = -3, sc do
		table.insert(samples, i * j)
	end

	local drops = {}
	local storedCoords = {}
	local entityTypesHit = {}
	local entitiesHit = {}
	local ledgeStartDist = nil
	local maxRise = 0
	local selected_index = 1
	local samplesAfterLedge = 0
	local lastSampleCoords = nil
	local requiredSeatSamples = 12

	for i, d in ipairs(samples) do
		local sx = c.x - f.x * d
		local sy = c.y - f.y * d
		local sz, entityType, entity = groundZAt(ped, sx, sy, c.z)
		table.insert(entityTypesHit, entityType)
		local drop = zHere - sz
		if debugmode then
			print("Hit entity of type:", entityType, "at distance:", d, "with drop:", drop)
		end
		local foundLedge = (lastSampleCoords and math.abs(lastSampleCoords.z - sz) > 0.15) or false
		lastSampleCoords = { x = sx, y = sy, z = sz }

		if ledgeStartDist and foundLedge then
			if debugmode then
				print("rerise detected at distance:", d, "from player. z diff:", lastSampleCoords.z - sz)
			end
			break
		end

		table.insert(storedCoords, { x = sx, y = sy, z = sz })
		table.insert(drops, drop)
		table.insert(entitiesHit, entity)

		if drop < 0 and math.abs(drop) > maxRise and math.abs(drop) < 1.5 then
			maxRise = math.abs(drop)
		end

		if drop < -0.3 and not ledgeStartDist then
			ledgeStartDist = d
			selected_index = i
		end

		if ledgeStartDist then
			samplesAfterLedge = samplesAfterLedge + 1
		end
	end
	local satOnAVehicle, mostCommonEntity = IsEntityAVehicle(entityTypesHit, entitiesHit, 1)
	if debugmode then
		print("satOnAVehicle:", satOnAVehicle, "mostCommonEntity:", mostCommonEntity)
	end
	local baseEntity = ResolveSittingBaseEntity(ped, mostCommonEntity)
	if debugmode then
		print("baseEntity:", baseEntity, "baseType:", baseEntity and GetEntityType(baseEntity) or "nil")
	end
	local isOnTrainOrVehicle = baseEntity and GetEntityType(baseEntity) == 2 or false
	if not ledgeStartDist or maxRise < 0.2 then
		mosquito.notify.right_tip("No ledge directly behind you.")
		return
	end
	local seatSampleWidthOffset = math.max(requiredSeatSamples - sittingIndexOffset, 0)
	local maxedOutIndex = math.max(math.min((selected_index + sittingIndexOffset - seatSampleWidthOffset), #storedCoords), 1)
	local selectedCoords = storedCoords[maxedOutIndex]
	local seatEntity = entitiesHit[maxedOutIndex]
	local sx, sy, sz = selectedCoords.x, selectedCoords.y, selectedCoords.z
	local maxSeatHeight = tonumber(Config.SitBehindMaxSeatHeight)
	local seatHeightDelta = sz - zHere
	local tooHigh = maxSeatHeight and maxSeatHeight >= 0.0 and seatHeightDelta > maxSeatHeight
	local tooHighForIntroAnim = maxSeatHeight and maxSeatHeight >= 0.0 and seatHeightDelta > Config.SitBehindMaxSeatHeightForAnimation
	if debugmode then
		startDrawingMarker(storedCoords, samples, selected_index, -sittingIndexOffset, E)
	end
	if tooHigh then
		if debugmode then
			print(string.format("SitBehind blocked: seat too high (delta=%.3f, limit=%.3f)", seatHeightDelta, maxSeatHeight))
		end
		mosquito.notify.right_tip("~COLOR_RED~Seat is too high to sit behind here.~q~")
		return
	end
	local posEIndex = math.min(selected_index + E, #storedCoords)
	local negEIndex = math.max(selected_index - E, 1)
	local delta = math.abs(storedCoords[negEIndex].z - storedCoords[posEIndex].z)

	local sCoords = vector3(sx, sy, sz) + vector3(f.x * finalOffset, f.y * finalOffset, 0.0) + xyzOffset
	local hit = CheckWallBetweenCoords(coords, sCoords, ped, 9)
	if delta > 0.3 and samplesAfterLedge > 2 and not hit then
		lastUsedSittingScenario = scenarioName
		if isOnTrainOrVehicle then
			mosquito.notify.right_tip("~COLOR_GOLD~Vehicle seating detected.~q~")

			if not IsVehicleSafeForSitting(baseEntity, seatEntity) then
				mosquito.notify.right_tip("~COLOR_RED~Vehicle is not safe for sitting.~q~")
				return
			end

			if TryAttachPedToSeatEntity(ped, seatEntity, baseEntity) then
				CurrentlySittingOnVehicle = true
				TaskStartScenarioAtPosition(ped, scenarioHash, sCoords.x, sCoords.y, sCoords.z + 0.05, heading, -1, false, true)
				CurrentlySitting = true
				CurrentSittingType = "behind"
				local originCoords = vector4(coords.x, coords.y, coords.z, heading)
				CurrentOriginCoords = originCoords
				startLeavePromptWatcher(ped, scenarioHash, originCoords, 1000, true, true, true)
			else
				mosquito.notify.right_tip("~COLOR_RED~Failed to attach to vehicle.~q~")
			end
		else
			TaskStartScenarioAtPosition(ped, scenarioHash, sCoords.x, sCoords.y, sCoords.z + 0.05, heading, -1, (not tooHighForIntroAnim) and (not Config.SitBehindInstantTeleport.enter), true)
			CurrentlySitting = true
			CurrentSittingType = "behind"
			local originCoords = vector4(coords.x, coords.y, coords.z, heading)
			CurrentOriginCoords = originCoords
			startLeavePromptWatcher(ped, scenarioHash, originCoords, 1000, true, false, tooHighForIntroAnim)
		end
	else
		if hit then
			mosquito.notify.right_tip("~COLOR_RED~Something detected between you and sitting position.~q~")
		else
			mosquito.notify.right_tip("~COLOR_RED~No suitable ledge detected for sitting directly behind player.~q~")
		end
	end
end

if debugmode then
	RegisterCommand("deleteprompts", function(source, args, rawCommand)
		local breakInterval = tonumber(args[1]) or 50000
		for i = 0, 9999999 * 2 do
			UiPromptDelete(i)
			if i % breakInterval == 0 then
				Wait(0)
			end
		end
	end)
end


AddEventHandler("onResourceStop", function(resource)
	if GetCurrentResourceName() ~= resource then
		return
	end
	local players = GetActivePlayers()
	for _, player in ipairs(players) do
		local ped = GetPlayerPed(player)
		if IsEntityAttachedToAnyPed(ped) then
			DetachEntity(ped)
		end
		FreezeEntityPosition(ped, false)
		SetEntityCollision(ped, true, true)
		PlaceObjectOnGroundProperly(ped)
	end
	if CurrentEmote then
		StopUsingEmote()
	end
	deleteLeavePrompt()
	deleteSitBehindPrompt()
	deleteSitLedgePrompt()
end)
