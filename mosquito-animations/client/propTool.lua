-- Simple prop offset/rotation helper for live tweaking.
-- Usage: /prop_tool [model] [bone] then adjust via the VORP menu sliders.
-- Values are shown every frame via DisplayDebugText.


local framework = string.lower(Config.Framework)
local scriptOfChoice = framework == "rsg" and "rsg-menubase" or "vorp_menu"
local MenuData = exports[scriptOfChoice]:GetMenuData()

local PropTool = {
	active = false,
	handle = nil,
	gizmoProxyHandle = nil,
	gizmoAnchorHandle = nil,
	gizmoSessionId = 0,
	pedLockSessionId = 0,
	pedLockActive = false,
	toolCam = nil,
	toolCamSessionId = 0,
	toolCamActive = false,
	model = nil,
	bone = "PH_R_Hand",
	gizmoEditing = false,
	pos = vector3(0.0, 0.0, 0.0), -- derived from step counts
	rot = vector3(0.0, 0.0, 0.0), -- derived from step counts
	posSteps = vector3(0.0, 0.0, 0.0), -- slider-controlled counts
	rotSteps = vector3(0.0, 0.0, 0.0),
	posStep = 0.001, -- base multiplier per step
	rotStep = 0.25,  -- base multiplier per step
	lockAnimIndex = 1,
	customLockAnimDict = "",
	customLockAnimName = ""
}

local attachProp
local ensureAnimDictLoaded
local TOOL_LOCK_ANIM_PRESETS = {
	{
		label = "Current",
		dict = "amb_work@world_human_broom@resting@male_b@idle_a",
		name = "idle_a"
	},
	{
		label = "Frozen Neanderthal",
		dict = "script_amb@discoverables@frozen_neanderthal",
		name = "frozen_neanderthal"
	},
	{
		label = "None",
		dict = nil,
		name = nil
	},
	{
		label = "Custom",
		dict = nil,
		name = nil,
		custom = true
	}
}

local function getCurrentLockAnimPreset()
	local preset = TOOL_LOCK_ANIM_PRESETS[PropTool.lockAnimIndex or 1]
	if not preset then
		preset = TOOL_LOCK_ANIM_PRESETS[1]
		PropTool.lockAnimIndex = 1
	end
	return preset
end

local function getResolvedLockAnimPreset()
	local preset = getCurrentLockAnimPreset()
	if preset and preset.custom then
		local dict = PropTool.customLockAnimDict
		local name = PropTool.customLockAnimName
		if type(dict) == "string" and dict ~= "" and type(name) == "string" and name ~= "" then
			return {
				label = string.format("Custom (%s:%s)", dict, name),
				dict = dict,
				name = name,
				custom = true
			}
		end

		return {
			label = "Custom (unset)",
			dict = nil,
			name = nil,
			custom = true
		}
	end

	return preset
end

local function ensureCurrentLockAnimLoaded()
	local preset = getResolvedLockAnimPreset()
	if not preset.dict or not preset.name then
		return true
	end
	return ensureAnimDictLoaded(preset.dict)
end

local function applyCurrentLockAnim(ped)
	local preset = getResolvedLockAnimPreset()
	if not preset.dict or not preset.name then
		ClearPedTasks(ped)
		return true
	end

	if not ensureAnimDictLoaded(preset.dict) then
		return false
	end

	if not IsEntityPlayingAnim(ped, preset.dict, preset.name, 3) then
		TaskPlayAnim(ped, preset.dict, preset.name, 8.0, -8.0, -1, 1, 0.0, false, false, false, "", false)
	end

	return true
end

local function removeAllToolAnimDicts()
	local removed = {}
	for i = 1, #TOOL_LOCK_ANIM_PRESETS do
		local dict = TOOL_LOCK_ANIM_PRESETS[i].dict
		if dict and not removed[dict] then
			RemoveAnimDict(dict)
			removed[dict] = true
		end
	end

	if PropTool.customLockAnimDict and PropTool.customLockAnimDict ~= "" and not removed[PropTool.customLockAnimDict] then
		RemoveAnimDict(PropTool.customLockAnimDict)
	end
end

local function startToolCamera()
	if PropTool.toolCamActive and PropTool.toolCam and DoesCamExist(PropTool.toolCam) then
		return true
	end

	local camPos = GetGameplayCamCoord()
	local camRot = GetGameplayCamRot(2)
	local camFov = GetGameplayCamFov and GetGameplayCamFov() or 45.0
	local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
	if not cam or cam == 0 or not DoesCamExist(cam) then
		cam = CreateCamWithParams(
			"DEFAULT_SCRIPTED_CAMERA",
			camPos.x, camPos.y, camPos.z,
			camRot.x, camRot.y, camRot.z,
			camFov,
			true,
			2
		)
	end

	if not cam or cam == 0 or not DoesCamExist(cam) then
		return false
	end

	SetCamCoord(cam, camPos.x, camPos.y, camPos.z)
	SetCamRot(cam, camRot.x, camRot.y, camRot.z, 2)
	SetCamFov(cam, camFov)

	PropTool.toolCam = cam
	PropTool.toolCamActive = true
	PropTool.toolCamSessionId = (PropTool.toolCamSessionId or 0) + 1

	SetCamActive(cam, true)
	pcall(function()
		RenderScriptCams(true, false, 0, true, true, 0)
	end)
	RenderScriptCams(true, false, 0, true, true)

	return true
end

local function stopToolCamera()
	if not PropTool.toolCamActive and (not PropTool.toolCam or not DoesCamExist(PropTool.toolCam)) then
		pcall(function()
			RenderScriptCams(false, false, 0, true, true, 0)
		end)
		RenderScriptCams(false, false, 0, true, true)
		return
	end

	PropTool.toolCamActive = false
	PropTool.toolCamSessionId = (PropTool.toolCamSessionId or 0) + 1

	if PropTool.toolCam and DoesCamExist(PropTool.toolCam) then
		SetCamActive(PropTool.toolCam, false)
		DestroyCam(PropTool.toolCam, false)
	end
	PropTool.toolCam = nil

	pcall(function()
		RenderScriptCams(false, false, 0, true, true, 0)
	end)
	RenderScriptCams(false, false, 0, true, true)
end

local function promptInput(opts, dontusevorp)
	opts = opts or {}
	local input
	if exports and exports.vorp_inputs and exports.vorp_inputs.advancedInput and not dontusevorp then
		local payload = {
			type = "enableinput",
			inputType = "input",
			button = opts.button or "Confirm",
			placeholder = opts.placeholder or "",
			style = "block",
			attributes = {
				inputHeader = opts.header or "Enter:",
				type = opts.htmlType or "text",
				pattern = opts.pattern or ".*",
				title = opts.title or "",
				style = "border-radius: 10px; background-color: ; border:none;",
			}
		}
		local res = exports.vorp_inputs:advancedInput(payload)
		if res and res ~= "" then
			input = res
		end
	end

	if (not input or input == "") and dontusevorp and GetUserInput then
		input = GetUserInput(opts.header or "Enter:", 2, opts.placeholder or "", opts.maxLength or 40)
	end

	return input
end

local function debugPrint(msg)
	print("[propTool] " .. msg)
end

local function normalizeAngle(angle)
	local normalized = angle % 360.0
	if normalized > 180.0 then
		normalized = normalized - 360.0
	elseif normalized < -180.0 then
		normalized = normalized + 360.0
	end
	return normalized
end

local function isObjectGizmoStarted()
	return GetResourceState and GetResourceState("object_gizmo") == "started"
end

local function useObjectGizmo()
	if not PropTool.active or not PropTool.handle or not DoesEntityExist(PropTool.handle) then
		return false
	end

	if not isObjectGizmoStarted() then
		return false
	end

	local previousPos = PropTool.pos
	local previousRot = PropTool.rot
	local previousPosSteps = PropTool.posSteps
	local previousRotSteps = PropTool.rotSteps

	local proxyModel = GetEntityModel(PropTool.handle)
	if not proxyModel or proxyModel == 0 then
		return false
	end

	if not HasModelLoaded(proxyModel) then
		RequestModel(proxyModel)
		local timeout = GetGameTimer() + 5000
		while not HasModelLoaded(proxyModel) do
			Wait(0)
			if GetGameTimer() > timeout then
				return false
			end
		end
	end

	local sourceCoords = GetEntityCoords(PropTool.handle)
	local sourceRotation = GetEntityRotation(PropTool.handle, 0)
	local ped = PlayerPedId()
	local boneIndex = GetEntityBoneIndexByName(ped, PropTool.bone)
	if not boneIndex or boneIndex == -1 then
		boneIndex = GetEntityBoneIndexByName(ped, "PH_R_Hand")
	end
	if not boneIndex or boneIndex == -1 then
		return false
	end
	local proxy = CreateObjectNoOffset(proxyModel, sourceCoords.x, sourceCoords.y, sourceCoords.z, false, false, false)
	if not proxy or proxy == 0 or not DoesEntityExist(proxy) then
		return false
	end

	SetEntityRotation(proxy, sourceRotation.x, sourceRotation.y, sourceRotation.z, 0, false)
	SetEntityCollision(proxy, false, false)
	SetEntityCompletelyDisableCollision(proxy, false, false)
	SetEntityAlpha(proxy, 0, false)
	FreezeEntityPosition(proxy, false)

	local anchor = CreateObjectNoOffset(proxyModel, sourceCoords.x, sourceCoords.y, sourceCoords.z, false, false, false)
	if not anchor or anchor == 0 or not DoesEntityExist(anchor) then
		DeleteObject(proxy)
		return false
	end
	SetEntityCollision(anchor, false, false)
	SetEntityCompletelyDisableCollision(anchor, false, false)
	SetEntityAlpha(anchor, 0, false)
	AttachEntityToEntity(anchor, ped, boneIndex, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, true, false, 0, true, false, false)

	PropTool.gizmoProxyHandle = proxy
	PropTool.gizmoAnchorHandle = anchor
	PropTool.gizmoEditing = true
	PropTool.gizmoSessionId = (PropTool.gizmoSessionId or 0) + 1
	local sessionId = PropTool.gizmoSessionId

	local function applyOffsetFromProxy()
		if not PropTool.active or not PropTool.handle or not DoesEntityExist(PropTool.handle) then
			return
		end
		if not PropTool.gizmoProxyHandle or not DoesEntityExist(PropTool.gizmoProxyHandle) then
			return
		end
		if not PropTool.gizmoAnchorHandle or not DoesEntityExist(PropTool.gizmoAnchorHandle) then
			return
		end

		local proxyPos = GetEntityCoords(PropTool.gizmoProxyHandle)
		local proxyRot = GetEntityRotation(PropTool.gizmoProxyHandle, 0)
		local anchorLocal = GetOffsetFromEntityGivenWorldCoords(PropTool.gizmoAnchorHandle, proxyPos.x, proxyPos.y, proxyPos.z)
		PropTool.pos = vector3(anchorLocal.x, anchorLocal.y, anchorLocal.z)

		local anchorRot = GetEntityRotation(PropTool.gizmoAnchorHandle, 0)
		PropTool.rot = vector3(
			normalizeAngle(proxyRot.x - anchorRot.x),
			normalizeAngle(proxyRot.y - anchorRot.y),
			normalizeAngle(proxyRot.z - anchorRot.z)
		)

		if PropTool.posStep ~= 0 then
			PropTool.posSteps = vector3(
				PropTool.pos.x / PropTool.posStep,
				PropTool.pos.y / PropTool.posStep,
				PropTool.pos.z / PropTool.posStep
			)
		end
		if PropTool.rotStep ~= 0 then
			PropTool.rotSteps = vector3(
				PropTool.rot.x / PropTool.rotStep,
				PropTool.rot.y / PropTool.rotStep,
				PropTool.rot.z / PropTool.rotStep
			)
		end

		attachProp()
	end

	CreateThread(function()
		while PropTool.gizmoEditing and PropTool.gizmoProxyHandle == proxy and sessionId == PropTool.gizmoSessionId do
			applyOffsetFromProxy()
			Wait(0)
		end
	end)

	local ok, result = pcall(function()
		return exports["object_gizmo"]:useGizmo(proxy)
	end)
	PropTool.gizmoEditing = false

	if not ok then
		debugPrint("object_gizmo export call failed")
		PropTool.pos = previousPos
		PropTool.rot = previousRot
		PropTool.posSteps = previousPosSteps
		PropTool.rotSteps = previousRotSteps
		if PropTool.gizmoProxyHandle and DoesEntityExist(PropTool.gizmoProxyHandle) then
			DeleteObject(PropTool.gizmoProxyHandle)
		end
		if PropTool.gizmoAnchorHandle and DoesEntityExist(PropTool.gizmoAnchorHandle) then
			DeleteObject(PropTool.gizmoAnchorHandle)
		end
		PropTool.gizmoProxyHandle = nil
		PropTool.gizmoAnchorHandle = nil
		attachProp()
		return false
	end

	if not result then
		PropTool.pos = previousPos
		PropTool.rot = previousRot
		PropTool.posSteps = previousPosSteps
		PropTool.rotSteps = previousRotSteps
		if PropTool.gizmoProxyHandle and DoesEntityExist(PropTool.gizmoProxyHandle) then
			DeleteObject(PropTool.gizmoProxyHandle)
		end
		if PropTool.gizmoAnchorHandle and DoesEntityExist(PropTool.gizmoAnchorHandle) then
			DeleteObject(PropTool.gizmoAnchorHandle)
		end
		PropTool.gizmoProxyHandle = nil
		PropTool.gizmoAnchorHandle = nil
		attachProp()
		return false
	end

	if PropTool.gizmoProxyHandle and DoesEntityExist(PropTool.gizmoProxyHandle) then
		DeleteObject(PropTool.gizmoProxyHandle)
	end
	if PropTool.gizmoAnchorHandle and DoesEntityExist(PropTool.gizmoAnchorHandle) then
		DeleteObject(PropTool.gizmoAnchorHandle)
	end
	PropTool.gizmoProxyHandle = nil
	PropTool.gizmoAnchorHandle = nil

	attachProp()
	return true
end

ensureAnimDictLoaded = function(dict)
	if HasAnimDictLoaded(dict) then
		return true
	end

	RequestAnimDict(dict)
	local timeout = GetGameTimer() + 5000
	while not HasAnimDictLoaded(dict) do
		Wait(0)
		if GetGameTimer() > timeout then
			return false
		end
	end

	return true
end

local function setPedLockState(ped, locked)
	FreezeEntityPosition(ped, locked)
	if locked then
		SetEntityCollision(ped, false, false)
	else
		SetEntityCollision(ped, true, true)
	end
end

local function startToolPedLock()
	if PropTool.pedLockActive then
		return true
	end

	if not ensureCurrentLockAnimLoaded() then
		return false
	end

	PropTool.pedLockActive = true
	PropTool.pedLockSessionId = (PropTool.pedLockSessionId or 0) + 1
	local sessionId = PropTool.pedLockSessionId
	local ped = PlayerPedId()
	if ped and ped ~= 0 and DoesEntityExist(ped) then
		setPedLockState(ped, true)
		applyCurrentLockAnim(ped)
	end

	CreateThread(function()
		while PropTool.pedLockActive and sessionId == PropTool.pedLockSessionId do
			if not PropTool.pedLockActive or sessionId ~= PropTool.pedLockSessionId then
				break
			end
			ped = PlayerPedId()
			if ped and ped ~= 0 and DoesEntityExist(ped) then
				setPedLockState(ped, true)
				applyCurrentLockAnim(ped)
			end
			Wait(0)
		end
	end)

	return true
end

local function stopToolPedLock(fastRestore)
	if PropTool.pedLockActive then
		PropTool.pedLockActive = false
		PropTool.pedLockSessionId = (PropTool.pedLockSessionId or 0) + 1
	end

	local ped = PlayerPedId()
	if ped and ped ~= 0 and DoesEntityExist(ped) then
		setPedLockState(ped, false)
		ClearPedTasksImmediately(ped)
	end

	removeAllToolAnimDicts()
end

local function useObjectGizmoOnPed()
	if not isObjectGizmoStarted() then
		return false
	end

	local ped = PlayerPedId()
	if not ped or ped == 0 or not DoesEntityExist(ped) then
		return false
	end

	if not PropTool.active or not PropTool.handle or not DoesEntityExist(PropTool.handle) then
		return false
	end

	if not ensureCurrentLockAnimLoaded() then
		return false
	end

	local proxyModel = GetEntityModel(PropTool.handle)
	if not proxyModel or proxyModel == 0 then
		return false
	end
	if not HasModelLoaded(proxyModel) then
		RequestModel(proxyModel)
		local timeout = GetGameTimer() + 5000
		while not HasModelLoaded(proxyModel) do
			Wait(0)
			if GetGameTimer() > timeout then
				return false
			end
		end
	end

	local pedCoords = GetEntityCoords(ped)
	local pedRot = GetEntityRotation(ped, 2)
	local proxy = CreateObjectNoOffset(proxyModel, pedCoords.x, pedCoords.y, pedCoords.z, false, false, false)
	if not proxy or proxy == 0 or not DoesEntityExist(proxy) then
		return false
	end
	SetEntityRotation(proxy, pedRot.x, pedRot.y, pedRot.z, 2, false)
	SetEntityCollision(proxy, false, false)
	SetEntityCompletelyDisableCollision(proxy, true, false)
	SetEntityAlpha(proxy, 0, false)

	local lockState = true
	CreateThread(function()
		while lockState do
			if not DoesEntityExist(ped) or not DoesEntityExist(proxy) then
				break
			end

			local proxyPos = GetEntityCoords(proxy)
			local proxyRot = GetEntityRotation(proxy, 2)
			SetEntityCoordsNoOffset(ped, proxyPos.x, proxyPos.y, proxyPos.z, false, false, false)
			SetEntityHeading(ped, proxyRot.z)
			SetPedDesiredHeading(ped, proxyRot.z)

			setPedLockState(ped, true)
			applyCurrentLockAnim(ped)

			if PropTool.active and PropTool.handle and DoesEntityExist(PropTool.handle) then
				attachProp()
			end
			Wait(0)
		end
	end)

	local ok, result = pcall(function()
		return exports["object_gizmo"]:useGizmo(proxy)
	end)

	lockState = false
	if proxy and DoesEntityExist(proxy) then
		DeleteObject(proxy)
	end
	if not PropTool.pedLockActive then
		setPedLockState(ped, false)
		ClearPedTasks(ped)
		removeAllToolAnimDicts()
	end

	if not ok or not result then
		return false
	end

	if PropTool.active and PropTool.handle and DoesEntityExist(PropTool.handle) then
		attachProp()
	end

	return true
end

local function ensureModelLoaded(model)
	if not IsModelValid(model) then
		return false
	end
	RequestModel(model)
	local timeout = GetGameTimer() + 5000
	while not HasModelLoaded(model) do
		Wait(0)
		if GetGameTimer() > timeout then
			return false
		end
	end
	return true
end

attachProp = function()
	if not PropTool.handle then return end
	local ped = PlayerPedId()
	local boneIndex = GetEntityBoneIndexByName(ped, PropTool.bone)
	if not boneIndex or boneIndex == -1 then
		return
	end
	AttachEntityToEntity(
		PropTool.handle,
		ped,
		boneIndex,
		PropTool.pos,
		PropTool.rot,
		false,
		false,
		true,
		false,
		0,
		true,
		false,
		false
	)
end

local function applyStepCounts()
	PropTool.pos = vector3(
		PropTool.posSteps.x * PropTool.posStep,
		PropTool.posSteps.y * PropTool.posStep,
		PropTool.posSteps.z * PropTool.posStep
	)
	PropTool.rot = vector3(
		PropTool.rotSteps.x * PropTool.rotStep,
		PropTool.rotSteps.y * PropTool.rotStep,
		PropTool.rotSteps.z * PropTool.rotStep
	)
	attachProp()
end

local function destroyProp(fastRestore)
	stopToolCamera()
	stopToolPedLock(fastRestore)

	if PropTool.gizmoProxyHandle and DoesEntityExist(PropTool.gizmoProxyHandle) then
		DeleteObject(PropTool.gizmoProxyHandle)
	end
	if PropTool.gizmoAnchorHandle and DoesEntityExist(PropTool.gizmoAnchorHandle) then
		DeleteObject(PropTool.gizmoAnchorHandle)
	end
	PropTool.gizmoProxyHandle = nil
	PropTool.gizmoAnchorHandle = nil
	PropTool.gizmoEditing = false
	if PropTool.handle and DoesEntityExist(PropTool.handle) then
		DeleteObject(PropTool.handle)
	end
	PropTool.handle = nil
	PropTool.active = false
	PropTool.model = nil
end

local function spawnProp(modelName, bone)
	destroyProp()
	local model = GetHashKey(modelName)
	if not ensureModelLoaded(model) then
		mosquito.notify.objective("Model invalid or failed to load: " .. tostring(modelName))
		return
	end
	PropTool.model = modelName
	PropTool.bone = bone or "PH_R_Hand"
	local ped = PlayerPedId()
	local coords = GetEntityCoords(ped)
	PropTool.handle = CreateObjectNoOffset(model, coords.x, coords.y, coords.z + 0.5, true, false, false)
	SetEntityCollision(PropTool.handle, false, false)
	SetEntityCompletelyDisableCollision(PropTool.handle, false, false)
	SetEntityAlpha(PropTool.handle, 255, false)
	PropTool.active = true
	if isObjectGizmoStarted() then
		if not startToolCamera() then
			mosquito.notify.objective("Prop tool enabled, but failed to start tool camera.")
		end
		if not startToolPedLock() then
			mosquito.notify.objective("Prop tool enabled, but failed to lock player animation/physics.")
		end
	else
		stopToolCamera()
		stopToolPedLock(true)
	end
	applyStepCounts()
	debugPrint("Spawned prop '" .. modelName .. "' on bone " .. PropTool.bone)
end

local function startDebugThread()
	CreateThread(function()
		while PropTool.active do
			Wait(0)
			if DisplayDebugText then
				local worldPos = nil
				local worldRot = nil
				local finalPos = vector3(
					PropTool.posSteps.x * PropTool.posStep,
					PropTool.posSteps.y * PropTool.posStep,
					PropTool.posSteps.z * PropTool.posStep
				)
				local finalRot = vector3(
					PropTool.rotSteps.x * PropTool.rotStep,
					PropTool.rotSteps.y * PropTool.rotStep,
					PropTool.rotSteps.z * PropTool.rotStep
				)
				if PropTool.handle and DoesEntityExist(PropTool.handle) then
					worldPos = GetEntityCoords(PropTool.handle)
					worldRot = GetEntityRotation(PropTool.handle)
				end

				local worldPosText = "(n/a)"
				if worldPos then
					worldPosText = string.format("(%.4f, %.4f, %.4f)", worldPos.x, worldPos.y, worldPos.z)
				end

				local worldRotText = "(n/a)"
				if worldRot then
					worldRotText = string.format("(%.2f, %.2f, %.2f)", worldRot.x, worldRot.y, worldRot.z)
				end

				local modeText = "Slider"
				if isObjectGizmoStarted() then
					modeText = PropTool.gizmoEditing and "Gizmo (editing)" or "Gizmo"
				end

				local text = string.format(
					"Prop: %s\nMode: %s\nBone: %s\nWorld pos: %s\nWorld rot: %s\nPos offset (X,Y,Z): (%.4f, %.4f, %.4f) [steps X,Y,Z: %.1f, %.1f, %.1f]\nRot offset (X,Y,Z): (%.2f, %.2f, %.2f) [steps X,Y,Z: %.1f, %.1f, %.1f]\nFinal offsets -> Pos (X,Y,Z): (%.4f, %.4f, %.4f) | Rot (X,Y,Z): (%.2f, %.2f, %.2f)\nBase step: pos=%.4f rot=%.2f",
					PropTool.model or "?",
					modeText,
					PropTool.bone,
					worldPosText,
					worldRotText,
					PropTool.pos.x, PropTool.pos.y, PropTool.pos.z,
					PropTool.posSteps.x, PropTool.posSteps.y, PropTool.posSteps.z,
					PropTool.rot.x, PropTool.rot.y, PropTool.rot.z,
					PropTool.rotSteps.x, PropTool.rotSteps.y, PropTool.rotSteps.z,
					finalPos.x, finalPos.y, finalPos.z,
					finalRot.x, finalRot.y, finalRot.z,
					PropTool.posStep, PropTool.rotStep
				)
				DisplayDebugText(text, 0.5, 0.78, 255, 255, 255, 200, true)
			end
		end
	end)
end

local function toggleTool(modelName, bone)
	if PropTool.active then
		mosquito.notify.objective("Prop tool disabled.")
		destroyProp()
		return
	end
	if not modelName or modelName == "" then
		local input = promptInput({ header = "Enter prop model", placeholder = PropTool.model or "" })
		modelName = input ~= "" and input or modelName
	end
	if not modelName or modelName == "" then
		mosquito.notify.objective("No model provided.")
		return
	end
	spawnProp(modelName, bone)
	startDebugThread()
	if isObjectGizmoStarted() then
		useObjectGizmo()
	end
end

local function rebuildMenu(menu)
	if menu then
		menu.close()
	end
	CreateThread(function()
		Wait(50)
		openPropToolMenu()
	end)
end

function openPropToolMenu()
	local gizmoMode = isObjectGizmoStarted()
	if gizmoMode then
		if not startToolCamera() then
			mosquito.notify.objective("Could not start tool camera.")
		end
		if not PropTool.active and not startToolPedLock() then
			mosquito.notify.objective("Could not apply player lock state.")
		end
	else
		stopToolCamera()
		stopToolPedLock(true)
	end

	local elements = {}

	local currentModel = PropTool.model or "(not set)"
	local currentBone = PropTool.bone or "PH_R_Hand"
	local lockAnimPreset = getResolvedLockAnimPreset()
	local isCustomLockAnimSelected = getCurrentLockAnimPreset().custom == true

	table.insert(elements, {
		label = "Model: " .. currentModel,
		value = "set_model",
		desc = "Enter the prop model to spawn/attach."
	})

	table.insert(elements, {
		label = "Bone: " .. currentBone,
		value = "set_bone",
		desc = "Enter bone name (default PH_R_Hand)."
	})

	table.insert(elements, {
		label = "Lock Animation: " .. lockAnimPreset.label,
		value = "cycle_lock_anim",
		desc = "Cycle between Current, Frozen Neanderthal, None, and Custom."
	})

	if isCustomLockAnimSelected then
		table.insert(elements, {
			label = "Custom Dict: " .. ((PropTool.customLockAnimDict and PropTool.customLockAnimDict ~= "") and PropTool.customLockAnimDict or "(unset)"),
			value = "set_custom_lock_anim_dict",
			desc = "Set custom animation dictionary used for lock animation."
		})

		table.insert(elements, {
			label = "Custom Name: " .. ((PropTool.customLockAnimName and PropTool.customLockAnimName ~= "") and PropTool.customLockAnimName or "(unset)"),
			value = "set_custom_lock_anim_name",
			desc = "Set custom animation name used for lock animation."
		})
	end

	table.insert(elements, {
		label = PropTool.active and "Disable Prop Tool" or "Enable Prop Tool",
		value = "toggle",
		desc = "Spawn/delete the prop using current model/bone."
	})

	if gizmoMode then
		table.insert(elements, {
			label = PropTool.active and "Edit with object_gizmo" or "object_gizmo detected",
			value = "use_object_gizmo",
			desc = PropTool.active and "Open object_gizmo for live transform editing." or "Enable tool first to edit with object_gizmo."
		})

		table.insert(elements, {
			label = "Edit Player Ped with object_gizmo",
			value = "use_ped_object_gizmo",
			desc = "Open object_gizmo on your player ped while prop tool is active."
		})
	else
		table.insert(elements, {
			label = string.format("Pos Step: %.4f", PropTool.posStep),
			value = "set_pos_step",
			desc = "Adjust position step size."
		})

		table.insert(elements, {
			label = string.format("Rot Step: %.2f", PropTool.rotStep),
			value = "set_rot_step",
			desc = "Adjust rotation step size."
		})
	end

	local function addAxisSlider(kind, axis, label, value, min, max, hop)
		table.insert(elements, {
			label = label,
			value = value,
			type = "slider",
			min = min,
			max = max,
			hop = hop,
			axis = axis,
			kind = kind,
			desc = string.format("Adjust %s %s steps (actual offset auto-applied).", kind == "pos" and "position" or "rotation", axis:upper())
		})
	end

	if not gizmoMode then
		addAxisSlider("pos", "x", string.format("Pos X steps (%.1f)", PropTool.posSteps.x), PropTool.posSteps.x, -2000.0, 2000.0, 0.1)
		addAxisSlider("pos", "y", string.format("Pos Y steps (%.1f)", PropTool.posSteps.y), PropTool.posSteps.y, -2000.0, 2000.0, 0.1)
		addAxisSlider("pos", "z", string.format("Pos Z steps (%.1f)", PropTool.posSteps.z), PropTool.posSteps.z, -2000.0, 2000.0, 0.1)
		addAxisSlider("rot", "x", string.format("Rot X steps (%.1f)", PropTool.rotSteps.x), PropTool.rotSteps.x, -1440.0, 1440.0, 0.1)
		addAxisSlider("rot", "y", string.format("Rot Y steps (%.1f)", PropTool.rotSteps.y), PropTool.rotSteps.y, -1440.0, 1440.0, 0.1)
		addAxisSlider("rot", "z", string.format("Rot Z steps (%.1f)", PropTool.rotSteps.z), PropTool.rotSteps.z, -1440.0, 1440.0, 0.1)
	end

	MenuData.CloseAll()
	MenuData.Open('default', GetCurrentResourceName(), 'prop_tool_menu', {
		title = "Prop Tool",
		align = "right",
		elements = elements
	}, function(data, menu)
		local val = data.current.value
		if val == "set_model" then
			local input = promptInput({ header = "Enter prop model", placeholder = PropTool.model or "" })
			if input and input ~= "" then
				PropTool.model = input
			end
			rebuildMenu(menu)
		elseif val == "set_bone" then
			local input = promptInput({ header = "Enter bone name", placeholder = PropTool.bone or "PH_R_Hand" })
			if input and input ~= "" then
				PropTool.bone = input
			end
			rebuildMenu(menu)
		elseif val == "cycle_lock_anim" then
			PropTool.lockAnimIndex = (PropTool.lockAnimIndex or 1) + 1
			if PropTool.lockAnimIndex > #TOOL_LOCK_ANIM_PRESETS then
				PropTool.lockAnimIndex = 1
			end

			if PropTool.pedLockActive then
				local ped = PlayerPedId()
				if ped and ped ~= 0 and DoesEntityExist(ped) then
					applyCurrentLockAnim(ped)
				end
			end

			rebuildMenu(menu)
		elseif val == "set_custom_lock_anim_dict" then
			local input = promptInput({
				header = "Custom lock anim dict",
				placeholder = PropTool.customLockAnimDict or "",
				maxLength = 120,
			})
			if input ~= nil then
				PropTool.customLockAnimDict = tostring(input or "")
			end

			if PropTool.pedLockActive then
				local ped = PlayerPedId()
				if ped and ped ~= 0 and DoesEntityExist(ped) then
					applyCurrentLockAnim(ped)
				end
			end

			rebuildMenu(menu)
		elseif val == "set_custom_lock_anim_name" then
			local input = promptInput({
				header = "Custom lock anim name",
				placeholder = PropTool.customLockAnimName or "",
				maxLength = 120,
			})
			if input ~= nil then
				PropTool.customLockAnimName = tostring(input or "")
			end

			if PropTool.pedLockActive then
				local ped = PlayerPedId()
				if ped and ped ~= 0 and DoesEntityExist(ped) then
					applyCurrentLockAnim(ped)
				end
			end

			rebuildMenu(menu)
		elseif val == "toggle" then
			toggleTool(PropTool.model, PropTool.bone)
			rebuildMenu(menu)
		elseif val == "set_pos_step" then
			local input = promptInput({
				header = "Pos step (e.g. 0.001)",
				placeholder = tostring(PropTool.posStep),
				htmlType = "number",
				title = "Numbers only",
				maxLength = 12,
			}, true)
			local num = input and tonumber(input)
			if num then
				PropTool.posStep = num
			end
			rebuildMenu(menu)
		elseif val == "set_rot_step" then
			local input = promptInput({
				header = "Rot step (e.g. 0.25)",
				placeholder = tostring(PropTool.rotStep),
				htmlType = "number",
				title = "Numbers only",
				maxLength = 12,
			}, true)
			local num = input and tonumber(input)
			if num then
				PropTool.rotStep = num
			end
			rebuildMenu(menu)
		elseif val == "use_object_gizmo" then
			if not PropTool.active then
				mosquito.notify.objective("Enable the prop tool first.")
			elseif not useObjectGizmo() then
				mosquito.notify.objective("object_gizmo is not available or edit was canceled.")
			end
			rebuildMenu(menu)
		elseif val == "use_ped_object_gizmo" then
			if not PropTool.active then
				mosquito.notify.objective("Enable the prop tool first.")
			elseif not useObjectGizmoOnPed() then
				mosquito.notify.objective("Could not open object_gizmo on player ped.")
			end
			rebuildMenu(menu)
		elseif data.current.kind then
			local kind = data.current.kind
			local axis = data.current.axis
			local newVal = tonumber(val)
			if newVal then
				if kind == "pos" then
					PropTool.posSteps = vector3(
						axis == "x" and newVal or PropTool.posSteps.x,
						axis == "y" and newVal or PropTool.posSteps.y,
						axis == "z" and newVal or PropTool.posSteps.z
					)
				else
					PropTool.rotSteps = vector3(
						axis == "x" and newVal or PropTool.rotSteps.x,
						axis == "y" and newVal or PropTool.rotSteps.y,
						axis == "z" and newVal or PropTool.rotSteps.z
					)
				end
				applyStepCounts()
			end
			-- keep menu open; slider updates in place
		else
			menu.close()
		end
	end, function(data, menu)
		if not PropTool.active then
			stopToolPedLock(true)
			stopToolCamera()
		end
		menu.close()
	end)
end

-- Public commands ---------------------------------------------------------

if Config.Debug then
	RegisterCommand("prop_tool", function(_, args)
		local model = args[1]
		local bone = args[2]
		if model or bone then
			toggleTool(model, bone)
		end
		openPropToolMenu()
	end, false)

	RegisterCommand("prop_tool_menu", function()
		openPropToolMenu()
	end, false)
end

AddEventHandler("onResourceStop", function(res)
	if res == GetCurrentResourceName() then
		destroyProp(true)
	end
end)
