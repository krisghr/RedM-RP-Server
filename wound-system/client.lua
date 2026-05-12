local prevHealth = nil
local debugDamageInfoEnabled = false
local recentGunshotUntil = 0
local ignoreDamageUntil = 0

local baseMaxHealth = nil
local baseMaxStamina = Config.DefaultMaxStamina or 100

local baseHealthRing = Config.DefaultRingPoints or 100
local baseStaminaRing = Config.DefaultRingPoints or 100

local appliedHpReduction = 0
local appliedStaminaReduction = 0

local targetHealthRing = nil
local targetStaminaRing = nil
local targetHealthCore = nil
local targetStaminaCore = nil
local targetHpCap = nil
local targetStaminaCap = nil

local function debugPrint(msg)
    if Config.Debug then
        print(("[rp_wounds:client] %s"):format(msg))
    end
end

local function notify(msg)
    TriggerEvent('chat:addMessage', { args = { '^3Wounds', msg } })
end

local function debugDamageOutput(msg)
    print(("[rp_wounds:damage] %s"):format(msg))
    TriggerEvent('chat:addMessage', { args = { '^6WoundDebug', msg } })
end

local function refreshBaselines(ped)
    baseHealthRing = Config.DefaultRingPoints or 100
    baseStaminaRing = Config.DefaultRingPoints or 100

    if DoesEntityExist(ped) then
        baseMaxHealth = baseMaxHealth or GetEntityMaxHealth(ped)
    end
end

local function computeTargets(ped)
    refreshBaselines(ped)

    local minStatPercent = Config.MinimumStatPercent or 25

    targetHealthRing = math.floor(baseHealthRing * (1.0 - (appliedHpReduction / 100.0)))
    targetStaminaRing = math.floor(baseStaminaRing * (1.0 - (appliedStaminaReduction / 100.0)))

    targetHealthCore = math.floor(100 * (1.0 - (appliedHpReduction / 100.0)))
    targetStaminaCore = math.floor(100 * (1.0 - (appliedStaminaReduction / 100.0)))

    targetHpCap = math.floor((baseMaxHealth or GetEntityMaxHealth(ped)) * (1.0 - (appliedHpReduction / 100.0)))
    targetStaminaCap = math.floor(baseMaxStamina * (1.0 - (appliedStaminaReduction / 100.0)))

    local minHpCap = math.floor((baseMaxHealth or GetEntityMaxHealth(ped)) * (minStatPercent / 100.0))
    local minStaminaCap = math.floor(baseMaxStamina * (minStatPercent / 100.0))

    targetHealthRing = math.max(minStatPercent, targetHealthRing)
    targetStaminaRing = math.max(minStatPercent, targetStaminaRing)
    targetHealthCore = math.max(minStatPercent, targetHealthCore)
    targetStaminaCore = math.max(minStatPercent, targetStaminaCore)
    targetHpCap = math.max(minHpCap, targetHpCap)
    targetStaminaCap = math.max(minStaminaCap, targetStaminaCap)
end

local function applyStatLimits(ped)
    if not DoesEntityExist(ped) then return end
    computeTargets(ped)

    -- Hard HP cap
    SetEntityMaxHealth(ped, targetHpCap)
    if type(SetPedMaxHealth) == 'function' then
        SetPedMaxHealth(ped, targetHpCap)
    end

    local currentHp = GetEntityHealth(ped)
    if currentHp > targetHpCap then
        ignoreDamageUntil = GetGameTimer() + 1200
        SetEntityHealth(ped, targetHpCap)
    end

    -- Stamina cap
    Citizen.InvokeNative(0xC3D4B754C0E86B9E, PlayerId(), targetStaminaCap)

    -- Core values (affect stamina runtime in many RedM setups)
    if type(SetAttributeCoreValue) == 'function' then
        SetAttributeCoreValue(ped, 0, targetHealthCore)
        SetAttributeCoreValue(ped, 1, targetStaminaCore)
    end

    -- Ring UI values
    if type(SetAttributePoints) == 'function' then
        SetAttributePoints(ped, 0, targetHealthRing)
        SetAttributePoints(ped, 1, targetStaminaRing)
    end
end

local function getBodyPartFromBone(bone)
    if bone == 0 then return "torso" end
    local head = {21030, 14283}
    local legs = {55120, 45454, 33646, 6884, 43312}
    local arms = {54187, 46065, 37873, 22711}

    for _, b in ipairs(head) do if bone == b then return "head" end end
    for _, b in ipairs(legs) do if bone == b then return "left_leg" end end
    for _, b in ipairs(arms) do if bone == b then return "left_arm" end end
    return "torso"
end

local function wasDamagedByWeapon(ped, hashList, causeHash)
    for _, hash in ipairs(hashList) do
        if causeHash ~= 0 and causeHash == hash then
            return true, hash
        end

        if causeHash ~= 0 and HasEntityBeenDamagedByWeapon(ped, hash, 0) then
            return true, hash
        end
    end
    return false, nil
end

local function markRecentGunshot(ms)
    recentGunshotUntil = math.max(recentGunshotUntil, GetGameTimer() + ms)
end

local function hasRecentGunshot()
    return GetGameTimer() <= recentGunshotUntil
end

local function findNearbyAnimalAttacker(victimPed)
    local victimCoords = GetEntityCoords(victimPed)
    local nearestPed, nearestDist = 0, (Config.AnimalDetectionRadius or 10.0)

    for _, ped in ipairs(GetGamePool('CPed')) do
        if ped ~= victimPed and DoesEntityExist(ped) and not IsEntityDead(ped) and IsPedInCombat(ped, victimPed) and not IsPedHuman(ped) then
            local coords = GetEntityCoords(ped)
            local dist = #(victimCoords - coords)
            if dist <= nearestDist then
                nearestDist = dist
                nearestPed = ped
            end
        end
    end

    return nearestPed
end

local function getSelectedWeaponHashSafe(ped)
    if type(GetSelectedPedWeapon) == 'function' then
        return GetSelectedPedWeapon(ped)
    end

    if type(GetCurrentPedWeapon) == 'function' then
        local ok, weaponHash = GetCurrentPedWeapon(ped, true, 0, false)
        if ok then return weaponHash end
    end

    return 0
end

local function isLikelyFirearmEquipped(attackerPed)
    local weaponHash = getSelectedWeaponHashSafe(attackerPed)
    if not weaponHash or weaponHash == 0 or weaponHash == `WEAPON_UNARMED` then
        return false
    end

    for _, knifeHash in ipairs(Config.WeaponHints.knife or {}) do
        if weaponHash == knifeHash then
            return false
        end
    end

    return IsPedArmed(attackerPed, 4) or IsPedArmed(attackerPed, 6)
end

local function findNearbyHumanShooter(victimPed)
    local victimCoords = GetEntityCoords(victimPed)
    local nearestPed, nearestDist = 0, 25.0

    for _, ped in ipairs(GetGamePool('CPed')) do
        if ped ~= victimPed and DoesEntityExist(ped) and not IsEntityDead(ped) and IsPedHuman(ped) and isLikelyFirearmEquipped(ped) and IsPedInCombat(ped, victimPed) then
            local coords = GetEntityCoords(ped)
            local dist = #(victimCoords - coords)
            if dist <= nearestDist then
                nearestDist = dist
                nearestPed = ped
            end
        end
    end

    return nearestPed
end

local function detectDamageCategory(ped, damageAmount)
    local sourceEntity = 0
    if type(GetPedSourceOfDamage) == 'function' then
        sourceEntity = GetPedSourceOfDamage(ped)
    elseif type(GetEntityDamageSource) == 'function' then
        sourceEntity = GetEntityDamageSource(ped)
    end

    local causeHash = type(GetPedCauseOfDeath) == 'function' and GetPedCauseOfDeath(ped) or 0

    if sourceEntity == 0 then
        local nearbyAnimal = findNearbyAnimalAttacker(ped)
        if nearbyAnimal ~= 0 then
            sourceEntity = nearbyAnimal
        else
            local nearbyShooter = findNearbyHumanShooter(ped)
            if nearbyShooter ~= 0 then
                sourceEntity = nearbyShooter
            end
        end
    end

    local entityType = sourceEntity ~= 0 and GetEntityType(sourceEntity) or 0

    if entityType == 1 and sourceEntity ~= ped and IsEntityAPed(sourceEntity) then
        if IsPedHuman(sourceEntity) then
            local dist = #(GetEntityCoords(ped) - GetEntityCoords(sourceEntity))
            if isLikelyFirearmEquipped(sourceEntity) and dist > 3.0 then
                markRecentGunshot(3500)
                return "gunshot", causeHash, entityType, nil
            end
            return "melee", causeHash, entityType, nil
        end

        local model = GetEntityModel(sourceEntity)
        if model == `A_C_BEAR_01` then
            return "predator", causeHash, entityType, nil
        end
        return "animal", causeHash, entityType, nil
    end

    local isShotgun, shotgunHash = wasDamagedByWeapon(ped, Config.WeaponHints.shotgun, causeHash)
    if isShotgun then markRecentGunshot(3500) return "shotgun", causeHash, entityType, shotgunHash end

    local isKnife, knifeHash = wasDamagedByWeapon(ped, Config.WeaponHints.knife, causeHash)
    if isKnife then return "knife", causeHash, entityType, knifeHash end

    local isFire, fireHash = wasDamagedByWeapon(ped, Config.WeaponHints.fire, causeHash)
    if isFire or IsEntityOnFire(ped) then return "fire", causeHash, entityType, fireHash end

    local isExplosion, expHash = wasDamagedByWeapon(ped, Config.WeaponHints.explosion, causeHash)
    if isExplosion then return "explosion", causeHash, entityType, expHash end

    if IsPedFalling(ped) or IsPedRagdoll(ped) then return "fall", causeHash, entityType, nil end

    if causeHash == 0 and entityType == 0 and hasRecentGunshot() and damageAmount >= 5 then
        return "gunshot", causeHash, entityType, nil
    end

    return "melee", causeHash, entityType, nil
end

CreateThread(function()
    Wait(2000)
    local ped = PlayerPedId()
    prevHealth = GetEntityHealth(ped)
    baseMaxHealth = GetEntityMaxHealth(ped)
    refreshBaselines(ped)

    while true do
        Wait(Config.DamagePollMs)
        ped = PlayerPedId()
        if DoesEntityExist(ped) and not IsEntityDead(ped) then
            local hp = GetEntityHealth(ped)
            if prevHealth and hp < prevHealth then
                if GetGameTimer() < ignoreDamageUntil then
                    prevHealth = hp
                    goto continue
                end

                local damageAmount = prevHealth - hp
                local category, causeHash, attackerType, weaponHash = detectDamageCategory(ped, damageAmount)
                if category == "gunshot" or category == "shotgun" then markRecentGunshot(3500) end

                local _, bone = GetPedLastDamageBone(ped)
                local bodyPart = getBodyPartFromBone(bone or 0)

                if debugDamageInfoEnabled or Config.Debug then
                    local debugMsg = ("hash=%s attackerType=%s category=%s amount=%s bone=%s weapon=%s")
                        :format(tostring(causeHash), tostring(attackerType), category, damageAmount, tostring(bone), tostring(weaponHash))
                    debugDamageOutput(debugMsg)
                    debugPrint("damage detected: " .. debugMsg)
                end

                TriggerServerEvent('rp_wounds:server:onDamageDetected', {
                    damageAmount = damageAmount,
                    category = category,
                    bodyPart = bodyPart,
                    causeHash = causeHash,
                    attackerType = attackerType,
                    weaponHash = weaponHash
                })

                ClearEntityLastDamageEntity(ped)
                ClearPedLastDamageBone(ped)
                if type(ClearEntityLastWeaponDamage) == 'function' then
                    ClearEntityLastWeaponDamage(ped)
                end
            end
            prevHealth = hp
            ::continue::
        else
            prevHealth = nil
        end
    end
end)

-- Reapply loop: handles /heal, revive scripts, passive regen over cap, and external resets.
CreateThread(function()
    while true do
        Wait(750)
        local ped = PlayerPedId()
        if DoesEntityExist(ped) and not IsEntityDead(ped) then
            if appliedHpReduction > 0 or appliedStaminaReduction > 0 then
                computeTargets(ped)

                local hpRing = type(GetAttributePoints) == 'function' and GetAttributePoints(ped, 0) or targetHealthRing
                local staminaRing = type(GetAttributePoints) == 'function' and GetAttributePoints(ped, 1) or targetStaminaRing
                local healthCore = type(GetAttributeCoreValue) == 'function' and GetAttributeCoreValue(ped, 0) or targetHealthCore
                local staminaCore = type(GetAttributeCoreValue) == 'function' and GetAttributeCoreValue(ped, 1) or targetStaminaCore
                local currentHp = GetEntityHealth(ped)
                local maxHpNow = GetEntityMaxHealth(ped)

                local needsReapply =
                    hpRing ~= targetHealthRing
                    or staminaRing ~= targetStaminaRing
                    or healthCore ~= targetHealthCore
                    or staminaCore ~= targetStaminaCore
                    or maxHpNow ~= targetHpCap
                    or currentHp > targetHpCap

                if needsReapply then
                    applyStatLimits(ped)
                    debugPrint("re-applied wound stat limits")
                end
            else
                -- No wounds/penalties: restore to full baseline.
                targetHealthRing = baseHealthRing
                targetStaminaRing = baseStaminaRing
                targetHealthCore = 100
                targetStaminaCore = 100

                if baseMaxHealth then
                    SetEntityMaxHealth(ped, baseMaxHealth)
                    if type(SetPedMaxHealth) == 'function' then
                        SetPedMaxHealth(ped, baseMaxHealth)
                    end
                end
                Citizen.InvokeNative(0xC3D4B754C0E86B9E, PlayerId(), baseMaxStamina)

                if type(SetAttributeCoreValue) == 'function' then
                    SetAttributeCoreValue(ped, 0, 100)
                    SetAttributeCoreValue(ped, 1, 100)
                end
                if type(SetAttributePoints) == 'function' then
                    SetAttributePoints(ped, 0, baseHealthRing)
                    SetAttributePoints(ped, 1, baseStaminaRing)
                end
            end
        end
    end
end)

RegisterCommand('debugdamageinfo', function()
    debugDamageInfoEnabled = not debugDamageInfoEnabled
    notify(("Damage debug is now %s"):format(debugDamageInfoEnabled and "^2ON^7" or "^1OFF^7"))
end, false)

local function printWoundStats()
    local ped = PlayerPedId()
    if not DoesEntityExist(ped) then return end

    computeTargets(ped)

    local currentHp = GetEntityHealth(ped)
    local maxHp = GetEntityMaxHealth(ped)
    local hpRing = type(GetAttributePoints) == 'function' and GetAttributePoints(ped, 0) or 'n/a'
    local staminaRing = type(GetAttributePoints) == 'function' and GetAttributePoints(ped, 1) or 'n/a'
    local hpCore = type(GetAttributeCoreValue) == 'function' and GetAttributeCoreValue(ped, 0) or 'n/a'
    local stCore = type(GetAttributeCoreValue) == 'function' and GetAttributeCoreValue(ped, 1) or 'n/a'

    local msg = ('HP: %s/%s (cap:%s) | StaminaCap:%s | HRing: %s/%s | SRing: %s/%s | HCore:%s Tgt:%s | SCore:%s Tgt:%s | Reductions HP%%:%s ST%%:%s')
        :format(
            currentHp, maxHp, tostring(targetHpCap), tostring(targetStaminaCap),
            tostring(hpRing), tostring(baseHealthRing),
            tostring(staminaRing), tostring(baseStaminaRing),
            tostring(hpCore), tostring(targetHealthCore),
            tostring(stCore), tostring(targetStaminaCore),
            appliedHpReduction, appliedStaminaReduction
        )

    print(('[rp_wounds:stats] %s'):format(msg))
    notify(msg)
end

RegisterCommand('woundstats', printWoundStats, false)
RegisterCommand('debugwoundstats', printWoundStats, false)

RegisterNetEvent('rp_wounds:client:notify', function(msg)
    notify(msg)
end)

RegisterNetEvent('rp_wounds:client:applyPenalties', function(data)
    local ped = PlayerPedId()
    if not DoesEntityExist(ped) then return end

    appliedHpReduction = math.max(0, math.min(Config.MaxTotalReductionPercent, data.hpReduction or data.hpPercent or 0))
    appliedStaminaReduction = math.max(0, math.min(Config.MaxTotalReductionPercent, data.staminaReduction or data.staminaPercent or 0))

    applyStatLimits(ped)

    debugPrint(("penalties applied: hp%%=%s stamina%%=%s hpCap=%s staminaCap=%s healthRing=%s staminaRing=%s healthCore=%s staminaCore=%s")
        :format(
            appliedHpReduction, appliedStaminaReduction,
            tostring(targetHpCap), tostring(targetStaminaCap),
            tostring(targetHealthRing), tostring(targetStaminaRing),
            tostring(targetHealthCore), tostring(targetStaminaCore)
        ))
end)