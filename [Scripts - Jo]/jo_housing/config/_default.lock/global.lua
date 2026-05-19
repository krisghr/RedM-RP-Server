-- ===================================
-- General Settings
-- ===================================

Config.enableKeyMode = false                   -- Enable physical house keys that players must carry to access their houses
Config.allowPayingInGold = false               -- Allow players to pay with gold in addition to money
Config.knockNotificationDuration = 5000        -- Duration (in ms) that knock notifications are displayed to house owners
Config.showInsideDoorMarker = true             -- While inside a house, show a marker on the ground near the entrance door
Config.distanceOutsideMarker = 10.0            -- Show a marker on the ground for each house near you (outside) (use 0 to turn OFF)
Config.showMloDoorsMarkers = false             -- Show markers on the ground for MLO and Zone house doors
Config.openManagerCommandName = "houseManager" -- The name of the command to open the house manager (ex: /houseManager)
Config.closeAllDoorsOnRestart = false          -- Wether to close all MLO and Zone  houses doors on server or script restart. If true, all doors will be closed. If false, doors will stay in the state they were before restart.

-- Default value for storage inventory
Config.storageConfig = {
    acceptWeapons = true,
    ignoreStackLimit = false
}

-- ===================================
-- Distance Settings
-- ===================================

Config.distanceShowHousePrompt = 2.0            -- Distance (in meters) to show house interaction prompts
Config.distanceShowStablePrompt = 2.0           -- Distance (in meters) to show stable interaction prompts
Config.distanceShowWagonPrompt = 2.0            -- Distance (in meters) to show wagon interaction prompts

Config.distanceShowInteriorDoorPrompt = 2.5     -- Distance (in meters) to show interior door prompts
Config.distanceShowInteriorStoragePrompt = 1.0  -- Distance (in meters) to show storage interaction prompts
Config.distanceShowInteriorDressingPrompt = 1.0 -- Distance (in meters) to show dressing room prompts

-- ===================================
-- External Handlers
-- ===================================

-- ⚠️ Stable, Wagon and Wardrobe are not included. You have to link them with your other scripts.

Config.openWardrobe = function()
    -- Add your Wardrobe handling code here
    -- This could call another resource's export for wardrobe management
    -- ex : exports["jo_clothingstore"]:openWardrobe()
    print("Config.openWardrobe must be configured to integrate with your wardrobe system")
end

Config.openStable = function(stableLocation, stableSpawnLocation)
    -- Add your stable handling code here
    -- This could call another resource's export for stable management
    -- TriggerEvent("your_stable_resource:openStable")
    print("Config.openStable must be configured to integrate with your stable system")
end

Config.openWagon = function(wagonLocation, wagonSpawnLocation)
    -- Add your wagon handling code here
    -- This could call another resource's export for wagon management
    -- TriggerEvent("your_wagon_resource:openWagon")
    print("Config.openWagon must be configured to integrate with your wagon system")
end
