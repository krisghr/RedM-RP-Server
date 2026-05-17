---@diagnostic disable: undefined-global, param-type-mismatch
-- ############################################################################
-- #                        EDITABLE FILE (SERVER)                             #
-- #                                                                           #
-- #   Each function below is a HOOK called at specific moments on the         #
-- #   server side. Return false to cancel the action where indicated.         #
-- #                                                                           #
-- #   Available helpers (already wired, do not redefine):                     #
-- #     AddItem, RemoveItem, HasItem, NotifyClient, Log,                      #
-- #     HasPermission, GetDailyUses, GetTotalUses, L, Config                  #
-- ############################################################################

-- Called before any UseInteraction is processed server-side
-- src: player source, entityType: 'job'/'gang'/'public', intType: interaction type
-- Return false to cancel the interaction
function OnBeforeUseInteraction(src, entityType, entityName, intId, intType)
    return true
end

-- Called after a UseInteraction is processed server-side
function OnAfterUseInteraction(src, entityType, entityName, intId, intType)
end

-- Called when a job is created
function OnJobCreated(jobName, jobLabel, jobData)
end

-- Called when a job is deleted
function OnJobDeleted(jobName)
end

-- Called when a gang is created
function OnGangCreated(gangName, gangLabel, gangData)
end

-- Called when a gang is deleted
function OnGangDeleted(gangName)
end

-- Called when an interaction is created
function OnInteractionCreated(entityType, entityName, intType, intId, data)
end

-- Called when an interaction is deleted
function OnInteractionDeleted(entityType, entityName, intId)
end

-- Called when a player receives salary
-- Return a modified amount to change the salary, or nil to keep default
function OnSalaryPaid(src, entityType, entityName, grade, amount)
    return amount
end

-- Called when a player connects and selects character
function OnPlayerReady(src, job, gang)
end

-- Called when a player disconnects
function OnPlayerDropped(src)
end

-- Custom permission check (called in addition to Config.PermissionGroup check)
-- Return true to grant access, false to deny, nil to use default behavior
function CustomPermissionCheck(src)
    return nil
end

-- ============================================================================
-- CLOTHING STORE / WARDROBE
-- ============================================================================
-- Called when a player uses a `clothing_store` interaction. Trigger your
-- clothing resource here. Return `true` when handled — the script will stop
-- processing and skip the Config.Framework.clothing.openStore fallback.
-- Return nil / false to let the script fall through to the Config event.
--
-- Example (vorp_clothing):
-- function CustomOpenClothingStore(src)
--     TriggerClientEvent('vorp_clothing:OpenMenu', src)
--     return true
-- end
function CustomOpenClothingStore(src)
    return nil
end

-- Same as above but for `clothing_wardrobe` interactions (personal closet).
function CustomOpenWardrobe(src)
    return nil
end

-- ============================================================================
-- CUSTOM FEATURE HOOKS (panel-driven extensions, server-side)
-- ============================================================================
-- Mirror of CallFeatureHook on client, executed when a custom server event is
-- triggered for a custom feature. Define `OnFeature_<key>(src, ...)` here, then
-- TriggerServerEvent('lo_jobscreator:server:CallFeatureHook', '<key>', ...)
-- from the client. The script will dispatch automatically.
function CallFeatureHook(name, ...)
    if type(name) ~= 'string' or name == '' then return end
    local fn = _G['OnFeature_' .. name]
    if type(fn) ~= 'function' then
        if Config and Config.Debug then
            print(('^3[lo_jobscreator] Missing server hook OnFeature_%s in modules/editable/server.lua^0'):format(name))
        end
        return
    end
    local ok, err = pcall(fn, ...)
    if not ok then
        print(('^1[lo_jobscreator] Server hook OnFeature_%s failed: %s^0'):format(name, tostring(err)))
    end
end

RegisterNetEvent('lo_jobscreator:server:CallFeatureHook', function(name, ...)
    local src = source
    CallFeatureHook(name, src, ...)
end)

-- ============================================================================
-- USABLE ITEMS — INVENTORY HOOKS (server side)
-- ============================================================================
-- Override these to plug a custom inventory provider when neither
-- vorp_inventory nor ox_inventory matches your setup. Default
-- implementations call Framework_RemoveUsableInstance / Framework_SetUsableMetadata
-- which already cover both popular providers.
--
-- ConsumeUsableItem fires when the player has finished the use animation
-- (or, for one-shot types, before the animation starts so the item is
-- gone even if the player disconnects mid-use). Return `true` to skip the
-- default implementation; nil/false = run the default after this.

---@param src number  player server id
---@param itemName string
---@param mainid number|string|nil  inventory main id of the consumed instance
---@diagnostic disable-next-line: unused-local
function OnUsableItemConsume(src, itemName, mainid)
    -- Example for a custom inventory:
    --   exports.my_inventory:RemoveItem(src, itemName, 1, mainid)
    --   return true
    return false
end

---@param src number
---@param mainid number|string|nil
---@param metadata table  { currentUses: number, description: string, ... }
---@diagnostic disable-next-line: unused-local
function OnUsableItemMetadata(src, mainid, metadata)
    -- Example:
    --   exports.my_inventory:SetMetadata(src, mainid, metadata)
    --   return true
    return false
end

-- Server-side counterpart of OnUsableItemTrigger. Fires when the player
-- uses a non-consumable item (e.g. lockpick, notepad). Item is NOT removed.
-- Example:
--   if itemName == 'lockpick' then
--       exports.lo_lockpick:StartFor(src)
--   end
---@param src number  player server id
---@param itemName string
---@param mainid number|string|nil
---@diagnostic disable-next-line: unused-local
function OnUsableItemTriggerServer(src, itemName, mainid)
end
