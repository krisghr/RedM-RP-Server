local RESOURCE_NAME = GetCurrentResourceName()
local CELLS_FILE = 'data/cells.json'
local CellsState = {}
local Core <const> = exports.vorp_core:GetCore()
local GetPlayerDisplayName

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
        GetPlayerDisplayName(source, 'unknown'),
        GetIdentifier(source) or 'no identifier',
        tostring(GetPlayerJobFromLoJobsCreator(source) or 'none'),
        tostring(GetPlayerGradeFromVorp(source) or 'none')
    ))
    Notify(source, 'You are not authorized to use police cell commands.')
    return false
end


local function HasLeadershipAccess(source)
    if source == 0 or HasAdminBypass(source) then
        return true
    end

    if not HasPoliceAccess(source) then
        return false
    end

    local leadershipConfig = Config.Leadership or {}
    local function IsLoJobsCreatorBossGrade()
        if not leadershipConfig.AllowLoJobsCreatorBossGrades then
            return false
        end

        if GetResourceState('lo_jobscreator') ~= 'started' then
            return false
        end

        local playerState = Player(source) and Player(source).state or nil
        if playerState then
            if playerState.isBoss == true or playerState.IsBoss == true or playerState.jobIsBoss == true or playerState.JobIsBoss == true then
                return true
            end
        end

        local exportChecks = {
            function() return exports.lo_jobscreator:IsBoss(source) end,
            function() return exports.lo_jobscreator:IsPlayerBoss(source) end,
            function()
                local currentJob = GetPlayerJobFromLoJobsCreator(source)
                if not currentJob then return false end
                return exports.lo_jobscreator:IsBoss(source, currentJob)
            end,
            function()
                local currentJob = GetPlayerJobFromLoJobsCreator(source)
                if not currentJob then return false end
                return exports.lo_jobscreator:IsDutyBoss(source, currentJob)
            end
        }

        for _, fn in ipairs(exportChecks) do
            local ok, result = pcall(fn)
            if ok and result == true then
                return true
            end
        end

        return false
    end

    local function IsConfiguredBossGradeForJob()
        local leadershipBossConfig = leadershipConfig.BossGradesByJob or {}
        if type(leadershipBossConfig) ~= 'table' then
            return false
        end

        local currentJob, currentGrade = GetPlayerJobData(source)
        if not currentJob or currentGrade == nil then
            return false
        end

        local allowedGrades = leadershipBossConfig[tostring(currentJob)]
        if type(allowedGrades) ~= 'table' or #allowedGrades == 0 then
            return false
        end

        local numericGrade = tonumber(currentGrade)
        if not numericGrade then
            return false
        end

        for _, grade in ipairs(allowedGrades) do
            if numericGrade == tonumber(grade) then
                return true
            end
        end

        return false
    end

    if IsLoJobsCreatorBossGrade() then
        return true
    end

    if IsConfiguredBossGradeForJob() then
        return true
    end

    local allowedJobs = leadershipConfig.AllowedJobs or {}
    if #allowedJobs == 0 then
        return true
    end

    local jobName = GetPlayerJobFromLoJobsCreator(source)
    if not jobName then
        return false
    end

    for _, allowedJob in ipairs(allowedJobs) do
        if jobName == allowedJob then
            return true
        end
    end

    return false
end

local function CanHireJob(jobName)
    local leadershipConfig = Config.Leadership or {}
    if not leadershipConfig.RestrictHireJobs then
        return true
    end

    for _, allowedJob in ipairs(leadershipConfig.HireJobs or {}) do
        if jobName == allowedJob then
            return true
        end
    end

    return false
end


local function GetStationForCell(cell)
    if not cell then
        return nil
    end

    return cell.station and tostring(cell.station) or nil
end

local function CanUseCellForJob(source, cell)
    local station = GetStationForCell(cell)
    if not station then
        return true
    end

    local permissions = Config.StationPermissions or {}
    local allowedJobs = permissions[station]
    if type(allowedJobs) ~= 'table' or #allowedJobs == 0 then
        return true
    end

    local jobName = GetPlayerJobFromLoJobsCreator(source)
    if not jobName then
        return false
    end

    for _, allowedJob in ipairs(allowedJobs) do
        if jobName == allowedJob then
            return true
        end
    end

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

GetPlayerDisplayName = function(playerSource, fallbackLabel)
    local sourceId = tonumber(playerSource)
    if not sourceId then
        return fallbackLabel or 'Unknown'
    end

    local user = Core.getUser(sourceId)
    if user then
        local character = user.getUsedCharacter
        if type(character) == 'function' then
            character = character(user)
        end

        if character then
            local firstname = character.firstname or character.firstName or ''
            local lastname = character.lastname or character.lastName or ''
            local fullName = (('%s %s'):format(firstname, lastname)):gsub('^%s*(.-)%s*$', '%1')
            if fullName ~= '' then
                return fullName
            end
        end
    end

    return GetPlayerName(sourceId) or fallbackLabel or ('ID %s'):format(sourceId)
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
    local officerName = source == 0 and 'Console' or GetPlayerDisplayName(source, 'Unknown officer')
    local targetName = GetPlayerDisplayName(target, ('ID %s'):format(target))
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
    state.assignedBy = source == 0 and 'Console' or GetPlayerDisplayName(source, 'Unknown officer')
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

local function GetReleaseCoordsForCell(cell)
    if not cell then
        return nil
    end

    local stationKey = GetStationForCell(cell)
    local station = stationKey and Config.Stations and Config.Stations[stationKey] or nil

    if station and station.releaseCoords then
        return station.releaseCoords
    end

    return cell.releaseCoords
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
        local releaseCoords = GetReleaseCoordsForCell(cellConfig)
        if releaseCoords then
            TeleportPlayer(prisonerSource, releaseCoords)
        end
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
    Log(('Cell clear: cell %s cleared by %s (previous: %s)'):format(cellId, source == 0 and 'Console' or GetPlayerDisplayName(source, 'Unknown officer'), oldName))
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
    Log(('Cell note: cell %s updated by %s'):format(cellId, source == 0 and 'Console' or GetPlayerDisplayName(source, 'Unknown officer')))
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
    Log(('Cell status: cell %s set to "%s" by %s'):format(cellId, status, source == 0 and 'Console' or GetPlayerDisplayName(source, 'Unknown officer')))
end, false)


local function BuildJailUiPayload(source)
    local allowedStations = {}
    local allStations = {}
    local seenAllowed = {}
    local seenAll = {}

    for _, cell in ipairs(Config.Cells or {}) do
        local stationKey = GetStationForCell(cell)
        if stationKey and Config.Stations and Config.Stations[stationKey] then
            if not seenAll[stationKey] then
                seenAll[stationKey] = true
                allStations[#allStations + 1] = {
                    id = stationKey,
                    label = Config.Stations[stationKey].label or stationKey
                }
            end

            if CanUseCellForJob(source, cell) and not seenAllowed[stationKey] then
                seenAllowed[stationKey] = true
                allowedStations[#allowedStations + 1] = {
                    id = stationKey,
                    label = Config.Stations[stationKey].label or stationKey
                }
            end
        end
    end

    local usingFallback = #allowedStations == 0 and #allStations > 0

    return {
        locations = usingFallback and allStations or allowedStations,
        usingPermissionFallback = usingFallback
    }
end

local function GetDistanceBetweenCoords(a, b)
    local dx = (a.x or 0.0) - (b.x or 0.0)
    local dy = (a.y or 0.0) - (b.y or 0.0)
    local dz = (a.z or 0.0) - (b.z or 0.0)
    return math.sqrt((dx * dx) + (dy * dy) + (dz * dz))
end

local function GetOfficerCoords(source)
    if source == 0 then
        return nil
    end

    local ped = GetPlayerPed(source)
    if not ped or ped <= 0 then
        return nil
    end

    local coords = GetEntityCoords(ped)
    if not coords then
        return nil
    end

    return { x = coords.x, y = coords.y, z = coords.z }
end

local function GetCharacterFullName(playerSource)
    local user = Core.getUser(playerSource)
    if not user then
        return nil
    end

    local character = user.getUsedCharacter
    if type(character) == 'function' then
        character = character(user)
    end

    if not character then
        return nil
    end

    local firstname = character.firstname or character.firstName or ''
    local lastname = character.lastname or character.lastName or ''
    local fullName = (('%s %s'):format(firstname, lastname)):gsub('^%s*(.-)%s*$', '%1')

    if fullName == '' then
        return nil
    end

    return fullName
end

local function ResolveTargetPlayer(rawTarget)
    local query = tostring(rawTarget or ''):gsub('^%s*(.-)%s*$', '%1')
    if query == '' then
        return nil, 'Please fill out all jail form fields.'
    end

    local parsedId = tonumber(query)
    if parsedId then
        if GetPlayerName(parsedId) then
            return parsedId
        end
        return nil, ('No active player found with server ID %s.'):format(parsedId)
    end

    local normalizedQuery = query:lower()
    local matches = {}

    for _, playerSource in ipairs(GetPlayers()) do
        local numericSource = tonumber(playerSource)
        if numericSource then
            local fullName = GetCharacterFullName(numericSource)
            if fullName and fullName:lower() == normalizedQuery then
                matches[#matches + 1] = numericSource
            end
        end
    end

    if #matches == 1 then
        return matches[1]
    end

    if #matches > 1 then
        return nil, ('Multiple active players match "%s". Please use server ID.'):format(query)
    end

    return nil, ('No active player found with name "%s".'):format(query)
end

local function GetAvailableCellsForStation(source, stationKey)
    local available = {}

    for _, cell in ipairs(Config.Cells or {}) do
        if GetStationForCell(cell) == stationKey and CanUseCellForJob(source, cell) then
            local state = GetCellState(cell.id)
            if state and not state.occupied then
                available[#available + 1] = cell
            end
        end
    end

   return available
end

RegisterNetEvent('nrrp-police:server:submitJailForm', function(data)
    local source = source
    if not CheckPoliceAccess(source, 'Jail form submission') then
        return
    end

    if type(data) ~= 'table' then
        Notify(source, 'Invalid jail form submission.')
        return
    end

    local stationKey = tostring(data.cellId or '')
    local targetInput = data.target or data.targetId or data.targetName
    local target, targetError = ResolveTargetPlayer(targetInput)
    local durationArg = tostring(data.duration or '')
    local reason = tostring(data.reason or '')

    if stationKey == '' or durationArg == '' then
        Notify(source, 'Please fill out all jail form fields.')
        return
    end

    if not target then
        Notify(source, targetError or 'Unable to find that player.')
        return
    end

local stationConfig = Config.Stations and Config.Stations[stationKey] or nil
    if not stationConfig then
        Notify(source, 'You selected an invalid jail location.')
        return
    end

    local availableCells = GetAvailableCellsForStation(source, stationKey)
    if #availableCells == 0 then
        Notify(source, ('No open cells are available at %s.'):format(stationConfig.label or stationKey))
        return
    end

    local officerCoords = GetOfficerCoords(source)
    local maxDistance = tonumber(Config.JailBookingMaxDistance) or 50.0
    local isNearStation = false

    if not officerCoords then
        Notify(source, 'Could not verify your location for jail booking.')
        return
    end

    for _, cell in ipairs(availableCells) do
        if GetDistanceBetweenCoords(officerCoords, cell.jailCoords) <= maxDistance then
            isNearStation = true
            break
        end
    end

    if not isNearStation then
        Notify(source, ('You must be within %.1f meters of %s to use /jail.'):format(maxDistance, stationConfig.label or stationKey))
        return
    end

  local selectedCell = availableCells[math.random(#availableCells)]
    JailPlayer(source, target, selectedCell.id, durationArg, reason)
    TriggerClientEvent('nrrp-police:client:closeJailUi', source)
end)

RegisterCommand('jail', function(source)

    if not CheckPoliceAccess(source, '/jail') then
        print('[nrrp-police] /jail blocked: no police access')
        return
    end

    local payload = BuildJailUiPayload(source)
    if #payload.locations == 0 then
        Notify(source, 'No jail locations are configured.')
        return
    end

if payload.usingPermissionFallback then
        Notify(source, 'No job-specific jail locations matched; showing all locations instead.')
    end

    print('[nrrp-police] opening jail UI')
    TriggerClientEvent('nrrp-police:client:openJailUi', source, payload)
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

RegisterCommand((Config.Leadership and Config.Leadership.Command) or 'leadership', function(source, args)
    if not HasLeadershipAccess(source) then
        Notify(source, 'You are not authorized to use leadership actions.')
        return
    end

    local action = (args[1] or ''):lower()
    if action == '' or action == 'help' then
        Notify(source, 'Leadership command usage:')
        Notify(source, '/leadership hire [serverId] [jobName] [grade(optional)]')
        Notify(source, '/leadership fire [serverId]')
        Notify(source, '/leadership setgrade [serverId] [grade]')
        return
    end

    local target = tonumber(args[2])
    if not target then
        Notify(source, 'Target server id is required.')
        return
    end

    local targetUser = Core.getUser(target)
    if not targetUser then
        Notify(source, 'Target player not found.')
        return
    end

    local targetCharacter = targetUser.getUsedCharacter
    if type(targetCharacter) == 'function' then
        targetCharacter = targetCharacter(targetUser)
    end

    if not targetCharacter then
        Notify(source, 'Could not access target character.')
        return
    end

    if action == 'hire' then
        local jobName = tostring(args[3] or '')
        if jobName == '' then
            Notify(source, 'Usage: /leadership hire [serverId] [jobName] [grade(optional)]')
            return
        end

        if not CanHireJob(jobName) then
            Notify(source, ('You cannot assign the "%s" job from leadership command.'):format(jobName))
            return
        end

        local grade = tonumber(args[4]) or tonumber((Config.Leadership and Config.Leadership.DefaultHireGrade) or 0) or 0
        targetCharacter.setJob(jobName, true)
        targetCharacter.setJobGrade(grade, true)
        targetCharacter.setJobLabel(jobName, true)

        Notify(source, ('Assigned %s to %s (grade %s).'):format(GetPlayerName(target) or ('ID ' .. target), jobName, tostring(grade)))
        Notify(target, ('You were assigned to %s (grade %s).'):format(jobName, tostring(grade)))
        Log(('Leadership hire: %s assigned %s to %s grade %s'):format(source == 0 and 'Console' or (GetPlayerName(source) or ('ID ' .. source)), GetPlayerName(target) or ('ID ' .. target), jobName, tostring(grade)))
        return
    end

    if action == 'fire' then
        local fireToJob = (Config.Leadership and Config.Leadership.FireToJob) or 'unemployed'
        local fireToLabel = (Config.Leadership and Config.Leadership.FireToLabel) or 'Unemployed'
        targetCharacter.setJob(fireToJob, true)
        targetCharacter.setJobLabel(fireToLabel, true)

        Notify(source, ('Removed %s from current police role.'):format(GetPlayerName(target) or ('ID ' .. target)))
        Notify(target, ('You were set to %s.'):format(fireToLabel))
        Log(('Leadership fire: %s removed %s to %s'):format(source == 0 and 'Console' or (GetPlayerName(source) or ('ID ' .. source)), GetPlayerName(target) or ('ID ' .. target), fireToJob))
        return
    end

    if action == 'setgrade' then
        local grade = tonumber(args[3])
        if not grade then
            Notify(source, 'Usage: /leadership setgrade [serverId] [grade]')
            return
        end

        targetCharacter.setJobGrade(grade, true)
        Notify(source, ('Updated %s to grade %s.'):format(GetPlayerName(target) or ('ID ' .. target), tostring(grade)))
        Notify(target, ('Your job grade was set to %s.'):format(tostring(grade)))
        Log(('Leadership setgrade: %s set %s to grade %s'):format(source == 0 and 'Console' or (GetPlayerName(source) or ('ID ' .. source)), GetPlayerName(target) or ('ID ' .. target), tostring(grade)))
        return
    end

    Notify(source, 'Unknown leadership action. Use /leadership help.')
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
