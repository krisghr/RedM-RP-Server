local NAME_DRAW_DISTANCE = 20.0
local isRDR = not TerraingridActivate and true or false
local names = {}
local showIds = false
local showNameplates = true
local typingDebugEnabled = false
local lastTypingStates = {}
local localTypingTestEnabled = false
local localTypingSynced = false

local function setLocalTypingState(isTyping)
    if localTypingSynced == isTyping then return end
    localTypingSynced = isTyping
    TriggerServerEvent("player_names:setTypingState", isTyping)

    if typingDebugEnabled then
        print(("[nameplates typing debug] local sync typing=%s"):format(tostring(isTyping)))
    end
end

CreateThread(function()
    while true do
        TriggerServerEvent("player_names:requestNames")
        Wait(5000)
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

        if not showNameplates then
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

                            if showIds then
                                displayText = "[" .. serverId .. "] " .. name
                            end

                            table.insert(nameplates, {
                                x = screenX,
                                y = screenY,
                                opacity = 1.0 - ((distance / NAME_DRAW_DISTANCE) * 0.5),
                                text = displayText,
                                isTyping = isTyping
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