-- ===================================
-- Key Bindings
-- ===================================

-- Find all usable keys here : https://docs.jumpon-studios.com/jo_libs/modules/raw-keys/client#keys

Config.keys = {

    openHouseMenu = "E",  -- Open house menu at front door
    enterSubMenu = "E",   -- Enter submenus
    buyDollar = "ENTER",  -- Purchase house with money
    buyGold = "G",        -- Purchase house with gold
    knockOnHouse = "K",   -- Knock on someone's door
    enterHouse = "ENTER", -- Enter owned house
    leaveHouse = "R",     -- Exit house
    manageHouse = "M",    -- Open house management menu


    enterVisitMode = "R",     -- Enter visit mode to preview interior
    hideMenu = "C",           -- Hide menu
    setHousePriceMoney = "M", -- Set money price prompt
    setHousePriceGold = "G",  -- Set gold price prompt
    editHouse = "E",          -- Edit existing house
    deleteHouse = "R",        -- Delete house


    setStorageLocation = "O",   -- Set storage location in build mode
    setDressingLocation = "K",  -- Set dressing room location in build mode
    openStorage = "E",          -- Open house storage
    openDressing = "E",         -- Open dressing room
    furnitureAction = "E",      -- Use furniture action

    addFurnitures = "A",        -- Add furniture to house
    editFurnitures = "E",       -- Edit existing furniture
    duplicateFurniture = "C",   -- Duplicate selected furniture
    deleteFurniture = "DELETE", -- Delete selected furniture
    buyFurniture = "ENTER",     -- Purchase furniture
    leaveBuildMode = "R",       -- Exit build mode


    addPlayer = "ENTER", -- Add player to house access list
    removePlayer = "R",  -- Remove player from access list
    enter = "ENTER",     -- Generic enter/confirm key

    -- ------------ ⚠️ USE NATIVE KEYS BELOW ⚠️ --------------

    -- Find all controls here : https://github.com/femga/rdr3_discoveries/tree/master/Controls

    addPointKey = `INPUT_CONTEXT_RT`,            -- Add point to zone
    heightUpKey = `INPUT_GAME_MENU_TAB_LEFT`,    -- Increase height of zone
    heightDownKey = `INPUT_GAME_MENU_TAB_RIGHT`, -- Decrease height of zone
    createZoneKey = `INPUT_FRONTEND_ACCEPT`,     -- Create zone
    deletePointKey = `INPUT_FRONTEND_RS`         -- Delete point of zone
}
