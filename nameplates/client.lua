local NAME_DRAW_DISTANCE = 20.0
local isRDR = not TerraingridActivate and true or false
local names = {}
local showIds = false
local showNameplates = true
local typingDebugEnabled = false
local lastTypingStates = {}
local localTypingTestEnabled = false
local localTypingSynced = false
local localAfkSynced = false
local hasSelectedCharacter = true
local AFK_TIMEOUT_MS = 5 * 60 * 1000
local ACTIVITY_CHECK_INTERVAL_MS = 250
local lastLocalActivityAt = GetGameTimer()


local function refreshCharacterSelectionState()
    local state = LocalPlayer and LocalPlayer.state
    if not state then return end

    if state.Character ~= nil or state.IsInSession == true then
        hasSelectedCharacter = true
    end
end

local function shouldHideNameplates()
    if not hasSelectedCharacter then
        return true
    end

    if IsLoadingScreenActive and IsLoadingScreenActive() then
        return true
    end

    if IsLoadingScreenVisible and IsLoadingScreenVisible() then
        return true
    end

    return false
end

local function setLocalTypingState(isTyping)
    if localTypingSynced == isTyping then return end
    localTypingSynced = isTyping
    TriggerServerEvent("player_names:setTypingState", isTyping)

    if typingDebugEnabled then
        print(("[nameplates typing debug] local sync typing=%s"):format(tostring(isTyping)))
    end
end

local function setLocalAfkState(isAfk)
    if localAfkSynced == isAfk then return end
    localAfkSynced = isAfk
    TriggerServerEvent("player_names:setAfkState", isAfk)
end

local function hasLocalActivity()
    local ped = PlayerPedId()

    if IsPedRunning(ped) or IsPedSprinting(ped) or IsPedWalking(ped) then
        return true
    end

    if IsPedJumping(ped) or IsPedClimbing(ped) or IsPedSwimming(ped) then
        return true
    end

    if IsPedInAnyVehicle(ped, false) and (GetEntitySpeed(ped) > 0.1) then
        return true
    end

    local movementControls = {
        isRDR and `INPUT_MOVE_UP_ONLY` or 32,
        isRDR and `INPUT_MOVE_DOWN_ONLY` or 33,
        isRDR and `INPUT_MOVE_LEFT_ONLY` or 34,
        isRDR and `INPUT_MOVE_RIGHT_ONLY` or 35,
        isRDR and `INPUT_JUMP` or 22,
        isRDR and `INPUT_ATTACK` or 24,
        isRDR and `INPUT_AIM` or 25,
        isRDR and `INPUT_SPRINT` or 21,
        isRDR and `INPUT_DUCK` or 36
    }

    for _, control in ipairs(movementControls) do
        if IsControlJustPressed(0, control) or IsControlPressed(0, control) then
            return true
        end
    end

    return false
end

CreateThread(function()
    while true do
        TriggerServerEvent("player_names:requestNames")
        Wait(5000)
    end
end)

CreateThread(function()
    while true do
        Wait(ACTIVITY_CHECK_INTERVAL_MS)

        if hasLocalActivity() then
            lastLocalActivityAt = GetGameTimer()
            setLocalAfkState(false)
        else
            local now = GetGameTimer()
            local isAfk = (now - lastLocalActivityAt) >= AFK_TIMEOUT_MS
            setLocalAfkState(isAfk)
        end
    end
end)

CreateThread(function()
    while true do
        Wait(100)

        if localTypingTestEnabled then
            setLocalTypingState(true)
        else
            if IsControlPressed(0, isRDR and `INPUT_MP_TEXT_CHAT_ALL` or 245) then
                setLocalTypingState(true)
            elseif localTypingSynced and not IsNuiFocused() then
                setLocalTypingState(false)
            end
        end
    end
end)

RegisterNetEvent("player_names:receiveNames", function(serverNames)
    refreshCharacterSelectionState()

local normalizedNames = {}

    for id, data in pairs(serverNames or {}) do
        local numericId = tonumber(id)
        if numericId then
            local previousData = names[numericId]
            if previousData and previousData.isTyping == true and (not data or data.isTyping == nil) then
                data = data or {}
                data.isTyping = true
            end
            normalizedNames[numericId] = data
        end
    end

    names = normalizedNames

    if typingDebugEnabled then
        for id, data in pairs(names) do
            local isTyping = data and data.isTyping == true

            if lastTypingStates[id] ~= isTyping then
                print(("[nameplates typing debug] id=%s typing=%s"):format(id, tostring(isTyping)))
                lastTypingStates[id] = isTyping
            end
        end
    end
end)

RegisterNetEvent("player_names:updateTypingState", function(serverId, isTyping)
    serverId = tonumber(serverId)
    if not serverId then return end

    if not names[serverId] then
        names[serverId] = {
            id = serverId,
            name = GetPlayerName(GetPlayerFromServerId(serverId)) or ("Player " .. serverId)
        }
    end

    names[serverId].isTyping = isTyping == true

    if typingDebugEnabled then
        print(("[nameplates typing debug] realtime id=%s typing=%s"):format(serverId, tostring(isTyping == true)))
    end
end)


RegisterNetEvent("player_names:updateAfkState", function(serverId, isAfk)
    serverId = tonumber(serverId)
    if not serverId then return end

    if not names[serverId] then
        names[serverId] = {
            id = serverId,
            name = GetPlayerName(GetPlayerFromServerId(serverId)) or ("Player " .. serverId)
        }
    end

    names[serverId].isAfk = isAfk == true
end)

RegisterNetEvent("vorp:SelectedCharacter", function()
    hasSelectedCharacter = true
end)

RegisterNetEvent("vorpcharacter:selectCharacter", function()
    hasSelectedCharacter = false
end)

RegisterNetEvent("vorpcharacter:startCharacterCreator", function()
    hasSelectedCharacter = false
end)

RegisterNetEvent("vorp:initNewCharacter", function()
    hasSelectedCharacter = false
end)


RegisterCommand("typingdebugnp", function()
    typingDebugEnabled = not typingDebugEnabled
    lastTypingStates = {}

    TriggerEvent("chat:addMessage", {
        args = {
            "TypingDebug",
            typingDebugEnabled and "Nameplates typing debug enabled." or "Nameplates typing debug disabled."
        }
    })
end, false)

AddEventHandler("onClientResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    TriggerServerEvent("player_names:setTypingState", false)
    TriggerServerEvent("player_names:setAfkState", false)
end)

RegisterCommand("typingtestnp", function()
    localTypingTestEnabled = not localTypingTestEnabled
    local myServerId = GetPlayerServerId(PlayerId())

    if not names[myServerId] then
        names[myServerId] = {
            id = myServerId,
            name = GetPlayerName(PlayerId())
        }
    end

    names[myServerId].isTyping = localTypingTestEnabled

    TriggerEvent("chat:addMessage", {
        args = {
            "TypingDebug",
            localTypingTestEnabled and "Local typing test ON." or "Local typing test OFF."
        }
    })
end, false)

RegisterCommand("toggleID", function()
    showIds = not showIds

    TriggerEvent("chat:addMessage", {
        args = {
            "Nameplates",
            showIds and "IDs enabled." or "IDs disabled."
        }
    })
end, false)

RegisterCommand("togglenames", function()
    showNameplates = not showNameplates

    TriggerEvent("chat:addMessage", {
        args = {
            "Nameplates",
            showNameplates and "Nameplates enabled." or "Nameplates disabled."
        }
    })

    if not showNameplates then
        SendNUIMessage({
            action = "updateNameplates",
            nameplates = {}
        })
    end
end, false)

CreateThread(function()
    while true do
        Wait(0)

        if not showNameplates or not hasSelectedCharacter then
            if not hasSelectedCharacter then
                SendNUIMessage({
                    action = "updateNameplates",
                    nameplates = {}
                })
            end
            Wait(250)
        else
            local nameplates = {}
            local myPed = PlayerPedId()
            local myCoords = GetEntityCoords(myPed)

            for _, player in ipairs(GetActivePlayers()) do
                local serverId = GetPlayerServerId(player)
                local targetPed = GetPlayerPed(player)

                if targetPed and targetPed ~= 0 and DoesEntityExist(targetPed) then
                    local rootCoords = GetEntityCoords(targetPed)
                    local distance = #(myCoords - rootCoords)

                    local isCrouching = Citizen.InvokeNative(0xD5FE956C70FF370B, targetPed)

                    if distance <= NAME_DRAW_DISTANCE and not isCrouching then
                        local data = names[serverId]
                        local name = data and data.name or GetPlayerName(player)

                        local zOffset = 0.45

                        if IsPedOnMount(targetPed) then
                            zOffset = 0.45
                        elseif IsPedInAnyVehicle(targetPed, false) then
                            zOffset = 0.65
                        end

                        local headCoords = GetPedBoneCoords(targetPed, 21030, 0.0, 0.0, 0.0)

                        local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(
                            headCoords.x,
                            headCoords.y,
                            headCoords.z + zOffset
                        )

                        if onScreen then
                            local displayText = name
                            local isTyping = data and data.isTyping == true
                            local isAfk = data and data.isAfk == true
                            local isEditor = data and data.isEditor == true

                            if isEditor then
                                displayText = displayText .. " (Editor)"
                            end

                            if showIds then
                                displayText = "[" .. serverId .. "] " .. name
                            end

                            table.insert(nameplates, {
                                x = screenX,
                                y = screenY,
                                opacity = 1.0 - ((distance / NAME_DRAW_DISTANCE) * 0.5),
                                text = displayText,
                                isTyping = isTyping,
                                isAfk = isAfk
                            })
                        end
                    end
                end
            end

            SendNUIMessage({
                action = "updateNameplates",
                nameplates = nameplates
            })
        end
    end
end)