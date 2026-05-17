---@diagnostic disable: undefined-global, param-type-mismatch, unused-local, unused-function
-- ############################################################################
-- #                        EDITABLE FILE (CLIENT)                             #
-- #                                                                           #
-- #   Each function below is a HOOK called at specific moments on the         #
-- #   client side. Return false to cancel the action where indicated.         #
-- #                                                                           #
-- #   Available bridges (already wired, do not redefine):                     #
-- #     ShowMenu, ShowInput, Notify, GetPed, ServerCallback,                  #
-- #     ShowProgressBar, GetItemLabel, GetItemOptions, L, Config              #
-- ############################################################################

-- Called when a player starts a farm interaction (before progress bar)
-- Return false to cancel the interaction
function OnBeforeFarm(interactionData, entityType, entityName, intId)
    return true
end

-- Called after a farm interaction completes successfully
function OnAfterFarm(interactionData, entityType, entityName, intId)
end

-- Called when a player starts a sell interaction (before progress bar)
-- Return false to cancel the interaction
function OnBeforeSell(interactionData, entityType, entityName, intId)
    return true
end

-- Called after a sell interaction completes successfully
function OnAfterSell(interactionData, entityType, entityName, intId)
end

-- Called when a player starts a process interaction (before progress bar)
-- Return false to cancel the interaction
function OnBeforeProcess(interactionData, entityType, entityName, intId)
    return true
end

-- Called after a process interaction completes successfully
function OnAfterProcess(interactionData, entityType, entityName, intId)
end

-- Called when a player opens a craft menu
-- Return false to cancel
function OnBeforeCraft(interactionData, entityType, entityName, intId)
    return true
end

-- Called after a craft interaction completes successfully
function OnAfterCraft(interactionData, entityType, entityName, intId)
end

-- Called when a player opens a shop menu
-- Return false to cancel
function OnBeforeShop(interactionData, entityType, entityName, intId)
    return true
end

-- Called when a player starts a delivery
-- Return false to cancel
function OnBeforeDelivery(interactionData, entityType, entityName, intId)
    return true
end

-- Called when a delivery is completed
function OnAfterDelivery(interactionData, entityType, entityName, intId)
end

-- Called when a player goes on/off duty
-- duty: true = on duty, false = off duty
function OnDutyChanged(duty, jobName)
end

-- Called when a player opens a stash
-- Return false to cancel
function OnBeforeStash(interactionData, entityType, entityName, intId)
    return true
end

-- Called when a player opens a phone
function OnPhoneOpened(phoneData)
end

-- Called when a player uses any interaction (generic hook)
-- Return false to cancel the interaction
function OnBeforeInteraction(intType, interactionData, entityType, entityName, intId)
    return true
end

-- Called after any interaction completes (generic hook)
function OnAfterInteraction(intType, interactionData, entityType, entityName, intId)
end

-- ============================================================================
-- CHARACTER DATA OVERRIDES
-- By default, the script reads job/gang data from LocalPlayer.state.Character
-- which requires VORP Core modifications for gang support.
-- If your framework stores this data differently, override these functions.
-- Return nil to disable the feature.
-- ============================================================================

-- Override how the script gets the player's current job
-- Example: function GetCustomJob() return exports.myframework:GetJob() end
-- function GetCustomJob() return nil end

-- Override how the script gets the player's current gang
-- Example: function GetCustomGang() return exports.myframework:GetGang() end
-- function GetCustomGang() return nil end

-- Override how the script gets the player's current job grade
-- Example: function GetCustomGrade() return exports.myframework:GetGrade() end
-- function GetCustomGrade() return nil end

-- Override how the script gets the player's current gang grade
-- Example: function GetCustomGangGrade() return exports.myframework:GetGangGrade() end
-- function GetCustomGangGrade() return nil end

-- ============================================================================
-- NATIVE UI HOOKS (used when the player picks the "native" provider)
-- ============================================================================
-- The Settings panel exposes these providers: auto / ox_lib / vorp / jo_libs /
-- native. When a player picks `native`, the script calls the functions below
-- instead of the library implementations — define them here to plug in your own
-- menu / input / progress bar (a UI you coded, or your framework's menu API).
-- Leave them undefined and the script falls back to a minimal built-in version.

-- Native menu (single selectable list)
-- `opts` = { id, title, subtext, options = { { label, description, icon, args, disabled }, ... } }
-- Call `opts.onSelect(index, scrollIndex, args)` with the selected item's args.
-- Call `opts.onClose()` when the user cancels.
-- Example:
-- function NativeShowMenu(opts)
--     exports.my_menu:open(opts.options, function(selectedIndex)
--         opts.onSelect(selectedIndex, 1, opts.options[selectedIndex] and opts.options[selectedIndex].args)
--     end, function()
--         if opts.onClose then opts.onClose() end
--     end)
-- end

-- Native input dialog (modal form)
-- `opts` = { title, fields = { { type, label, default, min, max, options, required, ... }, ... } }
-- Must return an array of values in field order, or `nil` if cancelled.
-- Example:
-- function NativeShowInput(opts)
--     -- Call your framework's input here and return the values.
--     return nil
-- end

-- Native progress bar (waits duration ms, plays anim, supports cancel)
-- `opts` = { duration, label, dict, anim, flag, disable = { car, move, combat } }
-- Must return `true` if completed, `false` if cancelled.
-- Example (VORP variant with custom colors):
-- function NativeShowProgressBar(opts)
--     return exports.vorp_lib:progressStart({
--         text = opts.label,
--         duration = opts.duration,
--         type = 'circular',
--         position = { top = 85, left = 50 },
--     })
-- end

-- ============================================================================
-- CUSTOM FEATURE HOOKS (panel-driven extensions)
-- ============================================================================
-- When you add a new entry in the NUI Server Config -> Features panel, the key
-- you typed becomes an "extension point". Define a global function named
-- `OnFeature_<yourKey>` here and the script will invoke it whenever the
-- corresponding action fires.
--
-- For personal actions (Config.Actions entry with type = 'custom'), the hook
-- is called via CallFeatureHook(name, actionId, action) defined below.
--
-- Example:
--   1) Add feature 'actionPrintCoords' in the panel.
--   2) Add this Config.Actions entry in config.lua (or via panel later):
--        actionPrintCoords = {
--            label = 'Print my coords', icon = 'pin',
--            type = 'custom', hook = 'actionPrintCoords',
--            featureKey = 'actionPrintCoords',
--            allowedTypes = { 'leo' }, minGrade = 0,
--        }
--   3) Define your hook below:
--        function OnFeature_actionPrintCoords(actionId, action)
--            local p = GetEntityCoords(GetPed())
--            Notify('info', ('x=%.1f y=%.1f z=%.1f'):format(p.x, p.y, p.z))
--        end
function CallFeatureHook(name, ...)
    if type(name) ~= 'string' or name == '' then return end
    local fn = _G['OnFeature_' .. name]
    if type(fn) ~= 'function' then
        if Config and Config.Debug then
            print(('^3[lo_jobscreator] Missing hook OnFeature_%s in modules/editable/client.lua^0'):format(name))
        end
        return
    end
    local ok, err = pcall(fn, ...)
    if not ok then
        print(('^1[lo_jobscreator] Hook OnFeature_%s failed: %s^0'):format(name, tostring(err)))
    end
end

-- ============================================================================
-- DEFAULT PERSONAL ACTION HOOKS
-- ============================================================================
-- Each Config.Actions entry with `hook = 'xxx'` calls OnFeature_xxx below.
-- The hook receives:
--   * `target` — for type='target_player' this is the server-side player id;
--                for type='target_vehicle' this is the vehicle entity handle.
--                for type='self'/'client_event'/'server_event' it's nil.
--   * `actionId`, `action` — from the menu entry (see Config.Actions).
--
-- WIRE THESE TO YOUR OWN JOB SCRIPTS. The defaults below are placeholders —
-- replace the bodies with whatever your police / medic / mechanic scripts expose.
-- Delete a hook to fall back to the legacy event trigger (`action.event`).
-- ============================================================================

-- Every hook below is OPTIONAL. By default the personal menu calls the native
-- DefaultAction_<name> implementation shipped with the script (see
-- modules/actions/client.lua). Uncomment a hook and write your own body to
-- override the native behavior for a specific server setup.
--
-- Hook signature:
--   * target_player actions → (actionId, action, targetServerId)
--   * target_vehicle actions → (actionId, action, vehicleEntity)
--   * self / client_event / server_event → (actionId, action)
--
-- POLICE
-- function OnFeature_handcuff(actionId, action, targetId) end
-- function OnFeature_search(actionId, action, targetId) end
-- function OnFeature_fine(actionId, action, targetId) end
-- function OnFeature_escort(actionId, action, targetId) end
-- function OnFeature_putinvehicle(actionId, action, targetId) end
-- function OnFeature_pullout(actionId, action, targetId) end
--
-- MEDICAL
-- function OnFeature_revive(actionId, action, targetId) end
-- function OnFeature_heal(actionId, action, targetId) end
--
-- MECHANIC
-- function OnFeature_repair(actionId, action, vehicleEntity) end
--
-- BILLING — the native default opens lo_billing when installed.
-- function OnFeature_bills(actionId, action) end

-- ============================================================================
-- PERSONAL MENU KEY BINDING
-- ============================================================================
-- Called at resource start to register the key that opens the personal action menu.
-- Default: uses Config.ActionMenuKey (F7) via the internal lo_jobscreator key manager
-- (client/keys.lua). The player can rebind it in-game via the menu's first row.
--
-- Return true to opt out of the default registration (you took over the binding).
-- Return false/nil to let the default wiring take over.
--
-- Example — register via the internal API with a custom key and extra callback:
--
-- function RegisterPersonalMenuKey(openFn)
--     RegisterJcKey('personalmenu', 'Action menu', 'G', openFn)
--     return true
-- end
--
-- Example — just change the default key:
--
-- function RegisterPersonalMenuKey(openFn)
--     Config.ActionMenuKey = 'INSERT'
--     return false -- let default wiring pick up the new Config.ActionMenuKey
-- end
--
-- Available functions from the internal key manager (client/keys.lua):
--   RegisterJcKey(name, description, defaultKey, onDown, onUp)
--   SetJcKeyCode(name, newKey)     -- programmatically change a key
--   GetJcKeyName(name)             -- returns 'F7' etc. for the current binding
--   ResetJcKey(name)               -- restore the default
--   RebindJcKey(name, cb)          -- capture next keypress and bind it
--   ListJcKeys()                   -- list every registered key
--
---@diagnostic disable-next-line: unused-local
function RegisterPersonalMenuKey(openFn)
    return false
end

-- ============================================================================
-- DISPATCH MENU — open hook
-- ============================================================================
-- Fired when the player presses the dispatch key (Config.WitnessMenuKey,
-- default F6) or when an external resource fires the
-- `lo_jobscreator:client:openDispatchMenu` event. Define
-- `OnOpenDispatchMenu` here to plug in your own dispatch UI; otherwise the
-- script falls back to its built-in ox_lib menu (see
-- modules/witness/client.lua → DefaultOpenDispatchMenu).
--
-- The hook receives:
--   * `alerts`  — table of active alerts shared by the server, keyed by id:
--                 alerts[id] = {
--                     id, type, coords = {x,y,z}, message, title,
--                     time, takenBy = nil | { id, name }, takenAt
--                 }
--   * `helpers` — utility table wired to the script's internals:
--                 helpers.formatTimeAgo(seconds)        → "5min", "01:12", ...
--                 helpers.getLocationInfo(coords)       → name, icon
--                 helpers.takeAlert(id)                 → marks taken on the
--                                                         server, sets GPS,
--                                                         starts sonar
--                 helpers.clearAlert(id)                → clears for everyone
--                 helpers.startSonar(id, coords)        → GPS + sonar blip
--                 helpers.stopSonar(id)
--                 helpers.stopAllSonar()
--                 helpers.refresh()                     → ask server for fresh
--                                                         list (already done
--                                                         right before the hook
--                                                         fires)
--                 helpers.getAlerts()                   → same as `alerts`
--
-- ============================================================================
-- !!! ACTIVE — DEV-SERVER OVERRIDE (NOT FOR THE SOLD VERSION) !!!
-- ----------------------------------------------------------------------------
-- The block below routes lo_jobscreator dispatch alerts into the customized
-- ox_lib build shipped on the script author's server (RedM-adapted ox_lib
-- with a Police-Dispatch React panel + pinned/keyed notifications + a
-- lo_keysMapper-bound dispatch key).
--
-- The OPEN key is NOT defined here on purpose — the dev-server's ox_lib
-- already registers its own 'dispatch' key (default U) and 'cursorDispatch'
-- key (default J) via lo_keysMapper. Players rebind them in-game with
-- `/keysmenu`. Pressing the dispatch key directly calls
-- `lib.displayNotificationHistory('all')` inside ox_lib.
--
-- => IF YOU ARE A BUYER and your ox_lib does NOT have these features:
--    1. Comment out (or DELETE) the function below: OnDispatchAlertReceived
--       and the AddEventHandler('ox_lib:dispatchReplay', ...) below it.
--    2. The script falls back to the dependency-free default flow:
--          - alerts shown via vorp_core.NotifyTop / lib.notify / chat
--          - the dispatch menu opens via Config.WitnessMenuKey (uncomment
--            the block in config.lua) using the built-in ShowMenu UI.
-- => IF YOU WANT TO PLUG ANOTHER DISPATCH RESOURCE (ps-dispatch, cd_dispatch,
--    a custom NUI, ...): replace the body of OnDispatchAlertReceived with
--    your own export call. The helpers table is documented in the comment
--    block above.
-- ============================================================================

-- Hook: replace the default banner with a pinned ox_lib notification that has
-- accept/refuse keys AND auto-stores in the dispatch history panel (so the
-- player can press U to re-open it later).
function OnDispatchAlertReceived(alertData, helpers, ctx)
    -- Safety: if the host server's ox_lib does not have the dispatch features,
    -- return false so the default banner kicks in.
    if not (lib and lib.notify) then
        return false
    end

    local id = alertData.id
    local locationName = (ctx and ctx.locationName) or 'inconnue'
    -- Le titre embarque toujours la zone : c'est l'info la plus actionnable
    -- pour un FDO qui décide en 2 secondes s'il prend l'alerte (ex. un agent
    -- de Saint-Denis ne se déplace pas à Tumbleweed).
    local rawTitle = alertData.title or 'Alerte'
    local title = rawTitle .. ' — ' .. locationName
    -- La description conserve le message custom envoyé par le script déclencheur
    -- mais on suffixe la localisation s'il ne la mentionne pas déjà, sinon on
    -- la pose seule. Évite la perte d'info quand le script source set un
    -- alertData.message qui ne précise pas la zone.
    local description
    if alertData.message and alertData.message ~= '' then
        if locationName ~= 'inconnue' and not alertData.message:lower():find(locationName:lower(), 1, true) then
            description = alertData.message .. ' · ' .. locationName
        else
            description = alertData.message
        end
    else
        description = (L('dispatch_location_prefix') or 'Location:') .. ' ' .. locationName
    end

    -- Pattern MDT (md_lspdmdt/client/alert_hud.lua):
    --   * `type` is the JOB BUCKET ('police' / 'ems' / 'fire'). The dev-server's
    --     ox_lib has been extended so any of these types behaves like the
    --     legacy 'dispatch' bucket (pin + keys + auto-store). The React side
    --     colors 'police' red/blue automatically.
    --   * `keys[].key` is a SEMANTIC ID, not a keyboard letter. The cursor
    --     (J via lo_keysMapper) is what clicks them — the string itself is
    --     just a stable identifier passed back to the action callback and to
    --     the dispatch panel for replay routing (lib.setNotifKeyAction).
    lib.notify({
        id = 'lo_jc_alert_' .. tostring(id),
        type = (ctx and ctx.dispatchType) or 'police',
        title = title,
        description = description,
        coords = alertData.coords,                     -- stored so click-to-replay can re-set GPS
        pinned = true,                                 -- stays on screen until a key is pressed
        position = 'bottom-right',                     -- per-notif override (the patched ox_lib React reads it)
        dismissDelay = 5000,                           -- show "ACCEPTED"/"DECLINED" badge for 5s before fading out
        keys = {
            {
                key = 'ACCEPT',
                label = L('dispatch_accept') or 'Accept',
                dismiss = true,
                action = function()
                    helpers.takeAlert(id)              -- marks taken on server + auto GPS + sonar
                end,
            },
            { key = 'DECLINE', label = L('dispatch_decline') or 'Decline', dismiss = true },
        },
    })

    return true -- short-circuit the script's default banner.
end

-- When the player clicks an entry in the dispatch panel, ox_lib re-fires the
-- notification AND emits this event with the original payload (including
-- coords). Use it to re-arm the GPS waypoint so a stale alert is still usable
-- for navigation.
-- When the player clicks an entry in the dispatch panel, ox_lib re-fires the
-- pinned notification with a NEW id (`replayId`) and emits this event with
-- the original payload. The original action closures are gone — we re-bind
-- ACCEPT / DECLINE on the replayed id (same pattern as md_lspdmdt).
AddEventHandler('ox_lib:dispatchReplay', function(data, replayId)
    if not (data and data.coords and data.coords.x and replayId) then return end

    local x, y, z = data.coords.x + 0.0, data.coords.y + 0.0, (data.coords.z or 0.0) + 0.0

    if lib and lib.setNotifKeyAction then
        lib.setNotifKeyAction(replayId, 'ACCEPT', function()
            -- RedM has no SetNewWaypoint native — use the GPS multi-route
            -- system (purple line, same one the witness sonar uses).
            ClearGpsMultiRoute()
            ClearGpsCustomRoute()
            StartGpsMultiRoute(GetHashKey('COLOR_PURE_WHITE'), true, true)
            AddPointToGpsMultiRoute(x, y, z)
            SetGpsMultiRouteRender(true)
            Citizen.InvokeNative(0x64C59DD6834FA942, x, y, z)
        end)
        lib.setNotifKeyAction(replayId, 'DECLINE', function() end)
    end
end)

-- ============================================================================
-- DISPATCH PANEL — opened from the personal action menu (F7 → "Dispatch")
-- ============================================================================
-- Wired to Config.Actions.dispatch via featureKey = 'actionDispatch'. The
-- personal menu resolves the hook name as `OnFeature_<hook|featureKey>`, so
-- defining this here intercepts the click and opens the React dispatch panel
-- (the same one the legacy U key used to bind) instead of the script's
-- built-in ShowMenu list.
--
-- Pattern:
--   - resolve the player's job type (leo/medic/fire) → ox_lib bucket
--     ('police' / 'ems' / 'fire') so the panel only lists that branch's calls
--   - fall back to the legacy event flow if ox_lib was not patched (so a
--     buyer who dropped this resource into a vanilla ox_lib still gets
--     SOMETHING when they click Dispatch).
function OnFeature_actionDispatch(actionId, action)
    if not (lib and lib.displayNotificationHistory) then
        TriggerEvent('lo_jobscreator:client:openDispatchMenu')
        return
    end
    local map = (Config and Config.WitnessDispatchTypes)
        or { leo = 'police', medic = 'ems', fire = 'fire' }
    local character = LocalPlayer and LocalPlayer.state and LocalPlayer.state.Character
    local job = character and (character.Job or character.job)
    local rec = rawget(_G, 'CreatedJobs') and CreatedJobs[job]
    local jobType = rec and rec.data and rec.data.type
    local dispatchType = map[jobType] or 'police'
    lib.displayNotificationHistory(dispatchType)
end

-- ============================================================================
-- !!! END OF DEV-SERVER OVERRIDE — for sale, comment everything above this !!!
-- ============================================================================

-- ============================================================================
-- DISPATCH MENU — key binding override
-- ============================================================================
-- Symmetric with RegisterPersonalMenuKey above. Return true to opt out of the
-- default Config.WitnessMenuKey wiring (you took over the binding).
--
-- Available functions from the internal key manager (client/keys.lua):
--   RegisterJcKey(name, description, defaultKey, onDown, onUp)
--   SetJcKeyCode(name, newKey)     -- programmatically change a key
--   GetJcKeyName(name)             -- returns 'F6' etc. for the current binding
--   ResetJcKey(name)               -- restore the default
--   RebindJcKey(name, cb)          -- capture next keypress and bind it
--
-- Example — just change the default key:
-- function RegisterDispatchMenuKey(openFn)
--     Config.WitnessMenuKey = 'F8'
--     return false -- let default wiring pick up the new Config.WitnessMenuKey
-- end
--
-- Example — full takeover via the internal API with a custom key:
-- function RegisterDispatchMenuKey(openFn)
--     RegisterJcKey('dispatch', 'Open dispatch menu', 'G', openFn)
--     return true
-- end

-- ============================================================================
-- USABLE ITEMS — STAT MODIFIERS (client side)
-- ============================================================================
-- These hooks fire whenever a player uses a configured item from his
-- inventory. All deltas are signed integers (-100 .. 100 typical for
-- hunger/thirst/stress). Errors are caught with pcall by the caller so a
-- broken hook never crashes the use flow.
--
-- Default behavior auto-detects which HUD/metabolism resource is running and
-- routes the call to it. Order of precedence:
--
--   1. vorp_metabolism started -> vorp_metabolism (routed via its server event)
--   2. lo_hud started          -> lo_hud
--   3. nothing matches         -> no-op (wire your own below)
--
-- If your HUD is none of the above, replace the body of each hook with your
-- own export/event call. Examples:
--   * Statebag-based HUD:   LocalPlayer.state:set('hunger', value, true)
--   * Custom event:         TriggerEvent('my_hud:setHunger', delta)
--   * Custom export:        exports.my_hud:Hunger(delta)

local _hudCache
local function ResolveHud()
    if _hudCache ~= nil then return _hudCache end
    local function isUp(name) return GetResourceState(name) == 'started' end
    if isUp('vorp_metabolism') then _hudCache = 'vorp_metabolism'
    elseif isUp('lo_hud') then _hudCache = 'lo_hud'
    else _hudCache = 'none' end
    return _hudCache
end

local function ApplyHudStat(stat, delta, itemName)
    local hud = ResolveHud()
    if hud == 'vorp_metabolism' then
        -- vorp_metabolism stores stats server-side; route via server event.
        TriggerServerEvent('vorp_metabolism:server:setStatus', stat, delta)
    elseif hud == 'lo_hud' then
        if stat == 'hunger' then exports.lo_hud:SetHunger(delta, itemName)
        elseif stat == 'thirst' then exports.lo_hud:SetThirst(delta, itemName)
        elseif stat == 'stress' then exports.lo_hud:SetStress(delta, itemName) end
    end
end

---@param delta number  signed change to apply
---@param itemName string  technical id of the item triggering the change
function OnUsableHunger(delta, itemName)
    ApplyHudStat('hunger', delta, itemName)
end

---@param delta number
---@param itemName string
function OnUsableThirst(delta, itemName)
    ApplyHudStat('thirst', delta, itemName)
end

---@param delta number
---@param itemName string
function OnUsableStress(delta, itemName)
    ApplyHudStat('stress', delta, itemName)
end

-- Player health/stamina cores. Default uses the vanilla RDR2 native which
-- works on every framework. Override only if you persist cores server-side
-- (e.g. send to the server so the mod tracks it across reconnects).
---@param coreType 'health'|'stamina'
---@param delta number  -100..100 typical
---@param itemName string
---@diagnostic disable-next-line: unused-local
function OnUsablePlayerCore(coreType, delta, itemName)
    local ped = (cache and cache.ped) or PlayerPedId()
    local coreIndex = coreType == 'stamina' and 1 or 0
    local current = GetAttributeCoreValue(ped, coreIndex)
    local newValue = math.min(math.max(current + delta, 0), 100)
    Citizen.InvokeNative(0xC6258F41D86676E0, ped, coreIndex, newValue)
end

-- Horse cores. Same idea, default uses the native. `boostOverpower` is the
-- temporary core boost in 0..100 (overpower native), `boostTimer` is how
-- long it lasts (ms).
---@param mount number  horse entity handle
---@param coreType 'health'|'stamina'
---@param delta number
---@param itemName string
---@param opts { boostOverpower:number|nil, boostTimer:number|nil }|nil
---@diagnostic disable-next-line: unused-local
function OnUsableHorseCore(mount, coreType, delta, itemName, opts)
    if not mount or mount == 0 then return end
    local coreIndex = coreType == 'stamina' and 1 or 0
    if delta and delta ~= 0 then
        local current = GetAttributeCoreValue(mount, coreIndex)
        local newValue = math.min(math.max(current + delta, 0), 100)
        Citizen.InvokeNative(0xC6258F41D86676E0, mount, coreIndex, newValue)
    end
    if opts and opts.boostOverpower and opts.boostOverpower > 0 and opts.boostTimer and opts.boostTimer > 0 then
        Citizen.InvokeNative(0xF6A7C08DF2E28B28, mount, coreIndex, opts.boostOverpower * 1000.0, true)
        SetTimeout(opts.boostTimer, function()
            if DoesEntityExist(mount) then
                Citizen.InvokeNative(0xF6A7C08DF2E28B28, mount, coreIndex, 0.0, false)
            end
        end)
    end
end

-- Generic "an item was just consumed" hook called AFTER all stat hooks. Use
-- it to layer custom logic (XP gain, achievement progress, dispatch alert,
-- camp morale, ...). itemData is the full lo_item_usables row payload.
---@param itemName string
---@param itemData table  the row stored in lo_item_usables
---@diagnostic disable-next-line: unused-local
function OnUsableConsumed(itemName, itemData)
end

-- ============================================================================
-- USABLE ITEMS — TRIGGER-ONLY HOOK (non-consumable items)
-- ============================================================================
-- Fired when the player uses an item that has been flagged "Usable" but NOT
-- "Consumable" in the panel. Use it to wire scripted items: notepads,
-- walkie-talkies, custom weapons, instruments, lockpicks... The item is
-- NOT removed, NO animation runs, NO stats are modified — you decide.
--
-- Examples:
--   if itemName == 'walkietalkie' then exports.lo_radio:Toggle() end
--   if itemName == 'notepad' then TriggerEvent('lo_notepad:open') end
--   if itemName == 'lockpick' then exports.lo_lockpick:Start(mainid) end
---@param itemName string
---@param mainid number|string|nil
---@param itemData table  the row stored in lo_item_usables
---@diagnostic disable-next-line: unused-local
function OnUsableItemTrigger(itemName, mainid, itemData)
end
