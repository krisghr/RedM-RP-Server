-- Global animation duration deductor (in milliseconds)
local AnimationDurationDeductor = -350

Config.Animations = {
    ["holstergrip"]           = {
        type = "solo",
        name = "Holster Grip",
        animation = {
            dict = "mech_inventory@equip@fallback@first_person@unarmed@belt_melee@blade_long_gesture",
            name = "unholster",
            flag = 25,
            upperBody = true,
            filter = "rightarmonly_filter",
            freezeAt = 300
        }
    },
    ["holdbars"] = {
        type = "solo",
        name = "Hold Bars",
        animation = {
            dict = "script_proc@robberies@unapproved",
            name = "stand_prisoner_cell_idle_a",
            flag = 1,
        }
    },
    ["raisearm"]              = {
        type = "solo",
        name = "Sword Pose",
        animation = {
            dict = "script_shows@sworddance@act3_p1",
            name = "dancer_sworddance",
            flag = 25,
            upperBody = true,
            filter = "rightarmonly_filter",
            freezeAt = 50
        }
    },
    ["swordpose"]             = {
        type = "solo",
        name = "Sword Pose",
        animation = {
            dict = "script_shows@sworddance@act3_p1",
            name = "dancer_sworddance",
            flag = 1,
            upperBody = false,
            freezeAt = 500
        }
    },
    ["swordplaying1"]         = {
        type = "solo",
        name = "Sword Playing 1",
        animation = {
            dict = "cnv_camp@rchso@cnv@ccjck3",
            name = "jack_sword_base",
            flag = 1,
            upperBody = false
        }
    },
    ["swordplaying2"]         = {
        type = "solo",
        name = "Sword Playing 2",
        animation = {
            dict = "cnv_camp@rchso@cnv@ccjck3",
            name = "john_sword_base",
            flag = 1,
            upperBody = false
        }
    },
    ["pee"]                   = {
        type = "solo",
        name = "Pee",
        animation = {
            dict = "amb_misc@world_human_pee@male_a@idle_a",
            name = "idle_a",
            flag = 1
        }
    },
    ["pee2"]                  = {
        type = "solo",
        name = "Pee 2",
        animation = {
            dict = "amb_misc@world_human_pee@male_a@idle_a",
            name = "idle_b",
            flag = 1
        }
    },
    ["pee3"]                  = {
        type = "solo",
        name = "Pee 3",
        animation = {
            dict = "amb_misc@world_human_pee@male_a@idle_a",
            name = "idle_c",
            flag = 1
        }
    },
    ["pee4"]                  = {
        type = "solo",
        name = "Pee 4",
        animation = {
            dict = "amb_misc@world_human_pee@male_a@idle_b",
            name = "idle_d",
            flag = 1
        }
    },
    ["pee5"]                  = {
        type = "solo",
        name = "Pee 5",
        animation = {
            dict = "amb_misc@world_human_pee@male_a@idle_b",
            name = "idle_e",
            flag = 1
        }
    },
    ["pee6"]                  = {
        type = "solo",
        name = "Pee 6",
        animation = {
            dict = "amb_misc@world_human_pee@male_a@idle_b",
            name = "idle_f",
            flag = 1
        }
    },
    ["pee7"]                  = {
        type = "solo",
        name = "Pee 7",
        animation = {
            dict = "amb_misc@world_human_pee@male_a@idle_c",
            name = "idle_g",
            flag = 1
        }
    },
    ["pee8"]                  = {
        type = "solo",
        name = "Pee 8",
        animation = {
            dict = "amb_misc@world_human_pee@male_a@idle_c",
            name = "idle_h",
            flag = 1
        }
    },
    ["bandage"]               = {
        type = "solo",
        name = "Bandage Fast",
        animation = {
            dict = "mini_games@story@mob4@heal_jules@bandage@arthur",
            name = "bandage_fast",
            flag = 1
        }
    },
    ["doctor"]                = {
        type = "solo",
        name = "Bandage Idle",
        animation = {
            dict = "mini_games@story@mob4@heal_jules@bandage@arthur",
            name = "bandage_idle",
            flag = 1
        }
    },
    ["takeoffercard"]         = {
        type = "solo",
        name = "Take Offer",
        animation = {
            dict = "cnv_camp@handover@dark_alley_stab@handover",
            name = "take_offer_victim",
            flag = 28,
            upperBody = true,
            filter = "rightarmonly_filter"
        },
    },
    ["inspect"]               = {
        type = "solo",
        name = "Inspect Item",
        animation = {
            dict = "mech_inventory@item@_templates@card@w6-5_h10-7@unarmed@base",
            name = "inspect_base",
            flag = 1
        }
    },
    ["talk1"]                 = {
        type = "solo",
        name = "Talk 1",
        animation = {
            dict = "script_ca@carust@02@ig@ig8_unclewaitgate",
            name = "lockpick_idle_02_uncle",
            flag = 25,
            upperBody = true,
            filter = "botharms_filter"
        }
    },
    ["talk2"]                 = {
        type = "solo",
        name = "Talk 2",
        animation = {
            dict = "script_ca@carust@02@ig@ig8_unclewaitgate",
            name = "lockpick_idle_01_uncle",
            flag = 25,
            upperBody = true,
            filter = "botharms_filter"
        }
    },
    ["talk3"]                 = {
        type = "solo",
        name = "Talk 3",
        animation = {
            dict = "script_ca@carust@02@ig@ig8_unclewaitgate",
            name = "lockpick_success_exit_uncle",
            flag = 25,
            upperBody = true,
            filter = "botharms_filter"
        }
    },
    ["crouchenter"]           = {
        type = "solo",
        name = "Crouch Enter",
        animation = {
            dict = "script_proc@rustling@unapproved@gate_lockpick",
            name = "enter",
            flag = 2
        }
    },
    ["crouch"]                = {
        type = "solo",
        name = "Crouch",
        animation = {
            dict = "script_proc@rustling@unapproved@gate_lockpick",
            name = "base",
            flag = 1
        }
    },
    ["dance1"]                = {
        type = "solo",
        name = "Dance: Lead",
        animation = {
            dict = "cnv_camp@rchso@cnv@ccdtc33@player_karen",
            name = "arthur_dance_loop",
            flag = 1
        }
    },
    ["dance2"]                = {
        type = "solo",
        name = "Dance: Follow",
        animation = {
            dict = "cnv_camp@rchso@cnv@ccdtc33@player_karen",
            name = "karen_dance_loop",
            flag = 1
        }
    },
    ["dogbarkground"]         = {
        type = "solo",
        name = "Dog: Bark on Ground",
        animation = {
            dict = "amb_creature_mammal@world_dog_barking_ground@base",
            name = "base",
            flag = 1
        },
        dogemote = true
    },
    ["dogbarkup"]             = {
        type = "solo",
        name = "Dog: Bark Up",
        animation = {
            dict = "amb_creature_mammal@world_dog_barking_up@base",
            name = "base",
            flag = 1
        },
        dogemote = true
    },
    ["dogbeg"]                = {
        type = "solo",
        name = "Dog: Beg",
        animation = {
            dict = "amb_creature_mammal@world_dog_begging@idle",
            name = "idle_a",
            flag = 1
        },
        dogemote = true
    },
    ["dogrest"]               = {
        type = "solo",
        name = "Dog: Rest",
        animation = {
            dict = "amb_creature_mammal@world_dog_resting@base",
            name = "base",
            flag = 1
        },
        dogemote = true
    },
    ["dogroll"]               = {
        type = "solo",
        name = "Dog: Roll",
        animation = {
            dict = "amb_creature_mammal@world_dog_roll_ground@base",
            name = "base",
            flag = 1
        },
        dogemote = true
    },
    ["dogsit"]                = {
        type = "solo",
        name = "Dog: Sit",
        animation = {
            dict = "amb_creature_mammal@world_dog_sitting@base",
            name = "base",
            flag = 1
        },
        dogemote = true
    },
    ["dogsleep"]              = {
        type = "solo",
        name = "Dog: Sleep",
        animation = {
            dict = "amb_creature_mammal@world_dog_sleeping@base",
            name = "base",
            flag = 1
        },
        dogemote = true
    },
    ["dogsniff"]              = {
        type = "solo",
        name = "Sniff",
        animation = {
            dict = "amb_creature_mammal@world_dog_sniffing_ground@base",
            name = "base",
            flag = 1
        },
        dogemote = true
    },
    ["dogwagtail"]            = {
        type = "solo",
        name = "Dog: Wag Tail",
        animation = {
            dict = "creatures_mammal@dog_pers@happy@idle",
            name = "idle",
            flag = 1
        },
        dogemote = true
    },
    ["handsup"]               = {
        type = "solo",
        name = "Hands Up",
        animation = {
            dict = "script_proc@robberies@homestead@lonnies_shack@deception",
            name = "hands_up_loop",
            flag = 25,
            upperBody = true,
            filter = "arms_filter"
        }
    },
    ["pet1"]                  = {
        type = "solo",
        name = "Pet",
        animation = {
            dict = "mech_animal_interaction@dog@patting@1h",
            name = "base",
            flag = 1
        }
    },
    ["throwstones"]           = {
        type = "solo",
        name = "Throw Stones",
        animation = {
            dict = "amb_misc@world_human_skip_rocks@male_b@wip_base",
            name = "wip_base",
            flag = 1
        }
    },
    ["sniff"]                 = {
        type = "solo",
        name = "Deep Breath",
        animation = {
            dict = "script_mp@emotes@sniffing@male@unarmed@upper",
            name = "action_alt1",
            flag = 4
        }
    },
    ["cough"]                 = {
        type = "solo",
        name = "Cough",
        animation = {
            dict = "amb_wander@upperbody_idles@miner@right_hand@male_a@idle_a",
            name = "idle_a",
            flag = 28,
            upperBody = true
        }
    },
    ["grandpawalk"]           = {
        type = "solo",
        name = "Grandpa Walk",
        animation = {
            dict = "script_common@other@unapproved",
            name = "gped_host_sit_idl",
            flag = 25,
        }
    },
    ["hostagesit"]            = {
        type = "solo",
        name = "Hostage Sit",
        animation = {
            dict = "script_common@other@unapproved",
            name = "gped_host_sit_idl",
            flag = 1
        }
    },
    ["aimgun1"]               = {
        type = "solo",
        name = "Aim Gun 1",
        animation = {
            dict = "script_story@ntv2@leadout@mcs3",
            name = "idle_soldier1",
            flag = 1
        }
    },
    ["aimgun2"]               = {
        type = "solo",
        name = "Aim Gun 2",
        animation = {
            dict = "script_story@ntv2@leadout@mcs3",
            name = "idle_soldier2",
            flag = 1
        }
    },
    ["aimgun3"]               = {
        type = "solo",
        name = "Aim Gun 3",
        animation = {
            dict = "script_story@ntv2@leadout@mcs3",
            name = "idle_soldier6",
            flag = 1
        }
    },
    ["aimgun4"]               = {
        type = "solo",
        name = "Aim Gun 4",
        animation = {
            dict = "ai_combat@poses@military@2h@kneeling",
            name = "military_2h_aim_kneel",
            flag = 1
        }
    },
    ["aimgun1upper"]          = {
        type = "solo",
        name = "Aim Gun 1 Upper",
        animation = {
            dict = "script_story@ntv2@leadout@mcs3",
            name = "idle_soldier1",
            flag = 25,
            upperBody = true,
            filter = "rightarmonly_filter"
        }
    },
    ["aimgun2upper"]          = {
        type = "solo",
        name = "Aim Gun 2 Upper",
        animation = {
            dict = "script_story@ntv2@leadout@mcs3",
            name = "idle_soldier2",
            flag = 25,
            upperBody = true,
            filter = "rightarmonly_filter"
        }
    },
    ["aimgun3upper"]          = {
        type = "solo",
        name = "Aim Gun 3 Upper",
        animation = {
            dict = "script_story@ntv2@leadout@mcs3",
            name = "idle_soldier6",
            flag = 25,
            upperBody = true,
            filter = "rightarmonly_filter"
        }
    },
    ["aimgun4upper"]          = {
        type = "solo",
        name = "Aim Gun 4 Upper",
        animation = {
            dict = "ai_combat@poses@military@2h@kneeling",
            name = "military_2h_aim_kneel",
            flag = 25,
            upperBody = true,
            filter = "rightarmonly_filter"
        }
    },
    ["riflewalk"]             = {
        type = "solo",
        name = "riflewalk",
        animation = {
            dict = "amb_work@world_human_guard@military@male_b@idle_c",
            name = "idle_g",
            flag = 25,
            upperBody = true,
            filter = "rightarmonly_filter"
        }
    },
    ["rifleidle"]             = {
        type = "solo",
        name = "rifleidle",
        animation = {
            dict = "amb_work@world_human_guard@military@male_b@idle_d",
            name = "idle_j",
            flag = 25,
            upperBody = true,
            filter = "rightarmonly_filter"
        }
    },
    ["riflehold"]             = {
        type = "solo",
        name = "Rifle Walk",
        animation = {
            dict = "amb_work@world_human_guard@military@male_c@idle_b",
            name = "idle_e",
            flag = 25,
            upperBody = true,
            filter = "arms_filter"
        }
    },
    ["silly"]                 = {
        type = "solo",
        name = "Silly Run",
        animation = {
            dict = "script_common@shared_scenarios@stand@random@town_burial@preacher@d@react_look@loop@low",
            name = "back_left_bible",
            flag = 25
        }
    },
    ["holster"]               = {
        type = "solo",
        name = "Hand on holster",
        animation = {
            dict = "mech_loco_m@character@slim_grant@normal@unarmed@idle@variations@touchholster",
            name = "idle",
            flag = 25
        }
    },
    ["punch2"]                = {
        type = "solo",
        name = "Punch (Loop)",
        animation = {
            dict = "script_common@other@unapproved",
            name = "plyr_punch",
            flag = 25
        }
    },
    ["prone"]                 = {
        type = "solo",
        name = "Prone",
        animation = {
            dict = "script_common@other@unapproved",
            name = "prone_michael",
            flag = 1
        }
    },

    -- Shared emotes
    -- ADD SLAPPING ANIMATIONS, FROM LENNY SLAPS PLAYER(ARTHUR) MINIGAME DICTS
    ["slap1"]                 = {
        type = "shared",
        name = "Slap (shared)",
        animation = {
            dict = "script_story@sal1@ig@sal1_ig3_slap_game",
            name = "arthur_slaps_01_arthur",
            flag = 4,
            duration = 2000,
            dontAttach = true
        },
        partner = {
            offset = vector4(-0.3, 0.9, 0, 180),
            animation = {
                dict = "script_story@sal1@ig@sal1_ig3_slap_game",
                name = "arthur_slaps_01_lenny",
                flag = 4,
                duration = 2000,
                dontAttach = true
            }
        }
    },
    ["slap2"]                 = {
        type = "shared",
        name = "Slap (shared)",
        animation = {
            dict = "script_story@sal1@ig@sal1_ig3_slap_game",
            name = "arthur_slaps_02_arthur",
            flag = 4,
            duration = 2000,
            dontAttach = true
        },
        partner = {
            offset = vector4(-0.3, 0.9, 0, 180),
            animation = {
                dict = "script_story@sal1@ig@sal1_ig3_slap_game",
                name = "arthur_slaps_02_lenny",
                flag = 4,
                duration = 2000,
                dontAttach = true
            }
        }
    },

    ["slap3"]                 = {
        type = "shared",
        name = "Slap (shared)",
        animation = {
            dict = "script_story@sal1@ig@sal1_ig3_slap_game",
            name = "arthur_slaps_03_arthur",
            flag = 4,
            duration = 2000,
            dontAttach = true
        },
        partner = {
            offset = vector4(-0.3, 0.9, 0, 180),
            animation = {
                dict = "script_story@sal1@ig@sal1_ig3_slap_game",
                name = "arthur_slaps_03_lenny",
                flag = 4,
                duration = 2000,
                dontAttach = true
            }
        }
    },

    ["slap4"]                 = {
        type = "shared",
        name = "Slap (shared)",
        animation = {
            dict = "script_story@sal1@ig@sal1_ig3_slap_game",
            name = "arthur_slaps_04_arthur",
            flag = 4,
            duration = 2000,
            dontAttach = true
        },
        partner = {
            offset = vector4(-0.3, 0.9, 0, 180),
            animation = {
                dict = "script_story@sal1@ig@sal1_ig3_slap_game",
                name = "arthur_slaps_04_lenny",
                flag = 4,
                duration = 2000,
                dontAttach = true
            }
        }
    },

    ["slap5"]                 = {
        type = "shared",
        name = "Slap (shared)",
        animation = {
            dict = "script_story@sal1@ig@sal1_ig3_slap_game",
            name = "arthur_slaps_05_arthur",
            flag = 4,
            duration = 2000,
            dontAttach = true
        },
        partner = {
            offset = vector4(-0.3, 0.9, 0, 180),
            animation = {
                dict = "script_story@sal1@ig@sal1_ig3_slap_game",
                name = "arthur_slaps_05_lenny",
                flag = 4,
                duration = 2000,
                dontAttach = true
            }
        }
    },

    ["slap6"]                 = {
        type = "shared",
        name = "Slap (shared)",
        animation = {
            dict = "script_story@sal1@ig@sal1_ig3_slap_game",
            name = "arthur_slaps_06_arthur",
            flag = 4,
            duration = 2000,
            dontAttach = true
        },
        partner = {
            offset = vector4(-0.3, 0.9, 0, 180),
            animation = {
                dict = "script_story@sal1@ig@sal1_ig3_slap_game",
                name = "arthur_slaps_06_lenny",
                flag = 4,
                duration = 2000,
                dontAttach = true
            }
        }
    },

    ["slap7"]                 = {
        type = "shared",
        name = "Slap (shared)",
        animation = {
            dict = "script_story@sal1@ig@sal1_ig3_slap_game",
            name = "lenny_slaps_01_lenny",
            flag = 4,
            duration = 4000,
            dontAttach = true
        },
        partner = {
            offset = vector4(-0.3, 0.9, 0, -160),
            animation = {
                dict = "script_story@sal1@ig@sal1_ig3_slap_game",
                name = "lenny_slaps_01_arthur",
                flag = 4,
                duration = 4000,
                dontAttach = true
            }
        }
    },
    ["slap8"]                 = {
        type = "shared",
        name = "Slap (shared)",
        animation = {
            dict = "script_story@sal1@ig@sal1_ig3_slap_game",
            name = "lenny_slaps_02_lenny",
            flag = 4,
            duration = 1200,
            dontAttach = true
        },
        partner = {
            offset = vector4(-0.3, 0.9, 0, -160),
            animation = {
                dict = "script_story@sal1@ig@sal1_ig3_slap_game",
                name = "lenny_slaps_02_arthur",
                flag = 4,
                duration = 4000,
                dontAttach = true
            }
        }
    },
    -- MORE PROMISING SLAPPIGN ANIMS script_re@unpaid_debt@paid
    ["dance2"]                = {
        type = "shared",
        name = "Dance2 (shared)",
        animation = {
            dict = "cnv_camp@rchso@cnv@ccdtc33@player_karen",
            name = "karen_dance_loop",
            flag = 1
        },
        partner = {
            offset = vector4(-0.05, 0.55, 0.0, 205.0),
            animation = {
                dict = "cnv_camp@rchso@cnv@ccdtc33@player_karen",
                name = "arthur_dance_loop",
                flag = 1
            }
        }
    },

    ["lay4"]                  = {
        type = "shared",
        name = "Lay 4 (shared)",
        animation = {
            dict = "amb_rest@world_human_sleep_ground@pillow@female_a@idle_a",
            name = "idle_a",
            flag = 1
        },
        partner = {
            offset = vector4(0.40, -0.55, 0.0, 110.0),
            animation = {
                dict = "amb_rest_sit@world_human_sit_ground@fall_asleep@female_a@sleeping@base",
                name = "base",
                flag = 1
            }
        }
    },

    ["lay3"]                  = {
        type = "shared",
        name = "Lay 3 (shared)",
        animation = {
            dict = "amb_camp@world_camp_jack_es_sleep@male_a@base",
            name = "base",
            flag = 1
        },
        partner = {
            offset = vector4(0.40, -0.55, 0.0, 110.0),
            animation = {
                dict = "amb_rest_sit@world_human_sit_ground@fall_asleep@female_a@sleeping@base",
                name = "base",
                flag = 1
            }
        }
    },

    ["lay2"]                  = {
        type = "shared",
        name = "Lay 2 (shared)",
        animation = {
            dict = "amb_rest@world_human_sleep_ground@pillow@female_a@idle_a",
            name = "idle_a",
            flag = 1
        },
        partner = {
            offset = vector4(0.10, -0.85, 0.0, 30.0),
            animation = {
                dict = "amb_rest_sit@world_human_sit_ground@fall_asleep@male_a@sleeping@base",
                name = "base",
                flag = 1
            }
        }
    },

    ["lay"]                   = {
        type = "shared",
        name = "Lay 1 (shared)",
        animation = {
            dict = "amb_camp@world_camp_jack_es_sleep@male_a@base",
            name = "base",
            flag = 1
        },
        partner = {
            offset = vector4(0.10, -0.95, -0.0, 30.0),
            animation = {
                dict = "amb_rest_sit@world_human_sit_ground@fall_asleep@male_a@sleeping@base",
                name = "base",
                flag = 1
            }
        }
    },

    ["lay5"]                  = {
        type = "shared",
        name = "Lay 5 (shared)",
        animation = {
            dict = "amb_rest_sit@world_human_sit_ground@fall_asleep@female_a@sleeping@base",
            name = "base",
            flag = 1
        },
        partner = {
            offset = vector4(0.55, 0.40, 0.03, -90.0),
            animation = {
                dict = "amb_rest@world_human_sleep_ground@pillow@female_a@idle_a",
                name = "idle_a",
                flag = 1
            }
        }
    },
    ["lay6"]                  = {
        type = "shared",
        name = "Lay 6 (shared)",
        animation = {
            dict = "amb_rest_sit@world_human_sit_ground@fall_asleep@female_a@sleeping@base",
            name = "base",
            flag = 1
        },
        partner = {
            offset = vector4(0.70, 0.40, -0.12, -90.0),
            animation = {
                dict = "amb_camp@world_camp_jack_es_sleep@male_a@base",
                name = "base",
                flag = 1
            }
        }
    },
    ["hug2"]                  = {
        type = "shared",
        name = "Hug 2 (shared)",
        animation = {
            dict = "mech_carry_box",
            name = "idle",
            flag = 1
        },
        partner = {
            offset = vector4(0.1, 0.42, 0.025, 180.0),
            animation = {
                dict = "mech_carry_box",
                name = "idle",
                flag = 1
            }
        }
    },
    ["hug"]                   = {
        type = "shared",
        name = "Hug (shared)",
        animation = {
            dict = "mech_loco_m@generic@carry@box@front@idle",
            name = "idle",
            flag = 1
        },
        partner = {
            offset = vector4(-0.00, 0.12, 0.0, 180.0),
            animation = {
                dict = "mech_loco_m@generic@carry@box@front@idle",
                name = "idle",
                flag = 1
            }
        }
    },
    ["doggystyle"]            = {
        type = "shared",
        name = "Doggy Style (shared)",
        animation = {
            dict = "script_story@mud3@ig@ig_1_throw_whore",
            name = "base_att",
            flag = 1
        },
        partner = {
            offset = vector4(0.0, 0.235, 0.1, 0.0),
            animation = {
                dict = "script_story@mud3@ig@ig_1_throw_whore",
                name = "base_vtm",
                flag = 1
            }
        }
    },
    ["cowgirl"]               = {
        type = "shared",
        name = "Cowgirl (shared)",
        animation = {
            dict = "script_story@sal1@ig@sal1_18_lenny_on_lenny",
            name = "loop_male",
            flag = 1
        },
        partner = {
            offset = vector4(0.1, 0.0, 0.10, 170.0),
            animation = {
                dict = "script_story@sal1@ig@sal1_18_lenny_on_lenny",
                name = "loop_female",
                flag = 1
            }
        }
    },
    ["cowgirl2"]              = {
        type = "shared",
        name = "Reverse Cowgirl (shared)",
        animation = {
            dict = "script_story@sal1@ig@sal1_18_lenny_on_lenny",
            name = "loop_male",
            flag = 1
        },
        partner = {
            offset = vector4(-0.1, 0.25, 0.10, -10.0),
            animation = {
                dict = "script_story@sal1@ig@sal1_18_lenny_on_lenny",
                name = "loop_female",
                flag = 1
            }
        }
    },
    ["spank"]                 = {
        type = "shared",
        name = "Spank (shared)",
        animation = {
            dict = "script_re@peep_tom@spanking_cowboy",
            name = "spanking_idle_female",
            flag = 1
        },
        partner = {
            offset = vector4(-0.45, 0.60, 0.0, 90.0),
            animation = {
                dict = "script_re@peep_tom@spanking_cowboy",
                name = "spanking_idle_cowboy",
                flag = 1
            },
        },
        prop = {
            model = "p_cratetable01x",
            position = vector3(-1.0, 0.68, -1.05),
            rotation = vector3(0.0, 0.0, 0.0),
            stationary = true,
            snaptoground = false
        }
    },
    ["faceriding"]            = {
        type = "shared",
        name = "Face Riding (shared)",
        animation = {
            dict = "script_story@sal1@ig@sal1_18_lenny_on_lenny",
            name = "loop_male",
            flag = 1
        },
        partner = {
            offset = vector4(-0.23, -0.38, 0.18, -10.0),
            animation = {
                dict = "script_story@sal1@ig@sal1_18_lenny_on_lenny",
                name = "loop_female",
                flag = 1
            }
        }
    },
    ["sittinginlap"]          = {
        type = "shared",
        name = "Sitting in Lap (shared)",
        animation = {
            dict = "script_hideout@six_point_cabin@couple",
            name = "base_male",
            flag = 1
        },
        partner = {
            offset = vector4(-0.13, 0.30, 0.10, -79.0),
            animation = {
                dict = "script_hideout@six_point_cabin@couple",
                name = "base_female",
                flag = 1
            }
        },
        prop = {
            model = "p_chair20x",
            position = vector3(0.0, 0.05, -1.0),
            rotation = vector3(0.0, 0.0, 180.0),
            stationary = true,
            snaptoground = false
        }
    },
    ["chairmissionary"]       = {
        type = "shared",
        name = "Chair Missionary (shared)",
        animation = {
            dict = "script_hideout@six_point_cabin@couple",
            name = "base_male",
            flag = 1,
            blendin = 80.0
        },
        partner = {
            offset = vector4(0.07, 0.15, 0.50, 180.0),
            animation = {
                dict = "script_story@sal1@ig@sal1_18_lenny_on_lenny",
                name = "loop_female",
                flag = 1,
                blendin = 80.0
            }
        },
        prop = {
            model = "p_chair20x",
            position = vector3(0.0, 0.05, -1.0),
            rotation = vector3(0.0, 0.0, 180.0),
            stationary = true,
            snaptoground = false
        }
    },
    ["kiss"]                  = {
        type = "shared",
        name = "Kiss (shared)",
        animation = {
            dict = "cnv_camp@rchso@cnv@ccsnk_par_cnv2",
            name = "sean_base_outro",
            flag = 1
        },
        partner = {
            offset = vector4(0.05, 0.40, 0.0, 140.0),
            boneZalign = {
                player = "PH_L_ChinIP",
                partner = "PH_L_ChinIP"
            },
            animation = {
                dict = "cnv_camp@rchso@cnv@ccsnk_par_cnv2",
                name = "karen_base_outro",
                flag = 1
            }
        }
    },
    ["getspanked"]            = {
        type = "shared",
        name = "Get Spanked (shared)",
        animation = {
            dict = "script_re@peep_tom@spanking_cowboy",
            name = "spanking_idle_cowboy",
            flag = 1
        },
        partner = {
            offset = vector4(-0.60, -0.50, 0.0, 270.0),
            animation = {
                dict = "script_re@peep_tom@spanking_cowboy",
                name = "spanking_idle_female",
                flag = 1
            }
        },
        prop = {
            model = "p_cratetable01x",
            position = vector3(0.0, 0.5, -1.05),
            rotation = vector3(0.0, 0.0, 90.0),
            stationary = true,
            snaptoground = false
        }
    },
    ["dance"]                 = {
        type = "shared",
        name = "Dance (shared)",
        animation = {
            dict = "cnv_camp@rchso@cnv@ccdtc33@player_karen",
            name = "arthur_dance_loop",
            flag = 1
        },
        partner = {
            offset = vector4(0.2, 0.5, 0.0, 155.0),
            animation = {
                dict = "cnv_camp@rchso@cnv@ccdtc33@player_karen",
                name = "karen_dance_loop",
                flag = 1
            }
        }
    },
    ["hostage"]               = {
        type = "shared",
        name = "Take Hostage (shared)",
        animation = {
            dict = "mech_grapple@blade@_male@_ambient@_healthy@back@loco@attacker",
            name = "idle",
            flag = 25,
            repeating = true
        },
        partner = {
            offset = vector4(0, 0.3, 0.0, 0.0),
            rotation = vector3(0.0, 0.0, 0.0),
            attatchToPedBone = "CollisionScale_Spine01",
            animation = {
                dict = "mech_grapple@blade@_male@_ambient@_healthy@back@loco@victim",
                name = "idle",
                flag = 1,
                repeating = true
            }
        }
    },
    ["drag"]                  = {
        type = "shared",
        name = "Drag (shared)",
        animation = {
            dict = "mech_grapple@unarmed@_male@ind1@_healthy@drag@loco@attacker",
            name = "walk_fwd",
            walkingName = "idle",
            stoppedName = "idle",
            flag = 25,
            walkingFlag = 25,
            stoppedFlag = 25,
            repeating = true,
            victim = false,
            walking = true,
        },
        partner = {
            offset = vector4(-0.1, 0.55, 0.0, -5.0),
            animation = {
                dict = "mech_grapple@unarmed@_male@ind1@_healthy@drag@loco@victim",
                name = "idle",
                walkingName = "walk_fwd",
                stoppedName = "idle",
                flag = 1,
                walkingFlag = 1,
                stoppedFlag = 1,
                repeating = true,
                walking = true,
                victim = true
            }
        }
    },
    ["pet"]                   = {
        type = "shared",
        name = "Pet Dog Standing (shared)",
        animation = {
            dict = "mech_animal_interaction@dog@patting@1h",
            name = "base",
            flag = 1
        },
        partner = {
            offset = vector4(0, 0.85, -0.6, 180),
            animation = {
                dict = "creatures_mammal@dog_pers@happy@idle",
                name = "idle",
                flag = 1
            }
        }
    },
    ["pet2"]                  = {
        type = "shared",
        name = "Pet Dog Sitting (shared)",
        animation = {
            dict = "mech_animal_interaction@dog@patting@1h",
            name = "base",
            flag = 1
        },
        partner = {
            offset = vector4(0, 0.7, -0.6, 180),
            animation = {
                dict = "amb_creature_mammal@world_dog_sitting@base",
                name = "base",
                flag = 1
            }
        }
    },
    ["cower"] = {
        type = "solo",
        name = "Cower",
        animation = {
            dict = "script_amb@discoverables@shack_on_the_run@ig_2",
            name = "flinch1",
            flag = 1,
        }
    },
    ["scared"]                 = {
        type = "solo",
        name = "Scared Begging",
        animation = {
            dict = "script_amb@discoverables@shack_on_the_run@ig_2",
            name = "flinch2",
            flag = 1,
        }
    },
    ["broomrest"]             = {
        type = "prop",
        name = "Broom Rest",
        interruptible = true,
        animation = {
            dict = "amb_work@world_human_broom@resting@male_b@idle_a",
            name = "idle_a",
            flag = 1
        },
        prop = {
            model = "p_broom04x",
            bone = "PH_R_HAND",
            position = vector3(0.0, 0.0, 0.0),
            rotation = vector3(0.0, 0.0, 0.0)
        }
    },
    ["doghat"]                = {
        type = "prop",
        name = "Dog Hat",
        prop = {
            model = "mp001_p_mp_hat_mr1_059",
            bone = "skel_head",
            position = vector3(0.04, -0.06, 0),
            rotation = vector3(100, 270, -25)
        },
        animation = {
            dict = "",
            name = "",
            flag = 25
        },
        dogemote = true,
        clothing = true
    },
    ["shoveldirt"]            = {
        type = "prop",
        name = "Shovel Dirt",
        interruptible = true,
        prop = {
            model = "p_shovel02x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0, 0.00),
            rotation = vector3(0.0, 0.0, 0.0),
        },
        animation = {
            dict = "amb_work@world_human_gravedig@working@male_b@base",
            name = "base",
            flag = 1
        }
    },
    ["groom"]                 = {
        type = "gesture",
        name = "Pick Nose",
        animation = {
            dict = "amb_rest_sit@prop_human_seat_chair@grooming@male_a@base",
            name = "base",
            flag = 25,
            upperBody = true,
            filter = "rightarmonly_filter"
        }
    },
    ["carrypick"]             = {
        type = "prop",
        name = "Carry Pickaxe",
        nonInterruptible = true,
        prop = {
            model = "p_pickaxe01x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0, 0.00),
            rotation = vector3(0.0, 0.0, 0.0)
        },
        animation = {
            dict = "amb_wander@code_human_pickaxe_wander@male_d@base",
            name = "base",
            flag = 25,
            upperBody = true,
            filter = "arms_filter"
        }
    },
    ["carrysledgehammer"]     = {
        type = "prop",
        name = "Carry Sledgehammer",
        nonInterruptible = true,
        prop = {
            model = "p_sledgehammer01x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0, 0.00),
            rotation = vector3(0.0, 0.0, -90.0)
        },
        animation = {
            dict = "amb_wander@code_human_pickaxe_wander@male_d@base",
            name = "base",
            flag = 25,
            upperBody = true,
            filter = "arms_filter"
        }
    },
    ["mine"]                  = {
        type = "prop",
        name = "Mine Pickaxe",
        interruptible = true,
        prop = {
            model = "p_pickaxe01x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0, 0.00),
            rotation = vector3(0.0, 0.0, 0.0)
        },
        animation = {
            dict = "amb_work@world_human_pickaxe@wall@male_d@idle_a",
            name = "idle_c",
            flag = 1
        }
    },
    ["mine2"]                 = {
        type = "prop",
        name = "Mine Pickaxe 2",
        interruptible = true,
        prop = {
            model = "p_pickaxe01x",
            bone = "PH_L_Hand",
            position = vector3(0.0, 0, 0.00),
            rotation = vector3(0.0, 0.0, 90.0)
        },
        animation = {
            dict = "amb_work@world_human_sledgehammer@male@idle_a",
            name = "idle_a",
            flag = 1
        }
    },
    ["sledgehammer"]          = {
        type = "prop",
        name = "Sledgehammer",
        interruptible = true,
        prop = {
            model = "p_sledgehammer01x",
            bone = "PH_L_Hand",
            position = vector3(0.0, 0, 0.00),
            rotation = vector3(0.0, 0.0, 0.0)
        },
        animation = {
            dict = "amb_work@world_human_sledgehammer@male@idle_a",
            name = "idle_a",
            flag = 1
        }
    },
    ["hammer"]                = {
        type = "prop",
        name = "Hammer",
        interruptible = true,
        prop = {
            model = "p_hammer01x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0, 0.00),
            rotation = vector3(0.0, 0.0, 0.0)
        },
        animation = {
            dict = "amb_work@world_human_hammer@kneel@male_a@trans",
            name = "a_trans_a",
            flag = 1
        }
    },
    ["blacksmith"]            = {
        type = "prop",
        name = "Blacksmith Hammer",
        interruptible = true,
        prop = {
            model = "p_hammer03x",
            bone = "PH_R_Hand",
            position = vector3(-0.01, -0.037, 0.0),
            rotation = vector3(0.0, 0.0, 0.0)
        },
        animation = {
            dict = "amb_work@world_human_hammer_kneel_stakes@male@male_a@base",
            name = "base",
            flag = 25
        }
    },
    ["inspectcard"]           = {
        type = "prop",
        name = "Inspect Card",
        prop = {
            model = "s_inv_businesscard01x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0, 0.00),
            rotation = vector3(0.0, 0.0, 0.0)
        },
        animation = {
            dict = "mech_inspection@cigarette_card",
            name = "inspect",
            flag = 1
        }
    },
    ["smokecigarette"]        = {
        type = "cigarette",
        name = "Smoke Cigarette",
        nonInterruptible = true,
        animation = {
            dict = "script_mp@emotes@smoke_cigarette@male@unarmed@upper",
            name = "action",
            flag = 25,
            upperBody = true
        },
        prop = {
            model = "p_cigarette01x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0, 0.00),
            rotation = vector3(0.0, 0.0, 0.0),
        }
    },
    ["smokecigarette_alt1"]   = {
        type = "cigarette",
        name = "Smoke Cigarette Alt1",
        nonInterruptible = true,
        animation = {
            dict = "script_mp@emotes@smoke_cigarette@male@unarmed@upper",
            name = "action_alt1",
            flag = 25,
            upperBody = true
        },
        prop = {
            model = "p_cigarette01x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0, 0.00),
            rotation = vector3(0.0, 0.0, 0.0),
        }
    },
    ["smokecigarette_alt2"]   = {
        type = "cigarette",
        name = "Smoke Cigarette Alt2",
        nonInterruptible = true,
        animation = {
            dict = "script_mp@emotes@smoke_cigarette@male@unarmed@upper",
            name = "action_alt2",
            flag = 25,
            upperBody = true
        },
        prop = {
            model = "p_cigarette01x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0, 0.00),
            rotation = vector3(0.0, 0.0, 0.0),
        }
    },
    ["smokecigarette_loop"]   = {
        type = "cigarette",
        name = "Smoke Cigarette Loop",
        nonInterruptible = true,
        animation = {
            dict = "script_mp@emotes@smoke_cigarette@male@unarmed@upper",
            name = "loop",
            flag = 25,
            upperBody = true
        },
        prop = {
            model = "p_cigarette01x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0, 0.00),
            rotation = vector3(0.0, 0.0, 0.0),
        }
    },
    ["smokecigarette_f"]      = {
        type = "cigarette",
        name = "Smoke Cigarette Female",
        nonInterruptible = true,
        animation = {
            dict = "script_mp@emotes@smoke_cigarette@female@unarmed@upper",
            name = "action",
            flag = 25,
            upperBody = true
        },
        prop = {
            model = "p_cigarette01x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0, 0.00),
            rotation = vector3(0.0, 0.0, 0.0),
        }
    },
    ["smokecigarette_alt1_f"] = {
        type = "cigarette",
        name = "Smoke Cigarette Alt1 Female",
        nonInterruptible = true,
        animation = {
            dict = "script_mp@emotes@smoke_cigarette@female@unarmed@upper",
            name = "action_alt1",
            flag = 25,
            upperBody = true
        },
        prop = {
            model = "p_cigarette01x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0, 0.00),
            rotation = vector3(0.0, 0.0, 0.0),
        }
    },
    ["smokecigarette_alt2_f"] = {
        type = "cigarette",
        name = "Smoke Cigarette Alt2 Female",
        nonInterruptible = true,
        animation = {
            dict = "script_mp@emotes@smoke_cigarette@female@unarmed@upper",
            name = "action_alt2",
            flag = 25,
            upperBody = true
        },
        prop = {
            model = "p_cigarette01x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0, 0.00),
            rotation = vector3(0.0, 0.0, 0.0),
        }
    },
    ["smokecigarette_loop_f"] = {
        type = "cigarette",
        name = "Smoke Cigarette Loop Female",
        nonInterruptible = true,
        animation = {
            dict = "script_mp@emotes@smoke_cigarette@female@unarmed@upper",
            name = "loop",
            flag = 25,
            upperBody = true
        },
        prop = {
            model = "p_cigarette01x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0, 0.00),
            rotation = vector3(0.0, 0.0, 0.0),
        }
    },
    ["smokecigar"]            = {
        type = "cigar",
        name = "Smoke Cigar",
        nonInterruptible = true,
        animation = {
            dict = "script_mp@emotes@smoke_cigar@male@unarmed@upper",
            name = "action",
            flag = 25,
            upperBody = true
        },
        prop = {
            model = "p_cigar02x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0, 0.00),
            rotation = vector3(0.0, 0.0, 0.0),
        }
    },
    ["smokecigar2"]           = {
        type = "prop",
        name = "Smoke Cigar 2",
        nonInterruptible = true,
        animation = {
            dict = "amb_wander@code_human_smoking_wander@cigar@male_a@base",
            name = "base",
            flag = 25,
            upperBody = true,
            filter = "rightarmonly_filter"
        },
        prop = {
            model = "p_cigar02x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0, 0.00),
            rotation = vector3(0.0, 0.0, 0.0),
        }
    },
    ["smokecigar3"]           = {
        type = "prop",
        name = "Smoke Cigar 3",
        nonInterruptible = true,
        animation = {
            dict = "amb_camp@world_camp_dutch_smoke_cigar@male_a@idle_a",
            name = "idle_a",
            flag = 25,
            upperBody = true,
            filter = "arms_filter"
        },
        prop = {
            model = "p_cigar02x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0, 0.00),
            rotation = vector3(0.0, 0.0, 0.0),
        }
    },
    ["smokecigar4"]           = {
        type = "prop",
        name = "Smoke Cigar 4",
        nonInterruptible = true,
        animation = {
            dict = "amb_camp@world_camp_dutch_smoke_cigar@male_b@idle_b",
            name = "idle_e",
            flag = 25,
            upperBody = true,
            filter = "arms_filter"
        },
        prop = {
            model = "p_cigar01x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0, 0.00),
            rotation = vector3(0.0, 0.0, 0.0),
        }
    },
    ["cigaridle"]             = {
        type = "prop",
        name = "Cigar Idle 1",
        nonInterruptible = true,
        animation = {
            dict = "amb_camp@world_camp_dutch_smoke_cigar@male_a@idle_a",
            name = "idle_a",
            flag = 25,
            upperBody = true,
            filter = "rightarmonly_filter"
        },
        prop = {
            model = "p_cigar02x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0, 0.00),
            rotation = vector3(0.0, 0.0, 0.0),
        }
    },
    ["cigaridle2"]            = {
        type = "prop",
        name = "Cigar Idle 2",
        nonInterruptible = true,
        animation = {
            dict = "amb_camp@world_camp_dutch_smoke_cigar@male_b@idle_c",
            name = "idle_i",
            flag = 25,
            upperBody = true,
            filter = "arms_filter"
        },
        prop = {
            model = "p_cigar02x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0, 0.00),
            rotation = vector3(0.0, 0.0, 0.0),
        }
    },
    ["cigaridle3"]            = {
        type = "prop",
        name = "Cigar Idle 3",
        nonInterruptible = true,
        animation = {
            dict = "amb_camp@world_camp_dutch_smoke_cigar@male_b@idle_a",
            name = "idle_a",
            flag = 25,
            upperBody = true,
            filter = "arms_filter"
        },
        prop = {
            model = "p_cigar02x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0, 0.00),
            rotation = vector3(0.0, 0.0, 0.0),
        }
    },
    ["smokecigar_alt1"]       = {
        type = "cigar",
        name = "Smoke Cigar Alt1",
        nonInterruptible = true,
        animation = {
            dict = "script_mp@emotes@smoke_cigar@male@unarmed@upper",
            name = "action_alt1",
            flag = 25,
            upperBody = true
        },
        prop = {
            model = "p_cigar02x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0, 0.00),
            rotation = vector3(0.0, 0.0, 0.0),
        }
    },
    ["smokecigar_alt2"]       = {
        type = "cigar",
        name = "Smoke Cigar Alt2",
        nonInterruptible = true,
        animation = {
            dict = "script_mp@emotes@smoke_cigar@male@unarmed@upper",
            name = "action_alt2",
            flag = 25,
            upperBody = true
        },
        prop = {
            model = "p_cigar02x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0, 0.00),
            rotation = vector3(0.0, 0.0, 0.0),
        }
    },
    ["smokecigar_loop"]       = {
        type = "cigar",
        name = "Smoke Cigar Loop",
        nonInterruptible = true,
        animation = {
            dict = "script_mp@emotes@smoke_cigar@male@unarmed@upper",
            name = "loop",
            flag = 25,
            upperBody = true
        },
        prop = {
            model = "p_cigar02x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0, 0.00),
            rotation = vector3(0.0, 0.0, 0.0),
        }
    },
    ["smokecigar_f"]          = {
        type = "cigar",
        name = "Smoke Cigar Female",
        nonInterruptible = true,
        animation = {
            dict = "script_mp@emotes@smoke_cigar@female@unarmed@upper",
            name = "action",
            flag = 25,
            upperBody = true
        },
        prop = {
            model = "p_cigar02x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0, 0.00),
            rotation = vector3(0.0, 0.0, 0.0),
        }
    },
    ["smokecigar_alt1_f"]     = {
        type = "cigar",
        name = "Smoke Cigar Alt1 Female",
        nonInterruptible = true,
        animation = {
            dict = "script_mp@emotes@smoke_cigar@female@unarmed@upper",
            name = "action_alt1",
            flag = 25,
            upperBody = true
        },
        prop = {
            model = "p_cigar02x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0, 0.00),
            rotation = vector3(0.0, 0.0, 0.0),
        }
    },
    ["smokecigar_alt2_f"]     = {
        type = "cigar",
        name = "Smoke Cigar Alt2 Female",
        nonInterruptible = true,
        animation = {
            dict = "script_mp@emotes@smoke_cigar@female@unarmed@upper",
            name = "action_alt2",
            flag = 25,
            upperBody = true
        },
        prop = {
            model = "p_cigar02x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0, 0.00),
            rotation = vector3(0.0, 0.0, 0.0),
        }
    },
    ["smokecigar_loop_f"]     = {
        type = "cigar",
        name = "Smoke Cigar Loop Female",
        nonInterruptible = true,
        animation = {
            dict = "script_mp@emotes@smoke_cigar@female@unarmed@upper",
            name = "loop",
            flag = 25,
            upperBody = true
        },
        prop = {
            model = "p_cigar02x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0, 0.00),
            rotation = vector3(0.0, 0.0, 0.0),
        }
    },
    ["paper"]                 = {
        type = "prop",
        name = "Hold Paper",
        nonInterruptible = true,
        prop = {
            model = "p_cs_ripped_paper01x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0, 0.00),
            rotation = vector3(0.0, 0.0, 0.0)
        },
        animation = {
            dict = "mech_inventory@document@paper_w18-9_h28-2_foldverticalx2",
            name = "base",
            flag = 25,
            upperBody = true,
            filter = "arms_filter"
        }
    },
    ["god"]                   = {
        type = "gesture",
        name = "God Pose",
        animation = {
            dict = "script_mp@last_round@photos",
            name = "pose1_m04",
            flag = 25,
            upperBody = true,
            filter = false
        }
    },
    ["inspectpaper"]          = {
        type = "prop",
        name = "Inspect Paper",
        nonInterruptible = true,
        prop = {
            model = "p_cs_ripped_paper01x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0, 0.00),
            rotation = vector3(0.0, 0.0, 0.0)
        },
        animation = {
            dict = "mech_inventory@document@paper_w18-9_h28-2_foldverticalx2",
            name = "base",
            flag = 1
        }
    },
    ["holdmap"]               = {
        type = "prop",
        name = "Open Empty Map",
        nonInterruptible = true,
        prop = {
            model = "s_twofoldmap01x_us",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0.0, 0.0),
            rotation = vector3(0.0, 0.0, 0.0),
            anim = {
                dict = "mech_inspection@two_fold_map@satchel",
                name = "enter_prop",
                looped = false,
                freeze = true,
            },
        },
        animation = {
            dict = "mech_inspection@two_fold_map@satchel",
            name = "enter",
            flag = 30,
            blendin = 3.0,
            upperBody = true,
            filter = false
        }
    },
    ["holdmap2"]              = {
        type = "prop",
        name = "Hold Mini Map",
        nonInterruptible = true,
        prop = {
            model = "mp001_mp_map01x",
            bone = "XH_L_Hand00",
            position = vector3(-0.06, 0.12, 0.36),
            rotation = vector3(-10.0, -120.0, -40.0)
        },
        animation = {
            dict = "mech_inspection@mini_map@base",
            name = "hold",
            flag = 25,
            upperBody = true,
            filter = false
        }
    },
    ["lockpick"]              = {
        type = "prop",
        name = "Lockpick",
        interruptible = true,
        prop = {
            model = "p_lockpick01X",
            bone = "skel_r_hand",
            position = vector3(0.05, 0.04, -0.03),
            rotation = vector3(-30.0, 0.0, -120.0)
        },
        animation = {
            dict = "script_ca@carust@02@ig@ig1_rustlerslockpickingconv01",
            name = "idle_base_smhthug_01",
            flag = 1
        }
    },
    ["syringe"]               = {
        type = "prop",
        name = "Inject Syringe",
        prop = {
            model = "p_cs_syringe01X",
            bone = "ph_r_hand",
            position = vector3(0.0, 0.0, 0.0),
            rotation = vector3(0.0, 0.0, 0.0)
        },
        animation = {
            dict = "mech_inventory@item@stimulants@inject@quick",
            name = "quick_stimulant_inject_rhand",
            flag = 28,
            upperBody = true,
            filter = "rightarmonly_filter",
            duration = 3000,
        }
    },
    ["clipboard"]             = {
        type = "prop",
        name = "Hold Clipboard",
        nonInterruptible = true,
        prop = {
            model = "mp007_p_clipboardmoonshine01x",
            bone = "skel_r_hand",
            position = vector3(0.25, 0.15, -0.035),
            rotation = vector3(60.0, -45.0, 180.0)
        },
        animation = {
            dict = "script_common@other@unapproved",
            name = "dockworker@clipboard@idle_a",
            flag = 25
        }
    },
    ["holdnewspaper"]         = {
        type = "prop",
        name = "Hold Up Newspaper",
        nonInterruptible = true,
        animation = {
            dict = "amb_rest_sit@prop_human_seat_chair@read@newspaper@male_b@idle_a",
            name = "idle_a",
            flag = 25,
            upperBody = true,
            filter = false
        },
        prop = {
            model = "p_cs_newspaper_03x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0.0, 0.0),
            rotation = vector3(0.0, 0.0, 0.0),
            anim = {
                dict = "amb_rest_sit@prop_human_seat_chair@read@newspaper@male_b@idle_c",
                name = "idle_g_newspaper",
            }
        },
    },
    ["readnewspaper"]         = {
        type = "prop",
        name = "Read Newspaper",
        nonInterruptible = true,
        animation = {
            dict = "amb_rest_lean@world_human_lean@barrel@read_newspaper@male_a@base",
            name = "base",
            flag = 25,
            upperBody = true,
            filter = false
        },
        prop = {
            model = "p_cs_newspaper_03x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0.0, 0.0),
            rotation = vector3(0.0, 0.0, 0.0),
            anim = {
                dict = "amb_rest_lean@world_human_lean@barrel@read_newspaper@male_a@base",
                name = "base_newspaper",
            }
        },
    },
    ["sellnewspaper"]         = {
        type = "prop",
        name = "Sell Newspaper",
        prop = {
            model = "p_cs_newspaper_02x_noanim",
            bone = "PH_L_Hand",
            position = vector3(0.0, 0.0, 0.0),
            rotation = vector3(0.0, 0.0, 0.0),
            anim = {
                dict = "amb_work@world_human_paper_sell@male_a@idle_a",
                name = "idle_c_newspaper",
                looped = true,
                freeze = true,
            }
        },
        animation = {
            dict = "amb_work@world_human_paper_sell@male_a@idle_a",
            name = "idle_c",
            flag = 25,
            upperBody = true,
            filter = false
        }
    },
    ["holdtorch"]             = {
        type = "prop",
        name = "Hold a torch",
        animation = {
            dict = "mech_weapons_special@loco@arthur@normal@torch@idle",
            name = "idle",
            flag = 25,
            upperBody = true,
            filter = "rightarmonly_filter"
        },
        prop = {
            model = "s_interact_torch",
            bone = "PH_R_Hand",
            position = vector3(0.04, 0.08, -0.02),
            rotation = vector3(-91.0, 10.0, -10.0),
        }
    },
    ["carryplank"]            = {
        type = "prop",
        name = "Carry Plank",
        nonInterruptible = true,
        prop = {
            model = "p_lumber09_cmb",
            bone = "PH_R_Hand",
            position = vector3(0.0, -0.7, 0.0),
            rotation = vector3(0.0, 0.0, 0.0),
        },
        animation = {
            dict = "amb_work@prop_vehicle_wagon@lumber_unload@3@shoulder_lumber@male_a@base",
            name = "base",
            flag = 25,
            upperBody = true,
            filter = false,
            repeating = true,
        }
    },
    ["carryplank2"]           = {
        type = "prop",
        name = "Carry Plank 2",
        nonInterruptible = true,
        prop = {
            model = "p_lumber09_cmb",
            bone = "PH_R_Hand",
            position = vector3(0.0, -0.9, 0.0),
            rotation = vector3(0.0, 0.0, 0.0),
        },
        animation = {
            dict = "amb_work@prop_vehicle_wagon@lumber_unload@1@shoulder_lumber@male_a@base",
            name = "base",
            flag = 25,
            repeating = true,
        }
    },
    ["planewood"]             = {
        type = "prop",
        name = "Plane Wood",
        prop = {
            model = "p_woodplane01x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0.0, 0.0),
            rotation = vector3(0.0, 0.0, 0.0),
        },
        animation = {
            dict = "amb_work@world_human_wood_plane@working@male_a@idle_a",
            name = "idle_a",
            flag = 1
        }
    },
    ["sawwood"]               = {
        type = "prop",
        name = "Saw Wood",
        prop = {
            model = "p_sawhand01x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0.0, 0.0),
            rotation = vector3(0.0, 0.0, 0.0),
            anim = {
                dict = "amb_work@world_human_saw_wood@male_a@idle_c",
                name = "idle_g_saw",
                looped = true,
                freeze = true,
            }
        },
        animation = {
            dict = "amb_work@world_human_saw_wood@male_a@idle_c",
            name = "idle_g",
            flag = 1
        }
    },
    ["carrybag"]              = {
        type = "prop",
        name = "Carry Bag",
        prop = {
            model = "p_sandbags03x",
            bone = "SKEL_L_Hand",
            position = vector3(0.02, 0.13, 0.28),
            rotation = vector3(2.0, 139.0, 0.0)
        },
        animation = {
            dict = "mech_loco_m@generic@carry@ped@idle",
            name = "idle",
            flag = 25,
            upperBody = true,
            filter = "leftarmonly_filter"
        }
    },
    ["carrysuitcase"]         = {
        type = "prop",
        name = "Carry Suitcase",
        prop = {
            model = "p_cs_suitcase05x_up",
            bone = "PH_L_Hand",
            position = vector3(0.0, 0.0, -0.0),
            rotation = vector3(0.0, 0.0, 0.0)
        },
        animation = {
            dict = "mech_loco_m@character@beau_gray@carry@suitcase@idle",
            name = "idle",
            flag = 25,
            upperBody = true,
            filter = "leftarmonly_filter"
        }
    },
    ["broom1"]                = {
        type = "prop",
        name = "Broom 1",
        prop = {
            model = "p_broom04x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0.0, 0.0),
            rotation = vector3(0.0, 0.0, 0.0)
        },
        animation = {
            dict = "amb_work@world_human_broom@working@male_b@base",
            name = "base",
            flag = 25,
        }
    },
    ["broom2"]                = {
        type = "prop",
        name = "Broom 2 (Clean Wall)",
        prop = {
            model = "p_broom04x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0.0, 0.0),
            rotation = vector3(0.0, 0.0, 0.0)
        },
        animation = {
            dict = "amb_work@world_human_broom@working@male_b@base",
            name = "base",
            flag = 25,
            upperBody = true,
            filter = false
        }
    },
    ["broom3"]                = {
        type = "prop",
        name = "Broom 3",
        prop = {
            model = "p_broom02x",
            bone = "PH_R_Hand",
            position = vector3(0.0, -0.03, 0.0),
            rotation = vector3(-3.0, 0.0, 0.0)
        },
        animation = {
            dict = "amb_work@world_human_broom@working@female_b@idle_a",
            name = "idle_b",
            flag = 25
        }
    },
    ["broom4"]                = {
        type = "prop",
        name = "Broom 4 (Clean Wall)",
        prop = {
            model = "p_broom02x",
            bone = "PH_R_Hand",
            position = vector3(0.0, -0.03, 0.0),
            rotation = vector3(-3.0, 0.0, 0.0)
        },
        animation = {
            dict = "amb_work@world_human_broom@working@female_b@idle_a",
            name = "idle_b",
            flag = 25,
            upperBody = true,
            filter = false
        }
    },
    ["holdcandle"]            = {
        type = "prop",
        name = "Hold Candle",
        prop = {
            model = "p_candlestick03x",
            bone = "PH_L_Hand",
            position = vector3(0.08, -0.06, -0.02),
            rotation = vector3(-42.0, -16.0, 0.0)
        },
        animation = {
            dict = "mech_inspection@cigarette_card@base",
            name = "hold",
            flag = 25,
            upperBody = true,
        }
    },
    ["pitchfork"]             = {
        type = "prop",
        name = "Pitchfork",
        prop = {
            model = "p_pitchfork01x",
            bone = "PH_R_Hand",
            position = vector3(-0.04, -0.07, -0.03),
            rotation = vector3(-95.0, -230.0, -38.0)
        },
        animation = {
            dict = "amb_work@world_human_pitch_hay@male_a@pitch@idle_a",
            name = "idle_a",
            flag = 1
        }
    },
    ["pitchfork2"]            = {
        type = "prop",
        name = "Pitchfork Upperbody",
        prop = {
            model = "p_pitchfork01x",
            bone = "PH_R_Hand",
            position = vector3(-0.04, -0.07, -0.03),
            rotation = vector3(-95.0, -230.0, -38.0)
        },
        animation = {
            dict = "amb_work@world_human_pitch_hay@male_a@pitch@idle_a",
            name = "idle_a",
            flag = 1
        }
    },
    ["rake"]                  = {
        type = "prop",
        name = "Rake",
        interruptible = true,
        prop = {
            model = "p_rake02x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0.0, 0.19),
            rotation = vector3(0.0, 0.0, 0.0)
        },
        animation = {
            dict = "amb_work@world_human_farmer_rake@male_a@idle_a",
            name = "idle_a",
            flag = 1
        }
    },
    ["stroller"]              = {
        type = "prop",
        name = "Stroller",
        prop = {
            model = "p_babystroller",
            bone = "MH_ApronFront_PT_000",
            position = vector3(-0.03, 0.99, -0.30),
            rotation = vector3(0.0, 0.0, 0.0)
        },
        animation = {
            dict = "veh_common@wheeled@front@fr@in_seat@male@fidgets",
            name = "idle_c",
            flag = 25,
        }
    },
    ["moonshine"]             = {
        type = "prop",
        name = "Drink Moonshine",
        nonInterruptible = true,
        prop = {
            model = "p_jug01x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0.0, 0.0),
            rotation = vector3(0.0, 0.0, 0.0)
        },
        animation = {
            dict = "script_re@moonshine_camp@return_taste@trans",
            name = "good_male_b",
            flag = 25,
            upperBody = true,
            filter = false
        }
    },
    ["bouquet"]               = {
        type = "prop",
        name = "Bouquet",
        prop = {
            model = "nbx_flowerarng1x",
            bone = "SKEL_L_Finger11",
            position = vector3(0.0, -0.04, -0.15),
            rotation = vector3(0.0, 0.0, 90.0)
        },
        animation = {
            dict = "mech_inspection@generic@lh@base",
            name = "hold",
            flag = 25,
            upperBody = true,
        },
    },
    ["bouquet2"]              = {
        type = "prop",
        name = "Bouquet 2",
        prop = {
            model = "mp006_p_mp_potflowerarng01x",
            bone = "SKEL_L_Finger11",
            position = vector3(0.0, -0.04, -0.15),
            rotation = vector3(0.0, 0.0, 0.0)
        },
        animation = {
            dict = "mech_inspection@generic@lh@base",
            name = "hold",
            flag = 25,
            upperBody = true,
        },
    },
    ["firewood_fire"]         = {
        type = "prop",
        name = "Drop Firewood at Fire",
        nonInterruptible = true,
        prop = {
            model = "p_cs_woodpile01x",
            bone = "PH_L_Hand",
            position = vector3(0.0, 0.0, 0.0),
            rotation = vector3(0.0, 0.0, 0.0),
            anim = {
                dict = "mech_pickup@firewood",
                name = "fire_prop",
                looped = false,
                freeze = true,
            }
        },
        animation = {
            dict = "mech_pickup@firewood",
            name = "fire",
            flag = 4
        }
    },
    ["firewood_putdown"]      = {
        type = "prop",
        name = "Put Down Firewood",
        nonInterruptible = true,
        prop = {
            model = "p_cs_woodpile01x",
            bone = "PH_L_Hand",
            position = vector3(0.0, 0.0, 0.0),
            rotation = vector3(0.0, 0.0, 0.0),
            anim = {
                dict = "mech_pickup@firewood",
                name = "putdown_prop",
                looped = false,
                freeze = true,
            }
        },
        animation = {
            dict = "mech_pickup@firewood",
            name = "putdown",
            flag = 4
        }
    },
    ["firewood_carry"]        = {
        type = "prop",
        name = "Hold Firewood Idle",
        nonInterruptible = true,
        prop = {
            model = "p_cs_woodpile01x",
            bone = "PH_L_Hand",
            position = vector3(0.0, 0.0, 0.0),
            rotation = vector3(0.0, 0.0, 0.0),
            anim = {
                dict = "mech_pickup@firewood",
                name = "idle_prop",
                looped = true,
                freeze = true,
            }
        },
        animation = {
            dict = "mech_pickup@firewood",
            name = "idle",
            flag = 25,
            upperBody = true,
            filter = "leftarmonly_filter"
        }
    },
    ["newspaperopen"]         = {
        type = "prop",
        name = "Open Newspaper",
        nonInterruptible = true,
        prop = {
            model = "p_cs_newspaper_02x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0.0, 0.0),
            rotation = vector3(0.0, 0.0, 0.0),
            anim = {
                dict = "mech_inspection@newspaper@satchel",
                name = "enter_prop",
                looped = false,
                freeze = true,
            },
        },
        animation = {
            dict = "mech_inspection@newspaper@satchel",
            name = "enter",
            flag = 30,
            upperBody = true,
            filter = false
        }
    },
    ["carrybucket"]           = {
        type = "prop",
        name = "Carry Bucket",
        nonInterruptible = true,
        prop = {
            model = "p_bucket03x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0, 0.0),
            rotation = vector3(0.0, 0.0, 0.0),
            anim = {
                dict = "amb_wander@code_human_bucket_wander@full@male_a@base",
                name = "base_bucket",
                looped = true,
                freeze = true,
            }
        },
        animation = {
            dict = "amb_wander@code_human_bucket_wander@full@male_a@base",
            name = "base",
            flag = 25,
            upperBody = false,
            filter = "rightarmonly_filter"
        }
    },
    ["letteropen1"]           = {
        type = "prop",
        name = "Letter",
        interruptible = true,
        prop = {
            model = "mp005_p_mp_lettertradecripps01x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0.0, 0.0),
            rotation = vector3(0.0, 0.0, 0.0),
            anim = {
                dict = "mech_inspection@letter@satchel",
                name = "enter_prop",
                looped = false,
                freeze = true,
            },
        },
        animation = {
            dict = "mech_inspection@letter@satchel",
            name = "enter",
            flag = 26,
        }
    },
    ["letteropen2"]           = {
        type = "prop",
        name = "Letter (Empty)",
        interruptible = true,
        prop = {
            model = "mp006_s_letter_breakout_lem01x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0.0, 0.0),
            rotation = vector3(0.0, 0.0, 0.0),
            anim = {
                dict = "mech_inspection@letter@satchel",
                name = "enter_prop",
                looped = false,
                freeze = true,
            },
        },
        animation = {
            dict = "mech_inspection@letter@satchel",
            name = "enter",
            flag = 2,
            blendin = 3.0,
        }
    },
    ["letterclose1"]          = {
        type = "prop",
        name = "Letter Exit",
        interruptible = true,
        prop = {
            model = "mp005_p_mp_lettertradecripps01x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0.0, 0.0),
            rotation = vector3(0.0, 0.0, 0.0),
            anim = {
                dict = "mech_inspection@letter@satchel",
                name = "exit_prop",
                looped = false,
                freeze = true,
            },
        },
        animation = {
            dict = "mech_inspection@letter@satchel",
            name = "exit",
            flag = 28,
            blendin = 3.0,
            blendout = 2.0,
            duration = 2700,
            upperBody = true,
        }
    },
    ["letterclose2"]          = {
        type = "prop",
        name = "Letter Exit (Empty)",
        interruptible = true,
        prop = {
            model = "mp006_s_letter_breakout_lem01x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0.0, 0.0),
            rotation = vector3(0.0, 0.0, 0.0),
            anim = {
                dict = "mech_inspection@letter@satchel",
                name = "exit_prop",
                looped = false,
                freeze = true,
            },
        },
        animation = {
            dict = "mech_inspection@letter@satchel",
            name = "exit",
            flag = 4,
            duration = 4000,
        }
    },
    ["supertonic"]            = {
        type = "prop",
        name = "Super Tonic",
        prop = {
            model = "s_craftedtonic_02x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0.0, 0.0),
            rotation = vector3(0.0, 0.0, 0.0),
            anim = {
                dict = "mech_inventory@item@fallbacks@tonic_potent@offhand",
                name = "use_tonic",
                looped = false,
                freeze = true,
            },
            donterase = true,
        },
        animation = {
            dict = "mech_inventory@item@fallbacks@tonic_potent@offhand",
            name = "use",
            flag = 4,
            blendin = 8.0,
        }
    },
    ["umbrella"]              = {
        type = "prop",
        name = "Hold Umbrella",
        nonInterruptible = true,
        prop = {
            model = "p_parasol02x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0.0, -0.15),
            rotation = vector3(0.0, 10.0, 0.0)
        },
        animation = {
            dict = "script_common@other@unapproved",
            name = "umbrella_hold",
            flag = 30,
            upperBody = true,
            filter = false,
            blendout = 999999.0,
        }
    },
    ["fiddle"]                = {
        type = "prop",
        name = "Play Fiddle",
        nonInterruptible = true,
        prop = {
            model = "p_fiddle01x",
            bone = "PH_L_Hand",
            position = vector3(0.0, 0.0, 0.0),
            rotation = vector3(0.0, 0.0, 0.0)
        },
        animation = {
            dict = "ai_gestures@instruments@fiddle@standing@female@drunk",
            name = "fiddle_low_long_shorts_-1_02",
            flag = 25,
        }
    },
    -- ["carrycrate"]            = {
    --     type = "prop",
    --     name = "Carry Crate",
    --     prop = {
    --         model = "p_cs_crateammo01x",
    --         bone = "PH_L_Hand",
    --         position = vector3(-0.10, 0.05, 0.25),
    --         rotation = vector3(0.0, 0.0, 0.0)
    --     },
    --     animation = {
    --         dict = "mech_pickup@saddle_bundle@carried@human",
    --         name = "idle",
    --         flag = 25,
    --         upperBody = true,
    --         filter = false
    --     }
    -- },
    ["carrycrate2"]           = {
        type = "prop",
        name = "Carry Crate2",
        nonInterruptible = true,
        prop = {
            model = "p_cs_crateammo01x",
            bone = "PH_R_HAND",
            position = vector3(-0.1, 0.0, 0.0),
            rotation = vector3(0.0, 15.0, 0.0),
        },
        animation = {
            dict = "mech_loco_m@character@arthur@carry@crate_tnt@idle",
            name = "idle",
            flag = 25,
            upperBody = true,
            filter = "arms_filter"
        }
    },
    ["carrycrate3"]           = {
        type = "prop",
        name = "Carry Bottle Crate",
        nonInterruptible = true,
        prop = {
            model = "p_bottlecrate01x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0.0, -0.02),
            rotation = vector3(0.0, 0.0, 0.0)
        },
        animation = {
            dict = "amb_wander@code_human_box_wander@male_a@base",
            name = "base",
            flag = 25,
            upperBody = true,
            filter = false
        }
    },
    -- ["carrycrate4"]           = {
    --     type = "prop",
    --     name = "Carry Whiskey Crate",
    --     prop = {
    --         model = "p_bottlecrate02x",
    --         bone = "PH_R_Hand",
    --         position = vector3(0.0, 0.0, -0.015),
    --         rotation = vector3(0.0, 0.0, 180.0)
    --     },
    --     animation = {
    --         dict = "amb_wander@code_human_box_wander@male_a@base",
    --         name = "base",
    --         flag = 25,
    --         upperBody = true,
    --         filter = false
    --     }
    -- },
    ["carrybox"]              = {
        type = "prop",
        name = "Carry Box",
        nonInterruptible = true,
        prop = {
            model = "p_guarmarumcase",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0.0, 0.0),
            rotation = vector3(0.0, 0.0, 0.0)
        },
        animation = {
            dict = "mech_carry_box",
            name = "idle",
            flag = 25,
            upperBody = true,
            filter = false
        }
    },
    ["carrycotton"]           = {
        type = "prop",
        name = "Carry Cotton",
        nonInterruptible = true,
        prop = {
            model = "s_cottonraw01x",
            bone = "PH_R_Hand",
            position = vector3(0.0, -0.03, 0.0),
            rotation = vector3(0.0, 0.0, 0.0)
        },
        animation = {
            dict = "mech_carry_box",
            name = "idle",
            flag = 25,
            upperBody = true,
            filter = false
        }
    },
    ["carrycotton2"]          = {
        type = "prop",
        name = "Carry Cotton 2",
        nonInterruptible = true,
        prop = {
            model = "s_cottonginned01x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0.0, 0.0),
            rotation = vector3(0.0, 0.0, 0.0)
        },
        animation = {
            dict = "amb_wander@code_human_box_wander@male_a@base",
            name = "base",
            flag = 25,
            upperBody = true,
            filter = false
        }
    },
    ["carrybaby"]             = {
        type = "prop",
        name = "Carry Baby",
        nonInterruptible = true,
        prop = {
            model = "prop_stuntdoll_01",
            bone = "PH_R_Hand",
            position = vector3(0.1, 0.0, 0.0),
            rotation = vector3(70.0, 200.0, -90.0)
        },
        animation = {
            dict = "amb_camp@prop_camp_seat_chair@clean_rifle@female_a@react_look@loop@generic",
            name = "react_look_front_loop",
            flag = 25,
            upperBody = true,
            filter = false
        },
    },
    ["holdbaby"]              = {
        type = "prop",
        name = "Hold Baby Awkwardly",
        nonInterruptible = true,
        prop = {
            model = "prop_stuntdoll_01",
            bone = "PH_R_Hand",
            position = vector3(0.0, -0.15, 0.2),
            rotation = vector3(50.0, -30.0, 110.0)
        },
        animation = {
            dict = "mech_carry_box",
            name = "idle",
            flag = 25,
            upperBody = true,
            filter = false
        },
    },
    ["stick"]                 = {
        type = "prop",
        name = "Hold Stick",
        prop = {
            model = "p_stickfirepoker01x",
            bone = "skel_r_hand",
            position = vector3(0.05, -0.07, -0.03),
            rotation = vector3(-90.0, -90.0, -30.0)
        },
        animation = {
            dict = "",
            name = "",
            flag = 25
        },
        propOnly = true
    },
    ["ciga"]                  = {
        type = "prop",
        name = "Cigar",
        prop = {
            model = "p_cigarlit01x",
            bone = "skel_head",
            position = vector3(-0.015, 0.1, 0.015),
            rotation = vector3(236.4, 1100.0, -90.3)
        },
        animation = {
            dict = "",
            name = "",
            flag = 25
        },
        propOnly = true
    },
    ["cig"]                   = {
        type = "prop",
        name = "Cigarette",
        prop = {
            model = "p_cigarette_cs02x",
            bone = "skel_head",
            position = vector3(-0.015, 0.1, 0.015),
            rotation = vector3(236.4, 1100.0, -90.3)
        },
        animation = {
            dict = "",
            name = "",
            flag = 25
        },
        propOnly = true
    },
    ["hat"]                   = {
        type = "prop",
        name = "hat",
        prop = {
            model = "mp001_p_mp_hat_mr1_059",
            bone = "skel_head",
            position = vector3(0.09, 0, 0),
            rotation = vector3(100, 270, 80)
        },
        animation = {
            dict = "",
            name = "",
            flag = 25
        },
        propOnly = true
    },
    ["basket"]                = { -----------------------------------------------------------
        type = "prop",
        name = "Basket",
        nonInterruptible = true,
        prop = {
            model = "p_basket04x",
            bone = "skel_r_hand",
            position = vector3(0.26, -0.07, -0.21),
            rotation = vector3(134.0, -176.0, -124.0)
        },
        animation = {
            dict = "amb_wander@code_human_basket_wander@female_a@base",
            name = "base",
            flag = 25,
        }
    },
    ["drunkhomeless"]         = {
        type = "prop",
        name = "Drunk Homeless",
        nonInterruptible = true,
        animation = {
            dict = "script_story@gry1@ig@ig_2_takedowns@ig_2_arthur_takedown_drunk@idle_loops",
            name = "base_drunk",
            flag = 1,
        },
        prop = {
            model = "p_bottlejd01x",
            bone = "PH_L_Hand",
            position = vector3(0.02, -0.05, 0.07),
            rotation = vector3(-100.0, 30.0, 0.0)
        }
    },
    ["bardrinking1"]          = {
        type = "prop",
        name = "Bar Drinking 1",
        animation = {
            dict = "script_story@sal1@ig@sal1_ig1_drink",
            name = "arthur_drink_arthur",
            flag = 1,
        },
        prop = {
            model = "p_bottlebeer01x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0.0, 0.0),
            rotation = vector3(0.0, 0.0, 0.0),
            anim = {
                dict = "script_story@sal1@ig@sal1_ig1_drink",
                name = "arthur_drink_bottle",
                looped = false,
                freeze = true,
            }
        }
    },
    ["bardrinking2"]          = {
        type = "prop",
        name = "Bar Drinking 2",
        animation = {
            dict = "script_story@sal1@ig@sal1_ig1_drink",
            name = "arthur_long_drink_arthur",
            flag = 1,
        },
        prop = {
            model = "p_bottlebeer01x",
            bone = "PH_R_Hand",
            position = vector3(0.0, 0.0, 0.0),
            rotation = vector3(0.0, 0.0, 0.0),
            anim = {
                dict = "script_story@sal1@ig@sal1_ig1_drink",
                name = "arthur_long_drink_bottle",
                looped = false,
                freeze = true,
            }
        }
    },
    ["salute"]                = {
        type = "gesture",
        name = "Salute",
        animation = {
            dict = "script_mp@emotes@fingersalute@male@unarmed@upper",
            name = "intro",
            flag = 30,
            upperBody = true,
            blendin = 2.0,
        }
    },
    ["saluteonce"]            = {
        type = "gesture",
        name = "Salute Once",
        animation = {
            dict = "script_mp@emotes@fingersalute@male@unarmed@upper",
            name = "action",
            flag = 28,
            upperBody = true,
            blendin = 4.0,
        }
    },
    ["saluteexaggarated"]     = {
        type = "gesture",
        name = "Salute Exaggerated",
        animation = {
            dict = "script_mp@emotes@fingersalute@male@unarmed@upper",
            name = "action_alt1",
            flag = 28,
            upperBody = true,
        }
    },
    ["salutecringe"]          = {
        type = "gesture",
        name = "Salute Cringe",
        animation = {
            dict = "script_mp@emotes@fingersalute@male@unarmed@upper",
            name = "action_alt2",
            flag = 28,
            upperBody = true,
            duration = 2260 + AnimationDurationDeductor
        }
    },
    ["dogbone"]               = {
        type = "prop",
        name = "Dog Bone",
        prop = {
            model = "p_dogbone01x",
            bone = "skel_head",
            position = vector3(0.18, 0.02, 0.0),
            rotation = vector3(0.0, 90.0, 0.0)
        },
        animation = {
            dict = "",
            name = "",
            flag = 1
        },
        dogemote = true,
    },
    ["dogchewbone"]           = {
        type = "prop",
        name = "Chew on Bone",
        prop = {
            model = "p_dogbone01x",
            bone = "skel_head",
            position = vector3(0.18, 0.02, 0.0),
            rotation = vector3(0.0, 90.0, 0.0)
        },
        animation = {
            dict = "amb_creature_mammal@prop_dog_eat_bone@base",
            name = "base",
            flag = 1
        },
        dogemote = true,
    },
    ["fan"]                   = {
        type = "prop",
        name = "Fan (right hand)",
        nonInterruptible = true,
        prop = {
            model = "p_cs_fan01x",
            bone = "skel_r_hand",
            position = vector3(0.1, 0, -0.035),
            rotation = vector3(0, 150, -9)
        },
        animation = {
            dict = "amb_wander@code_human_fan_wander@female_a@base",
            name = "base",
            flag = 25,
            upperBody = true,
            filter = "rightarmonly_filter"
        }
    },
    ["fan2"]                  = {
        type = "prop",
        name = "Fan (Stuck Up)",
        nonInterruptible = true,
        prop = {
            model = "p_cs_fan01x",
            bone = "skel_l_hand",
            position = vector3(0.07, 0.02, 0.04),
            rotation = vector3(-20, 0, 0)
        },
        animation = {
            dict = "amb_camp@prop_camp_marybeth_seat_chair@fan@female_a@base",
            name = "base",
            flag = 25,
            upperBody = false,
            filter = "leftarmonly_filter"
        }
    },
    ["parasol"]               = {
        type = "prop",
        name = "Parasol",
        nonInterruptible = true,
        prop = {
            model = "p_parasol02x",
            bone = "skel_r_hand",
            position = vector3(0.07, -0.04, -0.02),
            rotation = vector3(-90.0, 0.0, 0.0)
        },
        animation = {
            dict = "amb_rest_sit@prop_human_seat_bench@parasol@female_a@wip_base",
            name = "wip_base",
            flag = 25,
            upperBody = true,
            filter = "rightarmonly_filter"
        }
    },
    ---------------------------------------------------
    --  \____/\___/ \__,_|Gestures|\___|\___/|_| |_|
    ---------------------------------------------------
    ["pointangry"]            = { -- Disable loop
        type = "gesture",
        name = "Point Angry",
        animation = {
            dict = "ai_gestures@gen_female@standing@speaker",
            name = "angry_point_r_003",
            flag = 28,
            upperBody = true,
            filter = "rightarmonly_filter",
            duration = 1700 + AnimationDurationDeductor
        }
    },
    ["howshort"]              = {
        type = "gesture",
        name = "How (Short)",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "how",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 4470 + AnimationDurationDeductor
        }
    },
    ["how"]                   = {
        type = "gesture",
        name = "How",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "how",
            flag = 28,
            upperBody = true,
            filter = false,
            freezeAt = 900,
        }
    },
    ["stop"]                  = {
        type = "gesture",
        name = "Stop",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "stop",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 2280 + AnimationDurationDeductor
        }
    },
    ["shutup"]                = {
        type = "gesture",
        name = "Shut Up",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "shut_up",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 2100 + AnimationDurationDeductor
        }
    },
    ["flip"]                  = {
        type = "gesture",
        name = "Flip Off",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "screw_you",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1790 + AnimationDurationDeductor
        }
    },
    ["me?"]                   = {
        type = "gesture",
        name = "Me?",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "bring_it_to_me",
            flag = 28,
            upperBody = true,
            filter = "rightarmonly_filter",
            duration = 2110 + AnimationDurationDeductor
        }
    },
    ["butwhy"]                = {
        type = "gesture",
        name = "But Why?",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "but_why",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 2200 + AnimationDurationDeductor
        }
    },
    ["eyy"]                   = {
        type = "gesture",
        name = "Raise Hands",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "raise_hands",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 4200 + AnimationDurationDeductor
        }
    },

    ["comehere"]              = {
        type = "gesture",
        name = "Come To Me",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "come_here",
            flag = 28,
            upperBody = true,
            filter = "rightarmonly_filter",
            duration = 2640 + AnimationDurationDeductor
        }
    },

    ["pissoff"]               = {
        type = "gesture",
        name = "Piss Off",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "piss_off",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 2540 + AnimationDurationDeductor
        }
    },

    ["negative"]              = {
        type = "gesture",
        name = "Negative",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "negative",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 2420 + AnimationDurationDeductor
        }
    },
    ["nod"]                   = {
        type = "gesture",
        name = "Nod",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "gesture_pleased",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1940 + AnimationDurationDeductor
        }
    },
    ["spit"]                  = {
        type = "gesture",
        name = "Spit",
        animation = {
            dict = "script_re@harassment_attack",
            name = "spit",
            flag = 28,
            upperBody = true,
            filter = "headandneckonly_filter",
            duration = 3430 + AnimationDurationDeductor
        }
    },
    ["spit2"]                 = {
        type = "gesture",
        name = "Spit 2",
        animation = {
            dict = "amb_wander@upperbody_idles@seated@spitting_male@male_a@idle_a",
            name = "idle_c",
            flag = 28,
            upperBody = true,
            filter = "headandneckonly_filter",
            duration = 4360 + AnimationDurationDeductor
        }
    },
    ["spit3"]                 = {
        type = "gesture",
        name = "Spit 3",
        animation = {
            dict = "amb_wander@upperbody_idles@seated@spitting_male@male_a@idle_a",
            name = "idle_b",
            flag = 28,
            upperBody = true,
            filter = "headandneckonly_filter",
            duration = 3530 + AnimationDurationDeductor
        }
    },
    ["spit4"]                 = {
        type = "gesture",
        name = "Spit 4",
        animation = {
            dict = "amb_wander@upperbody_idles@seated@spitting_male@male_a@idle_a",
            name = "idle_a",
            flag = 28,
            upperBody = true,
            filter = "headandneckonly_filter",
            duration = 2850 + AnimationDurationDeductor
        }
    },
    ["spit5"]                 = {
        type = "gesture",
        name = "Spit 5",
        animation = {
            dict = "script_respawn@one_shot@upperbody@spitlongarm_lhand@c",
            name = "respawn_action",
            flag = 28,
            upperBody = false,
            filter = "headneckandrightarm_filter",
            duration = 1500
        }
    },
    ["isaidno"]               = {
        type = "gesture",
        name = "I Said No",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "i_said_no",
            flag = 28,
            upperBody = true,
            filter = "rightarmonly_filter",
            duration = 2310 + AnimationDurationDeductor
        }
    },
    ["enough"]                = {
        type = "gesture",
        name = "Enough",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "enough",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 2630 + AnimationDurationDeductor
        }
    },
    ["exactly"]               = {
        type = "gesture",
        name = "Exactly",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "exactly",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1600 + AnimationDurationDeductor
        }
    },
    ["forgetit"]              = {
        type = "gesture",
        name = "Forget It",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "forget_it",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 2480 + AnimationDurationDeductor
        }
    },
    ["pushwagon"]             = {
        type = "gesture",
        name = "Push Wagon",
        animation = {
            dict = "script_common@other@unapproved",
            name = "push_car_loop",
            flag = 1
        }
    },
    ["fuckoff"]               = {
        type = "gesture",
        name = "Go Away",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "gesture_bye_hard",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1560 + AnimationDurationDeductor
        }
    },

    ["unbelievable"]          = {
        type = "gesture",
        name = "Unbelievable",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "unbelievable",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 2150 + AnimationDurationDeductor
        }
    },

    ["goaway"]                = {
        type = "gesture",
        name = "Go Away",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "go_away",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1740 + AnimationDurationDeductor
        }
    },
    ["understand"]            = {
        type = "gesture",
        name = "Understand",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "u_understand",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 2090 + AnimationDurationDeductor
        }
    },
    ["gimmebreak"]            = {
        type = "gesture",
        name = "Give Me a Break",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "give_me_a_break",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 2330 + AnimationDurationDeductor
        }
    },
    ["userious"]              = {
        type = "gesture",
        name = "You Serious",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "u_serious",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 2000 + AnimationDurationDeductor
        }
    },

    ["youandme"]              = {
        type = "gesture",
        name = "You and Me",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "getsure_its_mine",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 2240 + AnimationDurationDeductor
        }
    },

    ["relax"]                 = {
        type = "gesture",
        name = "Relax",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "gesture_easy_now",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1790 + AnimationDurationDeductor
        }
    },


    ["nono"]                        = {
        type = "gesture",
        name = "No No",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "u_cant_do_that",
            flag = 28,
            upperBody = true,
            filter = "rightarmonly_filter",
            duration = 2170 + AnimationDurationDeductor
        }
    },

    ["fuckit"]                      = {
        type = "gesture",
        name = "To Hell With It",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "to_hell_with_it",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 3200 + AnimationDurationDeductor
        }
    },
    ["anger"]                       = {
        type = "gesture",
        name = "Anger",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "anger_a",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 2330 + AnimationDurationDeductor
        }
    },
    ["shake_fist"]                  = {
        type = "gesture",
        name = "Nervous Shoulder Stretching",
        animation = {
            dict = "ai_gestures@arthur@standing@grapple@unarmed",
            name = "nervous_shoulder_stretching",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 3870 + AnimationDurationDeductor
        }
    },
    ["nervous_shoulder_stretching"] = {
        type = "gesture",
        name = "Nervous Shoulder Stretching",
        animation = {
            dict = "ai_gestures@arthur@standing@grapple@unarmed",
            name = "nervous_shoulder_stretching",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 3870 + AnimationDurationDeductor
        }
    },
    ["amazing"]                     = {
        type = "gesture",
        name = "Amazing",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "amazing",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 3230 + AnimationDurationDeductor
        }
    },

    ["threaten"]                    = {
        type = "gesture",
        name = "Threaten",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "threaten",
            flag = 28,
            upperBody = true,
            filter = "leftarmonly_filter",
            duration = 1200 + AnimationDurationDeductor
        }
    },

    ["protest"]                     = {
        type = "gesture",
        name = "Protest Idle A",
        animation = {
            dict = "script_common@other@unapproved",
            name = "protest_female_idle_a",
            flag = 28,
            upperBody = true,
            filter = "arms_filter",
            duration = 6470 + AnimationDurationDeductor
        }
    },
    ["protest2"]                    = {
        type = "gesture",
        name = "Protest Idle B",
        animation = {
            dict = "script_common@other@unapproved",
            name = "protest_female_idle_b",
            flag = 28,
            upperBody = true,
            filter = "arms_filter",
            duration = 6470 + AnimationDurationDeductor
        }
    },
    ["protest3"]                    = {
        type = "gesture",
        name = "Protest Idle C",
        animation = {
            dict = "script_common@other@unapproved",
            name = "protest_female_idle_c",
            flag = 25,
            upperBody = true,
            filter = "arms_filter"
        }
    },
    ["foldarms"]                    = {
        type = "gesture",
        name = "Fold Arms",
        animation = {
            dict = "script_common@other@unapproved",
            name = "unarmed_fold_arms",
            flag = 25,
            upperBody = true,
            filter = "arms_filter"
        }
    },
    ["handsonhip_upper"] = {
        type = "gesture",
        name = "Hands on Hip (Upper Body)",
        animation = {
            dict = "amb_rest@world_human_sternguy@male_a@base",
            name = "base",
            flag = 25,
        }
    },
    ["handsonhip"]            = {
        type = "gesture",
        name = "Hands on Hip",
        animation = {
            dict = "amb_rest@world_human_sternguy@male_a@base",
            name = "base",
            flag = 1,
        }
    },
    ["handsbehindback"]           = {
        type = "gesture",
        name = "Hands Behind Back",
        animation = {
            dict = "amb_misc@world_human_stand_waiting@male_b@idle_a",
            name = "idle_b",
            flag = 25,
            upperBody = true,
            filter = "arms_filter"
        }
    },
    ["crossarms"]                       = {
        type = "gesture",
        name = "Cross Arms",
        animation = {
            dict = "amb_misc@world_human_stare_stoic@male_a@base",
            name = "base",
            flag = 25,
            upperBody = true,
            filter = "arms_filter"
        }
    },
    ["priestidle"]            = {
        type = "gesture",
        name = "Hands in Front",
        animation = {
            dict = "script_rc@cldn@leadout@rsc6",
            name = "idle_priest",
            flag = 25,
            upperBody = true,
            filter = false
        }
    },
    ["vomit"]                       = {
        type = "gesture",
        name = "Vomit",
        animation = {
            dict = "amb_misc@world_human_vomit@male_a@idle_c",
            name = "idle_h",
            flag = 1
        }
    },
    ["kneelvomit"]                  = {
        type = "gesture",
        name = "Kneel Vomit",
        animation = {
            dict = "amb_misc@world_human_vomit_kneel@male_a@idle_c",
            name = "idle_g",
            flag = 1
        }
    },
    ["knock"]                   = {
        type = "gesture",
        name = "Knock",
        animation = {
            dict = "amb_misc@world_human_door_knock@male_a@idle_a",
            name = "idle_b",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 2000 + AnimationDurationDeductor
        }
    },
    ["knockeddown"]           = {
        type = "gesture",
        name = "Get Knocked Down",
        animation = {
            dict = "veh_train@handcart@base",
            name = "die",
            flag = 2
        }
    },
    ["hellno"]                      = {
        type = "gesture",
        name = "Hell No!",
        animation = {
            dict = "script_common@other@unapproved",
            name = "car_deal_refuse_buyer",
            flag = 4
        }
    },
    ["kneel"]                       = {
        type = "gesture",
        name = "Kneel",
        animation = {
            dict = "script_common@other@unapproved",
            name = "medic_kneel_base",
            flag = 1
        }
    },
    ["cry"]                         = {
        type = "gesture",
        name = "Cry",
        animation = {
            dict = "script_common@other@unapproved",
            name = "cry_loop",
            flag = 25
        }
    },
    ["punch1"]                      = {
        type = "gesture",
        name = "Punch",
        animation = {
            dict = "script_common@other@unapproved",
            name = "plyr_punch",
            flag = 4
        }
    },
    ["come_here_hard"]              = {
        type = "gesture",
        name = "Come",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "gesture_come_here_hard",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1550 + AnimationDurationDeductor
        }
    },
    ["come_here_soft"]              = {
        type = "gesture",
        name = "Come (Alt)",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "gesture_come_here_soft",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1700 + AnimationDurationDeductor
        }
    },
    ["nod_yes_hard"]                = {
        type = "gesture",
        name = "Nod Yes (Hard)",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "gesture_nod_yes_hard",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1280 + AnimationDurationDeductor
        }
    },
    ["nod_yes_soft"]                = {
        type = "gesture",
        name = "Nod Yes (Soft)",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "gesture_nod_yes_soft",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1460 + AnimationDurationDeductor
        }
    },
    ["nod_no_hard"]                 = {
        type = "gesture",
        name = "Nod No (Hard)",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "gesture_nod_no_hard",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1710 + AnimationDurationDeductor
        }
    },
    ["nod_no_soft"]                 = {
        type = "gesture",
        name = "Nod No (Soft)",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "gesture_nod_no_soft",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1350 + AnimationDurationDeductor
        }
    },
    ["shrug_hard"]                  = {
        type = "gesture",
        name = "Shrug (Hard)",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "gesture_shrug_hard",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1750 + AnimationDurationDeductor
        }
    },
    ["shrug_soft"]                  = {
        type = "gesture",
        name = "Shrug (Soft)",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "gesture_shrug_soft",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1430 + AnimationDurationDeductor
        }
    },
    ["me"]                          = {
        type = "gesture",
        name = "Me",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "gesture_me",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1220 + AnimationDurationDeductor
        }
    },
    ["me_hard"]                     = {
        type = "gesture",
        name = "Me (Hard)",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "gesture_me_hard",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1440 + AnimationDurationDeductor
        }
    },

    ["dont_u_dare"]                 = {
        type = "gesture",
        name = "Don't You Dare",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "gesture_i_will",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1430 + AnimationDurationDeductor
        }
    },
    ["head_no"]                     = {
        type = "gesture",
        name = "Head No",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "gesture_head_no",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1430 + AnimationDurationDeductor
        }
    },

    ["what_hard"]                   = {
        type = "gesture",
        name = "What (Hard)",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "gesture_what_hard",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1800 + AnimationDurationDeductor
        }
    },
    ["what_soft"]                   = {
        type = "gesture",
        name = "What (Soft)",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "gesture_what_soft",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1610 + AnimationDurationDeductor
        }
    },

    ["why"]                         = {
        type = "gesture",
        name = "Why",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "gesture_why",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1630 + AnimationDurationDeductor
        }
    },
    ["why_left"]                    = {
        type = "gesture",
        name = "Why (Left)",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "gesture_why_left",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1640 + AnimationDurationDeductor
        }
    },

    ["hand_right"]                  = {
        type = "gesture",
        name = "Hand Right",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "gesture_hand_right",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1620 + AnimationDurationDeductor
        }
    },
    ["hand_left"]                   = {
        type = "gesture",
        name = "Hand Left",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "gesture_hand_left",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1840 + AnimationDurationDeductor
        }
    },
    ["hand_down"]                   = {
        type = "gesture",
        name = "Hand Down",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "gesture_hand_down",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1740 + AnimationDurationDeductor
        }
    },

    ["point"]                       = {
        type = "gesture",
        name = "Point",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "gesture_point",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1460 + AnimationDurationDeductor
        }
    },
    ["you_hard"]                    = {
        type = "gesture",
        name = "You (Hard)",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "gesture_you_hard",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1980 + AnimationDurationDeductor
        }
    },
    ["you_soft"]                    = {
        type = "gesture",
        name = "You (Soft)",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "gesture_you_soft",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1440 + AnimationDurationDeductor
        }
    },
    ["displeased"]                  = {
        type = "gesture",
        name = "Displeased",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "gesture_displeased",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 2610 + AnimationDurationDeductor
        }
    },
    ["pleased"]                     = {
        type = "gesture",
        name = "Pleased",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "gesture_pleased",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1950 + AnimationDurationDeductor
        }
    },
    ["no_way"]                      = {
        type = "gesture",
        name = "No Way",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "gesture_no_way",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1790 + AnimationDurationDeductor
        }
    },

    ["bye_soft"]                    = {
        type = "gesture",
        name = "Bye (Soft)",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "gesture_bye_soft",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1640 + AnimationDurationDeductor
        }
    },

    ["we_can_do_it"]                = {
        type = "gesture",
        name = "We Can Do It",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "we_can_do_it",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1670 + AnimationDurationDeductor
        }
    },
    ["how_could_you"]               = {
        type = "gesture",
        name = "How Could You?",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "how_could_you",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1900 + AnimationDurationDeductor
        }
    },
    ["how_much"]                    = {
        type = "gesture",
        name = "How Much?",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "how_much",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1390 + AnimationDurationDeductor
        }
    },
    ["i_cant_say"]                  = {
        type = "gesture",
        name = "I Can't Say",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "i_cant_say",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 2180 + AnimationDurationDeductor
        }
    },
    ["i_dont_have"]                 = {
        type = "gesture",
        name = "I Don't Have",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "i_dont_have",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1740 + AnimationDurationDeductor
        }
    },
    ["i_said_no"]                   = {
        type = "gesture",
        name = "I Said No",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "i_said_no",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 2290 + AnimationDurationDeductor
        }
    },
    ["dont_know"]                   = {
        type = "gesture",
        name = "Don't Know",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "dont_know",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 2680 + AnimationDurationDeductor
        }
    },
    ["im_telling_you"]              = {
        type = "gesture",
        name = "I'm Telling You",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "im_telling_you",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 2930 + AnimationDurationDeductor
        }
    },
    ["despair"]                     = {
        type = "gesture",
        name = "Despair",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "despair",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1980 + AnimationDurationDeductor
        }
    },
    ["is_this_it"]                  = {
        type = "gesture",
        name = "Is This It?",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "is_this_it",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 3160 + AnimationDurationDeductor
        }
    },
    ["come_on"]                     = {
        type = "gesture",
        name = "Come On",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "come_on",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1350 + AnimationDurationDeductor
        }
    },
    ["of_course"]                   = {
        type = "gesture",
        name = "Of Course",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "of_course",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 2030 + AnimationDurationDeductor
        }
    },
    ["say_again"]                   = {
        type = "gesture",
        name = "Say Again",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "say_again",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 2990 + AnimationDurationDeductor
        }
    },
    ["bring_it_on"]                 = {
        type = "gesture",
        name = "Come At Me",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "bring_it_on",
            flag = 28,
            upperBody = true,
            filter = "arms_filter",
            freezeAt = 850
        }
    },
    ["bring_it"]                    = {
        type = "gesture",
        name = "Bring It On",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "bring_it_on",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1970 + AnimationDurationDeductor
        }
    },
    ["damn_alt"]                    = {
        type = "gesture",
        name = "Damn",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "gesture_damn",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 2030 + AnimationDurationDeductor
        }
    },

    ["damn"]                        = {
        type = "gesture",
        name = "Damn (Alt)",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "damn",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1390 + AnimationDurationDeductor
        }
    },
    ["hey"]                         = {
        type = "gesture",
        name = "Hey",
        animation = {
            dict = "script_common@gestures@unapproved",
            name = "gesture_hello",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1480 + AnimationDurationDeductor
        }
    },
    ["hello"]                       = {
        type = "gesture",
        name = "Hello",

        animation = {
            dict = "script_common@gestures@unapproved",
            name = "hey",
            flag = 28,
            upperBody = true,
            filter = false,
            duration = 1250 + AnimationDurationDeductor
        }
    },
}
