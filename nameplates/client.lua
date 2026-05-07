local NAME_DRAW_DISTANCE = 20.0
local names = {}
local showIds = false
local showNameplates = true

CreateThread(function()
    while true do
        TriggerServerEvent("player_names:requestNames")
        Wait(5000)
    end
end)

RegisterNetEvent("player_names:receiveNames", function(serverNames)
    names = serverNames or {}
end)

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

                            if showIds then
                                displayText = "[" .. serverId .. "] " .. name
                            end

                            table.insert(nameplates, {
                                x = screenX,
                                y = screenY,
                                opacity = 1.0 - ((distance / NAME_DRAW_DISTANCE) * 0.5),
                                text = displayText
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