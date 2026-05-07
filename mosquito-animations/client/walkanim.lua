local timedOut = false
CurrentWalkAnim = CurrentWalkAnim or nil
local framework = string.lower(Config.Framework)
if Config.Debug then
    print("---------------------------------- ^2 PLAYER SPAWNED ^7 ----------------------------------")
    Wait(1000)
    TriggerServerEvent("mosquito:server:requestWalkAnim")
else
    if framework == "rsg" then
        RegisterNetEvent("RSGCore:Client:OnPlayerLoaded", function()
            Wait(1000)
            TriggerServerEvent("mosquito:server:requestWalkAnim")
        end)
    elseif framework == "vorp" then
        RegisterNetEvent("vorp:SelectedCharacter", function(charId)
            Wait(1000)
            TriggerServerEvent("mosquito:server:requestWalkAnim", charId)
        end)
    end
end

WalkStyle = {
    { hash = "MP_Style_Casual",      label = "Casual" },
    { hash = "MP_Style_Angry",       label = "Angry" },
    { hash = "MP_Style_Crazy",       label = "Crazy" },
    { hash = "MP_Style_drunk",       label = "Drunk" },
    { hash = "MP_Style_EasyRider",   label = "Easy Rider" },
    { hash = "MP_Style_Flamboyant",  label = "Flamboyant" },
    { hash = "MP_Style_Greenhorn",   label = "Greenhorn" },
    { hash = "MP_Style_Gunslinger",  label = "Gunslinger" },
    { hash = "MP_Style_inquisitive", label = "Inquisitive" },
    { hash = "MP_Style_Refined",     label = "Refined" },
    { hash = "MP_Style_SilentType",  label = "Silent Type" },
    { hash = "MP_Style_Veteran",     label = "Veteran" },
    { hash = "noanim",               label = "No Animation" }
}

RegisterNetEvent("mosquito:animations:setwalkanim")
AddEventHandler("mosquito:animations:setwalkanim", function(anim, reset, saveToDb, blendRatio)
    if (not anim) or (type(anim) ~= "string") then
        mosquito.notify.right_tip("Invalid walk animation.")
        return
    end
    timedOut = true
    local animHash = anim
    local ped = PlayerPedId()
    local walkName
    for _, style in ipairs(WalkStyle) do
        if style.hash == animHash then
            walkName = style.label
            break
        end
        if reset then
            RemovePedBlackboardBool(ped, style.hash)
        end
    end
    if CurrentWalkAnim and CurrentWalkAnim ~= animHash then
        RemovePedBlackboardBool(ped, CurrentWalkAnim)
        Wait(0)
    end
    if animHash == "noanim" then
        for _, style in ipairs(WalkStyle) do
            RemovePedBlackboardBool(ped, style.hash)
        end
    else
        SetPedBlackboardBool(ped, animHash, 1, -1)
    end
    if not reset then
        mosquito.notify.objective("Walk style set to: ~o~" .. walkName)
    end
    CurrentWalkAnim = animHash
    if tonumber(blendRatio) then
        maxBlendMoveRatio = math.max(0.1, math.min(3.0, tonumber(blendRatio)))
    end
    if saveToDb ~= false then
        TriggerServerEvent("mosquito:Server:animations:SaveWalkAnimToDB", animHash, maxBlendMoveRatio)
    end
    TriggerServerEvent("mosquito:Server:ApplyWalkAnimToOthers", animHash)
end)

RegisterNetEvent("mosquito:animations:applyToOtherPed")
AddEventHandler("mosquito:animations:applyToOtherPed", function(source, anim)
    if (not anim) or (type(anim) ~= "string") then
        return
    end

    local animHash = anim
    local targetPlayer = GetPlayerFromServerId(source)
    if targetPlayer and targetPlayer ~= -1 then
        local targetPed = GetPlayerPed(targetPlayer)
        if targetPed and DoesEntityExist(targetPed) then
            for _, style in ipairs(WalkStyle) do
                RemovePedBlackboardBool(targetPed, style.hash)
            end
            if animHash ~= "noanim" then
                SetPedBlackboardBool(targetPed, animHash, 1, -1)
            end
        end
    end
end)

RegisterCommand("resetwalkstyle", function()
    local ped = PlayerPedId()
    for _, style in ipairs(WalkStyle) do
        RemovePedBlackboardBool(ped, style.hash)
    end
    CurrentWalkAnim = nil
    mosquito.notify.objective("Walk style reset to default.")
end)

AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    local ped = PlayerPedId()
    for _, style in ipairs(WalkStyle) do
        RemovePedBlackboardBool(ped, style.hash)
    end
end)
