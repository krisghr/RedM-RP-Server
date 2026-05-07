local PickerIsOpen = false
local InteractionMarker
local StartingCoords
CurrentInteraction = nil
local CanStartInteraction = true
local MaxRadius = 0.0
local ObjectModelHashes = {}
local textString = "Use ~INPUT_SNIPER_ZOOM_OUT_ONLY~ to navigate, ~INPUT_AIM~ to ~COLOR_NET_PLAYER10~cancel~q~, ~INPUT_CONTEXT_RT~ to ~COLOR_GREENLIGHT~accept~q~ ~n~ and ~INPUT_FRONTEND_RLEFT~ to end interaction."
local InteractionStartTime = 0
local InteractionStartDebounceDelay = 100 -- milliseconds

local InteractPrompt

function CreateInteractPrompt(label)
    if not InteractPrompt then
        local prompt = UiPromptRegisterBegin()
        UiPromptSetControlAction(prompt, Config_InteractionMenu.InteractControl)
        UiPromptSetText(prompt, CreateVarString(10, 'LITERAL_STRING', label and (Config_InteractionMenu.InteractWithPromptText .. label) or Config_InteractionMenu.InteractPromptText))
        UiPromptSetEnabled(prompt, true)
        UiPromptSetVisible(prompt, true)
        UiPromptSetStandardMode(prompt, true)
        UiPromptSetHoldMode(prompt, false)
        UiPromptRegisterEnd(prompt)
        InteractPrompt = prompt
    end
end

function DeleteInteractPrompt()
    if InteractPrompt then
        UiPromptSetEnabled(InteractPrompt, false)
        UiPromptSetVisible(InteractPrompt, false)
        UiPromptDelete(InteractPrompt)
        InteractPrompt = nil
    end
end

function DrawMarker(type, posX, posY, posZ, dirX, dirY, dirZ, rotX, rotY, rotZ, scaleX, scaleY, scaleZ, red, green, blue, alpha, bobUpAndDown, faceCamera, p19, rotate, textureDict, textureName, drawOnEnts)
    Citizen.InvokeNative(0x2A32FAA57B937173, type, posX, posY, posZ, dirX, dirY, dirZ, rotX, rotY, rotZ, scaleX, scaleY, scaleZ, red, green, blue, alpha, bobUpAndDown, faceCamera, p19, rotate, textureDict, textureName, drawOnEnts)
end

function IsPedUsingScenarioHash(ped, scenarioHash)
    return Citizen.InvokeNative(0x34D6AC1157C8226C, ped, scenarioHash)
end

local ScanNearbyObjectsRate = Config_InteractionMenu.ScanNearbyObjectsRate or 250
local ScanNearbyObjectsMoveThreshold = Config_InteractionMenu.ScanNearbyObjectsMoveThreshold or 1.5
local LastNearbyObjectsScanAt = 0
local LastNearbyObjectsScanCoords = nil
local CachedNearbyObjects = {}
local InteractionNearbyCacheRate = Config_InteractionMenu.InteractionNearbyCacheRate or 100
local InteractionNearbyMoveThreshold = Config_InteractionMenu.InteractionNearbyMoveThreshold or 0.75
local LastInteractionNearbyCheckAt = 0
local LastInteractionNearbyCoords = nil
local CachedInteractionNearby = false
local CachedInteractionNearbyLabel = nil

local function shouldRescanNearbyObjects(coords, timed)
    if not timed then
        return true
    end

    local now = GetGameTimer()
    local timePassed = now - LastNearbyObjectsScanAt
    local shouldRescan = timePassed >= ScanNearbyObjectsRate

    if not shouldRescan and LastNearbyObjectsScanCoords then
        shouldRescan = #(coords - LastNearbyObjectsScanCoords) >= ScanNearbyObjectsMoveThreshold
    end

    return shouldRescan
end

local function shouldRecheckInteractionNearby(coords)
    local now = GetGameTimer()
    local shouldRecheck = (now - LastInteractionNearbyCheckAt) >= InteractionNearbyCacheRate

    if not shouldRecheck and LastInteractionNearbyCoords then
        shouldRecheck = #(coords - LastInteractionNearbyCoords) >= InteractionNearbyMoveThreshold
    end

    return shouldRecheck
end

if Config_InteractionMenu.DontNearbyObjectScanItemset then
    function GetNearbyObjects(coords, timed)
        if not shouldRescanNearbyObjects(coords, timed) then
            return CachedNearbyObjects
        end

        local objects = {}
        local seen = {}

        for _, modelHash in ipairs(ObjectModelHashes) do
            local object = GetClosestObjectOfType(coords.x, coords.y, coords.z, MaxRadius, modelHash, false, false, false)

            if object ~= 0 and DoesEntityExist(object) and not seen[object] then
                seen[object] = true
                table.insert(objects, object)
            end
        end

        CachedNearbyObjects = objects
        LastNearbyObjectsScanAt = GetGameTimer()
        LastNearbyObjectsScanCoords = coords

        return objects
    end
else
    function GetNearbyObjects(coords, timed)
        if not shouldRescanNearbyObjects(coords, timed) then
            return CachedNearbyObjects
        end

        local itemset = CreateItemset(true)
        local size = Citizen.InvokeNative(0x59B57C4B06531E1E, coords, MaxRadius, itemset, 3, Citizen.ResultAsInteger())

        local objects = {}

        if size > 0 then
            for i = 0, size - 1 do
                table.insert(objects, GetIndexedItemInItemset(i, itemset))
            end
        end

        if IsItemsetValid(itemset) then
            DestroyItemset(itemset)
        end

        CachedNearbyObjects = objects
        LastNearbyObjectsScanAt = GetGameTimer()
        LastNearbyObjectsScanCoords = coords

        return objects
    end
end

function HasCompatibleModel(entity, models)
    local entityModel = GetEntityModel(entity)

    for _, model in ipairs(models) do
        if entityModel == GetHashKey(model) then
            return model
        end
    end

    return nil
end

function CanStartInteractionAtObject(interaction, object, playerCoords, objectCoords)
    if #(playerCoords - objectCoords) > interaction.radius then
        return nil
    end

    return HasCompatibleModel(object, interaction.objects)
end

function PlayInteractionAnimation(ped, anim)
    if not DoesAnimDictExist(anim.dict) then
        return
    end

    RequestAnimDict(anim.dict)

    while not HasAnimDictLoaded(anim.dict) do
        Citizen.Wait(0)
    end

    TaskPlayAnim(ped, anim.dict, anim.name, 0.0, 0.0, -1, 1, 1.0, false, false, false, "", false)

    RemoveAnimDict(anim.dict)
end

function StartInteractionAtCoords(interaction)
    if not CanStartSeatInteraction() then
        return
    end
    local x = interaction.x
    local y = interaction.y
    local z = interaction.z
    local h = interaction.heading

    local ped = PlayerPedId()

    if not StartingCoords then
        StartingCoords = GetEntityCoords(ped)
    end

    ClearPedTasksImmediately(ped)

    local baseEntity = GetEntityUnderPed(ped)
    local isOnVehicle = baseEntity and GetEntityType(baseEntity) == 2 or false

    if not isOnVehicle and IsPlayerInVehicleViaNative(ped) then
        baseEntity = ResolveSittingBaseEntity(ped, nil)
        isOnVehicle = baseEntity and GetEntityType(baseEntity) == 2 or false
    end

    if isOnVehicle and baseEntity and TryAttachPedToSeatEntity(ped, nil, baseEntity) then
        mosquito.notify.right_tip("~COLOR_GOLD~Vehicle seating detected.~q~")
        CurrentlySitting = true
        CurrentSittingType = "interaction"
        CurrentlySittingOnVehicle = true
    end

    if interaction.scenario then
        local instant = false
        for _, scenario in ipairs(IntroAnimations) do
            if interaction.scenario == scenario then
                instant = false
                break
            end
        end
        if not instant then
            TaskStartScenarioAtPosition(ped, GetHashKey(interaction.scenario), x, y, z, h, -1, false, true)
        else
            SetEntityCollision(ped, false, false)
            SetEntityCoordsNoOffset(ped, x, y, z)
            SetEntityHeading(ped, h)
            ExecuteCommand("startscenario " .. interaction.scenario)
        end
    elseif interaction.animation then
        SetEntityCoordsNoOffset(ped, x, y, z)
        SetEntityHeading(ped, h)
        PlayInteractionAnimation(ped, interaction.animation)
    end

    if interaction.effect then
        clean()
    end

    CurrentInteraction = interaction
    InteractionStartTime = GetGameTimer()
end

function StartInteractionAtObject(interaction)
    if not CanStartSeatInteraction() then
        return
    end
    local objectHeading = GetEntityHeading(interaction.object)
    local objectCoords = GetEntityCoords(interaction.object)

    local r = math.rad(objectHeading)
    local cosr = math.cos(r)
    local sinr = math.sin(r)

    local x = interaction.x * cosr - interaction.y * sinr + objectCoords.x
    local y = interaction.y * cosr + interaction.x * sinr + objectCoords.y
    local z = interaction.z + objectCoords.z
    local h = interaction.heading + objectHeading

    interaction.x = x
    interaction.y = y
    interaction.z = z
    interaction.heading = h

    local ped = PlayerPedId()
    local baseEntity = GetEntityUnderPed(ped)

    if not baseEntity and IsPlayerInVehicleViaNative(ped) then
        baseEntity = ResolveSittingBaseEntity(ped, nil)
    end

    if baseEntity and GetEntityType(baseEntity) == 2 then
        TryAttachPedToSeatEntity(ped, interaction.object, baseEntity)
    end

    StartInteractionAtCoords(interaction)
end

function IsCompatible(t, ped)
    return not t.isCompatible or t.isCompatible(ped)
end

function SortInteractions(a, b)
    if a.distance == b.distance then
        if a.object == b.object then
            local aLabel = a.scenario or a.animation.label
            local bLabel = b.scenario or b.animation.label
            return aLabel < bLabel
        else
            return a.object < b.object
        end
    else
        return a.distance < b.distance
    end
end

function AddInteractions(availableInteractions, interaction, playerPed, playerCoords, targetCoords, modelName, object)
    local distance = #(playerCoords - targetCoords)

    if interaction.scenarios then
        for _, scenario in ipairs(interaction.scenarios) do
            if IsCompatible(scenario, playerPed) then
                table.insert(availableInteractions, {
                    x = interaction.x,
                    y = interaction.y,
                    z = interaction.z,
                    heading = interaction.heading,
                    scenario = scenario.name,
                    object = object,
                    modelName = modelName,
                    distance = distance,
                    label = interaction.label,
                    title = scenario.label or scenario.name,
                    effect = interaction.effect
                })
            end
        end
    end

    if interaction.animations then
        for _, animation in ipairs(interaction.animations) do
            if IsCompatible(animation, playerPed) then
                table.insert(availableInteractions, {
                    x = interaction.x,
                    y = interaction.y,
                    z = interaction.z,
                    heading = interaction.heading,
                    animation = animation,
                    object = object,
                    modelName = modelName,
                    distance = distance,
                    title = interaction.label or animation.label,
                    effect = interaction.effect
                })
            end
        end
    end
end

function GetAvailableInteractions()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local availableInteractions = {}
    local nearbyObjects = GetNearbyObjects(playerCoords, false)
    for _, interaction in ipairs(Config_InteractionMenu.Interactions) do
        if IsCompatible(interaction, playerPed) then
            if interaction.objects then
                for _, object in ipairs(nearbyObjects) do
                    local objectCoords = GetEntityCoords(object)

                    local modelName = CanStartInteractionAtObject(interaction, object, playerCoords, objectCoords)

                    if modelName then
                        AddInteractions(availableInteractions, interaction, playerPed, playerCoords, objectCoords, modelName, object)
                    end
                end
            else
                local targetCoords = vector3(interaction.x, interaction.y, interaction.z)

                if #(playerCoords - targetCoords) <= interaction.radius then
                    AddInteractions(availableInteractions, interaction, playerPed, playerCoords, targetCoords)
                end
            end
        end
    end

    table.sort(availableInteractions, SortInteractions)

    return availableInteractions
end

function StartInteraction()
    if not CanStartSeatInteraction() then
        return
    end
    if not (CurrentlySitting or CurrentlyInteracting or CurrentScenario or CurrentEmote) then
        local availableInteractions = GetAvailableInteractions()

        if #availableInteractions > 0 then
            Citizen.CreateThread(PlaySound)
            SendNUIMessage({
                type = "showInteractionPicker",
                interactions = json.encode(availableInteractions),
            })
            PickerIsOpen = true
        else
            SendNUIMessage({
                type = "hideInteractionPicker"
            })
            SetInteractionMarker()
            PickerIsOpen = false

            if CurrentInteraction then
                StopInteraction(false)
            end
        end
    else
        mosquito.notify.right_tip("You are already performing an action. Stop emote to reset.")
    end
end

function StopInteraction(instantly)
    if CurrentInteraction then
        local ped = PlayerPedId()
        local sittingType = CurrentSittingType
        local currentPedCoords = GetEntityCoords(ped)
        local coords = StartingCoords or currentPedCoords

        if CurrentlySittingOnVehicle and IsEntityAttached(ped) then
            DetachEntity(ped, true, true)
        end

        ClearPedTasksImmediately(ped, true, true)
        ClearPedSecondaryTask(ped)
        HidePedWeapons(ped, 2, 1)

        if coords then
            local distFromOrigin = #(vector3(currentPedCoords.x, currentPedCoords.y, currentPedCoords.z) - vector3(coords.x, coords.y, coords.z))

            if distFromOrigin < 3.5 then
                SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, true)
            end
        end

        FreezeEntityPosition(ped, false)

        CurrentlySitting = false
        CurrentSittingType = nil
        CurrentlySittingOnVehicle = false
        CurrentOriginCoords = nil
        CurrentSeatEntity = nil
        CurrentBaseEntity = nil
        StartingCoords = nil
    end

    CurrentInteraction = nil
end

function SetInteractionMarker(target)
    InteractionMarker = target
end

function DrawInteractionMarker()
    local x, y, z

    if type(InteractionMarker) == "number" then
        x, y, z = table.unpack(GetEntityCoords(InteractionMarker))
    else
        x, y, z = table.unpack(InteractionMarker)
    end

    DrawMarker(Config_InteractionMenu.MarkerType, x, y, z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, Config_InteractionMenu.MarkerColor[1], Config_InteractionMenu.MarkerColor[2], Config_InteractionMenu.MarkerColor[3], Config_InteractionMenu.MarkerColor[4], 0, 0, 2, 0, 0, 0, 0)
end

function IsPedUsingInteraction(ped, interaction)
    if interaction.scenario then
        return IsPedUsingScenarioHash(ped, GetHashKey(interaction.scenario))
    elseif interaction.animation then
        return IsEntityPlayingAnim(ped, interaction.animation.dict, interaction.animation.name, 1)
    else
        return false
    end
end

RegisterNUICallback("startInteraction", function(data, cb)
    if data.object then
        StartInteractionAtObject(data)
    else
        StartInteractionAtCoords(data)
    end
    cb({})
end)

RegisterNUICallback("stopInteraction", function(data, cb)
    StopInteraction()
    cb({})
end)

RegisterNUICallback("setInteractionMarker", function(data, cb)
    if data.entity then
        SetInteractionMarker(data.entity)
    elseif data.x and data.y and data.z then
        SetInteractionMarker(vector3(data.x, data.y, data.z))
    else
        SetInteractionMarker()
    end
    cb({})
end)

RegisterCommand(Config_InteractionMenu.InteractCommand, function(source, args, raw)
    StartInteraction()
end, false)

local margin = 0.03

function IsInteractionNearby(playerPed)
    local playerCoords = GetEntityCoords(playerPed)

    if not shouldRecheckInteractionNearby(playerCoords) then
        return CachedInteractionNearby, CachedInteractionNearbyLabel
    end

    local nearbyObjects = GetNearbyObjects(playerCoords, true)
    for i, interaction in ipairs(Config_InteractionMenu.Interactions) do
        local isCompatible = IsCompatible(interaction, playerPed)
        if isCompatible then
            if interaction.objects then
                for _, object in ipairs(nearbyObjects) do
                    local objectCoords = GetEntityCoords(object)

                    local modelName = CanStartInteractionAtObject(interaction, object, playerCoords, objectCoords)

                    if modelName then
                        CachedInteractionNearby = true
                        CachedInteractionNearbyLabel = interaction.seatLabel
                        LastInteractionNearbyCheckAt = GetGameTimer()
                        LastInteractionNearbyCoords = playerCoords
                        return true, interaction.seatLabel
                    end
                end
            else
                local targetCoords = vector3(interaction.x, interaction.y, interaction.z)

                if #(playerCoords - targetCoords) <= interaction.radius then
                    CachedInteractionNearby = true
                    CachedInteractionNearbyLabel = interaction.seatLabel
                    LastInteractionNearbyCheckAt = GetGameTimer()
                    LastInteractionNearbyCoords = playerCoords
                    return true, interaction.seatLabel
                end
            end
        end
    end
    CachedInteractionNearby = false
    CachedInteractionNearbyLabel = nil
    LastInteractionNearbyCheckAt = GetGameTimer()
    LastInteractionNearbyCoords = playerCoords
    return false
end

Citizen.CreateThread(function()
    local uniqueHashes = {}

    for _, interaction in ipairs(Config_InteractionMenu.Interactions) do
        MaxRadius = math.max(MaxRadius, interaction.radius)

        if interaction.objects then
            for _, model in ipairs(interaction.objects) do
                local modelHash = type(model) == "number" and model or GetHashKey(model)

                if not uniqueHashes[modelHash] then
                    uniqueHashes[modelHash] = true
                    table.insert(ObjectModelHashes, modelHash)
                end
            end
        end
    end
end)

function IsPedBeingShotAt(playerPed)
    if HasEntityBeenDamagedByAnyPed(playerPed) or HasEntityBeenDamagedByAnyVehicle(playerPed) then
        ClearEntityLastDamageEntity(playerPed)
        return HasEntityBeenDamagedByWeapon(playerPed, 0, 2)
    end

    return false
end

local previousHealth = nil -- To store the player's previous health
local healthThreshold = 20 -- The amount of health difference to detect

function HasPlayerLostSignificantHealth()
    local playerPed = PlayerPedId()
    local currentHealth = GetEntityHealth(playerPed)

    if previousHealth == nil then
        previousHealth = currentHealth
        return false
    end

    local healthDifference = previousHealth - currentHealth

    previousHealth = currentHealth

    return healthDifference >= healthThreshold
end

local is_frontend_sound_playing = false
local frontend_soundset_ref = "HUD_POKER"
local frontend_soundset_name = "BET_AMOUNT"


function PlaySound()
    if frontend_soundset_ref ~= 0 then
        Citizen.InvokeNative(0x0F2A2175734926D8, frontend_soundset_name, frontend_soundset_ref);      -- load sound frontend
    end
    Citizen.InvokeNative(0x67C540AA08E4A6F5, frontend_soundset_name, frontend_soundset_ref, true, 0); -- play sound frontend
    Wait(50)
    Citizen.InvokeNative(0x9D746964E0CF2C5F, frontend_soundset_name, frontend_soundset_ref)           -- stop audio
end

function handleInteractionMenu(playerPed)
    local IsEnabled = InteractPrompt and (UiPromptIsEnabled(InteractPrompt) ~= 0) or false
    local passThrough = Config_InteractionMenu.AlwaysActive or (Config_InteractionMenu.HoldToInteract and IsControlPressed(0, Config_InteractionMenu.HoldingControl) or (not Config_InteractionMenu.HoldToInteract and emoteMenuOpen))
    if passThrough or IsEnabled then
        local IsInteractionNearby, label = IsInteractionNearby(playerPed)
        CanStartInteraction = not IsPedDeadOrDying(playerPed) and not IsPedInCombat(playerPed) and not IsPedCuffed(playerPed) and not IsPedRagdoll(playerPed) and IsPedHogtied(PlayerPedId()) == 0
        if CanStartInteraction and IsInteractionNearby and passThrough then
            if not IsEnabled then
                CreateInteractPrompt(label)
            end
        else
            if IsEnabled then
                DeleteInteractPrompt()
            end
        end
    end

    if CurrentInteraction then
        if HasPlayerLostSignificantHealth() and CurrentInteraction ~= nil then
            SetPedToRagdoll(playerPed, 2000, 2000, 0, false, false, false)
            StopInteraction(true)
        end

        if IsPedPerformingMeleeAction(playerPed, GetHashKey('HOGTIE_ACTION'), 0) and IsPedInMeleeCombat(playerPed) and CurrentInteraction ~= nil then
            StopInteraction(true)
        end

        if IsPedRagdoll(playerPed) then
            StopInteraction(false)
        end

        if CurrentlySittingOnVehicle and CurrentBaseEntity and DoesEntityExist(CurrentBaseEntity) then
            local rotation = GetEntityRotation(CurrentBaseEntity, 2)
            local pitch = math.abs(rotation.x)
            local roll = math.abs(rotation.y)
            local onAllWheels = IsVehicleOnAllWheels(CurrentBaseEntity)

            if pitch > 25.0 or roll > 20.0 or not onAllWheels then
                StopInteraction(true)
            end
        end

        if IsControlJustPressed(0, Config_InteractionMenu.cancelcontrol) and CanStartInteraction then
            StopInteraction(false)
        end
    end

    if passThrough then
        if IsControlJustPressed(0, Config_InteractionMenu.InteractControl) and CanStartInteraction then
            StartInteraction()
            emoteMenuOpen = false
        end
    end

    if not PickerWasOpen then PickerWasOpen = false end
    if not PickerNotified then PickerNotified = false end

    if PickerIsOpen then
        DisableAllControlActions(0)
        local x, y = 0.5, 0.95
        local string = textString

        if not PickerNotified then
            mosquito.notify.objective(string, 9999999)
            PickerNotified = true
        end
        PickerWasOpen = true

        if IsDisabledControlJustPressed(0, 0x62800C92) then
            Citizen.CreateThread(PlaySound)
            SendNUIMessage({
                type = "moveSelectionUp"
            })
        end

        if IsDisabledControlJustPressed(0, Config_InteractionMenu.MenuUpControl) then
            Citizen.CreateThread(PlaySound)
            SendNUIMessage({
                type = "moveSelectionUp"
            })
        end

        if IsDisabledControlJustPressed(0, 0x8BDE7443) then
            Citizen.CreateThread(PlaySound)
            SendNUIMessage({
                type = "moveSelectionDown"
            })
        end

        if IsDisabledControlJustPressed(0, Config_InteractionMenu.MenuDownControl) then
            Citizen.CreateThread(PlaySound)
            SendNUIMessage({
                type = "moveSelectionDown"
            })
        end

        if IsDisabledControlJustPressed(0, 0x9D2AEA88) then
            Citizen.CreateThread(PlaySound)
            SendNUIMessage({
                type = "startInteraction"
            })
            SetInteractionMarker()
            PickerIsOpen = false
        end

        if IsDisabledControlJustPressed(0, Config_InteractionMenu.MenuAcceptControl) then
            Citizen.CreateThread(PlaySound)
            SendNUIMessage({
                type = "startInteraction"
            })
            SetInteractionMarker()
            PickerIsOpen = false
        end

        if IsDisabledControlJustPressed(0, 0x39336A4F) then
            Citizen.CreateThread(PlaySound)
            StopInteraction(false)
            SendNUIMessage({
                type = "hideInteractionPicker"
            })
            SetInteractionMarker()
            PickerIsOpen = false
        end

        if IsDisabledControlJustPressed(0, Config_InteractionMenu.MenuCancelControl) or IsDisabledControlJustPressed(0, 0xF84FA74F) or not CanStartInteraction then
            Citizen.CreateThread(PlaySound)
            SendNUIMessage({
                type = "hideInteractionPicker"
            })
            SetInteractionMarker()
            PickerIsOpen = false
        elseif not IsControlPressed(0, Config_InteractionMenu.HoldingControl) then
            DeleteInteractPrompt()
        end

        if InteractionMarker then
            DrawInteractionMarker()
        end
    else
        if PickerWasOpen and PickerNotified then
            mosquito.notify.objective(" ", 1)
            PickerNotified = false
            PickerWasOpen = false
        end
        if CurrentInteraction and not IsPedUsingInteraction(playerPed, CurrentInteraction) then
            local timeSinceStart = GetGameTimer() - InteractionStartTime
            if timeSinceStart > InteractionStartDebounceDelay then
                StartInteractionAtCoords(CurrentInteraction)
            end
        end
    end
end

RegisterCommand("removeprops", function()
    local playerPed = PlayerPedId()
    RemoveAllAttachedProps(playerPed)
    print("All attached props removed from your player.")
end)

function RemoveAllAttachedProps(ped)
    local attachedObjects = GetGamePool('CObject') -- Get all objects in the game
    for _, object in ipairs(attachedObjects) do
        if IsEntityAttachedToEntity(object, ped) then
            local modelHash = GetEntityModel(object) -- Get the object's model hash
            if not IsWeaponModel(modelHash) then
                DetachEntity(object, true, true)
                DeleteObject(object)
            end
        end
    end
end

function IsWeaponModel(modelHash)
    local weaponModels = {
        GetHashKey("w_dis_pis_mauser01"),
        GetHashKey("w_dis_pis_semiauto01"),
        GetHashKey("w_dis_pistol_derringer01"),
        GetHashKey("w_dis_pis_volcanic01"),
        GetHashKey("w_dis_rep_carbine01_1"),
        GetHashKey("w_dis_rep_henry01"),
        GetHashKey("w_dis_rep_pumpaction01"),
        GetHashKey("w_dis_rep_winchester01"),
        GetHashKey("w_dis_rev_cattleman01_2"),
        GetHashKey("w_dis_rev_doubleaction01"),
        GetHashKey("w_dis_rev_lemat01"),
        GetHashKey("w_dis_rev_schofield01"),
        GetHashKey("w_dis_rif_blunderbuss01"),
        GetHashKey("w_dis_rif_boltaction01"),
        GetHashKey("w_dis_rif_buffalo01"),
        GetHashKey("w_dis_rif_carcano01"),
        GetHashKey("w_dis_rif_elephant01"),
        GetHashKey("w_dis_rif_rollingblock01"),
        GetHashKey("w_dis_rif_springfield01"),
        GetHashKey("w_dis_sho_doublebarrel01"),
        GetHashKey("w_dis_sho_pumpaction01"),
        GetHashKey("w_dis_sho_repeating01"),
        GetHashKey("w_dis_sho_sawed01"),
        GetHashKey("w_dis_sho_semiauto01"),

        GetHashKey("w_electricfielddetector01"),
        GetHashKey("w_leftshoulder_strap01"),
        GetHashKey("w_melee_brassknuckles01"),
        GetHashKey("w_melee_tomahawk01"),
        GetHashKey("w_melee_tomahawk02"),
        GetHashKey("w_melee_tomahawk03"),
        GetHashKey("w_melee_tomahawk04"),
        GetHashKey("w_mp_bowarrow_arrow_tracking"),

        GetHashKey("w_pistol_m189902"),
        GetHashKey("w_pistol_mauser01"),
        GetHashKey("w_pistol_mauser02"),
        GetHashKey("w_pistol_semiauto01"),
        GetHashKey("w_pistol_volcanic01"),
        GetHashKey("w_pistol_volcanic03"),
        GetHashKey("w_repeater_carbine01"),
        GetHashKey("w_repeater_evans01"),
        GetHashKey("w_repeater_henry01"),
        GetHashKey("w_repeater_pumpaction01"),
        GetHashKey("w_repeater_winchester01"),
        GetHashKey("w_repeater_winchester03"),
        GetHashKey("w_revolver_cattleman01"),
        GetHashKey("w_revolver_cattleman02"),
        GetHashKey("w_revolver_cattleman03"),
        GetHashKey("w_revolver_doubleaction01"),
        GetHashKey("w_revolver_doubleaction02"),
        GetHashKey("w_revolver_doubleaction03"),
        GetHashKey("w_revolver_doubleaction04"),
        GetHashKey("w_revolver_doubleaction06"),
        GetHashKey("w_revolver_lemat01"),
        GetHashKey("w_revolver_navy01"),
        GetHashKey("w_revolver_navy02"),
        GetHashKey("w_revolver_schofield01"),
        GetHashKey("w_revolver_schofield02"),
        GetHashKey("w_revolver_schofield03"),
        GetHashKey("w_revolver_schofield04"),
        GetHashKey("w_revolver_schofield05"),
        GetHashKey("w_rifle_boltaction01"),
        GetHashKey("w_rifle_boltaction03"),
        GetHashKey("w_rifle_carcano01"),
        GetHashKey("w_rifle_rollingblock01"),
        GetHashKey("w_rifle_rollingblock02"),
        GetHashKey("w_rifle_springfield01"),
        GetHashKey("w_shotgun_doublebarrel01"),
        GetHashKey("w_shotgun_doublebarrel02"),
        GetHashKey("w_shotgun_pumpaction01"),
        GetHashKey("w_shotgun_pumpaction03"),
        GetHashKey("w_shotgun_repeating01"),
        GetHashKey("w_shotgun_sawed01"),
        GetHashKey("w_shotgun_sawed03"),
        GetHashKey("w_shotgun_semiauto01"),
        GetHashKey("w_stick_dynamite01"),
        GetHashKey("w_throw_dynamite01"),
        GetHashKey("w_throw_lantern01"),
        GetHashKey("w_throw_molotov01"),
        GetHashKey("w_throw_poisonbottle01")
    }

    for _, weaponHash in ipairs(weaponModels) do
        if modelHash == weaponHash then
            return true
        end
    end

    return false
end

function ClearIdleVehicles()
    local vehicles = GetGamePool('CVehicle')

    for _, vehicle in ipairs(vehicles) do
        if not IsVehicleOccupiedByPlayer(vehicle) then
            DeleteEntity(vehicle)
        end
    end
end

function IsVehicleOccupiedByPlayer(vehicle)
    for seat = -1, GetVehicleMaxNumberOfPassengers(vehicle) do
        local ped = GetPedInVehicleSeat(vehicle, seat)
        if DoesEntityExist(ped) and IsPedAPlayer(ped) then
            return true
        end
    end
    return false
end

function RemoveAllNonPlayerPeds()
    local peds = GetGamePool('CPed')
    for _, ped in ipairs(peds) do
        if not IsPedAPlayer(ped) and IsPedDeadOrDying(ped) then
            DeleteEntity(ped)
        end
    end
end

function RemoveAllAttachedPropsFromPlayers()
    local players = GetActivePlayers()
    for _, playerId in ipairs(players) do
        local ped = GetPlayerPed(playerId)
        RemoveAllAttachedProps(ped)
    end
end

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        print("Resource " .. resourceName .. " is stopping. Cleaning up prompts.")
        stop = true
        UiPromptDelete(InteractPrompt)
        DeleteInteractPrompt()
    end
end)
