local selectedMaskId = Config.MaskOptions[1].id
local isWearingMask = false

local function syncMaskedState(masked)
    isWearingMask = masked == true
    TriggerServerEvent("masked_identity:setMaskedState", isWearingMask)
end

local function applyMask()
    -- Neck-wear bandanas are handled by VORP via /bandanaon.
    ExecuteCommand("bandanaon")
end

local function removeMaskVisual()
    -- Same command toggles bandana back down/off-face.
    ExecuteCommand("bandanaon")
end

local function printMaskOptions()
    TriggerEvent("chat:addMessage", {
        color = { 255, 200, 120 },
        args = { "Mask", "Use /setmask <id>. Available options:" }
    })

    for _, option in ipairs(Config.MaskOptions) do
        TriggerEvent("chat:addMessage", {
            color = { 255, 255, 255 },
            args = { "Mask", ("- %s (%s)"):format(option.id, option.label) }
        })
    end
end

RegisterCommand("setmask", function(_, args)
    local maskId = args[1]
    if not maskId then
        printMaskOptions()
        return
    end

    for _, option in ipairs(Config.MaskOptions) do
        if option.id == maskId then
            selectedMaskId = option.id

            if isWearingMask then
                -- Re-apply face-cover state after selection change.
                removeMaskVisual()
                Wait(150)
                applyMask()
            end

            TriggerEvent("chat:addMessage", {
                color = { 120, 255, 120 },
                args = { "Mask", ("Selected mask: %s"):format(option.label) }
            })
            return
        end
    end

    TriggerEvent("chat:addMessage", {
        color = { 255, 120, 120 },
        args = { "Mask", "Invalid mask id." }
    })
    printMaskOptions()
end, false)

RegisterCommand("wearmask", function()
    isWearingMask = not isWearingMask

    if isWearingMask then
        applyMask()
        syncMaskedState(true)
    else
        removeMaskVisual()
        syncMaskedState(false)
    end
end, false)

RegisterCommand("removemask", function()
    if not isWearingMask then
        TriggerEvent("chat:addMessage", {
            color = { 255, 200, 120 },
            args = { "Mask", "You are not currently wearing a mask." }
        })
        syncMaskedState(false)
        return
    end

    removeMaskVisual()
    syncMaskedState(false)

    TriggerEvent("chat:addMessage", {
        color = { 120, 255, 120 },
        args = { "Mask", "Mask removed. Your real identity is now visible." }
    })
end, false)
