function IsPedChild(ped)
    return Citizen.InvokeNative(0x137772000DAF42C5, ped)
end

function IsPedAdult(ped)
    return IsPedHuman(ped) and not IsPedChild(ped)
end

function IsPedHumanMale(ped)
    return IsPedHuman(ped) and IsPedMale(ped)
end

function IsPedHumanFemale(ped)
    return IsPedHuman(ped) and not IsPedMale(ped)
end

function IsPedAdultMale(ped)
    return not IsPedChild(ped) and IsPedMale(ped)
end

function IsPedAdultFemale(ped)
    return not IsPedChild(ped) and not IsPedMale(ped)
end

function clean()
    local ped = PlayerPedId()
    ClearPedEnvDirt(ped)
    ClearPedDamageDecalByZone(ped, 10, "ALL")
    ClearPedBloodDamage(ped)
end
