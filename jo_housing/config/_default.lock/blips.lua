-- ===================================
-- Blips configuration
-- ===================================
-- Find other colors here : https://github.com/femga/rdr3_discoveries/tree/master/useful_info_from_rpfs/blip_modifiers

Config.blips = { -- Blip icons for houses on the map
    forSale = {  -- set to false to disable
        sprite = "blip_proc_home",
        color = "BLIP_MODIFIER_DEBUG_BLUE"
    },
    forRent = { -- set to false to disable
        sprite = "blip_proc_home",
        color = "BLIP_MODIFIER_DEBUG_YELLOW"
    },
    boughtByMe = {
        sprite = "blip_proc_home_locked",
        color = "BLIP_MODIFIER_DEBUG_GREEN"
    },
    boughtBySomeoneElse = {
        sprite = "blip_proc_home_locked",
        color = "BLIP_MODIFIER_DEBUG_RED"
    },
    rentedByMe = {
        sprite = "blip_proc_home_locked",
        color = "BLIP_MODIFIER_DEBUG_GREEN"
    },
    rentedBySomeoneElse = {
        sprite = "blip_proc_home_locked",
        color = "BLIP_MODIFIER_DEBUG_RED"
    }
}
