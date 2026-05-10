-- ===================================
-- Furniture Configuration
-- ===================================

-- Available furniture categories: beds, carpets, cabinets, chairs, tables, desks, fireplaces, lamps, plants, sofas, wall_decorations, decorations, bathroom, kitchen, food, curtains

-- Default pricing for furniture categories
Config.furnituresCategoriesPrices = {
    default = { -- Default pricing for furniture categories
        money = 100,
        gold = 1
    },
    beds = { -- example : Pricing for bed category furniture
        money = 50,
        gold = 2
    }
}

-- Specific pricing per furniture model
Config.furnituresPrices = {
    p_bath02x = { -- Specific pricing per furniture model
        money = 200,
        gold = 10
    }
}

-- Add actions when near a specific furniture
Config.furnituresActions = {
    [`p_bath02bx`] = {
        prompt = "Use bath",
        distance = 2.0,
        action = function()
            -- example : print("hello bathtub")
        end
    },
    [`p_stove01x`] = {
        prompt = "Use stove",
        distance = 2.0,
        action = function()
            -- example : print("hello stove")
        end
    }
}
