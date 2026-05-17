---@diagnostic disable: undefined-global
-- ############################################################################
-- #                        EDITABLE FILE                                      #
-- #                                                                           #
-- #   Shared framework bridge (client + server).                              #
-- #   THIS RELEASE SUPPORTS VORP ONLY (vorp_core). Without it the bridge      #
-- #   degrades to "standalone" (statebag-based, minimal).                     #
-- #                                                                           #
-- #   Force standalone (skip VORP detection): Config.Framework.force =        #
-- #   'standalone' in config.lua, or the convar `setr lo_jobscreator:framework #
-- #   standalone`. Want another framework? modules/editable/framework.lua is   #
-- #   yours — point `Core` at your core and reimplement the Framework_*        #
-- #   functions there.                                                        #
-- ############################################################################

local function IsResourceRunning(resource)
    local state = GetResourceState(resource)
    return state == 'starting' or state == 'started'
end

local function CompareVersion(a, b)
    if type(a) ~= 'string' or type(b) ~= 'string' then return 0 end
    local ai = {}
    local bi = {}
    for n in a:gmatch('%d+') do ai[#ai + 1] = tonumber(n) end
    for n in b:gmatch('%d+') do bi[#bi + 1] = tonumber(n) end
    local len = math.max(#ai, #bi)
    for i = 1, len do
        local x = ai[i] or 0
        local y = bi[i] or 0
        if x < y then return -1 end
        if x > y then return 1 end
    end
    return 0
end

-- Resource constraint syntax:
--   'vorp_core'           → must be running
--   'vorp_core>=1.5.0'    → running AND version >= 1.5.0
--   '!some_resource'      → must NOT be running
local function ResourceConstraintMet(constraint)
    if type(constraint) ~= 'string' then return false end
    if constraint:sub(1, 1) == '!' then
        return not IsResourceRunning(constraint:sub(2))
    end
    local resource, op, version = constraint:match('^([%w%-_]+)%s*(<>=)%s*([%d%.]+)$')
    if not resource then
        resource, op, version = constraint:match('^([%w%-_]+)%s*([<>=]+)%s*([%d%.]+)$')
    end
    resource = resource or constraint
    if not IsResourceRunning(resource) then return false end
    if op and version then
        local current = GetResourceMetadata(resource, 'version', 0) or '0'
        local cmp = CompareVersion(current, version)
        if op == '>=' then return cmp >= 0 end
        if op == '<=' then return cmp <= 0 end
        if op == '>'  then return cmp > 0 end
        if op == '<'  then return cmp < 0 end
        if op == '='  or op == '==' then return cmp == 0 end
    end
    return true
end

local function SafeGetCore(resource, getters)
    if not IsResourceRunning(resource) then return nil end
    local exportRef = exports[resource]
    if not exportRef then return nil end
    for i = 1, #getters do
        local ok, result = pcall(function()
            local fn = exportRef[getters[i]]
            if type(fn) == 'function' then return fn() end
            return nil
        end)
        if ok and result ~= nil then return result end
    end
    return exportRef
end

local function NormalizeName(value)
    if type(value) ~= 'string' then return nil end
    local n = value:lower():gsub('%s+', '')
    if n == '' or n == 'auto' then return nil end
    if n == 'vorpcore' or n == 'vorp_core' then return 'vorp' end
    return n
end

-- ----------------------------------------------------------------------------
-- This release ships VORP-only support. `vorp_core` is the one supported
-- framework; anything else degrades to 'standalone' (statebag-based, minimal).
--
-- WANT ANOTHER FRAMEWORK? This whole file (modules/editable/*) is yours to edit.
-- Point `Core` at your framework's core object and reimplement the
-- `Framework_*` functions in modules/editable/framework.lua accordingly.
-- ----------------------------------------------------------------------------
local function ResolveFramework()
    local forced = NormalizeName(GetConvar('lo_jobscreator:framework', ''))
        or NormalizeName(Config and Config.Framework and Config.Framework.force)
    if forced == 'standalone' then
        return { name = 'standalone', resource = nil, core = nil, forced = true }
    end
    if ResourceConstraintMet('vorp_core') then
        return {
            name = 'vorp', display = 'VORP', resource = 'vorp_core',
            core = SafeGetCore('vorp_core', { 'GetCore' }), forced = forced == 'vorp',
        }
    end
    return { name = 'standalone', resource = nil, core = nil, forced = false }
end

local resolved = ResolveFramework()

Core = resolved.core
FrameworkBridge = {
    name = resolved.name,
    display = resolved.display,
    resource = resolved.resource,
    hasCore = resolved.core ~= nil,
    forced = resolved.forced,
}
FrameworkBridge.family = resolved.name

