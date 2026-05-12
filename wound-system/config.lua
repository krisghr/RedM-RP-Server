Config = {}

Config.Debug = false
Config.AllowDebugCommandsWithoutAce = true
Config.DamagePollMs = 350
Config.CleanupIntervalMs = 60000
Config.MaxTotalReductionPercent = 75
Config.MinimumStatPercent = 25
Config.NpcDoctorCost = 0 -- Placeholder for economy integration.
Config.UseVorpIdentity = true
Config.DefaultMaxHealth = 200
Config.DefaultMaxStamina = 100
Config.AnimalDetectionRadius = 10.0

Config.BodyParts = {
    "head", "neck", "torso", "left_arm", "right_arm", "left_leg", "right_leg"
}

Config.DamageCategories = {
    melee = {
        display = "Melee",
        chances = { minor = 8, severe = 1 },
        minorPool = { "Bruising" },
        severePool = { "Concussion", "Broken Nose" },
        minorHours = { 4, 10 },
        severeHours = { 20, 30 },
        penalties = {
            minor = { hp = 5, stamina = 5 },
            severe = { hp = 15, stamina = 12 }
        }
    },
    knife = {
        display = "Knife/Blade",
        chances = { minor = 18, severe = 5 },
        minorPool = { "Shallow Cut" },
        severePool = { "Deep Stab Wound" },
        minorHours = { 8, 14 },
        severeHours = { 20, 30 },
        penalties = {
            minor = { hp = 8, stamina = 6 },
            severe = { hp = 18, stamina = 14 }
        }
    },
    gunshot = {
        display = "Gunshot",
        chances = { minor = 20, severe = 6 },
        minorPool = { "Graze Wound" },
        severePool = { "Lodged Bullet" },
        minorHours = { 6, 12 },
        severeHours = { 20, 30 },
        penalties = {
            minor = { hp = 10, stamina = 8 },
            severe = { hp = 50, stamina = 22 }
        }
    },
    shotgun = {
        display = "Shotgun",
        chances = { minor = 25, severe = 8 },
        minorPool = { "Pellet Graze" },
        severePool = { "Pellet Trauma" },
        minorHours = { 6, 12 },
        severeHours = { 20, 30 },
        penalties = {
            minor = { hp = 12, stamina = 10 },
            severe = { hp = 35, stamina = 20 }
        }
    },
    animal = {
        display = "Animal Attack",
        chances = { minor = 22, severe = 7 },
        minorPool = { "Minor Lacerations" },
        severePool = { "Deep Lacerations" },
        minorHours = { 8, 16 },
        severeHours = { 20, 30 },
        penalties = {
            minor = { hp = 12, stamina = 10 },
            severe = { hp = 30, stamina = 22 }
        }
    },
    predator = {
        display = "Large Predator",
        chances = { minor = 30, severe = 12 },
        minorPool = { "Predator Claw Wounds" },
        severePool = { "Mauling Wounds" },
        minorHours = { 10, 18 },
        severeHours = { 48, 48 },
        penalties = {
            minor = { hp = 12, stamina = 10 },
            severe = { hp = 40, stamina = 25 }
        }
    },
    fall = {
        display = "Fall",
        chancesByDamage = {
            { damage = 15, minor = 6, severe = 0 },
            { damage = 30, minor = 12, severe = 2 },
            { damage = 45, minor = 18, severe = 5 },
            { damage = 70, minor = 26, severe = 10 }
        },
        minorPool = { "Sprained Ankle" },
        severePool = { "Broken Arm", "Broken Leg" },
        minorHours = { 12, 24 },
        severeHours = { 20, 48 },
        penalties = {
            minor = { hp = 10, stamina = 12 },
            severe = { hp = 22, stamina = 22 }
        }
    },
    fire = {
        display = "Fire",
        chances = { minor = 15, severe = 4 },
        minorPool = { "Minor Burns" },
        severePool = { "Severe Burns" },
        minorHours = { 8, 16 },
        severeHours = { 48, 48 },
        penalties = {
            minor = { hp = 8, stamina = 6 },
            severe = { hp = 30, stamina = 22 }
        }
    },
    explosion = {
        display = "Explosion",
        chances = { minor = 20, severe = 10 },
        minorPool = { "Blast Bruising" },
        severePool = { "Blast Trauma" },
        minorHours = { 10, 20 },
        severeHours = { 24, 48 },
        penalties = {
            minor = { hp = 12, stamina = 10 },
            severe = { hp = 30, stamina = 24 }
        }
    }
}

Config.WeaponHints = {
    shotgun = { `WEAPON_SHOTGUN_DOUBLEBARREL`, `WEAPON_SHOTGUN_PUMP`, `WEAPON_SHOTGUN_REPEATING`, `WEAPON_SHOTGUN_SAWEDOFF` },
    knife = { `WEAPON_MELEE_KNIFE`, `WEAPON_MELEE_KNIFE_JAWBONE`, `WEAPON_THROWN_THROWING_KNIVES` },
    fire = { `WEAPON_MOLOTOV`, `WEAPON_MOLOTOV_VOLATILE`, `WEAPON_THROWN_TORCH` },
    explosion = { `WEAPON_THROWN_DYNAMITE`, `WEAPON_THROWN_DYNAMITE_VOLATILE`, `WEAPON_THROWN_POISONBOTTLE` }
}
