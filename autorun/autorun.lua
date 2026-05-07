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
local KEY_CTRL = GetHashKey("INPUT_DUCK")
local KEY_TOGGLE = 0x80F28E95 -- G
local KEY_SHIFT = 0x8FFC75D6
local KEY_AIM = 0x07CE1E61

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

local function drawAutoRunHelp()
    local boxRight = 0.98
    local boxWidth = 0.18
    local boxHeight = 0.145
    local boxTop = 0.08
    local padding = 0.01

    local boxLeft = boxRight - boxWidth

    -- Background: black, roughly 20% opacity


    -- Red title
    SetTextScale(0.35, 0.35)
    SetTextColor(255, 80, 80, 255)
    SetTextJustification(2)
    SetTextWrap(boxLeft + padding, boxRight - padding)

    DisplayText(CreateVarString(10, "LITERAL_STRING",
        "Autowalk Active"
    ), boxRight - padding, boxTop + padding)

    -- White body
    SetTextScale(0.35, 0.35)
    SetTextColor(255, 255, 255, 215)
    SetTextJustification(2)
    SetTextWrap(boxLeft + padding, boxRight - padding)

    DisplayText(CreateVarString(10, "LITERAL_STRING",
        getSpeedLabel(currentSpeed) ..
        "\nG, Left Click, or /autorun: Cancel" ..
        "\nShift: Increase Speed" ..
        "\nCtrl: Decrease Speed" ..
        "\nA/D: Turn"
    ), boxRight - padding, boxTop + padding + 0.025)
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

local function stopAutoRun(reason)
    autoRun = false
    ClearPedTasks(PlayerPedId())
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
    while true do
        Wait(0)

        if IsControlJustPressed(0, KEY_TOGGLE) then
            toggleAutoRun()
        end

        if autoRun then
            drawAutoRunHelp()

            local ped = PlayerPedId()

            -- Increase speed with Shift
            if IsControlJustPressed(0, KEY_SHIFT) then
                currentSpeed = currentSpeed + SPEED_STEP

                if currentSpeed > MAX_SPEED then
                    currentSpeed = MAX_SPEED
                end
            end

            -- Disable default Ctrl actions so Ctrl only affects autorun speed
            DisableControlAction(0, KEY_CTRL, true)
            DisableControlAction(1, KEY_CTRL, true)
            DisableControlAction(2, KEY_CTRL, true)

            -- Decrease speed with Ctrl
            if IsDisabledControlPressed(0, KEY_CTRL) or IsDisabledControlPressed(1, KEY_CTRL) or IsDisabledControlPressed(2, KEY_CTRL) then
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
end)