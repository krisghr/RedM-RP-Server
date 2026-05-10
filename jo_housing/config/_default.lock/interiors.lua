-- ===================================
-- Interior Configuration
-- ===================================

Config.mloMaxFurnitures = 100 -- MLO and Zone Houses max furnitures inside

-- Available interior categories: shack, rock_shack, house, flat, manor, worker
-- Default furniture limit for interior categories
Config.interiorsCategoriesMaxFurnitures = {
    default = 100, -- Default furniture limit for interior categories
    manor = 200    -- example : Furniture limit for manor category interiors
}

-- Specific furniture limits per interior ID
Config.interiorsMaxFurnitures = {
    jo_pai_house = 100,
}

-- Interior IDs to hide from selection (commented examples included)
Config.interiorsBlacklist = {
    -- jo_pai_house = true,
    -- jo_new_gamble = true
}
