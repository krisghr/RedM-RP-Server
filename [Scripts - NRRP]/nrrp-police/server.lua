local RESOURCE_NAME = GetCurrentResourceName()
local CELLS_FILE = 'data/cells.json'
local CellsState = {}
local Core <const> = exports.vorp_core:GetCore()

AddEventHandler("onResourceStart", function(resourceName)
    if resourceName ~= RESOURCE_NAME then return end

    Wait(5000)

    for _, playerSource in ipairs(GetPlayers()) do
        local _source = tonumber(playerSource)
        local user <const> = Core.getUser(_source)
        if not user then
            print(("[JOB DEBUG] src=%s user=nil"):format(_source))
        else
            local character <const> = user.getUsedCharacter
            local job <const> = character.job
            local grade <const> = character.jobGrade
            print(("[JOB DEBUG] src=%s job=%s grade=%s"):format(_source, tostring(job), tostring(grade)))
        end
    end
end)

function Notify(source, message)
    if not source or source == 0 then
        print(('[Police] %s'):format(message))
        return
    end

    TriggerClientEvent('chat:addMessage', source, {
        color = { 80, 160, 255 },
        multiline = true,
        args = { 'Police', message }
    })
end

function Log(message)
    print(('[nrrp-police] %s'):format(message))
end

local function Debug(message)
    if Config.Debug then
        Log(('DEBUG: %s'):format(message))
    end
end

function GetIdentifier(source)
    local identifiers = GetPlayerIdentifiers(source)
    local fallback = nil

    for _, identifier in ipairs(identifiers) do
        fallback = fallback or identifier
        if identifier:sub(1, 8) == 'license:' then
            return identifier
        end
    end

    return fallback
end

local function HasAdminBypass(source)
    local identifiers = GetPlayerIdentifiers(source)

    for _, playerIdentifier in ipairs(identifiers) do
        for _, adminIdentifier in ipairs(Config.AdminIdentifiers or {}) do
            if playerIdentifier == adminIdentifier then
                return true
            end
        end
    end

    return false
end

-- job adapter ---------------------------------------------------------------
-- This resource does not create jobs.
-- It reads the player's current job/jobGrade from vorp_core character data
-- and compares job name against Config.AllowedJobs.
local function GetPlayerJobData(source)
    local user = Core.getUser(source)
    if not user then
        return nil, nil
    end

    local character = user.getUsedCharacter
    if type(character) == 'function' then
        character = character(user)
    end

    if not character then
        return nil, nil
    end

    return character.job, character.jobGrade
end

local function GetPlayerGradeFromVorp(source)
    local _, jobGrade = GetPlayerJobData(source)
    return jobGrade
end

function GetPlayerJobFromLoJobsCreator(source)
    if not Config.UseLoJobsCreator then
        return nil
    end

    local jobName = GetPlayerJobData(source)
    if jobName and jobName ~= '' then
        return jobName
    end

    Debug('Could not resolve player job from vorp_core.')
    return nil
end

local function IsPlayerInLoJobType(source, jobType)
    if GetResourceState('lo_jobscreator') ~= 'started' then
        return false
    end

    local ok, players = pcall(function()
        return exports.lo_jobscreator:GetPlayersByType(jobType)
    end)

    if not ok or type(players) ~= 'table' then
        if not ok then
            Log(('lo_jobscreator GetPlayersByType check failed for type "%s": %s'):format(jobType, tostring(players)))
        end
        return false
    end

    local wantedSource = tonumber(source)
    for _, playerSource in ipairs(players) do
        if tonumber(playerSource) == wantedSource then
            return true
        end
    end

    return false
end

local function HasLoJobTypeFallbackAccess(source)
    if not Config.UseLoJobsCreator or not Config.AllowLoJobTypeFallback then
        return false
    end

    for _, jobType in ipairs(Config.AllowedJobTypes or {}) do
        if IsPlayerInLoJobType(source, jobType) then
            return true
        end
    end

    return false
end

function HasPoliceAccess(source)
    if source == 0 then
        return true
    end

    if HasAdminBypass(source) then
        return true
    end

    local jobName = GetPlayerJobFromLoJobsCreator(source)
    if jobName then
        for _, allowedJob in ipairs(Config.AllowedJobs or {}) do
            if jobName == allowedJob then
                if Config.RequireDutyForPoliceAccess then
                    if GetResourceState('lo_jobscreator') ~= 'started' then
                        return false
                    end

                    local ok, isOnDuty = pcall(function()
                        return exports.lo_jobscreator:IsDutyActive(source, allowedJob)
                    end)

                    if ok and isOnDuty then
                        return true
                    end
                else
                    return true
                end
            end
        end
    end

    return HasLoJobTypeFallbackAccess(source)
end

local function CheckPoliceAccess(source, commandName)
    if HasPoliceAccess(source) then
        return true
    end

    Log(('Unauthorized %s attempt by %s (%s) [job=%s grade=%s]'):format(
        commandName,
        GetPlayerName(source) or 'unknown',
        GetIdentifier(source) or 'no identifier',
        tostring(GetPlayerJobFromLoJobsCreator(source) or 'none'),
        tostring(GetPlayerGradeFromVorp(source) or 'none')
    ))
    Notify(source, 'You are not authorized to use police cell commands.')
    return false
end

function GetCellConfig(cellId)
    local wantedId = tonumber(cellId)
    if not wantedId then
        return nil
    end

    for _, cell in ipairs(Config.Cells or {}) do
        if tonumber(cell.id) == wantedId then
            return cell
        end
    end

    return nil
end

function GetCellState(cellId)
    return CellsState[tostring(cellId)]
end

local function NewDefaultCellState(cellId)
    return {
        id = tonumber(cellId),
        occupied = false,
        prisonerName = nil,
        prisonerServerId = nil,
        prisonerIdentifier = nil,
        reason = nil,
        status = nil,
        detentionType = nil,
        assignedBy = nil,
        assignedByIdentifier = nil,
        jailedAt = nil,
        releaseAt = nil,
        notes = nil
    }
end

local function ClearOccupancy(state)
    state.occupied = false
    state.prisonerName = nil
    state.prisonerServerId = nil
    state.prisonerIdentifier = nil
    state.reason = nil
    state.status = nil
    state.detentionType = nil
    state.assignedBy = nil
    state.assignedByIdentifier = nil
    state.jailedAt = nil
    state.releaseAt = nil
    state.notes = nil
end

local function EncodeJson(data)
    local ok, encoded = pcall(json.encode, data, { indent = true })
    if ok then
        return encoded
    end

    return json.encode(data)
end

function SaveCells()
    local encoded = EncodeJson(CellsState)
    SaveResourceFile(RESOURCE_NAME, CELLS_FILE, encoded, -1)
end

function LoadCells()
    local loaded = {}
    local raw = LoadResourceFile(RESOURCE_NAME, CELLS_FILE)

    if raw and raw ~= '' then
        local ok, decoded = pcall(json.decode, raw)
        if ok and type(decoded) == 'table' then
            loaded = decoded
        else
            Log('Cell data file was missing or malformed. Starting with default cell state.')
        end
    else
        Log('No existing cell data found. Starting with default cell state.')
    end

    CellsState = {}
    for _, cell in ipairs(Config.Cells or {}) do
        local key = tostring(cell.id)
        local existing = loaded[key] or loaded[tonumber(cell.id)] or {}
        local state = NewDefaultCellState(cell.id)

        for stateKey, value in pairs(existing) do
            state[stateKey] = value
        end

        state.id = tonumber(cell.id)
        state.occupied = state.occupied and true or false
        CellsState[key] = state
    end

    SaveCells()
end

function ParseDuration(input)
    if not input then
        return nil, 'Missing duration. Use 10m, 2h, 1d, indefinite, or hold.'
    end

    local value = input:lower()
    if value == 'indefinite' or value == 'hold' then
        return {
            detentionType = 'indefinite',
            seconds = nil,
            releaseAt = nil,
            label = value
        }
    end

    local amount, unit = value:match('^(%d+)([mhd])$')
    amount = tonumber(amount)
    if not amount or amount <= 0 then
        return nil, 'Invalid duration. Use formats like 10m, 2h, 1d, indefinite, or hold.'
    end

    local multiplier = 60
    if unit == 'h' then
        multiplier = 60 * 60
    elseif unit == 'd' then
        multiplier = 24 * 60 * 60
    end

    local seconds = amount * multiplier
    return {
        detentionType = 'timed',
        seconds = seconds,
        releaseAt = os.time() + seconds,
        label = value
    }
end

local function FormatTime(timestamp)
    if not timestamp then
        return 'N/A'
    end

    return os.date('%Y-%m-%d %H:%M:%S UTC', timestamp)
end

local function GetOnlinePlayerByIdentifier(identifier)
    if not identifier then
        return nil
    end

    for _, playerId in ipairs(GetPlayers()) do
        if GetIdentifier(tonumber(playerId)) == identifier then
            return tonumber(playerId)
        end
    end

    return nil
end

local function GetOnlinePrisonerSource(state)
    if not state then
        return nil
    end

    if state.prisonerServerId and GetPlayerName(tonumber(state.prisonerServerId)) then
        return tonumber(state.prisonerServerId)
    end

    return GetOnlinePlayerByIdentifier(state.prisonerIdentifier)
end

local function Vector4ToTable(coords)
    if not coords then
        return nil
    end

    return {
        x = coords.x or coords[1] or 0.0,
        y = coords.y or coords[2] or 0.0,
        z = coords.z or coords[3] or 0.0,
        w = coords.w or coords[4] or 0.0
    }
end

local function TeleportPlayer(target, coords)
    TriggerClientEvent('nrrp-police:client:teleport', target, Vector4ToTable(coords))
end

function JailPlayer(source, target, cellId, durationArg, reason)
    local cellConfig = GetCellConfig(cellId)
    local state = GetCellState(cellId)
    if not cellConfig or not state then
        Notify(source, 'Invalid cell ID.')
        return false
    end

    target = tonumber(target)
    if not target or not GetPlayerName(target) then
        Notify(source, 'Target player is not online.')
        return false
    end

    local duration, durationError = ParseDuration(durationArg)
    if not duration then
        Notify(source, durationError)
        return false
    end

    reason = reason and reason ~= '' and reason or 'No reason provided'
    local officerName = source == 0 and 'Console' or (GetPlayerName(source) or 'Unknown officer')
    local targetName = GetPlayerName(target) or ('ID %s'):format(target)
    local status = reason

    if duration.detentionType == 'indefinite' then
        status = Config.DefaultIndefiniteLabels[duration.label] or Config.DefaultIndefiniteLabels.indefinite or 'Indefinite hold'
    end

    state.occupied = true
    state.prisonerName = targetName
    state.prisonerServerId = target
    state.prisonerIdentifier = GetIdentifier(target)
    state.reason = reason
    state.status = status
    state.detentionType = duration.detentionType
    state.assignedBy = officerName
    state.assignedByIdentifier = source == 0 and 'console' or GetIdentifier(source)
    state.jailedAt = os.time()
    state.releaseAt = duration.releaseAt
    state.notes = state.notes or nil

    TeleportPlayer(target, cellConfig.jailCoords)
    SaveCells()

    Notify(source, ('%s jailed in %s. Detention: %s.'):format(targetName, cellConfig.label, duration.label))
    Notify(target, ('You have been placed in %s. Reason: %s'):format(cellConfig.label, reason))
    Log(('Jail: %s (%s) placed %s (%s) in cell %s for %s. Reason: %s'):format(officerName, state.assignedByIdentifier or 'no identifier', targetName, state.prisonerIdentifier or 'no identifier', cellId, duration.label, reason))
    return true
end

function ReleaseCell(source, cellId, automatic)
    local cellConfig = GetCellConfig(cellId)
    local state = GetCellState(cellId)
    if not cellConfig or not state then
        if not automatic then
            Notify(source, 'Invalid cell ID.')
        end
        return false
    end

    if not state.occupied then
        if not automatic then
            Notify(source, ('%s is already empty.'):format(cellConfig.label))
        end
        return false
    end

    local prisonerName = state.prisonerName or 'Unknown prisoner'
    local prisonerSource = GetOnlinePrisonerSource(state)

    if prisonerSource then
        TeleportPlayer(prisonerSource, cellConfig.releaseCoords)
        Notify(prisonerSource, ('You have been released from %s.'):format(cellConfig.label))
    end

    ClearOccupancy(state)
    SaveCells()

    if not automatic then
        Notify(source, ('%s released from %s.'):format(prisonerName, cellConfig.label))
    end

    Log(('%srelease: %s from cell %s%s'):format(automatic and 'Auto-' or 'Manual ', prisonerName, cellId, prisonerSource and ' (teleported online prisoner)' or ' (prisoner offline/not found)'))
    return true
end

local function ShowCells(source)
    for _, cell in ipairs(Config.Cells or {}) do
        local state = GetCellState(cell.id) or NewDefaultCellState(cell.id)
        local prisonerSource = GetOnlinePrisonerSource(state)
        local occupancy = state.occupied and 'Occupied' or 'Empty'
        local detention = state.detentionType or 'N/A'
        local release = state.detentionType == 'timed' and FormatTime(state.releaseAt) or 'N/A'
        local prisoner = state.prisonerName or 'None'
        local serverId = prisonerSource and tostring(prisonerSource) or 'Offline/N/A'
        local reason = state.reason or 'N/A'
        local status = state.status or 'N/A'
        local assignedBy = state.assignedBy or 'N/A'
        local notes = state.notes or 'N/A'

        Notify(source, ('Cell %s: %s | %s | Prisoner: %s (Server ID: %s) | Reason: %s | Status: %s | Type: %s | Release: %s | Assigned by: %s | Notes: %s'):format(cell.id, cell.label, occupancy, prisoner, serverId, reason, status, detention, release, assignedBy, notes))
    end
end

RegisterCommand('cells', function(source)
    if not CheckPoliceAccess(source, '/cells') then
        return
    end

    ShowCells(source)
end, false)

RegisterCommand('cellassign', function(source, args)
    if not CheckPoliceAccess(source, '/cellassign') then
        return
    end

    local cellId = tonumber(args[1])
    local cellConfig = GetCellConfig(cellId)
    local state = GetCellState(cellId)
    if not cellConfig or not state then
        Notify(source, 'Usage: /cellassign [cellId] [name...]')
        return
    end

    table.remove(args, 1)
    local name = table.concat(args, ' ')
    if name == '' then
        Notify(source, 'Usage: /cellassign [cellId] [name...]')
        return
    end

    state.occupied = true
    state.prisonerName = name
    state.prisonerServerId = nil
    state.prisonerIdentifier = nil
    state.reason = 'Manual RP record'
    state.status = Config.DefaultIndefiniteLabels.manual or 'Manual record'
    state.detentionType = 'indefinite'
    state.assignedBy = source == 0 and 'Console' or (GetPlayerName(source) or 'Unknown officer')
    state.assignedByIdentifier = source == 0 and 'console' or GetIdentifier(source)
    state.jailedAt = os.time()
    state.releaseAt = nil
    state.notes = state.notes or nil
    SaveCells()

    Notify(source, ('Assigned %s to %s.'):format(name, cellConfig.label))
    Log(('Manual assignment: %s assigned to cell %s by %s'):format(name, cellId, state.assignedBy))
end, false)

RegisterCommand('cellclear', function(source, args)
    if not CheckPoliceAccess(source, '/cellclear') then
        return
    end

    local cellId = tonumber(args[1])
    local cellConfig = GetCellConfig(cellId)
    local state = GetCellState(cellId)
    if not cellConfig or not state then
        Notify(source, 'Usage: /cellclear [cellId]')
        return
    end

    local oldName = state.prisonerName or 'No prisoner'
    ClearOccupancy(state)
    SaveCells()
    Notify(source, ('Cleared occupancy record for %s.'):format(cellConfig.label))
    Log(('Cell clear: cell %s cleared by %s (previous: %s)'):format(cellId, source == 0 and 'Console' or (GetPlayerName(source) or 'Unknown officer'), oldName))
end, false)

RegisterCommand('cellnote', function(source, args)
    if not CheckPoliceAccess(source, '/cellnote') then
        return
    end

    local cellId = tonumber(args[1])
    local state = GetCellState(cellId)
    if not GetCellConfig(cellId) or not state then
        Notify(source, 'Usage: /cellnote [cellId] [note...]')
        return
    end

    table.remove(args, 1)
    local note = table.concat(args, ' ')
    if note == '' then
        Notify(source, 'Usage: /cellnote [cellId] [note...]')
        return
    end

    state.notes = note
    SaveCells()
    Notify(source, ('Updated note for cell %s.'):format(cellId))
    Log(('Cell note: cell %s updated by %s'):format(cellId, source == 0 and 'Console' or (GetPlayerName(source) or 'Unknown officer')))
end, false)

RegisterCommand('cellstatus', function(source, args)
    if not CheckPoliceAccess(source, '/cellstatus') then
        return
    end

    local cellId = tonumber(args[1])
    local state = GetCellState(cellId)
    if not GetCellConfig(cellId) or not state then
        Notify(source, 'Usage: /cellstatus [cellId] [status...]')
        return
    end

    table.remove(args, 1)
    local status = table.concat(args, ' ')
    if status == '' then
        Notify(source, 'Usage: /cellstatus [cellId] [status...]')
        return
    end

    state.status = status
    SaveCells()
    Notify(source, ('Updated status for cell %s: %s'):format(cellId, status))
    Log(('Cell status: cell %s set to "%s" by %s'):format(cellId, status, source == 0 and 'Console' or (GetPlayerName(source) or 'Unknown officer')))
end, false)


RegisterCommand('jailcell', function(source, args)
    if not CheckPoliceAccess(source, '/jailcell') then
        return
    end

    local cellId = tonumber(args[1])
    local target = tonumber(args[2])
    local durationArg = args[3]
    if not cellId or not target or not durationArg then
        Notify(source, 'Usage: /jailcell [cellId] [targetServerId] [10m|2h|1d|indefinite|hold] [reason...]')
        return
    end

    local reasonParts = {}
    for i = 4, #args do
        reasonParts[#reasonParts + 1] = args[i]
    end

    JailPlayer(source, target, cellId, durationArg, table.concat(reasonParts, ' '))
end, false)

RegisterCommand('releasecell', function(source, args)
    if not CheckPoliceAccess(source, '/releasecell') then
        return
    end

    local cellId = tonumber(args[1])
    if not cellId then
        Notify(source, 'Usage: /releasecell [cellId]')
        return
    end

    ReleaseCell(source, cellId, false)
end, false)

RegisterCommand('sentencecell', function(source, args)
    if not CheckPoliceAccess(source, '/sentencecell') then
        return
    end

    local cellId = tonumber(args[1])
    local durationArg = args[2]
    local state = GetCellState(cellId)
    if not GetCellConfig(cellId) or not state or not durationArg then
        Notify(source, 'Usage: /sentencecell [cellId] [time|indefinite|release] [status/reason...]')
        return
    end

    if durationArg:lower() == 'release' then
        ReleaseCell(source, cellId, false)
        return
    end

    local duration, durationError = ParseDuration(durationArg)
    if not duration then
        Notify(source, durationError)
        return
    end

    local statusParts = {}
    for i = 3, #args do
        statusParts[#statusParts + 1] = args[i]
    end

    local status = table.concat(statusParts, ' ')
    if status == '' then
        status = duration.detentionType == 'timed' and 'Sentenced' or (Config.DefaultIndefiniteLabels[duration.label] or Config.DefaultIndefiniteLabels.indefinite or 'Indefinite hold')
    end

    state.detentionType = duration.detentionType
    state.releaseAt = duration.releaseAt
    state.status = status
    state.reason = status
    SaveCells()

    Notify(source, ('Updated sentence for cell %s: %s.'):format(cellId, status))
    Log(('Sentence update: cell %s set to %s by %s. Status/reason: %s'):format(cellId, durationArg, source == 0 and 'Console' or (GetPlayerName(source) or 'Unknown officer'), status))
end, false)




CreateThread(function()
    LoadCells()
    Log('Resource started and cell state loaded.')

end)

CreateThread(function()
    while true do
        Wait(60000)

        local now = os.time()
        for cellId, state in pairs(CellsState) do
            if state.occupied and state.detentionType == 'timed' and state.releaseAt and state.releaseAt <= now then
                ReleaseCell(0, tonumber(cellId), true)
            end
        end
    end
end)
