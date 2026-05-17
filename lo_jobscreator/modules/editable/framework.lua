---@diagnostic disable: undefined-global, undefined-field
-- ############################################################################
-- #                          EDITABLE FILE                                   #
-- #   modules/editable/framework.lua  —  the bridge between lo_jobscreator    #
-- #   and the server framework.                                               #
-- #                                                                          #
-- #   This script was built for VORP and OFFICIALLY supports VORP ONLY        #
-- #   (vorp_core + vorp_inventory). It is, however, *coded* so you can plug    #
-- #   in another framework yourself: everything that touches the framework    #
-- #   goes through the `Framework_*` functions in this file. Rewrite them so   #
-- #   they read/write your framework's character data, money and inventory     #
-- #   and the rest of lo_jobscreator works unchanged. NOTE: framework support  #
-- #   beyond VORP is NOT covered by support — you're on your own there.        #
-- #                                                                          #
-- #   When vorp_core isn't running, the bridge degrades to "standalone": the   #
-- #   character lives on the player's `Character` statebag (see                #
-- #   GetStandaloneCharacter) and the inventory functions become no-ops —      #
-- #   enough to keep the panel usable without a core.                          #
-- ############################################################################

local GetResourceState   = GetResourceState
local RegisterNetEvent   = RegisterNetEvent
local TriggerClientEvent = TriggerClientEvent
local AddEventHandler    = AddEventHandler
local Player             = Player

-- True when modules/editable/shared.lua resolved VORP (vorp_core present).
local function IsVorp() return FrameworkBridge ~= nil and FrameworkBridge.name == 'vorp' end
local function HasCore() return Core ~= nil end
local function HasVorpInventory() return GetResourceState('vorp_inventory') == 'started' end

-- ============================================================================
-- CHARACTER ACCESS  (VORP, with a statebag fallback for standalone)
-- ============================================================================

-- The active VORP character object (exposes .job/.gang/.money/.setJob/...), or nil.
local function VorpCharacter(src)
    if not (IsVorp() and HasCore() and Core.getUser) then return nil end
    local ok, user = pcall(Core.getUser, src)
    if not ok or type(user) ~= 'table' then return nil end
    local char = user.getUsedCharacter
    if type(char) == 'table' then return char end
    return nil
end

-- Standalone fallback: the character lives on the player's `Character` statebag.
local function PlayerStateBag(src)
    local p = Player(src)
    return p and p.state or nil
end
local function GetStandaloneCharacter(src)
    local state = PlayerStateBag(src)
    if not state then return nil end
    if type(state.Character) == 'table' then return state.Character end
    return {
        job = state.Job or state.job, gang = state.Gang or state.gang,
        jobGrade = state.Grade or state.grade or 0, gangGrade = state.GangGrade or state.gangGrade or 0,
        money = state.money or state.cash or 0, gold = state.gold or 0,
        group = state.group or state.permissionGroup or state.adminGroup,
    }
end
local function SetStandaloneValue(src, key, value)
    local state = PlayerStateBag(src)
    if not state or not state.set then return false end
    local out = {}
    if type(state.Character) == 'table' then for k, v in pairs(state.Character) do out[k] = v end end
    out[key] = value
    state:set('Character', out, true)
    return true
end

-- ============================================================================
-- READ — character / job / gang / grade / money
-- ============================================================================

function Framework_GetCharacter(src)
    return VorpCharacter(src) or GetStandaloneCharacter(src)
end

local function readChar(src, key, alts)
    local char = Framework_GetCharacter(src)
    if type(char) ~= 'table' then return nil end
    if char[key] ~= nil then return char[key] end
    if alts then for _, k in ipairs(alts) do if char[k] ~= nil then return char[k] end end end
    return nil
end

function Framework_GetJob(src)       return readChar(src, 'job',  { 'Job' }) end
function Framework_GetGang(src)      return readChar(src, 'gang', { 'Gang' }) end
function Framework_GetGroup(src)
    local g = readChar(src, 'group', { 'Group' })
    if g ~= nil and g ~= '' then return g end
    local state = PlayerStateBag(src)
    if state then return state.group or state.permissionGroup or state.adminGroup end
    return nil
end
function Framework_GetJobGrade(src)  return tostring(readChar(src, 'jobGrade',  { 'JobGrade', 'grade', 'Grade' }) or 0) end
function Framework_GetGangGrade(src) return tostring(readChar(src, 'gangGrade', { 'GangGrade' }) or 0) end
function Framework_GetMoney(src)     return tonumber(readChar(src, 'money', { 'Money' })) or 0 end
function Framework_GetGold(src)      return tonumber(readChar(src, 'gold',  { 'Gold' })) or 0 end

-- ============================================================================
-- WRITE — money / job / gang / grade / labels
-- ============================================================================

-- currencyType: 0 = dollars, 1 = gold (VORP convention).
function Framework_AddCurrency(src, currencyType, amount)
    local char = VorpCharacter(src)
    if char and char.addCurrency then char.addCurrency(currencyType, amount) return end
    local field = currencyType == 1 and 'gold' or 'money'
    local cur = tonumber((Framework_GetCharacter(src) or {})[field]) or 0
    SetStandaloneValue(src, field, math.max(0, cur + amount))
end

function Framework_RemoveCurrency(src, currencyType, amount)
    local char = VorpCharacter(src)
    if char and char.removeCurrency then char.removeCurrency(currencyType, amount) return end
    local field = currencyType == 1 and 'gold' or 'money'
    local cur = tonumber((Framework_GetCharacter(src) or {})[field]) or 0
    SetStandaloneValue(src, field, math.max(0, cur - math.abs(amount)))
end

function Framework_SetJob(src, job)
    local char = VorpCharacter(src)
    if char and char.setJob then char.setJob(job, true) return end
    SetStandaloneValue(src, 'job', job)
end
function Framework_SetJobGrade(src, grade)
    local char = VorpCharacter(src)
    if char and char.setJobGrade then char.setJobGrade(tonumber(grade) or 0, true) return end
    SetStandaloneValue(src, 'jobGrade', tonumber(grade) or 0)
end
function Framework_SetGang(src, gang)
    local char = VorpCharacter(src)
    if char and char.setGang then char.setGang(gang, true) return end
    SetStandaloneValue(src, 'gang', gang)
end
function Framework_SetGangGrade(src, grade)
    local char = VorpCharacter(src)
    if char and char.setGangGrade then char.setGangGrade(tonumber(grade) or 0, true) return end
    SetStandaloneValue(src, 'gangGrade', tonumber(grade) or 0)
end
function Framework_SetJobLabel(src, label)
    if type(label) ~= 'string' or label == '' then return end
    local char = VorpCharacter(src)
    if char and char.setJobLabel then char.setJobLabel(label) return end
    SetStandaloneValue(src, 'jobLabel', label)
end
function Framework_SetGangLabel(src, label)
    if type(label) ~= 'string' or label == '' then return end
    local char = VorpCharacter(src)
    if char and char.setGangLabel then char.setGangLabel(label) return end
    SetStandaloneValue(src, 'gangLabel', label)
end

-- ============================================================================
-- SERVER CALLBACKS — ox_lib if installed, else vorp_core's Callback, else a
-- built-in request/response event pair (so the script always has callbacks).
-- ============================================================================

local CALLBACK_REQUEST_EVENT  = 'lo_jobscreator:internal:CallbackRequest'
local CALLBACK_RESPONSE_EVENT = 'lo_jobscreator:internal:CallbackResponse'
local FallbackCallbacks = {}

RegisterNetEvent(CALLBACK_REQUEST_EVENT, function(name, requestId, ...)
    local src = source
    local handler = FallbackCallbacks[name]
    local result
    if handler then
        local ok, response = pcall(handler, src, ...)
        if ok then result = response
        elseif Logger then Logger.error('framework', ('callback "%s" failed: %s'):format(tostring(name), tostring(response))) end
    end
    TriggerClientEvent(CALLBACK_RESPONSE_EVENT, src, requestId, result)
end)

function Framework_RegisterCallback(name, handler)
    if GetResourceState('ox_lib') == 'started' and lib and lib.callback and lib.callback.register then
        lib.callback.register(name, handler)
        return
    end
    if IsVorp() and HasCore() and Core.Callback and Core.Callback.Register then
        Core.Callback.Register(name, function(source, cb, ...)
            cb(handler(source, ...))
        end)
        return
    end
    FallbackCallbacks[name] = handler
end

-- ============================================================================
-- INVENTORY — vorp_inventory (no-ops in standalone)
-- ============================================================================

-- Inventory provider tag, used by the boot banner and Framework_CanEditItems.
function InvProvider() return HasVorpInventory() and 'vorp_inventory' or 'core' end
if FrameworkBridge then FrameworkBridge.inventory = InvProvider() end

function Framework_CanCarryItem(src, itemName, amount, cb)
    if HasVorpInventory() then exports.vorp_inventory:canCarryItem(src, itemName, amount, cb) return end
    cb(true)
end

function Framework_AddInventoryItem(src, itemName, amount)
    if HasVorpInventory() then exports.vorp_inventory:addItem(src, itemName, amount) end
end

function Framework_RemoveInventoryItem(src, itemName, amount)
    if HasVorpInventory() then exports.vorp_inventory:subItem(src, itemName, amount) end
end

function Framework_GetItemCount(src, itemName)
    if HasVorpInventory() then return exports.vorp_inventory:getItemCount(src, nil, itemName) or 0 end
    return 0
end

-- Player inventory as { { name, label, count, metadata? }, ... }.
function Framework_GetInventoryItems(src)
    local out = {}
    if not HasVorpInventory() then return out end
    local function push(name, label, count, metadata)
        local c = tonumber(count) or 0
        if not name or name == '' or c <= 0 then return end
        out[#out + 1] = { name = name, label = label or name, count = c, metadata = metadata }
    end
    local ok, items = pcall(function() return exports.vorp_inventory:getUserInventoryItems(src) end)
    if ok and type(items) == 'table' then
        for _, it in pairs(items) do push(it.name, it.label, it.count or it.amount, it.metadata) end
    end
    local okW, weapons = pcall(function() return exports.vorp_inventory:getUserInventoryWeapons(src) end)
    if okW and type(weapons) == 'table' then
        for _, w in pairs(weapons) do push(w.name, w.custom_label or w.name, 1, { weaponId = w.id, ammo = w.ammo }) end
    end
    return out
end

function Framework_CanCarryWeapons(src, count, cb, weaponHash)
    if HasVorpInventory() then exports.vorp_inventory:canCarryWeapons(src, count, cb, weaponHash) return end
    cb(true)
end

function Framework_CreateWeapon(src, weaponHash, cb, serial)
    if HasVorpInventory() then exports.vorp_inventory:createWeapon(src, weaponHash, {}, {}, {}, cb, nil, serial) return end
    if cb then cb(false) end
end

function Framework_RemoveWeapon(src, weaponHash)
    if HasVorpInventory() then exports.vorp_inventory:subWeapon(src, weaponHash) end
end

function Framework_OpenInventory(src, invId)
    if HasVorpInventory() then exports.vorp_inventory:openInventory(src, invId) end
end

function Framework_RegisterStash(config)
    if HasVorpInventory() then exports.vorp_inventory:registerInventory(config) end
end

function Framework_BlacklistItem(invId, itemName)
    if HasVorpInventory() then exports.vorp_inventory:BlackListCustomAny(invId, itemName) end
end

-- Removes one usable-item instance by its inventory main id (VORP keeps each
-- usable in its own row, so per-instance metadata / leftover-uses works).
function Framework_RemoveUsableInstance(src, mainid, count)
    if HasVorpInventory() and mainid then
        pcall(function() exports.vorp_inventory:subItemById(src, mainid, function() end, false, tonumber(count) or 1) end)
        return true
    end
    return false
end

-- Re-creates a usable-item instance with metadata (multi-use stash-mid-use flow).
function Framework_AddUsableInstance(src, itemName, count, metadata)
    if HasVorpInventory() then
        pcall(function() exports.vorp_inventory:addItem(src, itemName, tonumber(count) or 1, metadata or {}, function() end) end)
        return true
    end
    return false
end

function Framework_SetUsableMetadata(src, mainid, metadata)
    if HasVorpInventory() and src and mainid and type(metadata) == 'table' then
        pcall(function() exports.vorp_inventory:setItemMetadata(src, mainid, metadata, 1, function() end) end)
        return true
    end
    return false
end

function Framework_RegisterUsableItem(itemName, callback)
    if type(itemName) ~= 'string' or itemName == '' or type(callback) ~= 'function' then return false end
    if HasVorpInventory() then
        pcall(function() exports.vorp_inventory:registerUsableItem(itemName, callback, GetCurrentResourceName()) end)
        return true
    end
    return false
end

-- vorp_inventory builds its item list (ServerItems) once at boot from the
-- `items` table and never re-scans it — so an item created from the panel is in
-- the DB but vorp won't know about it (and shows it without the give/drop
-- actions) until vorp_inventory is restarted. There's no public export to
-- refresh that cache, so this just logs a reminder.
---@param itemName string
---@return boolean
function Framework_RefreshInventoryItem(itemName)
    if Logger then Logger.warn('framework', ('item "%s" created — restart vorp_inventory for it to appear in-game.'):format(tostring(itemName))) end
    return false
end

-- ============================================================================
-- ITEMS CATALOG — VORP keeps items in the `items` SQL table; the panel CRUDs it.
-- (On standalone there's no items table → the Items tab is hidden.)
-- ============================================================================

-- The panel only exposes the Items tab when item CRUD is wired (writable store).
function Framework_CanEditItems() return IsVorp() end

function Framework_GetItemsCatalog()
    if not IsVorp() then return {} end
    local ok, rows = pcall(function()
        return MySQL.query.await('SELECT `item`, `label`, `desc`, `weight`, `limit`, `can_remove`, `type`, `usable` FROM `items`')
    end)
    return (ok and type(rows) == 'table') and rows or {}
end

function Framework_ItemExists(itemName)
    if type(itemName) ~= 'string' or itemName == '' or not IsVorp() then return false end
    local ok, row = pcall(function() return MySQL.scalar.await('SELECT item FROM items WHERE item = ?', { itemName }) end)
    return ok and row ~= nil
end

-- data: { item, label, desc, weight, limit, can_remove, type, usable }
function Framework_CreateItem(data)
    if type(data) ~= 'table' or type(data.item) ~= 'string' or not IsVorp() then return false end
    return (pcall(function()
        local maxRow = MySQL.query.await('SELECT COALESCE(MAX(id), 0) AS maxid FROM items')
        local nextId = ((maxRow and maxRow[1] and tonumber(maxRow[1].maxid)) or 0) + 1
        MySQL.insert.await(
            'INSERT INTO items (id, item, label, `desc`, weight, `limit`, can_remove, `type`, usable) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
            { nextId, data.item, data.label or data.item, tostring(data.desc or ''),
              tonumber(data.weight) or 0.25, tonumber(data.limit) or 10,
              data.can_remove ~= false, data.type or 'item_standard', data.usable == true }
        )
    end))
end

function Framework_UpdateItem(itemName, data)
    if type(itemName) ~= 'string' or itemName == '' or type(data) ~= 'table' or not IsVorp() then return false end
    return (pcall(function()
        MySQL.update.await(
            'UPDATE items SET label = ?, `desc` = ?, weight = ?, `limit` = ?, can_remove = ?, `type` = ?, usable = ? WHERE item = ?',
            { data.label or itemName, tostring(data.desc or ''), tonumber(data.weight) or 0.25,
              tonumber(data.limit) or 10, data.can_remove ~= false, data.type or 'item_standard',
              data.usable == true, itemName }
        )
    end))
end

function Framework_DeleteItem(itemName)
    if type(itemName) ~= 'string' or itemName == '' or not IsVorp() then return false end
    return (pcall(function() MySQL.query.await('DELETE FROM items WHERE item = ?', { itemName }) end))
end

-- ============================================================================
-- JOB / GANG SYNC  (optional)
-- ----------------------------------------------------------------------------
-- VORP has no central job registry — a job is just a string on the character,
-- which lo_jobscreator sets directly via Framework_SetJob. If you run a separate
-- job-management resource that exposes upsert/delete exports, declare them in
-- Config.Framework.entityExports.vorp and panel-created jobs/gangs get pushed
-- there too:
--   Config.Framework.entityExports = {
--     vorp = { resource = 'my_jobs', upsertJob = 'AddJob', upsertGang = 'AddGang',
--              deleteJob = 'RemoveJob', deleteGang = 'RemoveGang' }
--   }
-- Leave it unset and these are no-ops.
-- ============================================================================

local function EntityExportCfg()
    local cfg = Config and Config.Framework and Config.Framework.entityExports
    cfg = cfg and cfg.vorp
    return type(cfg) == 'table' and cfg or nil
end

local function CallExport(resourceName, exportName, payload)
    if type(resourceName) ~= 'string' or resourceName == '' then return false end
    if type(exportName) ~= 'string' or exportName == '' then return false end
    if GetResourceState(resourceName) ~= 'started' then return false end
    return (pcall(function()
        local fn = exports[resourceName] and exports[resourceName][exportName]
        if type(fn) ~= 'function' then error('missing export ' .. resourceName .. ':' .. exportName) end
        fn(payload)
    end))
end

local function BuildEntityGrades(grades)
    local out = {}
    for gradeId, g in pairs(grades or {}) do
        local id = tonumber(gradeId) or tonumber(g.id) or 0
        out[tostring(id)] = { name = g.name or ('Grade ' .. id), payment = tonumber(g.payment) or 0, isboss = g.isboss == true }
    end
    return out
end

function Framework_UpsertEntity(entityType, name, label, data)
    if entityType ~= 'job' and entityType ~= 'gang' then return false end
    local cfg = EntityExportCfg()
    if not cfg then return false end
    return CallExport(cfg.resource, entityType == 'job' and cfg.upsertJob or cfg.upsertGang, {
        name = name, label = label or name, type = (data and data.type) or entityType,
        grades = BuildEntityGrades(data and data.grades or {}),
        defaultDuty = entityType == 'job' and true or nil,
        offDutyPay  = entityType == 'job' and false or nil,
    })
end

function Framework_DeleteEntity(entityType, name)
    if entityType ~= 'job' and entityType ~= 'gang' then return false end
    local cfg = EntityExportCfg()
    if not cfg then return false end
    return CallExport(cfg.resource, entityType == 'job' and cfg.deleteJob or cfg.deleteGang, { name = name, type = entityType })
end

-- VORP has no shared job/gang registry to import — lo_jobscreator owns them.
function Framework_GetAllEntities(_) return {} end
function Framework_GetAllJobs()  return {} end
function Framework_GetAllGangs() return {} end

function Framework_SyncAllEntities()
    if not EntityExportCfg() then return end
    if type(CreatedJobs) == 'table' then
        for n, e in pairs(CreatedJobs) do Framework_UpsertEntity('job', n, e.label or n, e.data or {}) end
    end
    if type(CreatedGangs) == 'table' then
        for n, e in pairs(CreatedGangs) do Framework_UpsertEntity('gang', n, e.label or n, e.data or {}) end
    end
end

AddEventHandler('lo_jobscreator:server:DataReady', function()
    if FrameworkBridge then FrameworkBridge.inventory = InvProvider() end
    Framework_SyncAllEntities()
end)

-- ============================================================================
-- CLOTHING — open the server's clothing resource for a player. Set the client
-- events in Config.Framework.clothing { openStore = 'evt', openWardrobe = 'evt' }.
-- ============================================================================

function Framework_OpenClothingStore(src, intData)
    local cfg = Config and Config.Framework and Config.Framework.clothing
    if not cfg or type(cfg.openStore) ~= 'string' or cfg.openStore == '' then return false end
    local payload
    if type(intData) == 'table' then
        payload = {}
        if intData.needInstance ~= nil then payload.needInstance = intData.needInstance and true or false end
        if intData.useOutfitMenu ~= nil then payload.useOutfitMenu = intData.useOutfitMenu and true or false end
    end
    TriggerClientEvent('lo_jobscreator:client:OpenClothingStore', src, payload)
    return true
end

function Framework_OpenWardrobe(src, intData)
    local cfg = Config and Config.Framework and Config.Framework.clothing
    if not cfg or type(cfg.openWardrobe) ~= 'string' or cfg.openWardrobe == '' then return false end
    local needInstance
    if type(intData) == 'table' and intData.needInstance ~= nil then needInstance = intData.needInstance and true or false end
    TriggerClientEvent('lo_jobscreator:client:OpenWardrobe', src, needInstance)
    return true
end

-- ============================================================================
-- NOTIFICATIONS — server → client toast. ox_lib if installed, else vorp:TipBottom.
-- Override the event in Config.Framework.notify.vorp = 'your:notify:event'.
-- ============================================================================

function Framework_NotifyClient(src, notifType, msg)
    local cfg = Config and Config.Framework and Config.Framework.notify
    local evt = cfg and cfg.vorp
    if type(evt) ~= 'string' or evt == '' then
        evt = (GetResourceState('ox_lib') == 'started') and 'ox_lib:notify' or 'vorp:TipBottom'
    end
    if evt == 'ox_lib:notify' then
        TriggerClientEvent(evt, src, { title = notifType, description = msg, type = notifType, duration = 5000 })
    elseif evt == 'vorp:TipBottom' then
        TriggerClientEvent(evt, src, msg, 5000)
    else
        TriggerClientEvent(evt, src, msg, notifType, 5000)
    end
end

-- ============================================================================
-- PLAYER LOADED — VORP fires `vorp:SelectedCharacter` when a character is
-- selected. Add your framework's equivalent here; it must call
-- QueueConnectedPlayerRefresh(src, delayMs) so OnPlayerReady fires once.
-- ============================================================================

AddEventHandler('vorp:SelectedCharacter', function(src)
    if type(QueueConnectedPlayerRefresh) == 'function' then QueueConnectedPlayerRefresh(src, 0) end
end)
