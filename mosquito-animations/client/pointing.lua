local TraceFlags = 1 + 2 + 4 + 8 + 16 + 32 + 64 + 128 + 256 + 512 + 1024 + 2048

function Raycast(from, to)
    local rayHandle = StartShapeTestRay(from.x, from.y, from.z, to.x, to.y, to.z, TraceFlags, PlayerPedId(), 0) -- 2048 is ragdolled horses and horses, 1024 is horses alone, 4 is peds alone, 8 is peds ragdolled and peds, 
    local _, hit, hitCoords, _, hitEntity = GetShapeTestResult(rayHandle)
    return hit == 1, hitCoords, hitEntity
end

if Config.Pointing == false then return end

state                  = {}
local animDict
local animName
local OptionType

local IK_SEND_HZ       = 15
local IK_LOSS_TIMEOUT  = 750
local IK_HALF_LIFE     = 0.10

local IK_XMIN, IK_XMAX = -10.0, 10.0
local IK_YMIN, IK_YMAX = -10.0, 10.0
local IK_ZMIN, IK_ZMAX = -10.0, 10.0

local SB_IK_POINTQ     = "mosqIkPointQ"
local SB_IK_ACTIVE     = "mosqIkActive"
local SB_IK_FLAGS      = "mosqIkFlags"
local _ik_last_send    = 0
local _ik_last_sent_q  = nil

local _ik_targets      = {}
local _ik_smooth       = {}


local PointAtDirectionPrompt       = nil
local StopPointingPrompt           = nil
local centerXOffset, centerYOffset = -0.025, 0.0
local CursorRotation               = -20.0
local CursorSizePx                 = 10
local screenW, screenH             = GetCurrentScreenResolution()
local CursorSizeX                  = CursorSizePx / screenW
local CursorSizeY                  = CursorSizePx / screenH
local textureDict                  = "ammo_types"
local textureName                  = "tomahawk_normal"
local EmoteDirectionalState        = {
    isPointing = false,
    prevDict = nil,
    prevAnim = nil,
    isActive = false,
    promptGroup = GetRandomIntInRange(0, 0xFFFFFF)
}

local BASE_ANIM_DICT               = "script_mp@emotes@point@male@unarmed@upper"
local BASE_ANIM_NAME               = "loop"
local ANIM_FLAG                    = 25
local IK_FLAG                      = (1 << 16)
local BlendIn                      = 2.0
local BlendOut                     = 2.0
local BlendIkIsolateIn             = 1000
local BlendIkIsolateOut            = 250

local _ik_targets                  = _ik_targets or {}
local _ik_smooth                   = _ik_smooth or {}
local _ik_active_sids              = _ik_active_sids or {}

-- Only task/stop anims on entities we control (remote player peds can spam task pools).
local function HasControlOfEntitySafe(ent)
    if ent == 0 then return false end
    if ent == PlayerPedId() then return true end
    if type(NetworkHasControlOfEntity) == "function" then
        return NetworkHasControlOfEntity(ent)
    end
    return false
end

local function addActiveSid(sid)
    for i = 1, #_ik_active_sids do
        if _ik_active_sids[i] == sid then
            return
        end
    end
    _ik_active_sids[#_ik_active_sids + 1] = sid
end

local function removeActiveSid(sid)
    for i = 1, #_ik_active_sids do
        if _ik_active_sids[i] == sid then
            table.remove(_ik_active_sids, i)
            break
        end
    end
end

local function cleanupSid(sid, pedOpt)
    local tgt = _ik_targets[sid]
    if not tgt then
        removeActiveSid(sid)
        _ik_smooth[sid] = nil
        return
    end

    local ped = pedOpt
    if ped == nil then
        local ply = GetPlayerFromServerId(sid)
        if ply and ply ~= -1 then
            ped = GetPlayerPed(ply)
        else
            ped = 0
        end
    end

    if ped ~= 0 and HasControlOfEntitySafe(ped) and IsEntityPlayingAnim(ped, BASE_ANIM_DICT, BASE_ANIM_NAME, 3) then
        StopAnimTask(ped, BASE_ANIM_DICT, BASE_ANIM_NAME, 1.7)
    end

    _ik_smooth[sid]  = nil
    _ik_targets[sid] = nil
    removeActiveSid(sid)
end

local function RotationToDirection(rotation)
    local radZ = math.rad(rotation.z)
    local radX = math.rad(rotation.x)
    local cosX = math.cos(radX)
    return vector3(-math.sin(radZ) * cosX, math.cos(radZ) * cosX, math.sin(radX))
end

local function getLookAtCoords(ped)
    local camRot = GetGameplayCamRot(2)
    local isLookingUp = camRot.x > Config.PointingUpValue
    local camCoords = GetGameplayCamCoord()
    local forward = RotationToDirection(camRot)
    local targetCoords = camCoords + (forward * 10.0)
    local pedHeading = GetEntityHeading(ped)
    local signedDiff = ((camRot.z - pedHeading + 180) % 360) - 180
    local baseThreshold = (GetPedCrouchMovement(ped) ~= 1 and Config.PointingBehindThreshold.standing or Config.PointingBehindThreshold.crouching)
    local advancedThresholds = isLookingUp and baseThreshold.lookingup or baseThreshold.normal
    local effectiveThreshold = (signedDiff > 0) and advancedThresholds.left or advancedThresholds.right
    local isBehind = math.abs(signedDiff) > effectiveThreshold
    if isBehind then
        local sign = signedDiff > 0 and 1 or -1
        local clampedZ = pedHeading + (sign * effectiveThreshold)
        local newCamRot = vector3(camRot.x, camRot.y, clampedZ)
        local forwardClamped = RotationToDirection(newCamRot)
        local maxTarget = camCoords + (forwardClamped * 10.0)
        return isBehind, maxTarget.x, maxTarget.y, maxTarget.z, newCamRot
    end
    return isBehind, targetCoords.x, targetCoords.y, targetCoords.z, camRot
end

local function ensurePrompt(stopPrompt)
    if not PointAtDirectionPrompt then
        PointAtDirectionPrompt = PromptRegisterBegin()
        PromptSetControlAction(PointAtDirectionPrompt, 0xF84FA74F)
        PromptSetText(PointAtDirectionPrompt, CreateVarString(10, "LITERAL_STRING", "Hold to Aim Direction"))
        PromptSetGroup(PointAtDirectionPrompt, EmoteDirectionalState.promptGroup)
        PromptSetEnabled(PointAtDirectionPrompt, true)
        PromptSetVisible(PointAtDirectionPrompt, true)
        PromptRegisterEnd(PointAtDirectionPrompt)
    end
    if not StopPointingPrompt and stopPrompt then
        StopPointingPrompt = PromptRegisterBegin()
        PromptSetControlAction(StopPointingPrompt, Config.PointControlKeyboards)
        PromptSetText(StopPointingPrompt, CreateVarString(10, "LITERAL_STRING", "Stop Pointing"))
        PromptSetGroup(StopPointingPrompt, EmoteDirectionalState.promptGroup)
        PromptSetEnabled(StopPointingPrompt, true)
        PromptSetVisible(StopPointingPrompt, true)
        PromptRegisterEnd(StopPointingPrompt)
    end
end

EmoteDirectionalState = EmoteDirectionalState or {
    isPointing = false,
    prevDict = nil,
    prevAnim = nil,
    isActive = false,
    ikX = nil,
    ikY = nil,
    ikZ = nil,
}

function DrawPointer(ped, x, y, z)
    if not HasStreamedTextureDictLoaded(textureDict) then
        RequestStreamedTextureDict(textureDict, true)
        while not HasStreamedTextureDictLoaded(textureDict) do
            Wait(0)
        end
    end
    local handBone = GetEntityBoneIndexByName(ped, "SKEL_R_Finger13")
    local handCoords = GetWorldPositionOfEntityBone(ped, handBone)
    local camRot = GetGameplayCamRot(2)
    local forward = RotationToDirection(camRot)
    local to = handCoords + (forward * 5.0)
    local hit, hitCoords, hitEntity = Raycast(handCoords, to)

    if not hit then
        hitCoords = to
    end

    local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(hitCoords.x, hitCoords.y,
        hitCoords.z)
    if onScreen then
        local distance = #(handCoords - hitCoords)
        local screenW, screenH = GetCurrentScreenResolution()
        local baseCursorSize = math.min(screenW, screenH) * 0.03
        local minSize = baseCursorSize * 0.2
        local scaleFactor = math.max(0.15, 1.0 - (distance * 0.2))
        local cursorSize = math.max(minSize, baseCursorSize * scaleFactor)
        local cursorAlpha = math.max(150, math.min(255, math.floor(scaleFactor * 255 * 3.5)))

        local sizeX = cursorSize / screenW
        local sizeY = cursorSize / screenH

        DrawSprite(
            textureDict,
            textureName,
            screenX + centerXOffset, screenY + centerYOffset,
            sizeX, sizeY,
            CursorRotation,
            255, 255, 255, cursorAlpha
        )
    end
end

local function SmoothIkTarget(state, tx, ty, tz)
    local dt        = GetFrameTime and GetFrameTime() or 0.016

    local baseSpeed = (Config.PointingSmoothBase or 4.0)   -- always move at least this much
    local accel     = (Config.PointingSmoothAccel or 10.0) -- how much extra speed we add if the target is far
    local maxSpeed  = (Config.PointingSmoothMax or 25.0)   -- clamp so it does not explode

    local sx        = state.ikX or tx
    local sy        = state.ikY or ty
    local sz        = state.ikZ or tz

    local dx        = tx - sx
    local dy        = ty - sy
    local dz        = tz - sz
    local dist      = math.sqrt(dx * dx + dy * dy + dz * dz)

    local speed     = baseSpeed + dist * accel
    if speed > maxSpeed then
        speed = maxSpeed
    end

    local t = speed * dt
    if t > 1.0 then
        t = 1.0
    end

    sx = sx + dx * t
    sy = sy + dy * t
    sz = sz + dz * t

    state.ikX = sx
    state.ikY = sy
    state.ikZ = sz

    return sx, sy, sz
end


local function q16(n, min, max)
    local t = (n - min) / (max - min)
    if t < 0.0 then t = 0.0 elseif t > 1.0 then t = 1.0 end
    return math.floor(t * 65535 + 0.5)
end

local function dq16(q, min, max)
    return min + (q / 65535.0) * (max - min)
end

local function spring(current, target, vel, halfLife, dt)
    local k = 0.69314718056 / math.max(halfLife, 0.0001)
    local f = 1 + 2 * k * dt
    local oo = k * k * dt * dt
    local det = 1.0 / (f + oo)
    local yNext = (f * current + dt * vel + oo * target) * det
    local vNext = (vel + k * k * dt * (target - current)) * det
    return yNext, vNext
end
local function GetActivePlayersServerIds()
    local ids = {}
    for _, ply in ipairs(GetActivePlayers()) do
        table.insert(ids, GetPlayerServerId(ply))
    end
    return ids
end

local function PublishIkTarget(ped, sx, sy, sz, isActive)
    local now = GetGameTimer()
    if now - _ik_last_send < (1000 / IK_SEND_HZ) then
        LocalPlayer.state:set(SB_IK_ACTIVE, isActive and true or false, true)
        return
    end
    _ik_last_send = now

    LocalPlayer.state:set(SB_IK_ACTIVE, isActive and true or false, true)

    if not isActive or not sx then
        _ik_last_sent_q = nil
        return
    end

    local px, py, pz = table.unpack(GetEntityCoords(ped))
    local rx, ry, rz = sx - px, sy - py, sz - pz

    if rx < IK_XMIN then rx = IK_XMIN elseif rx > IK_XMAX then rx = IK_XMAX end
    if ry < IK_YMIN then ry = IK_YMIN elseif ry > IK_YMAX then ry = IK_YMAX end
    if rz < IK_ZMIN then rz = IK_ZMIN elseif rz > IK_ZMAX then rz = IK_ZMAX end

    local qx = q16(rx, IK_XMIN, IK_XMAX)
    local qy = q16(ry, IK_YMIN, IK_YMAX)
    local qz = q16(rz, IK_ZMIN, IK_ZMAX)

    local pack = { qx, qy, qz }

    if not _ik_last_sent_q
        or _ik_last_sent_q[1] ~= qx
        or _ik_last_sent_q[2] ~= qy
        or _ik_last_sent_q[3] ~= qz
    then
        LocalPlayer.state:set(SB_IK_POINTQ, pack, true)
        _ik_last_sent_q = pack
    end
end

-- =========================
-- Receive remote IK state
-- =========================
AddStateBagChangeHandler(SB_IK_ACTIVE, nil, function(bagName, key, value, _reserved, _replicated)
    local sid = tonumber(bagName:match("player:(%d+)"))
    if not sid then return end

    local tgt = _ik_targets[sid] or {}
    tgt.ts    = GetGameTimer()

    if value then
        tgt.active = true
        _ik_targets[sid] = tgt
        addActiveSid(sid)
    else
        tgt.active = false
        _ik_targets[sid] = tgt
        cleanupSid(sid)
    end
end)

AddStateBagChangeHandler(SB_IK_POINTQ, nil, function(bagName, key, value, _reserved, _replicated)
    local sid = tonumber(bagName:match("player:(%d+)"))
    if not sid or type(value) ~= "table" then return end

    local ply = GetPlayerFromServerId(sid)
    if not ply or ply == -1 then return end
    local ped = GetPlayerPed(ply)
    if ped == 0 then return end

    local px, py, pz = table.unpack(GetEntityCoords(ped))
    local rx         = dq16(value[1], IK_XMIN, IK_XMAX)
    local ry         = dq16(value[2], IK_YMIN, IK_YMAX)
    local rz         = dq16(value[3], IK_ZMIN, IK_ZMAX)

    local tgt        = _ik_targets[sid] or {}
    tgt.x            = px + rx
    tgt.y            = py + ry
    tgt.z            = pz + rz
    tgt.ts           = GetGameTimer()

    _ik_targets[sid] = tgt
end)

local function GetActivePlayersServerIds()
    local sids = {}
    local players = GetActivePlayers()
    for i = 1, #players do
        local ply = players[i]
        local sid = GetPlayerServerId(ply)
        if sid ~= 0 then
            sids[#sids + 1] = sid
        end
    end
    -- for i = 1, 100 do
    --     sids[i] = i
    -- end
    return sids
end

if Config.PointingSyncIsolateArm and Config.PointingIsolateArm then
    CreateThread(function()
        RequestAnimDict(BASE_ANIM_DICT)

        while true do
            if #_ik_active_sids == 0 then
                Wait(200)
            else
                Wait(0)

                local dt    = GetFrameTime()
                local now   = GetGameTimer()
                local mySid = GetPlayerServerId(PlayerId())

                if not HasAnimDictLoaded(BASE_ANIM_DICT) then
                    RequestAnimDict(BASE_ANIM_DICT)
                end

                for i = #_ik_active_sids, 1, -1 do
                    local sid = _ik_active_sids[i]
                    if sid ~= mySid then
                        local t = _ik_targets[sid]

                        if (not t) or (not t.active) then
                            cleanupSid(sid)
                        else
                            local ply = GetPlayerFromServerId(sid)
                            local ped = (ply and GetPlayerPed(ply)) or 0

                            if ped == 0 then
                                cleanupSid(sid, ped)
                            else
                                if (t.ts and (now - t.ts) > IK_LOSS_TIMEOUT) then
                                    cleanupSid(sid, ped)
                                else
                                    local playing = IsEntityPlayingAnim(ped, BASE_ANIM_DICT, BASE_ANIM_NAME, 3)

                                    if (not playing) and HasAnimDictLoaded(BASE_ANIM_DICT) and HasControlOfEntitySafe(ped) then
                                        TaskPlayAnim(
                                            ped,
                                            BASE_ANIM_DICT,
                                            BASE_ANIM_NAME,
                                            BlendIn,
                                            BlendOut,
                                            -1,
                                            ANIM_FLAG,
                                            0.0,
                                            false,
                                            IK_FLAG,
                                            false,
                                            "",
                                            false
                                        )
                                    end

                                    if t.x and t.y and t.z then
                                        local s = _ik_smooth[sid] or {
                                            x = t.x,
                                            y = t.y,
                                            z = t.z,
                                            vx = 0.0,
                                            vy = 0.0,
                                            vz = 0.0
                                        }

                                        s.x, s.vx = spring(s.x, t.x, s.vx, IK_HALF_LIFE, dt)
                                        s.y, s.vy = spring(s.y, t.y, s.vy, IK_HALF_LIFE, dt)
                                        s.z, s.vz = spring(s.z, t.z, s.vz, IK_HALF_LIFE, dt)

                                        SetIkTarget(
                                            ped,
                                            4, 0, 0,
                                            s.x, s.y, s.z,
                                            0,
                                            BlendIkIsolateIn,
                                            BlendIkIsolateOut
                                        )

                                        _ik_smooth[sid] = s
                                    end
                                end
                            end
                        end
                    end
                    if Config.PointingSyncingBreakTickPlayerCount and (i % Config.PointingSyncingBreakTickPlayerCount == 0) then
                        Wait(0)
                    end
                end
            end
        end
    end)
end

function CheckButtonPressed(optionType)
    if Config.PointControlUseRawKey and not IsUsingController then
        return IsRawKeyPressed(0, Config.PointControl[optionType])
    else
        if Config.DisableActionControl[optionType] then
            DisableControlAction(0, Config.PointControl[optionType], true)
            return IsDisabledControlJustPressed(0, Config.PointControl[optionType])
        else
            return IsControlJustPressed(0, Config.PointControl[optionType])
        end
    end
end

function CheckButtonHold(optionType)
    if Config.PointControlUseRawKey and not IsUsingController then
        return IsRawKeyPressed(0, Config.PointControl[optionType])
    else
        if Config.DisableActionControl[optionType] then
            DisableControlAction(0, Config.PointControl[optionType], true)
            return IsDisabledControlPressed(0, Config.PointControl[optionType])
        else
            return IsControlPressed(0, Config.PointControl[optionType])
        end
    end
end



function UpdatePointing(ped)
    if not ped or ped == 0 then
        return
    end

    state = EmoteDirectionalState
    animDict = BASE_ANIM_DICT
    animName = BASE_ANIM_NAME
    OptionType = IsUsingController and "Controller" or "Keyboard"
    if Config.PointControlType[OptionType] == "toggle" then
        if IsPedRagdoll(ped) or IsPedDeadOrDying(ped, true) or (IsPedArmed(ped, 4) and IsPedArmed(ped, 4) ~= 0) then
            if state.isPointing then
                state.isPointing = false
                for i = 1, 3 do
                    mosquito.notify.right_tip(" ", 9999999)
                end
                StopAnimTask(ped, animDict, animName, 1.7)
                state.prevDict, state.prevAnim = nil, nil
                PublishIkTarget(ped, nil, nil, nil, false) -- [IK NET]
            end
        end

        local isPressed = CheckButtonPressed(OptionType)

        if isPressed then
            if state.isPointing then
                state.isPointing = false
                StopAnimTask(ped, animDict, animName, 1.7)
                for i = 1, 3 do
                    mosquito.notify.right_tip(" ", 9999999)
                end
                state.prevDict, state.prevAnim = nil, nil
                PublishIkTarget(ped, nil, nil, nil, false) -- [IK NET]
            else
                if GetCurrentPedWeaponEntityIndex(ped, 0) ~= 0 then
                    local _, weaponHash = GetCurrentPedWeapon(ped, true)
                    local isGun = IsWeaponAGun(weaponHash)
                    local isTwoHanded = IsWeaponTwoHanded(weaponHash)
                    local isTwoHandedGun = isTwoHanded ~= 0 and isGun ~= 0
                    if isTwoHandedGun then
                        SetCurrentPedWeapon(ped, weaponHash, false, 1, false, false)
                    else
                        SetCurrentPedWeapon(ped, GetHashKey('WEAPON_UNARMED'), false)
                    end
                    Wait(400)
                elseif (GetCurrentPedWeaponEntityIndex(ped, 0) ~= 0 or GetCurrentPedWeaponEntityIndex(ped, 1) ~= 0) then
                    local _, weaponHash = GetCurrentPedWeapon(ped, true)
                    local isGun = IsWeaponAGun(weaponHash)
                    local isTwoHanded = IsWeaponTwoHanded(weaponHash)
                    local isTwoHandedGun = isTwoHanded ~= 0 and isGun ~= 0
                    GiveWeaponToPed(ped, weaponHash, 0, true, false)
                    SetCurrentPedWeapon(ped, GetHashKey('WEAPON_UNARMED'), true)
                end
                state.isPointing = true
                state.ikX, state.ikY, state.ikZ = nil, nil, nil
                local text = string.format(Config.PointingTogglePromptText, "~" .. Config.PointControl[OptionType] .. "~")
                mosquito.notify.right_tip(text, 9999999)
                PublishIkTarget(ped, nil, nil, nil, true) -- expose active immediately
            end

            if state.isPointing then
                RequestAnimDict(animDict)
                while not HasAnimDictLoaded(animDict) do
                    Wait(0)
                end
                TaskPlayAnim(ped, animDict, animName, BlendIn, BlendOut, -1, ANIM_FLAG, 0.0, false, IK_FLAG, false, "", false)
                state.prevDict, state.prevAnim = animDict, animName
            else
                StopAnimTask(ped, animDict, animName, 1.7)
                state.prevDict, state.prevAnim = nil, nil
            end
        end

        if state.isPointing then
            local isbehind, x, y, z, camRot = getLookAtCoords(ped)
            local sx, sy, sz
            SetPlayerSimulateAiming(PlayerId(), true)

            if Config.PointingIsolateArm then
                sx, sy, sz = SmoothIkTarget(state, x, y, z)
                SetIkTarget(ped, 4, 0, 0, sx, sy, sz, 0, BlendIkIsolateIn, BlendIkIsolateOut)
            end

            if isbehind then
                SetPedDesiredHeading(ped, camRot.z)
            end

            if (state.prevDict ~= animDict or state.prevAnim ~= animName)
                or not IsEntityPlayingAnim(ped, animDict, animName, 3) then
                RequestAnimDict(animDict)
                while not HasAnimDictLoaded(animDict) do
                    Wait(0)
                end
                TaskPlayAnim(ped, animDict, animName, BlendIn, BlendOut, -1, ANIM_FLAG, 0.0, false, IK_FLAG, false, "")
                state.prevDict, state.prevAnim = animDict, animName
            end

            if Config.PointingDrawPointer then
                DrawPointer(ped, sx, sy, sz)
            end

            PublishIkTarget(ped, sx, sy, sz, true)

            SetPlayerSimulateAiming(PlayerId(), true)
        else
            SetPlayerSimulateAiming(PlayerId(), false)
        end
    elseif Config.PointControlType[OptionType] == "hold" then
        local isPressed = CheckButtonHold(OptionType)
        if isPressed ~= state.isActive then
            state.isActive = isPressed
            if isPressed then
                if GetCurrentPedWeaponEntityIndex(ped, 0) ~= 0 then
                    local _, weaponHash = GetCurrentPedWeapon(ped, true)
                    local isGun = IsWeaponAGun(weaponHash)
                    local isTwoHanded = IsWeaponTwoHanded(weaponHash)
                    local isTwoHandedGun = isTwoHanded ~= 0 and isGun ~= 0
                    if isTwoHandedGun then
                        SetCurrentPedWeapon(ped, weaponHash, false, 1, false, false)
                    else
                        SetCurrentPedWeapon(ped, GetHashKey('WEAPON_UNARMED'), false)
                    end
                    Wait(400)
                elseif (GetCurrentPedWeaponEntityIndex(ped, 0) ~= 0 or GetCurrentPedWeaponEntityIndex(ped, 1) ~= 0) then
                    local _, weaponHash = GetCurrentPedWeapon(ped, true)
                    local isGun = IsWeaponAGun(weaponHash)
                    local isTwoHanded = IsWeaponTwoHanded(weaponHash)
                    local isTwoHandedGun = isTwoHanded ~= 0 and isGun ~= 0
                    GiveWeaponToPed(ped, weaponHash, 0, true, false)
                    SetCurrentPedWeapon(ped, GetHashKey('WEAPON_UNARMED'), true)
                end
            end
            if state.isActive then
                state.isPointing = true
                state.ikX, state.ikY, state.ikZ = nil, nil, nil
                PublishIkTarget(ped, nil, nil, nil, true) -- [IK NET]
            else
                state.isPointing = false
                if state.prevDict and state.prevAnim then
                    StopAnimTask(ped, state.prevDict, state.prevAnim, 1.7)
                    state.prevDict, state.prevAnim = nil, nil
                end
                PublishIkTarget(ped, nil, nil, nil, false) -- [IK NET]
            end
        end

        if state.isActive then
            local isbehind, x, y, z, camRot = getLookAtCoords(ped)
            SetPlayerSimulateAiming(PlayerId(), true)
            local sx, sy, sz
            if Config.PointingIsolateArm then
                sx, sy, sz = SmoothIkTarget(state, x, y, z)
                SetIkTarget(ped, 4, 0, 0, sx, sy, sz, 0, BlendIkIsolateIn, BlendIkIsolateOut)
            end

            if isbehind then
                SetPedDesiredHeading(ped, camRot.z)
            end

            if state.isPointing and (IsPedRagdoll(ped) or IsPedDeadOrDying(ped, true) or (IsPedArmed(ped, 4) and IsPedArmed(ped, 4) ~= 0)) then
                state.isPointing = false
                StopAnimTask(ped, state.prevDict or animDict, state.prevAnim or animName, 1.7)
                state.prevDict, state.prevAnim = nil, nil
                mosquito.notify.right_tip(" ", 9999999)
                PublishIkTarget(ped, nil, nil, nil, false) -- [IK NET]
            end

            if (state.prevDict ~= animDict or state.prevAnim ~= animName)
                or not IsEntityPlayingAnim(ped, animDict, animName, 3) then
                RequestAnimDict(animDict)
                while not HasAnimDictLoaded(animDict) do
                    Wait(0)
                end
                TaskPlayAnim(ped, animDict, animName, BlendIn, BlendOut, -1, ANIM_FLAG, 0.0, false, IK_FLAG, false, "")
                state.prevDict, state.prevAnim = animDict, animName
            end

            if Config.PointingDrawPointer then
                DrawPointer(ped, sx, sy, sz)
            end

            -- removed: per-tick RequestTaskMoveNetworkStateTransition spam

            PublishIkTarget(ped, sx, sy, sz, true)
        else
            SetPlayerSimulateAiming(PlayerId(), false)
        end
    end
end

function StopPointing()
    local ped = PlayerPedId()
    local state = EmoteDirectionalState
    if state.isPointing then
        state.isPointing = false
        StopAnimTask(ped, state.prevDict or BASE_ANIM_DICT, state.prevAnim or BASE_ANIM_NAME, 1.7)
        for i = 1, 3 do
            mosquito.notify.right_tip(" ", 9999999)
        end
        state.prevDict, state.prevAnim = nil, nil
    end
end

RegisterCommand("stoppointing", function()
    StopPointing()
end, false)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if PointAtDirectionPrompt then
            PromptDelete(PointAtDirectionPrompt)
            PointAtDirectionPrompt = nil
        end
        if StopPointingPrompt then
            PromptDelete(StopPointingPrompt)
            StopPointingPrompt = nil
        end
    end
end)
