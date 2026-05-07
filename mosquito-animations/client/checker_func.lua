local function NativeFunctionBooleanCheck(func, ...)
    local result = func(...)
    return result and result ~= 0
end

local function SafeNativeFunctionBooleanCheck(func, ...)
    if type(func) ~= "function" then
        return false
    end

    local ok, result = pcall(func, ...)
    return ok and result and result ~= 0
end

local function SafeNativeFunctionNumberCheck(func, ...)
    if type(func) ~= "function" then
        return nil, false
    end

    local ok, result = pcall(func, ...)
    if not ok then
        return nil, false
    end

    result = tonumber(result)
    return result, result ~= nil
end

local function IsTruthy(value)
    if value == true then
        return true
    end

    local valueType = type(value)
    if valueType == "number" then
        return value ~= 0
    end

    if valueType == "string" then
        local normalized = value:lower()
        return normalized == "true" or normalized == "1" or normalized == "yes" or normalized == "y" or normalized == "on"
    end

    return false
end

local function IsEmoteNonInterruptibleForCheck(emote)
    if type(emote) ~= "table" then
        return false
    end

    return IsTruthy(emote.nonInterruptible)
end

local function IsEmoteInterruptibleForCheck(emote)
    if type(emote) ~= "table" then
        return false
    end

    return IsTruthy(emote.interruptible)
end

local function IsEmoteReloadInterruptableForCheck(emote)
    if type(emote) ~= "table" then
        return false
    end

    return IsTruthy(emote.reloadInterruptable)
end

local function GetAnimNonInterruptStateFlags(ped)
    local isDeadOrDying = SafeNativeFunctionBooleanCheck(IsPedDeadOrDying, ped, true)
    local isHogtied = SafeNativeFunctionBooleanCheck(IsPedHogtied, ped)
    local isCuffed = SafeNativeFunctionBooleanCheck(IsPedCuffed, ped)
    local isRagdoll = SafeNativeFunctionBooleanCheck(IsPedRagdoll, ped)
    local isFalling = SafeNativeFunctionBooleanCheck(IsPedFalling, ped)
    local isSwimming = SafeNativeFunctionBooleanCheck(IsPedSwimming, ped)
    local isSwimmingUnderWater = SafeNativeFunctionBooleanCheck(IsPedSwimmingUnderWater, ped)
    local isClimbing = SafeNativeFunctionBooleanCheck(IsPedClimbing, ped)
    local isOnMount = SafeNativeFunctionBooleanCheck(IsPedOnMount, ped)
    local isInVehicle = SafeNativeFunctionBooleanCheck(IsPedInAnyVehicle, ped, false) or SafeNativeFunctionBooleanCheck(IsPedSittingInAnyVehicle, ped)

    local blockedByState = isDeadOrDying or isHogtied or isCuffed or isRagdoll or isFalling or isSwimming or isSwimmingUnderWater or isClimbing or isOnMount or isInVehicle

    return blockedByState
end

local function GetAnimInterruptStateFlags(ped)
    local player = PlayerId()
    local isInCombat = SafeNativeFunctionBooleanCheck(IsPedInCombat, ped)
    local isInMeleeCombat = SafeNativeFunctionBooleanCheck(IsPedInMeleeCombat, ped)
    local isRagdolled = SafeNativeFunctionBooleanCheck(IsPedRagdoll, ped)
    local isFalling = SafeNativeFunctionBooleanCheck(IsPedFalling, ped)
    local isDeadOrDying = SafeNativeFunctionBooleanCheck(IsPedDeadOrDying, ped, true)

    local blockedByState = isInCombat or isInMeleeCombat or isRagdolled or isFalling or isDeadOrDying

    return blockedByState
end


function CanPlayerStartScenario()
    local ped = PlayerPedId()
    local isPedOnWagon = NativeFunctionBooleanCheck(IsPedSittingInAnyVehicle, ped)
    local isPedCuffed = NativeFunctionBooleanCheck(IsPedCuffed, ped)
    local isPedHogtied = NativeFunctionBooleanCheck(IsPedHogtied, ped)
    local isPedDeadOrDying = NativeFunctionBooleanCheck(IsPedDeadOrDying, ped, true)
    local isPedSwimming = NativeFunctionBooleanCheck(IsPedSwimming, ped)
    local notAllowed = isPedOnWagon or isPedCuffed or isPedHogtied or isPedDeadOrDying or isPedSwimming
    if notAllowed then
        print("You cannot start a scenario.")
        return false
    end
    return true
end

function CanStartSeatInteraction()
    return true
end

function CanPlayerStartAnim()
    local ped = PlayerPedId()
    local isPedHogtied = NativeFunctionBooleanCheck(IsPedHogtied, ped)
    local isPedDeadOrDying = NativeFunctionBooleanCheck(IsPedDeadOrDying, ped, true)
    local isPedSwimming = NativeFunctionBooleanCheck(IsPedSwimming, ped)
    local notAllowed = isPedHogtied or isPedDeadOrDying or isPedSwimming
    if notAllowed then
        print("You cannot start an animation.")
        return false
    end
    return true
end

function ShouldAnimBeNotInturrupted(ped, emote)
    if not IsEmoteNonInterruptibleForCheck(emote) then
        return true
    end

    ped = ped or PlayerPedId()
    if not ped or ped == 0 then
        return false
    end

    local blockedByState = GetAnimInterruptStateFlags(ped)
    return not blockedByState
end

function ShouldAnimBeInturrupted(ped, emote)
    local notPlayingAnim = not IsEntityPlayingAnim(ped, emote.animation.dict, emote.animation.name, 3)
    local isInterruptible = IsEmoteInterruptibleForCheck(emote)
    local isReloadInterruptable = IsEmoteReloadInterruptableForCheck(emote)
    if not isInterruptible and not isReloadInterruptable then
        return false
    end

    ped = ped or PlayerPedId()
    if not ped or ped == 0 then
        return false
    end

    local reloadControl = GetHashKey("INPUT_RELOAD")
    local reloadPressed = IsControlJustPressed(0, reloadControl) or IsDisabledControlJustPressed(0, reloadControl)
    if isReloadInterruptable and reloadPressed then
        return true
    end

    if not isInterruptible then
        return false
    end

    local blockedByState = GetAnimInterruptStateFlags(ped)
    return (blockedByState == true) or notPlayingAnim
end

function ShouldApplyCustomWalkBlendRatio(ped)
    ped = ped or PlayerPedId()
    if not ped or ped == 0 or not DoesEntityExist(ped) then
        return false
    end

    local sprintControl = 0x8FFC75D6 -- INPUT_SPRINT
    if IsControlPressed(0, sprintControl) or IsDisabledControlPressed(0, sprintControl) then
        return false
    end

    return SafeNativeFunctionBooleanCheck(IsPedWalking, ped)
end
