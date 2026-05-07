print("[EDITOR_CAM] client.lua loaded")

local editorActive = false
local editorCam = nil

local showHelpMenu = true

local camSpeed = 0.10
local minCamSpeed = 0.02
local maxCamSpeed = 1.0
local camSpeedStep = 0.02

local maxDistance = 10.0

local pitch = 0.0
local yaw = 0.0
local roll = 0.0

-- Zoom / FOV
local fov = 70.0
local minFov = 5.0
local maxFov = 130.0

-- Movement keys
local KEY_W = 0x8FD015D8
local KEY_S = 0xD27782E3
local KEY_A = 0x7065027D
local KEY_D = 0xB4E465B4
local KEY_SHIFT = 0x8FFC75D6
local KEY_Z = 0x26E9DC00
local KEY_Q = 0xDE794E3E
local KEY_E = 0xCEFD9220
local KEY_BACKSPACE = 0x156F7119
local KEY_LEFTBRACKET = 0x430593AA
local KEY_RIGHTBRACKET = 0xA5BDCD3C

-- UI toggle
local KEY_TOGGLE_HELP = 0x24978A28 -- H

-- Mouse look
local MOUSE_X = 0xA987235F
local MOUSE_Y = 0xD2047988

-- Mouse wheel
local MOUSE_WHEEL_UP = 0x3076E97C
local MOUSE_WHEEL = 0xFD0F0C2C

-- Controls to keep blocked
local KEY_CTRL = 0xDB096B85
local KEY_CHAT = `INPUT_MP_TEXT_CHAT_ALL`

local function DrawEditorHelpMenu()
    local boxRight = 0.98
    local boxWidth = 0.26
    local boxTop = 0.08
    local padding = 0.01

    local boxLeft = boxRight - boxWidth

    SetTextScale(0.35, 0.35)
    SetTextColor(255, 80, 80, 255)
    SetTextJustification(2)
    SetTextWrap(boxLeft + padding, boxRight - padding)

    DisplayText(CreateVarString(10, "LITERAL_STRING", "Editor Cam Active"), boxRight - padding, boxTop + padding)

    SetTextScale(0.35, 0.35)
    SetTextColor(255, 255, 255, 215)
    SetTextJustification(2)
    SetTextWrap(boxLeft + padding, boxRight - padding)

    DisplayText(CreateVarString(10, "LITERAL_STRING",
        string.format("Cam Speed: %.2f", camSpeed) ..
        "\nW/A/S/D: Move" ..
        "\nShift/Ctrl: Up/Down" ..
        "\nMouse: Look" ..
        "\nQ/E: Roll" ..
        "\n[/]: Speed -/+" ..
        "\nMouse Wheel: Zoom" ..
        "\nBackspace: Exit" ..
        "\nH: Toggle this menu"
    ), boxRight - padding, boxTop + padding + 0.025)
end

local function RotationToDirection(rot)
    local z = math.rad(rot.z)
    local x = math.rad(rot.x)
    local cosX = math.cos(x)

    return vector3(
        -math.sin(z) * cosX,
        math.cos(z) * cosX,
        math.sin(x)
    )
end

local function GetRightVector(yawDegrees)
    local z = math.rad(yawDegrees)

    return vector3(
        math.cos(z),
        math.sin(z),
        0.0
    )
end

local function IsDisabledControlPressedAnyGroup(control)
    return IsDisabledControlPressed(0, control)
        or IsDisabledControlPressed(1, control)
        or IsDisabledControlPressed(2, control)
end

local function ClampCameraDistance(camCoords)
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)

    local dx = camCoords.x - pedCoords.x
    local dy = camCoords.y - pedCoords.y
    local dz = camCoords.z - pedCoords.z

    local dist = math.sqrt(dx * dx + dy * dy + dz * dz)

    if dist <= maxDistance then
        return camCoords
    end

    local scale = maxDistance / dist

    return vector3(
        pedCoords.x + dx * scale,
        pedCoords.y + dy * scale,
        pedCoords.z + dz * scale
    )
end

local function ClampCameraAboveGround(camCoords)
    local success, groundZ = GetGroundZFor_3dCoord(camCoords.x, camCoords.y, camCoords.z, 0)

    if success then
        local minCamZ = groundZ + 0.2

        if camCoords.z < minCamZ then
            return vector3(camCoords.x, camCoords.y, minCamZ)
        end
    end

    return camCoords
end

local function StartEditorCam()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    -- Do NOT clear ped tasks here.
    -- Clearing tasks cancels sitting/bench animations.
    FreezeEntityPosition(ped, true)

    editorCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

    SetCamCoord(editorCam, coords.x, coords.y, coords.z + 1.5)

    pitch = 0.0
    yaw = heading
    roll = 0.0
    fov = 70.0

    SetCamRot(editorCam, pitch, roll, yaw, 2)
    SetCamFov(editorCam, fov)
    SetCamActive(editorCam, true)
    RenderScriptCams(true, false, 0, true, true)

    editorActive = true

    print("[EDITOR_CAM] Enabled")
end

local function StopEditorCam()
    local ped = PlayerPedId()

    if editorCam then
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(editorCam, false)
        editorCam = nil
    end

    FreezeEntityPosition(ped, false)

    editorActive = false

    print("[EDITOR_CAM] Disabled")
end


RegisterCommand("editortogglehelp", function()
    showHelpMenu = not showHelpMenu
end, false)

RegisterCommand("editor", function()
    if editorActive then
        StopEditorCam()
    else
        StartEditorCam()
    end
end, false)

CreateThread(function()
    while true do
        Wait(0)

        if editorActive and editorCam then
            local ped = PlayerPedId()

            DisableAllControlActions(0)
            DisableAllControlActions(1)
            DisableAllControlActions(2)

            EnableControlAction(0, KEY_W, true)
            EnableControlAction(0, KEY_S, true)
            EnableControlAction(0, KEY_A, true)
            EnableControlAction(0, KEY_D, true)
            EnableControlAction(0, KEY_SHIFT, true)
            EnableControlAction(0, KEY_CTRL, true)
            EnableControlAction(0, KEY_BACKSPACE, true)
            EnableControlAction(0, KEY_TOGGLE_HELP, true)
            EnableControlAction(0, KEY_LEFTBRACKET, true)
            EnableControlAction(0, KEY_RIGHTBRACKET, true)
            EnableControlAction(0, MOUSE_X, true)
            EnableControlAction(0, MOUSE_Y, true)
            EnableControlAction(0, MOUSE_WHEEL_UP, true)
            EnableControlAction(0, MOUSE_WHEEL, true)
            EnableControlAction(0, KEY_CHAT, true)
            EnableControlAction(1, KEY_CHAT, true)
            EnableControlAction(2, KEY_CHAT, true)

            DisableControlAction(0, KEY_Q, true)
            DisableControlAction(1, KEY_Q, true)
            DisableControlAction(2, KEY_Q, true)

            DisableControlAction(0, KEY_CTRL, true)
            DisableControlAction(1, KEY_CTRL, true)
            DisableControlAction(2, KEY_CTRL, true)

            FreezeEntityPosition(ped, true)

            if IsDisabledControlJustPressed(0, KEY_BACKSPACE) then
                StopEditorCam()
                goto continue
            end

            if IsDisabledControlJustPressed(0, KEY_TOGGLE_HELP) then
                showHelpMenu = not showHelpMenu
            end

            if showHelpMenu then
                DrawEditorHelpMenu()
            end

            if IsDisabledControlJustPressed(0, KEY_LEFTBRACKET) then
                camSpeed = math.max(minCamSpeed, camSpeed - camSpeedStep)
            end

            if IsDisabledControlJustPressed(0, KEY_RIGHTBRACKET) then
                camSpeed = math.min(maxCamSpeed, camSpeed + camSpeedStep)
            end


            local mouseX = GetDisabledControlNormal(0, MOUSE_X)
            local mouseY = GetDisabledControlNormal(0, MOUSE_Y)

            local sensitivity = 8.0
            local rollRad = math.rad(roll)

            local adjustedX = (mouseX * math.cos(rollRad)) - (mouseY * math.sin(rollRad))
            local adjustedY = (mouseX * math.sin(rollRad)) + (mouseY * math.cos(rollRad))

            yaw = yaw - adjustedX * sensitivity
            pitch = pitch - adjustedY * sensitivity

            if IsDisabledControlPressedAnyGroup(KEY_Q) then
                roll = roll - camSpeed * 2
            end

            if IsDisabledControlPressedAnyGroup(KEY_E) then
                roll = roll + camSpeed * 2
            end

            if pitch > 89.0 then pitch = 89.0 end
            if pitch < -89.0 then pitch = -89.0 end

            local camCoords = GetCamCoord(editorCam)
            local forward = RotationToDirection(vector3(pitch, 0.0, yaw))
            local right = GetRightVector(yaw)

            local newCoords = camCoords

            if IsDisabledControlPressed(0, KEY_W) then
                newCoords = newCoords + forward * camSpeed
            end

            if IsDisabledControlPressed(0, KEY_S) then
                newCoords = newCoords - forward * camSpeed
            end

            if IsDisabledControlPressed(0, KEY_A) then
                newCoords = newCoords - right * camSpeed
            end

            if IsDisabledControlPressed(0, KEY_D) then
                newCoords = newCoords + right * camSpeed
            end

            if IsDisabledControlPressed(0, KEY_SHIFT) then
                newCoords = vector3(newCoords.x, newCoords.y, newCoords.z + camSpeed)
            end

            if IsDisabledControlPressedAnyGroup(KEY_CTRL) then
                newCoords = vector3(newCoords.x, newCoords.y, newCoords.z - camSpeed)
            end

            -- Mouse wheel zoom
            -- Wheel up hash handles zoom in.
            if IsDisabledControlPressed(0, MOUSE_WHEEL_UP) then
                fov = fov - camSpeed
            end

            -- Wheel axis handles zoom out.
            local wheel = GetDisabledControlNormal(0, MOUSE_WHEEL)

            if wheel ~= 0.0 then
                fov = fov + (wheel * camSpeed)
            end

            if fov < minFov then fov = minFov end
            if fov > maxFov then fov = maxFov end

            newCoords = ClampCameraDistance(newCoords)
            newCoords = ClampCameraAboveGround(newCoords)

            SetCamCoord(editorCam, newCoords.x, newCoords.y, newCoords.z)
            SetCamRot(editorCam, pitch, roll, yaw, 2)
            SetCamFov(editorCam, fov)
        end

        ::continue::
    end
end)