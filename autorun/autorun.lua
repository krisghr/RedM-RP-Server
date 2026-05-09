local autoRun = false
local speedHeld = false

local DISTANCE_AHEAD = 8.0
local TURN_SPEED = 1

local SPEED_STEP = 0.5
local MAX_SPEED = 2.0
local currentSpeed = 1.0

-- Controls
local KEY_A = 0x7065027D
local KEY_D = 0xB4E465B4
local KEY_CTRL = 0xDB096B85 -- LEFT CONTROL
local KEY_TOGGLE = 0x80F28E95 -- G
local KEY_SHIFT = 0x8FFC75D6
local KEY_AIM = 0x07CE1E61

local SLOPE_CHECK_DISTANCE = 2.0
local MAX_UPHILL_GRADE = 0.8 -- ~39 degrees; blocks near-vertical climbs

local autoRunPromptGroupMain = GetRandomIntInRange(0, 0xffffff)
local promptStop, promptInc, promptDec

local function getSpeedLabel(speed)
    if speed <= 0.5 then
        return "Strolling"
    elseif speed <= 1.0 then
        return "Walking"
    elseif speed <= 1.9 then
        return "Fast-Walking"
    else
        return "Running"
    end
end

local function registerAutoRunPrompts()
    -- Stop Autowalking (Left Click)
    promptStop = UiPromptRegisterBegin()
    UiPromptSetControlAction(promptStop, KEY_AIM)
    UiPromptSetText(promptStop, CreateVarString(10, "LITERAL_STRING", "Stop Autowalking"))
    UiPromptSetEnabled(promptStop, true)
    UiPromptSetVisible(promptStop, true)
    UiPromptSetStandardMode(promptStop, true)
    UiPromptSetGroup(promptStop, autoRunPromptGroupMain, 0)
    UiPromptRegisterEnd(promptStop)

    -- Increase Speed (Shift)
    promptInc = UiPromptRegisterBegin()
    UiPromptSetControlAction(promptInc, KEY_SHIFT)
    UiPromptSetText(promptInc, CreateVarString(10, "LITERAL_STRING", "Increase Speed"))
    UiPromptSetEnabled(promptInc, true)
    UiPromptSetVisible(promptInc, true)
    UiPromptSetStandardMode(promptInc, true)
    UiPromptSetGroup(promptInc, autoRunPromptGroupMain, 0)
    UiPromptRegisterEnd(promptInc)

    -- Decrease Speed (Ctrl)
    promptDec = UiPromptRegisterBegin()
    UiPromptSetControlAction(promptDec, KEY_CTRL)
    UiPromptSetText(promptDec, CreateVarString(10, "LITERAL_STRING", "Decrease Speed"))
    UiPromptSetEnabled(promptDec, true)
    UiPromptSetVisible(promptDec, true)
    UiPromptSetStandardMode(promptDec, true)
    UiPromptSetGroup(promptDec, autoRunPromptGroupMain, 0)
    UiPromptRegisterEnd(promptDec)
end

local function getForwardPoint(ped, distance)
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local headingRad = math.rad(heading)

    local x = coords.x + math.sin(-headingRad) * distance
    local y = coords.y + math.cos(headingRad) * distance
    local z = coords.z

    return x, y, z, heading
end

local function getGroundZAt(x, y, z)
    local foundGround, groundZ = GetGroundZFor_3dCoord(x, y, z + 1.0, true)
    if foundGround then
        return groundZ
    end

    return nil
end

local function isForwardSlopeWalkable(ped)
    local x1, y1, z1 = table.unpack(GetEntityCoords(ped))
    local x2, y2, z2 = getForwardPoint(ped, SLOPE_CHECK_DISTANCE)

    local groundZ1 = getGroundZAt(x1, y1, z1)
    local groundZ2 = getGroundZAt(x2, y2, z2)

    if not groundZ1 or not groundZ2 then
        return false
    end

    local deltaZ = groundZ2 - groundZ1
    local grade = deltaZ / SLOPE_CHECK_DISTANCE

    return grade <= MAX_UPHILL_GRADE
end

local function stopAutoRun(reason)
    autoRun = false
    ClearPedTasks(PlayerPedId())
    print(reason)
end

local function toggleAutoRun()
    autoRun = not autoRun

    if autoRun then
        currentSpeed = 1.0
        speedHeld = false
    else
        stopAutoRun("Disabled.")
    end
end

RegisterCommand("autorun", function()
    toggleAutoRun()
end, false)

CreateThread(function()
    registerAutoRunPrompts()
    while true do
        Wait(0)

        if IsControlJustPressed(0, KEY_TOGGLE) then
            toggleAutoRun()
        end

        if autoRun then
            local labelMain = CreateVarString(10, "LITERAL_STRING", "Autowalk - " .. getSpeedLabel(currentSpeed))
            UiPromptSetActiveGroupThisFrame(autoRunPromptGroupMain, labelMain, 0, 0, 0, 0)

            local ped = PlayerPedId()

            if IsControlJustPressed(0, KEY_SHIFT) then
                currentSpeed = currentSpeed + SPEED_STEP
                if currentSpeed > MAX_SPEED then
                    currentSpeed = MAX_SPEED
                end
            end

            if IsControlPressed(0, KEY_CTRL) then
                if not speedHeld then
                    speedHeld = true
                    currentSpeed = currentSpeed - SPEED_STEP

                    if currentSpeed <= 0.0 then
                        stopAutoRun("Cancelled: speed reached 0.")
                    end
                end
            else
                speedHeld = false
            end

            if autoRun then
                if IsControlPressed(0, KEY_AIM) then
                    stopAutoRun("Cancelled.")
                else
                    if DoesEntityExist(ped) and not IsPedDeadOrDying(ped) then
                        local heading = GetEntityHeading(ped)

                        if IsControlPressed(0, KEY_A) then
                            heading = heading + TURN_SPEED
                            SetEntityHeading(ped, heading)
                        end

                        if IsControlPressed(0, KEY_D) then
                            heading = heading - TURN_SPEED
                            SetEntityHeading(ped, heading)
                        end

                        if not isForwardSlopeWalkable(ped) then
                            stopAutoRun("Cancelled: slope too steep.")
                        else
                            SetPedMaxMoveBlendRatio(ped, currentSpeed)

                            local x, y, z, newHeading = getForwardPoint(ped, DISTANCE_AHEAD)

                            TaskGoStraightToCoord(
                            ped,
                            x, y, z,
                            currentSpeed,
                            300,
                            newHeading,
                            0.5
                            )
                        end
                    end
                end
            end
        end
    end
end)
