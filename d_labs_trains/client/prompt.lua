promptsGroup = {}
prompts = {}
PromptTemp = {}

----------------------------------------------------------------------------
--  Config
----------------------------------------------------------------------------

local PromptGroup = {
    [1] = {id = GetRandomIntInRange(0, 0xffffff),   desc = texts.prompt.descOpenMenu, target = true},
    [2] = {id = GetRandomIntInRange(0, 0xffffff),   desc = texts.prompt.descTimetable},
    [3] = {id = GetRandomIntInRange(0, 0xffffff),   desc = texts.prompt.descManagment},
    [4] = {id = GetRandomIntInRange(0, 0xffffff),   desc = texts.prompt.descBoiler},
    [5] = {id = GetRandomIntInRange(0, 0xffffff),   desc = texts.prompt.descTimetableAll},
    [6] = {id = GetRandomIntInRange(0, 0xffffff),   desc = texts.prompt.descTrainStash},
    [7] = {id = GetRandomIntInRange(0, 0xffffff),   desc = texts.prompt.descTrainStash},
    [8] = {id = GetRandomIntInRange(0, 0xffffff),   desc = texts.prompt.descPostOffice},
    [9] = {id = GetRandomIntInRange(0, 0xffffff),   desc = texts.prompt.descSit},
    [10] = {id = GetRandomIntInRange(0, 0xffffff),  desc = texts.prompt.boxDesc},
    [12] = {id = GetRandomIntInRange(0, 0xffffff),  desc = texts.prompt.descFakeDoor},
}

local PromptConfig = {
    [1] = {group = 1, name = texts.prompt.openMenu,             key = promptKey.menu},
    [2] = {group = 2, name = texts.prompt.timetableOpen,        key = promptKey.timetable},
    [4] = {group = 3, name = texts.prompt.openMenu,             key = promptKey.menu},
    [5] = {group = 4, name = texts.prompt.repairBoiler,         key = promptKey.boiler},
    [6] = {group = 5, name = texts.prompt.timetableInteraction, key = promptKey.timetable},
    [7] = {group = 6, name = texts.prompt.openStash,            key = promptKey.openStash},
    [8] = {group = 7, name = texts.prompt.box,                  key = promptKey.wagonBox},
    [9] = {group = 7, name = texts.prompt.openStash,            key = promptKey.openStash},
    [10] = {group = 8, name = texts.prompt.bagSubmit,           key = promptKey.submitTelegram},
    [11] = {group = 9, name = texts.prompt.sit,                 key = promptKey.sit},
    [12] = {group = 10, name = texts.prompt.putUp,              key = promptKey.grabBox},
    [13] = {group = 6,  name = texts.prompt.loadCoal,           key = promptKey.loadCoal},
    [14] = {group = 7,  name = texts.prompt.loadCoal,           key = promptKey.loadCoal},
    [15] = {group = 12, name = texts.prompt.passDoorIn,         key = promptKey.sit},
}

local PromptTempConfig = {
    [1] = {name = texts.prompt.relight,     key = promptKey.relight},
    [2] = {name = texts.prompt.lockSpeed,   key = promptKey.lockSpeed},
    [3] = {name = texts.prompt.unlockSpeed, key = promptKey.lockSpeed},
    [4] = {name = texts.prompt.whistle,     key = promptKey.whistle},
}

----------------------------------------------------------------------------
--  setup
----------------------------------------------------------------------------

function setupPrompt(k,pool)
    if not PromptGroup[pool.group].target or not Config.Server.MetaTarget then 
        local promptKey = PromptRegisterBegin()
        local str = CreateVarString(10, 'LITERAL_STRING', pool.name)
        PromptSetControlAction(promptKey, pool.key)
        PromptSetText(promptKey, str)
        PromptSetEnabled(promptKey, 1)
        PromptSetVisible(promptKey, 1)
        PromptSetStandardMode(promptKey, 1)
        PromptSetGroup(promptKey, PromptGroup[pool.group].id)
        Citizen.InvokeNative(0xC5F428EE08FA7F2C, promptKey, true)
        PromptRegisterEnd(promptKey)
        promptsGroup[pool.group] = {id = k, key = promptKey, group = PromptGroup[pool.group].id, desc = PromptGroup[pool.group].desc}        
        prompts[k] = {id = k, key = promptKey, group = PromptGroup[pool.group].id, desc = PromptGroup[pool.group].desc}
        Citizen.Wait(10)
    end
end

for k, v in pairs(PromptConfig) do
    setupPrompt(k,v)
end

function activePrompt(groupNumber)
    if promptsGroup[groupNumber] then
        local label = CreateVarString(10, 'LITERAL_STRING', promptsGroup[groupNumber].desc)
        PromptSetActiveGroupThisFrame(promptsGroup[groupNumber].group, label)
    end
end

function pressPrompt(number)
    if number and prompts[number] and Citizen.InvokeNative(0xC92AC953F0A982AE, prompts[number].key) then 
        return true
    else
        return false 
    end
end

----------------------------------------
-- Temp prompt 
---------------------------------------

function tempPrompStatus(id, show)
    if PromptTemp[id] then
        PromptSetEnabled(PromptTemp[id], show)
        PromptSetVisible(PromptTemp[id], show)
    end
end

function tempPrompPress(id)
    if id and IsControlJustPressed(1, PromptTempConfig[id].key) then 
        return true
    end
    return false
end

function setupPromptTemp(id,key)
    local label = key.name
    local prompt = PromptRegisterBegin()
    PromptSetControlAction(prompt, key.key)
    label = CreateVarString(10, 'LITERAL_STRING', label)
    PromptSetText(prompt, label)
    PromptSetEnabled(prompt, false)
    PromptSetVisible(prompt, false)
    PromptSetStandardMode(prompt, 1)
    PromptSetHoldMode(prompt, false)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, prompt, true)
    PromptRegisterEnd(prompt)

    PromptTemp[id] = prompt
end

for k, v in pairs(PromptTempConfig) do
    setupPromptTemp(k,v)
end

----------------------------------------------------------------------------
--  onResourceStop
----------------------------------------------------------------------------

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for _, v in pairs(promptsGroup) do 
            if type(v) == "table" and v.key then 
                PromptDelete(v.key) 
            end
        end

        for _, v in pairs(PromptTemp) do 
            if v then
                PromptSetEnabled(v, false)
                PromptSetVisible(v, false)
            end
        end
    end
end)



