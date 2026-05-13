-- Cross-client expression sync.
-- SetCharExpression is local-only in RDR3, so other clients never see a player's
-- slider customization unless they re-apply it themselves. Owners publish their
-- expressions to a replicated statebag; observers listen and re-apply periodically
-- to handle late joins, ped re-streaming, and respawns.

local STATEBAG_KEY = 'murphy_expressions'
local APPLY_INTERVAL_MS = (Config and Config.ExpressionSyncIntervalMs) or 1500
local SYNC_RADIUS = (Config and Config.ExpressionSyncRadius) or 75.0
local SYNC_RADIUS_SQ = SYNC_RADIUS * SYNC_RADIUS

RemoteExpressions = {}            -- [serverId] = { slider = value }
local RemoteExpressionsSig = {}   -- [serverId] = signature string of the cached expressions
local LastAppliedSig = {}         -- [serverId] = signature string at last apply
local LastAppliedPed = {}         -- [serverId] = ped handle at last apply (detects re-stream/respawn)

local function ExpressionsSignature(t)
    local keys = {}
    for k in pairs(t) do keys[#keys + 1] = k end
    table.sort(keys)
    local parts = {}
    for _, k in ipairs(keys) do
        parts[#parts + 1] = k .. '=' .. tostring(t[k])
    end
    return table.concat(parts, ';')
end

local function IsLocalAppearancePaused()
    return LocalPlayer and LocalPlayer.state and LocalPlayer.state.murphy_appearance_paused == true
end

local function ReadPlayerStateExpressions(serverId)
    local ok, value = pcall(function()
        local p = Player(serverId)
        return p and p.state and p.state[STATEBAG_KEY] or nil
    end)
    if not ok then return nil end
    if type(value) ~= 'table' or next(value) == nil then return nil end
    return value
end

function PublishLocalExpressions()
    if not LocalPlayer or not LocalPlayer.state then return end
    if IsLocalAppearancePaused() then return end
    if not CachePedData or not CachePedData.expressions then return end
    if next(CachePedData.expressions) == nil then return end
    LocalPlayer.state:set(STATEBAG_KEY, CachePedData.expressions, true)
    if Config and Config.Debug then
        print("[murphy_creator] Published local expressions")
    end
end
exports('PublishLocalExpressions', PublishLocalExpressions)

function ClearLocalExpressions()
    if not LocalPlayer or not LocalPlayer.state then return end
    LocalPlayer.state:set(STATEBAG_KEY, nil, true)
end
exports('ClearLocalExpressions', ClearLocalExpressions)

RegisterNetEvent('murphy_creator:localExpressionsReady', function()
    PublishLocalExpressions()
end)

AddStateBagChangeHandler(STATEBAG_KEY, nil, function(bagName, _key, value)
    local serverId = tonumber(bagName:match('player:(%d+)'))
    if not serverId then return end
    if value == nil or type(value) ~= 'table' or next(value) == nil then
        RemoteExpressions[serverId] = nil
        RemoteExpressionsSig[serverId] = nil
        LastAppliedSig[serverId] = nil
        LastAppliedPed[serverId] = nil
        return
    end
    RemoteExpressions[serverId] = value
    RemoteExpressionsSig[serverId] = ExpressionsSignature(value)
    LastAppliedSig[serverId] = nil  -- force re-apply on next loop tick
end)

local function ApplyExpressionsTo(ped, expressions)
    if not ExpressionsHashes then return end
    for slider, value in pairs(expressions) do
        local hash = ExpressionsHashes[slider]
        if hash then
            Citizen.InvokeNative(0x5653AB26C82938CF, ped, value, hash)
        end
    end
    -- _UPDATE_PED_VARIATION (local-only refresh, commits the expression changes visually).
    -- Only called when expressions actually need to be (re)applied — see signature/ped checks
    -- in the loop — so no per-tick cost on unchanged peds.
    Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, false, true, true, true, false)
end

Citizen.CreateThread(function()
    while true do
        Wait(APPLY_INTERVAL_MS)
        local localPed = PlayerPedId()
        if not localPed or localPed == 0 or not DoesEntityExist(localPed) then
            goto continue
        end
        local localServerId = GetPlayerServerId(PlayerId())
        local localCoords = GetEntityCoords(localPed)

        for _, playerId in ipairs(GetActivePlayers()) do
            local serverId = GetPlayerServerId(playerId)
            if serverId and serverId ~= localServerId then
                local ped = GetPlayerPed(playerId)
                if ped and ped ~= 0 and DoesEntityExist(ped) and not IsPedDeadOrDying(ped, true) then
                    local pedCoords = GetEntityCoords(ped)
                    local dx = pedCoords.x - localCoords.x
                    local dy = pedCoords.y - localCoords.y
                    local dz = pedCoords.z - localCoords.z
                    if (dx * dx + dy * dy + dz * dz) <= SYNC_RADIUS_SQ then
                        local expressions = RemoteExpressions[serverId]
                        if not expressions then
                            -- Late-join fallback: AddStateBagChangeHandler may not fire for
                            -- bags that already existed before our handler was registered.
                            -- Read directly and populate the cache.
                            expressions = ReadPlayerStateExpressions(serverId)
                            if expressions then
                                RemoteExpressions[serverId] = expressions
                                RemoteExpressionsSig[serverId] = ExpressionsSignature(expressions)
                            end
                        end
                        if expressions and Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, ped) then
                            local sig = RemoteExpressionsSig[serverId]
                            if LastAppliedPed[serverId] ~= ped or LastAppliedSig[serverId] ~= sig then
                                ApplyExpressionsTo(ped, expressions)
                                LastAppliedPed[serverId] = ped
                                LastAppliedSig[serverId] = sig
                            end
                        end
                    end
                end
            end
        end
        ::continue::
    end
end)
