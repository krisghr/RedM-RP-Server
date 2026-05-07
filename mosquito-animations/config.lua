Config = {}
Config.Debug = true -- ⚠️ ensure that this is false on live servers.
-- These are the commands that you use to trigger each type of animation, each one responsible for each one of the 3 tables in animations.lua.
-- EXAMPLE: /e dance1 would play the "dance1" emote.
Config.NativeEmoteCommand = "ne" -- The native emotes from Multiplier
Config.ScenarioCommand = "s"     -- The scenario animations
Config.EmoteCommand = "e"        -- The custom emotes/animations in Config.Emotes


-- Set to false to disable the sit ledge command,
Config.SitLedgeCommand = "sitledge"   -- The sit ledge command, it will make the player sit on the nearest ledge infront of him
Config.SitBehindCommand = "sitbehind" -- The sit behind command, it will make the player sit on the nearest ledge infront of him but facing the opposite direction, this is useful for scenarios like campfires or sitting on benches with friends

Config.SitBehindPromptEnabled = true
Config.SitLedgePromptEnabled = true


-- Seating Teleports
Config.SitLedgeTeleport = true                                   -- RECOMMENDED TO KEEP true, Whether to teleport the player to the ledge when using the sit ledge command, this is to avoid exploits, but may cause exploits if script not functioned as intended.
Config.SitBehindTeleport = true                                  -- RECOMMENDED TO KEEP true, Whether to teleport the player back to the original position before sitting down, this is to avoid exploits, but may cause exploits if script not functioned as intended.

Config.SitBehindInstantTeleport = { enter = true, exit = true }  -- RECOMMENDED TO KEEP trueWhether to instantly teleport the player to the position behind the ledge when using the sit behind command, or to do a quick fade out, teleport and fade in, this is to avoid exploits, but may cause exploits if script not functioned as intended.
Config.SitLedgeInstantTeleport = { enter = false, exit = false } -- RECOMMENDED TO KEEP true, Whether to instantly teleport the player to the ledge when using the sit ledge command, or to do a quick fade out, teleport and fade in, this is to avoid exploits, but may cause exploits if script not functioned as intended

Config.SitBehindMaxSeatHeight = 1.0                              -- The maximum height difference allowed for sitting behind a ledge
Config.SitBehindMaxSeatHeightForAnimation = 0.7


Config.SitBehindControl = { Keyboard = "INPUT_FRONTEND_DOWN", Controller = "INPUT_LOOK_BEHIND" } -- The control to use for the sit behind action, will be shown when quick emote menu is open.
Config.SitBehindPromptText = "Take a seat behind"
Config.SitLedgeControl = { Keyboard = "INPUT_FRONTEND_UP", Controller = "INPUT_WHISTLE" }        -- The control to use for the sit ledge action
Config.SitLedgePromptText = "Sit on ledge in front"

Config.CancelControl = "INPUT_FRONTEND_RS"                                                   -- The control to cancel an emote/animation, set to false to disable
Config.CancelControlClearsPedTasks = false                                                   -- Whether to clear ped tasks when using CancelControl evenn if not playing an animation through the script, I suggest setting to false
Config.HandsUpControl = { Keyboard = "INPUT_FRONTEND_RS", Controller = "INPUT_PLAYER_MENU" } -- X
Config.HandsUpWalkSpeed = 1.5                                                                -- The speed of walking/running when hands up is active

Config.Pointing = true                                                                       -- Enable or disable the pointing feature
Config.PointControlType = { Keyboard = "hold", Controller = "toggle" }                       -- Control type, whether to toggle or hold ("hold", "toggle",), for keyboard and controller separately
Config.DisableActionControl = { Keyboard = false, Controller = false }
Config.PointControlUseRawKey = false
Config.PointControl = { Keyboard = "INPUT_OPEN_SATCHEL_MENU", Controller = "INPUT_SELECT_RADAR_MODE" } -- Conntrols to use for pointing, for keyboard and controller separately
Config.PointingWalkSpeed = 2.0
Config.PointingDrawPointer = false                                                                     -- Draw the pointer/Crosshair when pointing
Config.PointingTogglePromptText = "Press %s to stop pointing"

-- These following settings are a bit more technical, you can leave them as default unless you want to tweak the pointing behavior
Config.PointingIsolateArm = true                -- Isolate the pointing arm, it looks a bit more unrealistic, but it allows to point vertically as well.
Config.PointingSyncIsolateArm = true            -- In order for other players to see your pointing animation and IK, this requires a bit more network usage as the pointing direction needs to be synced to other players
Config.PointingSyncingBreakTickPlayerCount = 10 -- The amount of players nearby required to break the pointing syncing into ticks rather than every frame, to save network usage on servers with many players
Config.PointingSmoothBase = 4.0                 -- The base speed of the pointing IK smoothing
Config.PointingSmoothAccel = 10.0               -- The acceleration factor of the pointing IK smoothing
Config.PointingSmoothMax = 5.0                  -- The maximum speed of the pointing IK smoothing
Config.PointingBehindThreshold = {              -- The threshold in degrees to consider the player is behind the target when pointing
	standing = { normal = { right = 100.0, left = 70.0 }, lookingup = { right = 90.0, left = 55.0 }, },
	crouching = { normal = { right = 75.0, left = 30.0 }, lookingup = { right = 60.0, left = 20.0 }, },
}
Config.PointingUpValue = 25.0               -- 25.0 deg, the angle threshold to consider the player is looking up when pointing

Config.AnimationWalkSpeed = 1.5             -- When using an upper body emote, the speed of walk/running will be limited based on this value in order to prevent goofy movement

Config.PauseMenuAndMapAnimations = true     -- Pause menu and map animations when opening the pause menu or map

Config.LeaningRailingFeatureEnabled = false -- EXPERIMENTAL: Enable or disable the leaning on railing feature, where if near specific objects the player will get the option to lean on them

Config.SharedEmoteOnPeds = true             -- Enable/Disable the shared emote feature on NPC peds as well, if false it will only work on players with consent
Config.SharedEmoteRange = 3.0
Config.SharedEmoteTimeout = 5000
Config.SharedEmoteMustAccept = true -- Whether the other player must accept the shared emote request in order for it to play, it forces the recipient player

Config.SharedEmoteAcceptControl = "INPUT_LOOK_BEHIND"
Config.SharedEmoteRejectControl = "INPUT_RELOAD"
Config.SharedEmoteAcceptText = "Accept ~%s~"
Config.SharedEmoteRejectText = "Reject ~%s~"
Config.SharedEmoteHasBeenRejectedText = "ID ~COLOR_GREEN~%s~q~ rejected your emote request."
Config.SharedEmoteRequestWantsToUseText = "ID ~COLOR_GREEN~%s~q~ wants to use ~COLOR_RED~%s~q~. Expires in " .. "%s" .. "s..."
Config.SharedEmoteNobodyNearbyText = "Nobody in range"
Config.SharedEmoteRequestSentText = "Emote request sent to ID ~COLOR_GREEN~%s~q~."

-- Don't worry too much about the names of these settings below, it's just called "...RegularVORPMENU..." because originally this feature was made for VORP framework's vorp_menu, but now it also supports RSG's rsg-menubase
Config.EnableRegularVORPMenu = true                                                                  -- Enable/Disable the regular emote menu feature, this relies on vorp_menu or rsg-menubase script to be installed which is already installed if you're using VORP or RSG framework
Config.RegularVORPMenuCommand = "openAnims"
Config.RegularVORPMenuKeybind = { Keyboard = "INPUT_PLAYER_MENU", Controller = "INPUT_PLAYER_MENU" } -- or set each one individually to false, to disable keybinds so if you wanna disable both: { Keyboard = false, Controller = false }
Config.RegularVORPMenuTitle = "Mosquito Animations"
Config.WalkstyleSaveToCharacter = true                                                               -- Save the selected walkstyle to the the specific character in use, if false it will save to the user accross all characters
Config.MaxBlendMoveRatio = 1.0                                                                       -- Global walking limiter base value. If set to exactly 1.0, custom limiter is treated as disabled.
Config.Framework = "VORP"                                                                            -- supported for "RSG" or "VORP" only, this is the framework in use, this only matters in order to apply and save the walk styles to the player

---------------------------------   \    /
--- QUICK EMOTE MENU SETTINGS ---    \  /
---------------------------------     \/

Config_QuickMenu = {}
Config_QuickMenu.Enabled = true                            -- Enable/Disable the quick emote menu feature
-- NEW 19/12/2025
Config_QuickMenu.SettingsMenuCommand = "quickmenuposition" -- Command to open the quick emote menu
-- NEW 19/12/2025
Config_QuickMenu.MenuScale = 0.8                           -- Scale of the emote menu
Config_QuickMenu.MenuFont = 30                             -- Font of the emote menu, you can change this to any valid font id, just make sure to adjust the MenuTextScale as well if you choose a font that is bigger or smaller than the default one
Config_QuickMenu.MenuTextScale = 0.35                      -- Scale of the text in the emote menu, you can adjust this if you want smaller or bigger text in the menu, it will also affect the description text scale
-- NEW 19/12/2025
Config_QuickMenu.MenuTextOffset = { x = 0.0, y = 0.0 }     -- Offset to apply to the text position in the emote menu, values are in screen percentage (0.0 - 1.0)
-- NEW 19/12/2025
Config_QuickMenu.MenuPositionOffset = { x = 0.0, y = 0.0 } -- Offset to apply to the emote menu position, values are in screen percentage (0.0 - 1.0), the higher the farther away from the top left corner, this will be applied + the user's settings saved in the database
Config_QuickMenu.FavoriteEmotesMenuLimit = 36              -- The limit for the amount of favorite emotes a player can have. Make sure this is increments of EmotesPerPage for uniformity so all pages are the same length.
Config_QuickMenu.DefaultControllerLayout = 1               -- 1 = XBOX, 2 = PlayStation, it doesn't have an affect just the icons for the controller layout in the menu
Config_QuickMenu.EmotesPerPage = {                         -- of cousre if you want to increase the number you must add more controls in the Config_QuickMenu.KeyboardMenuControls and Config_QuickMenu.ControllerMenuControls
	["keyboard"] = 9,
	["controller"] = 4,
}
Config_QuickMenu.ColorEachMenuKeybindByType = true -- Color each keybind in the emote menu based on the type of emote it is (favorite, gesture, prop, solo, scenario, emote, shared)
Config_QuickMenu.MenuTimeout = 30000               -- Time in milliseconds before the emote menu auto closes, set to 0 to disable auto close
Config_QuickMenu.MenuLanguage = {
	pickAnEmoteSubtitle = { text = "Select an emote", color = { 255, 255, 255, 200 } },
	pickAnEmoteSpot = { text = "You have ~COLOR_GOLD~ %s ~q~ selected to favorite. Pick a slot to add it to.", color = { 255, 255, 255, 200 } },
	pickAnEmoteToFavorite = { text = "Add to favorites", color = { 255, 215, 0 } },
	emotesOnly = { text = " ~q~(emotes only)~q~" },
	exitMenu = { text = "Stop Emote / Hold to Close", color = { 255, 64, 64, 255 } },
	pageNumber = { text = "Page ", color = { 255, 255, 255, 255 } },
	switchEmoteTable = { text = "Switch Table", color = { 255, 255, 128, 255 } },
	switchControllerLayout = { text = "Switch Controller Layout - ", color = { 255, 255, 128, 255 } },
	favoriteAnEmote = { text = "Favorite Emote", color = { 255, 215, 0, 200 } },
	stopFavoriting = { text = "Stop Favoriting", color = { 255, 64, 64, 255 } },
}

-- {"25":{"animation_type":"emote","animation_command":"thumbs_up"},"26":{"animation_type":"emote","animation_command":"thumbs_down_1"},"27":{"animation_type":"gesture","animation_command":"come_on"},"22":{"animation_type":"emote","animation_command":"greeting_1"},"12":{"animation_type":"gesture","animation_command":"no_way"},"13":{"animation_type":"gesture","animation_command":"flip"},"14":{"animation_type":"gesture","animation_command":"shrug_hard"},"18":{"animation_command":"god","animation_type":"gesture"},"17":{"animation_type":"gesture","animation_command":"foldarms"},"16":{"animation_command":"nod_yes_soft","animation_type":"gesture"},"15":{"animation_type":"gesture","animation_command":"butwhy"},"11":{"animation_type":"emote","animation_command":"dance_wild_a"},"23":{"animation_type":"emote","animation_command":"greeting_2"},"19":{"animation_type":"emote","animation_command":"laugh_2"},"21":{"animation_type":"emote","animation_command":"dance_carefree_b"},"7":{"animation_type":"emote","animation_command":"facepalm_1"},"6":{"animation_type":"gesture","animation_command":"salute"},"24":{"animation_type":"emote","animation_command":"show_1"},"9":{"animation_type":"gesture","animation_command":"damn_alt"},"8":{"animation_type":"solo","animation_command":"crouch"},"20":{"animation_type":"emote","animation_command":"follow_me"},"10":{"animation_type":"gesture","animation_command":"amazing"},"5":{"animation_type":"gesture","animation_command":"pointangry"},"4":{"animation_type":"gesture","animation_command":"bring_it_on"},"3":{"animation_type":"emote","animation_command":"respect_1"},"2":{"animation_type":"gesture","animation_command":"me_hard"},"1":{"animation_type":"emote","animation_command":"slow_clap"}}
-- If you wanna have an empty favorite emote menu by default, just set this to Config.PresetFavoriteEmotes = {}
Config.PresetFavoriteEmotes = { -- A table of what will show up in the favorite emote menu by default, can be customized by players later
	[1]  = { animation_type = "emote", animation_command = "slow_clap" },
	[2]  = { animation_type = "gesture", animation_command = "me_hard" },
	[3]  = { animation_type = "emote", animation_command = "respect_1" },
	[4]  = { animation_type = "gesture", animation_command = "bring_it_on" },
	[5]  = { animation_type = "gesture", animation_command = "pointangry" },
	[6]  = { animation_type = "gesture", animation_command = "salute" },
	[7]  = { animation_type = "emote", animation_command = "facepalm_1" },
	[8]  = { animation_type = "solo", animation_command = "crouch" },
	[9]  = { animation_type = "gesture", animation_command = "damn_alt" },
	[10] = { animation_type = "gesture", animation_command = "amazing" },
	[11] = { animation_type = "emote", animation_command = "dance_wild_a" },
	[12] = { animation_type = "gesture", animation_command = "no_way" },
	[13] = { animation_type = "gesture", animation_command = "flip" },
	[14] = { animation_type = "gesture", animation_command = "shrug_hard" },
	[15] = { animation_type = "gesture", animation_command = "butwhy" },
	[16] = { animation_type = "gesture", animation_command = "nod_yes_soft" },
	[17] = { animation_type = "gesture", animation_command = "foldarms" },
	[18] = { animation_type = "gesture", animation_command = "god" },
	[19] = { animation_type = "emote", animation_command = "laugh_2" },
	[20] = { animation_type = "emote", animation_command = "follow_me" },
	[21] = { animation_type = "emote", animation_command = "dance_carefree_b" },
	[22] = { animation_type = "emote", animation_command = "greeting_1" },
	[23] = { animation_type = "emote", animation_command = "greeting_2" },
	[24] = { animation_type = "emote", animation_command = "show_1" },
	[25] = { animation_type = "emote", animation_command = "thumbs_up" },
	[26] = { animation_type = "emote", animation_command = "thumbs_down_1" },
	[27] = { animation_type = "gesture", animation_command = "come_on" },
}

Config_QuickMenu.emoteTablesTitles = {
	["favorite"] = "Favorited Emotes",
	["gesture"] = "Gestures",
	["prop"] = "Prop Emotes",
	["solo"] = "Solo Emotes",
	["scenario"] = "Scenarios",
	["emote"] = "MP Emotes",
	["shared"] = "Shared Emotes",
	["sitinteraction"] = "Sit Interactions",
}

Config_QuickMenu.emoteTablesTextures = {
	["favorite"] = { dict = "itemtype_textures", texture = "itemtype_player_health" },
	["gesture"] = { dict = "multiwheel_emotes", texture = "emote_greet_tada" },
	["prop"] = { dict = "inventory_items", texture = "clothing_hl_player_hat_002_2" },
	["solo"] = { dict = "blips_mp", texture = "blip_adversary_small" },
	["scenario"] = { dict = "multiwheel_emotes", texture = "emote_action_smoke_cigar" },
	["emote"] = { dict = "multiwheel_emotes", texture = "emote_reaction_facepalm_1" },
	["shared"] = { dict = "blips_mp", texture = "blip_adversary_medium" },
	["sitinteraction"] = { dict = "blips", texture = "blip_swap" },
}

Config_QuickMenu.emoteTablesTitlesColors = {
	["favorite"] = { 255, 215, 0, 255 },
	["gesture"] = { 225, 50, 50, 255 },
	["prop"] = { 192, 158, 255, 255 },
	["solo"] = { 144, 238, 144, 255 },
	["scenario"] = { 255, 165, 0, 255 },
	["emote"] = { 135, 206, 250, 255 },
	["shared"] = { 255, 158, 236, 255 },
	["sitinteraction"] = { 255, 140, 64, 255 },
}

Config_QuickMenu.playbackTypes = {
	[1] = "Upperbody",
	[2] = "Looped",
	[3] = "Fullbody",
}

Config_QuickMenu.playbackColors = {
	{ 200, 200, 255, 255 }, -- Upperbody: light blue
	{ 255, 200, 128, 255 }, -- Looped: orange
	{ 128, 255, 128, 255 }, -- Fullbody: green
	{ 255, 128, 128, 255 }, -- 4: red
	{ 255, 255, 128, 255 }, -- 5: yellow
	{ 200, 200, 200, 255 } -- 6: gray
}

-- NEW 22/3/2026
Config_QuickMenu.controlIconsKeyboard = {
	[1] = "button1",
	[2] = "button2",
	[3] = "button3",
	[4] = "button4",
	[5] = "button5",
	[6] = "button6",
	[7] = "button7",
	[8] = "button8",
	[9] = "button9",
}

Config_QuickMenu.controlIconsGamepad = {
	[1] = {
		[1] = "button_30_img",
		[2] = "button_31_img",
		[3] = "button_32_img",
		[4] = "button_33_img",
		openMenu = "button_5_img",
		exitMenu = "button_39_img",
		switchPlayBackType = "button_16_img",
		switchEmoteTable = "button_6_img",
		switchControllerLayout = "button_25_img",
		favoriteEmote = "button_36_img",
	},
	[2] = {
		[1] = "ps4_button_30_img",
		[2] = "ps4_button_31_img",
		[3] = "ps4_button_32_img",
		[4] = "ps4_button_33_img",
		openMenu = "ps4_button_5_img",
		exitMenu = "ps4_button_39_img",
		switchPlayBackType = "ps4_button_16_img",
		switchEmoteTable = "ps4_button_6_img",
		switchControllerLayout = "ps4_button_25_img",
		favoriteEmote = "ps4_button_36_img",
	},
}

Config_QuickMenu.KeyboardMenuControlsText = {
	openMenu = "Y",
	exitMenu = "ESC",
	switchPlayBackType = "N",
	switchEmoteTable = "SPACE",
	favoriteEmote = "F",
}

Config_QuickMenu.KeyboardMenuControls = {
	[1] = 49,
	[2] = 50,
	[3] = 51,
	[4] = 52,
	[5] = 53,
	[6] = 54,
	[7] = 55,
	[8] = 56,
	[9] = 57,
	openMenu = 89,        -- Raw key code for Y, https://cherrytree.at/misc/vk.htm
	exitMenu = 27,        -- Raw key code for ESC, https://cherrytree.at/misc/vk.htm
	switchPlayBackType = 78, -- Raw key code for N, https://cherrytree.at/misc/vk.htm
	switchEmoteTable = 32, -- Raw key code for L, https://cherrytree.at/misc/vk.htm
	favoriteEmote = 70,   -- Raw key code for F, https://cherrytree.at/misc/vk.htm
}

Config_QuickMenu.ControllerMenuControls = {
	[1] = GetHashKey("INPUT_FRONTEND_ACCEPT"), -- A
	[2] = GetHashKey("INPUT_FRONTEND_CANCEL"), -- B
	[3] = GetHashKey("INPUT_FRONTEND_X"),   -- X
	[4] = GetHashKey("INPUT_FRONTEND_Y"),   -- Y	
	openMenu = GetHashKey("INPUT_FRONTEND_DOWN"),
	exitMenu = GetHashKey("INPUT_NEXT_CAMERA"),
	switchPlayBackType = GetHashKey("INPUT_DUCK"),
	switchEmoteTable = GetHashKey("INPUT_SWITCH_SHOULDER"),
	-- switchControllerLayout = GetHashKey("INPUT_LOOK_BEHIND"),
	favoriteEmote = GetHashKey("INPUT_COVER"),
}

Config_QuickMenu.ControlsToDisable = { -- Controls to disable when the quick emote menu is open, you can specify different controls for keyboard and controller
	["controller"] = {
		GetHashKey("INPUT_EMOTE_TWIRL_GUN_VAR_B"),
		GetHashKey("INPUT_SELECT_QUICKSELECT_SIDEARMS_LEFT"),
		GetHashKey("INPUT_EMOTE_DANCE"),
		GetHashKey("INPUT_SELECT_QUICKSELECT_DUALWIELD"),
		GetHashKey("INPUT_EMOTE_TWIRL_GUN_VAR_A"),
		GetHashKey("INPUT_EMOTE_GREET"),
		GetHashKey("INPUT_SELECT_QUICKSELECT_SIDEARMS_RIGHT"),
		GetHashKey("INPUT_EMOTE_TWIRL_GUN_VAR_D"),
		GetHashKey("INPUT_EMOTE_COMM"),
		GetHashKey("INPUT_SELECT_QUICKSELECT_UNARMED"),
		GetHashKey("INPUT_EMOTE_TAUNT"),
		GetHashKey("INPUT_SELECT_QUICKSELECT_MELEE_NO_UNARMED"),
		GetHashKey("INPUT_SELECT_QUICKSELECT_SECONDARY_LONGARM"),
		GetHashKey("INPUT_SELECT_QUICKSELECT_THROWN"),
		GetHashKey("INPUT_SELECT_QUICKSELECT_PRIMARY_LONGARM"),
		GetHashKey("INPUT_FRONTEND_ACCEPT"), -- A
		GetHashKey("INPUT_FRONTEND_CANCEL"), -- B
		GetHashKey("INPUT_FRONTEND_X"), -- X
		GetHashKey("INPUT_FRONTEND_Y"), -- Y
		GetHashKey("INPUT_ATTACK,"),
		GetHashKey("INPUT_HORSE_ATTACK,"),
		GetHashKey("INPUT_MELEE_GRAPPLE_CHOKE,"),
		GetHashKey("INPUT_MELEE_GRAPPLE,"),
		GetHashKey("INPUT_MELEE_GRAPPLE_REVERSAL,"),
		GetHashKey("INPUT_MELEE_GRAPPLE_ATTACK,"),
		GetHashKey("INPUT_MELEE_ATTACK"),
		GetHashKey("INPUT_JUMP"),
		GetHashKey("INPUT_HORSE_SPRINT"),
		GetHashKey("INPUT_HORSE_SPRINT"),
		GetHashKey("INPUT_VEH_ACCELERATE"),
		GetHashKey("INPUT_VEH_FLY_THROTTLE_UP"),
		GetHashKey("INPUT_VEH_BOAT_ACCELERATE"),
		GetHashKey("INPUT_VEH_CAR_ACCELERATE"),
		GetHashKey("INPUT_VEH_DRAFT_ACCELERATE"),
		GetHashKey("INPUT_VEH_HANDCART_ACCELERATE"),
		GetHashKey("INPUT_LOOT_VEHICLE"),
		GetHashKey("INPUT_QUIT"),
		GetHashKey("INPUT_PLAYER_MENU"),
		GetHashKey("INPUT_FRONTEND_RRIGHT"),
		GetHashKey("INPUT_FRONTEND_PAUSE_ALTERNATE"),
		GetHashKey("INPUT_GAME_MENU_CANCEL"),
		GetHashKey("INPUT_DUCK"),
		GetHashKey("INPUT_NEXT_CAMERA"),
		GetHashKey("INPUT_SPRINT"),
		GetHashKey("INPUT_COVER"),
	},
	["keyboard"] = {
		GetHashKey("INPUT_EMOTE_TWIRL_GUN_VAR_B"),
		GetHashKey("INPUT_SELECT_QUICKSELECT_SIDEARMS_LEFT"),
		GetHashKey("INPUT_EMOTE_DANCE"),
		GetHashKey("INPUT_SELECT_QUICKSELECT_DUALWIELD"),
		GetHashKey("INPUT_EMOTE_TWIRL_GUN_VAR_A"),
		GetHashKey("INPUT_EMOTE_GREET"),
		GetHashKey("INPUT_SELECT_QUICKSELECT_SIDEARMS_RIGHT"),
		GetHashKey("INPUT_EMOTE_TWIRL_GUN_VAR_D"),
		GetHashKey("INPUT_EMOTE_COMM"),
		GetHashKey("INPUT_SELECT_QUICKSELECT_UNARMED"),
		GetHashKey("INPUT_EMOTE_TAUNT"),
		GetHashKey("INPUT_SELECT_QUICKSELECT_MELEE_NO_UNARMED"),
		GetHashKey("INPUT_SELECT_QUICKSELECT_SECONDARY_LONGARM"),
		GetHashKey("INPUT_SELECT_QUICKSELECT_THROWN"),
		GetHashKey("INPUT_SELECT_QUICKSELECT_PRIMARY_LONGARM"),
		GetHashKey("INPUT_FRONTEND_ACCEPT"), -- A
		GetHashKey("INPUT_FRONTEND_CANCEL"), -- B
		GetHashKey("INPUT_FRONTEND_X"), -- X
		GetHashKey("INPUT_FRONTEND_Y"), -- Y
		GetHashKey("INPUT_ATTACK,"),
		GetHashKey("INPUT_HORSE_ATTACK,"),
		GetHashKey("INPUT_MELEE_GRAPPLE_CHOKE,"),
		GetHashKey("INPUT_MELEE_GRAPPLE,"),
		GetHashKey("INPUT_MELEE_GRAPPLE_REVERSAL,"),
		GetHashKey("INPUT_MELEE_GRAPPLE_ATTACK,"),
		GetHashKey("INPUT_MELEE_ATTACK"),
		GetHashKey("INPUT_JUMP"),
		GetHashKey("INPUT_HORSE_SPRINT"),
		GetHashKey("INPUT_HORSE_SPRINT"),
		GetHashKey("INPUT_VEH_ACCELERATE"),
		GetHashKey("INPUT_VEH_FLY_THROTTLE_UP"),
		GetHashKey("INPUT_VEH_BOAT_ACCELERATE"),
		GetHashKey("INPUT_VEH_CAR_ACCELERATE"),
		GetHashKey("INPUT_VEH_DRAFT_ACCELERATE"),
		GetHashKey("INPUT_VEH_HANDCART_ACCELERATE"),
		GetHashKey("INPUT_LOOT_VEHICLE"),
		GetHashKey("INPUT_QUIT"),
		GetHashKey("INPUT_PLAYER_MENU"),
		GetHashKey("INPUT_FRONTEND_RRIGHT"),
		GetHashKey("INPUT_FRONTEND_PAUSE_ALTERNATE"),
		GetHashKey("INPUT_GAME_MENU_CANCEL"),
		-- GetHashKey("INPUT_DUCK"),
		GetHashKey("INPUT_NEXT_CAMERA"),
	}
}

-------------------------------------------		\    /
--- SITTING / PROP INTERACTION SETTINGS ---      \  /
-------------------------------------------  	  \/

Config_InteractionMenu = {}

-- Control to start/stop interactions. Comment this out to disable the control.
Config_InteractionMenu.EnableInteractionMenu = true
Config_InteractionMenu.DontNearbyObjectScanItemset = false       -- Whether to not use itemsets to scan for nearby objects, if you get recursive-recursive pool itemset == 400 error then set this to true
Config_InteractionMenu.ScanNearbyObjectsRate = 500               -- How often to scan for nearby objects fit for interaction in milliseconds
Config_InteractionMenu.InteractControl = "INPUT_INTERACT_ANIMAL" -- U
-- Control to hold down for the interactions prompt to show up. Comment this out to disable the control
Config_InteractionMenu.HoldToInteract = false                    -- true/false                               - Enable hold to interact feature, if set to false then the prompt will show up whenever the quick emote menu is open
Config_InteractionMenu.AlwaysActive = false                      -- DONT USE; Only use this if you have Config_InteractionMenu.ScanNearbyObjectsRate really high, this will continuously scan for nearby objects without a gate, bad for performance
Config_InteractionMenu.HoldingControl = "INPUT_RELOAD"           -- R
Config_InteractionMenu.InteractPromptText = "Interact"
Config_InteractionMenu.InteractWithPromptText = "Interact With "
Config_InteractionMenu.StopInteractionPromptText = "Stop Interaction"
Config_InteractionMenu.InteractCommand = "interact"
-- Interaction picker menu controls
Config_InteractionMenu.MenuAcceptControl = "INPUT_GAME_MENU_ACCEPT"
Config_InteractionMenu.MenuCancelControl = "INPUT_GAME_MENU_CANCEL"
Config_InteractionMenu.MenuUpControl = "INPUT_GAME_MENU_UP"
Config_InteractionMenu.MenuDownControl = "INPUT_GAME_MENU_DOWN"
Config_InteractionMenu.cancelcontrol = "INPUT_FRONTEND_RS"
-- Settings for the marker that appears on the currently selected object
Config_InteractionMenu.MarkerType = 0x94FDAE17
Config_InteractionMenu.MarkerColor = { 255, 255, 255, 64 }

Config_InteractionMenu.Interactions = {
	{ seatLabel = "Piano",   isCompatible = IsPedHuman,                                                                                                                                                                               objects = { "p_piano03x" },                   radius = 2.0,                                                                                                                                         scenarios = { { name = "PROP_HUMAN_PIANO", isCompatible = IsPedHumanMale }, { name = "PROP_HUMAN_ABIGAIL_PIANO", isCompatible = IsPedHumanFemale } }, x = 0.0,                            y = -0.70,         z = 0.5,         heading = 0.0 },
	{ seatLabel = "Piano",   isCompatible = IsPedHuman,                                                                                                                                                                               objects = { "p_piano02x" },                   radius = 2.0,                                                                                                                                         scenarios = { { name = "PROP_HUMAN_PIANO", isCompatible = IsPedHumanMale }, { name = "PROP_HUMAN_ABIGAIL_PIANO", isCompatible = IsPedHumanFemale } }, x = 0.0,                            y = -0.70,         z = 0.5,         heading = 0.0 },
	{ seatLabel = "Piano",   isCompatible = IsPedHuman,                                                                                                                                                                               objects = { "p_nbxpiano01x" },                radius = 2.0,                                                                                                                                         scenarios = { { name = "PROP_HUMAN_PIANO", isCompatible = IsPedHumanMale }, { name = "PROP_HUMAN_ABIGAIL_PIANO", isCompatible = IsPedHumanFemale } }, x = -0.1,                           y = -0.75,         z = 0.5,         heading = 0.0 },
	{ seatLabel = "Piano",   isCompatible = IsPedHuman,                                                                                                                                                                               objects = { "p_nbmpiano01x" },                radius = 2.0,                                                                                                                                         scenarios = { { name = "PROP_HUMAN_PIANO", isCompatible = IsPedHumanMale }, { name = "PROP_HUMAN_ABIGAIL_PIANO", isCompatible = IsPedHumanFemale } }, x = 0.0,                            y = -0.77,         z = 0.5,         heading = 0.0 },
	{ seatLabel = "Piano",   objects = { "sha_man_piano01" },                                                                                                                                                                         radius = 2.0,                                 scenarios = { { name = "PROP_HUMAN_PIANO", isCompatible = IsPedHumanMale }, { name = "PROP_HUMAN_ABIGAIL_PIANO", isCompatible = IsPedHumanFemale } }, x = 0.0,                                                                                                                                              y = -0.75,                          z = 0.5,           heading = 0.0 },

	{ seatLabel = "Seat",    isCompatible = IsPedAdult,                                                                                                                                                                               objects = Chairs,                             radius = 1.5,                                                                                                                                         scenarios = ChairAndBenchScenarios,                                                                                                                   x = 0.0,                            y = 0.0,           z = 0.5,         heading = 180.0 },
	{ seatLabel = "Seat",    isCompatible = IsPedAdult,                                                                                                                                                                               objects = Chairs,                             radius = 1.5,                                                                                                                                         scenarios = { { name = "PROP_HUMAN_SEAT_CHAIR_DRINKING" } },                                                                                          x = 0.0,                            y = 0.05,          z = -0.4,        heading = 180.0 },

	{ seatLabel = "Bench",   isCompatible = IsPedAdult,                                                                                                                                                                               objects = Benches,                            radius = 1.5,                                                                                                                                         scenarios = { { name = "PROP_HUMAN_SEAT_CHAIR_DRINKING" } },                                                                                          label = "left",                     x = 0.4,           y = -0.05,       z = -0.4,        heading = 180.0 },
	{ seatLabel = "Bench",   isCompatible = IsPedAdult,                                                                                                                                                                               objects = Benches,                            radius = 1.5,                                                                                                                                         scenarios = { { name = "PROP_HUMAN_SEAT_CHAIR_DRINKING" } },                                                                                          label = "right",                    x = -0.4,          y = -0.05,       z = -0.4,        heading = 180.0 },

	{ seatLabel = "Seat",    isCompatible = IsPedHumanMale,                                                                                                                                                                           objects = Chairs,                             radius = 1.5,                                                                                                                                         scenarios = { { name = "PROP_HUMAN_SEAT_BENCH_HARMONICA" } },                                                                                         x = 0.0,                            y = -0.3,          z = 0.5,         heading = 180.0 },
	{ seatLabel = "Seat",    isCompatible = IsPedAdultFemale,                                                                                                                                                                         objects = Chairs,                             radius = 1.5,                                                                                                                                         scenarios = { { name = "PROP_HUMAN_SEAT_CHAIR_FAN" } },                                                                                               x = 0.0,                            y = 0.0,           z = 0.5,         heading = 240.0 },

	{ seatLabel = "Seat",    isCompatible = IsPedAdult,                                                                                                                                                                               objects = { "p_chairrusticsav01x" },          radius = 1.5,                                                                                                                                         scenarios = ChairAndBenchScenarios,                                                                                                                   x = 0.0,                            y = -0.1,          z = 0.5,         heading = 180.0 },
	{ seatLabel = "Seat",    isCompatible = IsPedAdult,                                                                                                                                                                               objects = { "p_chairtall01x" },               radius = 1.5,                                                                                                                                         scenarios = ChairAndBenchScenarios,                                                                                                                   x = 0.0,                            y = 0.0,           z = 0.8,         heading = 180.0 },
	{ seatLabel = "Seat",    isCompatible = IsPedHuman,                                                                                                                                                                               objects = { "p_barstool01x" },                radius = 1.5,                                                                                                                                         scenarios = ChairAndBenchScenarios,                                                                                                                   x = 0.0,                            y = 0.0,           z = 0.8,         heading = 0.0 },

	{ seatLabel = "Seat",    isCompatible = IsPedChild,                                                                                                                                                                               objects = Chairs,                             radius = 1.5,                                                                                                                                         scenarios = ChairAndBenchScenarios,                                                                                                                   x = 0.0,                            y = 0.0,           z = 0.4,         heading = 180.0 },

	{ seatLabel = "Bench",   isCompatible = IsPedHuman,                                                                                                                                                                               objects = Benches,                            label = "right",                                                                                                                                      radius = 2.0,                                                                                                                                         scenarios = ChairAndBenchScenarios, x = -0.5,          y = 0.0,         z = 0.5,         heading = 180.0 },
	{ seatLabel = "Bench",   isCompatible = IsPedHuman,                                                                                                                                                                               objects = Benches,                            label = "left",                                                                                                                                       radius = 2.0,                                                                                                                                         scenarios = ChairAndBenchScenarios, x = 0.5,           y = 0.0,         z = 0.5,         heading = 180.0 },

	{ seatLabel = "Bench",   isCompatible = IsPedHuman,                                                                                                                                                                               objects = { "p_bench17x", "p_benchbear01x" }, label = "right",                                                                                                                                      radius = 1.5,                                                                                                                                         scenarios = ChairAndBenchScenarios, x = -0.3,          y = 0.0,         z = 0.5,         heading = 180.0 },
	{ seatLabel = "Bench",   objects = { "p_bench17x", "p_benchbear01x" },                                                                                                                                                            label = "left",                               radius = 1.5,                                                                                                                                         scenarios = ChairAndBenchScenarios,                                                                                                                   x = 0.3,                            y = 0.0,           z = 0.5,         heading = 180.0 },

	{ seatLabel = "Bed",     objects = { "p_bed14x", "p_bed17x", "p_bed21x", "p_bedbunk03x", "p_bedindian02x", "p_cot01x" },                                                                                                          radius = 2.0,                                 scenarios = BedScenarios,                                                                                                                             x = 0.0,                                                                                                                                              y = 0.0,                            z = 0.5,           heading = 180.0 },
	{ seatLabel = "Bed",     objects = { "p_bed20madex", "p_cs_pro_bed_unmade", "p_cs_bed20madex" },                                                                                                                                  label = "right",                              radius = 2.0,                                                                                                                                         scenarios = BedScenarios,                                                                                                                             x = -0.3,                           y = -0.2,          z = 0.5,         heading = 180.0 },
	{ seatLabel = "Bed",     objects = { "p_bed20madex", "p_cs_pro_bed_unmade", "p_cs_bed20madex" },                                                                                                                                  label = "left",                               radius = 2.0,                                                                                                                                         scenarios = BedScenarios,                                                                                                                             x = 0.3,                            y = -0.2,          z = 0.5,         heading = 180.0 },

	{ seatLabel = "Bed",     objects = { "p_ambbed01x", "p_bed03x", "p_bed09x", "p_bedindian01x" },                                                                                                                                   radius = 2.0,                                 scenarios = BedScenarios,                                                                                                                             x = 0.0,                                                                                                                                              y = 0.0,                            z = 0.5,           heading = 270.0 },
	{ seatLabel = "Bed",     objects = { "p_bed05x" },                                                                                                                                                                                radius = 2.0,                                 scenarios = BedScenarios,                                                                                                                             x = 0.0,                                                                                                                                              y = -0.5,                           z = 0.5,           heading = 180.0 },
	{ seatLabel = "Bed",     objects = { "p_bed10x", "p_bed12x", "p_bed13x", "p_bed22x" },                                                                                                                                            radius = 2.0,                                 scenarios = BedScenarios,                                                                                                                             x = 0.0,                                                                                                                                              y = -0.3,                           z = 0.8,           heading = 180.0 },

	{ seatLabel = "Bed",     objects = { "p_bed20x" },                                                                                                                                                                                label = "right",                              radius = 2.0,                                                                                                                                         scenarios = BedScenarios,                                                                                                                             x = -0.3,                           y = -0.2,          z = 0.8,         heading = 180.0 },
	{ seatLabel = "Bed",     objects = { "p_bed20x" },                                                                                                                                                                                label = "left",                               radius = 2.0,                                                                                                                                         scenarios = BedScenarios,                                                                                                                             x = 0.3,                            y = -0.2,          z = 0.8,         heading = 180.0 },

	{ seatLabel = "Bed",     objects = { "p_bedking02x" },                                                                                                                                                                            label = "left",                               radius = 2.0,                                                                                                                                         scenarios = BedScenarios,                                                                                                                             x = -0.5,                           y = 0.5,           z = 0.5,         heading = 180.0 },
	{ seatLabel = "Bed",     objects = { "p_bedking02x" },                                                                                                                                                                            label = "right",                              radius = 2.0,                                                                                                                                         scenarios = BedScenarios,                                                                                                                             x = 0.5,                            y = 0.5,           z = 0.5,         heading = 180.0 },

	{ seatLabel = "Bed",     objects = { "p_bedrollopen01x", "p_bedrollopen03x", "p_re_bedrollopen01x", "s_bedrollfurlined01x", "s_bedrollopen01x", "p_amb_mattress04x", "p_mattress04x", "p_mattress07x", "p_mattresscombined01x" }, radius = 1.5,                                 scenarios = BedScenarios,                                                                                                                             x = 0.0,                                                                                                                                              y = 0.0,                            z = 0.0,           heading = 180.0 },
	{ seatLabel = "Bed",     objects = { "p_cs_ann_wrkr_bed01x", "p_cs_roc_hse_bed", "p_medbed01x" },                                                                                                                                 radius = 2.0,                                 scenarios = BedScenarios,                                                                                                                             x = 0.1,                                                                                                                                              y = 0.0,                            z = 0.85,          heading = 270.0 },

	{ seatLabel = "Bed",     objects = { "p_cs_bedsleptinbed08x" },                                                                                                                                                                   label = "left",                               radius = 2.0,                                                                                                                                         scenarios = BedScenarios,                                                                                                                             x = 0.3,                            y = -0.3,          z = 0.5,         heading = 270.0 },
	{ seatLabel = "Bed",     objects = { "p_cs_bedsleptinbed08x" },                                                                                                                                                                   label = "right",                              radius = 2.0,                                                                                                                                         scenarios = BedScenarios,                                                                                                                             x = 0.3,                            y = 0.3,           z = 0.5,         heading = 270.0 },

	{ seatLabel = "Bath",    radius = 2.0,                                                                                                                                                                                            animations = BathAnimations,                  x = -317.01651,                                                                                                                                       y = 761.86,                                                                                                                                           z = 117.45099,                      heading = 100.278, effect = "clean" },
	{ seatLabel = "Bath",    radius = 2.0,                                                                                                                                                                                            animations = BathAnimations,                  x = 2629.4099,                                                                                                                                        y = -1223.7757,                                                                                                                                       z = 59.6699,                        heading = 2.896,   effect = "clean" },
	{ seatLabel = "Bath",    radius = 2.0,                                                                                                                                                                                            animations = BathAnimations,                  x = -1812.46838,                                                                                                                                      y = -373.23529,                                                                                                                                       z = 166.64999,                      heading = 92.105,  effect = "clean" },
	{ seatLabel = "Bath",    radius = 2.0,                                                                                                                                                                                            animations = BathAnimations,                  x = 2952.804199,                                                                                                                                      y = 1335.031494,                                                                                                                                      z = 44.496986,                      heading = 154.996, effect = "clean" },
	{ seatLabel = "Bath",    radius = 2.0,                                                                                                                                                                                            animations = BathAnimations,                  x = 2365.649,                                                                                                                                         y = -1211.78,                                                                                                                                         z = 51.888,                         heading = 3.0,     effect = "clean" },
	{ seatLabel = "Bath",    radius = 2.0,                                                                                                                                                                                            animations = BathAnimations,                  x = 1336.35,                                                                                                                                          y = -1377.972,                                                                                                                                        z = 84.345,                         heading = -96.693, effect = "clean" },
	{ seatLabel = "Bath",    radius = 2.0,                                                                                                                                                                                            animations = BathAnimations,                  x = -5513.196,                                                                                                                                        y = -2972.139,                                                                                                                                        z = -0.75,                          heading = 108.131, effect = "clean" },
	{ seatLabel = "Bath",    radius = 2.0,                                                                                                                                                                                            animations = BathAnimations,                  x = 2987.698,                                                                                                                                         y = 573.76,                                                                                                                                           z = 47.92,                          heading = 171.942, effect = "clean" },
	{ seatLabel = "Bath",    radius = 2.0,                                                                                                                                                                                            animations = BathAnimations,                  x = -823.362,                                                                                                                                         y = -1318.832,                                                                                                                                        z = 43.679,                         heading = 92.793,  effect = "clean" },

	{ seatLabel = "Bathtub", isCompatible = IsPedHuman,                                                                                                                                                                               objects = { "p_bath03x" },                    radius = 2.0,                                                                                                                                         animations = BathAnimations,                                                                                                                          x = -0.5,                           y = 0.0,           z = 0.65,        heading = 270.0, effect = "clean" },
}

Config.AddEmotes = {
	["carrybox2"] = {
		type = "prop",
		name = "Carry Box 2",
		prop = {
			model = "p_crate03x",
			bone = "PH_R_Hand",
			position = vector3(0.0, 0.025, 0.0),
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
	["riflecheck"] = {
		type = "solo",
		name = "riflecheck",
		animation = {
			dict = "amb_work@world_human_guard@military@male_b@idle_c",
			name = "idle_h",
			flag = 1
		}
	},
	["imtellingya"] = {
		type = "gesture",
		name = "I'm Telling You",
		animation = {
			dict = "script_common@gestures@unapproved",
			name = "im_telling_you",
			flag = 28,
			upperBody = true,
			filter = false
		}
	},
	-- This is the format of the emote if you wanna add more
	-- ["emotecommand"] = {
	--     type = "solo/prop/gesture",
	--     name = "Emote Name",
	--     prop = {                                       -- Only for prop emotes
	--         model = "prop_model_name",
	--         bone = "bone_name",
	--         position = vector3(x, y, z),
	--         rotation = vector3(x, y, z)
	--     },
	--     animation = {
	--         dict = "animation_dictionary",
	--         name = "animation_name",
	--         flag = animation_flags,
	--         upperBody = true/false,                  -- Only for solo emotes
	--         filter = true/false                       -- Only for solo emotes
	--     }
	-- },
}
