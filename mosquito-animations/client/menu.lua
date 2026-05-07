local framework = string.lower(Config.Framework)
local scriptOfChoice = framework == "rsg" and "rsg-menubase" or "vorp_menu"
MenuData = exports[scriptOfChoice]:GetMenuData()
vorpMenuOpen = false
local iconPath = "<img style='max-height:30px;max-width:30px;vertical-align:middle; float:left;' src='nui://" .. GetCurrentResourceName() .. "/ui/imgs/%s.png'>"

function openAnimationMenu()
end

local colorMap = {
	favorite       = "#FFD700",
	gesture        = "#E13232",
	prop           = "#C09EFF",
	solo           = "#90EE90",
	scenario       = "#FFA500",
	emote          = "#87CEFA",
	shared         = "#FF9EEC",
	sitinteraction = "#FF8C40"
}

function startMenuThreadDisabler()
	vorpMenuOpen = true
	CreateThread(function()
		while vorpMenuOpen do
			Wait(0)
			for k, control in pairs(Config_QuickMenu.ControllerMenuControls) do
				DisableControlAction(0, control, true)
			end
		end
	end)
end

local function IsSitInteractionVisibleForMenu(interactionKey, ped)
	local interaction = Config.SitInteractionEntries and Config.SitInteractionEntries[interactionKey]
	if not interaction then
		return false
	end
	if interaction.command ~= "behind" then
		return true
	end
	return IsSitBehindScenarioAllowedForPed(interaction.scenario, ped or PlayerPedId(), interaction.sex)
end

local function ExecuteMenuAnimationChoice(typ, key, playBackType)
	local ped = PlayerPedId()
	if not key then
		return
	end

	if typ == "sitinteraction" then
		if not IsSitInteractionVisibleForMenu(key, ped) then
			mosquito.notify.right_tip("~COLOR_RED~This sit scenario is not available for your character.~q~")
			return
		end
		ExecuteSitInteraction(key)
	elseif typ == "scenario" and not IsPedOnMount(ped) then
		ScenarioCommand(nil, { key })
	elseif typ == "emote" then
		NativeEmoteCommand(nil, { key, playBackType })
	else
		local info = Config.Emotes[key]
		if not IsPedOnMount(ped) or (info and info.animation and info.animation.flag > 5) then
			EmoteCommand(nil, { key })
		end
	end
end

function openSubMenu(type)
	startMenuThreadDisabler()
	local elements = {}
	local sorted = {}
	local color = colorMap[type] or "#FFFFFF"
	for key, anim in pairs(Config.Emotes) do
		if anim.type == type then
			local isHuman = IsPedHuman(PlayerPedId()) == 1
			if anim.dogemote and not isHuman then
				table.insert(sorted, { label = anim.name, value = key, desc = "<br>To use this command type <span style='color:" .. color .. "'>/" .. Config.EmoteCommand .. " " .. key .. "</span>" })
			elseif not anim.dogemote and isHuman then
				table.insert(sorted, { label = anim.name, value = key, desc = "<br>To use this command type <span style='color:" .. color .. "'>/" .. Config.EmoteCommand .. " " .. key .. "</span>" })
			end
		end
	end

	table.sort(sorted, function(a, b)
		return a.label:lower() < b.label:lower()
	end)

	for _, emote in ipairs(sorted) do
		table.insert(elements, emote)
	end
	MenuData.CloseAll() -- Close all menus before opening the submenu

	MenuData.Open('default', GetCurrentResourceName(), 'sub_animation_menu', {
			title = type:gsub("^%l", string.upper) .. " Emotes",
			align = "right",
			elements = elements
		},
		function(data, menu)
			vorpMenuOpen = false
			EmoteCommand(nil, { data.current.value })
		end,
		function(data, menu)
			menu.close()
			openAnimationMenu()
		end)
end

function openScenarioMenu()
	startMenuThreadDisabler()
	local elements = {}
	local color = colorMap["scenario"] or "#FFFFFF"
	for key, scenario in pairs(Config.Scenarios) do
		table.insert(elements, {
			label = scenario.name or key,
			value = key,
			desc = "<br>To use this command type <span style='color:" .. color .. "'>/" .. Config.ScenarioCommand .. " " .. key .. "</span>"
		})
	end

	table.sort(elements, function(a, b)
		return a.label:lower() < b.label:lower()
	end)

	MenuData.CloseAll()

	MenuData.Open('default', GetCurrentResourceName(), 'scenario_menu', {
			title = "Scenarios",
			align = "right",
			elements = elements
		},
		function(data, menu)
			vorpMenuOpen = false
			ScenarioCommand(nil, { data.current.value })
		end,
		function(data, menu)
			menu.close()
			openAnimationMenu()
		end)
end

function openNativeEmoteMenu()
	startMenuThreadDisabler()
	local elements = {}
	local color = colorMap["emote"] or "#FFFFFF"
	for key, scenario in pairs(Config.NativeEmotes) do
		table.insert(elements, {
			label = scenario.name or key,
			value = key,
			desc = "<br>To use this command type <span style='color:" .. color .. "'>/" .. Config.NativeEmoteCommand .. " " .. key .. "</span>"
		})
	end

	table.sort(elements, function(a, b)
		return a.label:lower() < b.label:lower()
	end)

	MenuData.CloseAll()

	MenuData.Open('default', GetCurrentResourceName(), 'nativeemote_menu', {
			title = "MP Emotes",
			align = "right",
			elements = elements
		},
		function(data, menu)
			vorpMenuOpen = false
			NativeEmoteCommand(nil, { data.current.value })
		end,
		function(data, menu)
			menu.close()
			openAnimationMenu()
		end)
end

function openSitInteractionMenu()
	startMenuThreadDisabler()
	local elements = {}
	local ped = PlayerPedId()
	local color = colorMap["sitinteraction"] or "#FFFFFF"
	for key, interaction in pairs(Config.SitInteractionEntries or {}) do
		if IsSitInteractionVisibleForMenu(key, ped) then
			local commandLabel = interaction.command == "ledge" and Config.SitLedgeCommand or Config.SitBehindCommand
			commandLabel = commandLabel or "sitinteraction"
			table.insert(elements, {
				label = interaction.name or key,
				value = key,
				emoteType = "sitinteraction",
				desc = "<br>To use this command type <span style='color:" .. color .. "'>/" .. commandLabel .. "</span>"
			})
		end
	end

	table.sort(elements, function(a, b)
		local interactionA = Config.SitInteractionEntries and Config.SitInteractionEntries[a.value] or nil
		local interactionB = Config.SitInteractionEntries and Config.SitInteractionEntries[b.value] or nil
		local isLedgeA = interactionA and interactionA.command == "ledge"
		local isLedgeB = interactionB and interactionB.command == "ledge"
		if isLedgeA ~= isLedgeB then
			return isLedgeA
		end
		return a.label:lower() < b.label:lower()
	end)

	MenuData.CloseAll()
	MenuData.Open('default', GetCurrentResourceName(), 'sit_interaction_menu', {
			title = "Sit Interactions",
			align = "right",
			elements = elements
		},
		function(data, menu)
			ExecuteMenuAnimationChoice(data.current.emoteType, data.current.value)
		end,
		function(data, menu)
			menu.close()
			openAnimationMenu()
		end)
end

function searchEmote()
	startMenuThreadDisabler()
	MenuData.CloseAll()
	local input = GetUserInput("Search for emote", 2)
	local results = {}
	if input and input ~= "" then
		local query = input:lower()
		local isHuman = IsPedHuman(PlayerPedId()) == 1
		local ped = PlayerPedId()
		for key, anim in pairs(Config.Emotes) do
			local usable = (anim.dogemote and not isHuman) or (not anim.dogemote and isHuman)
			if usable then
				local name = (anim.name or key)
				if name:lower():find(query, 1, true) or key:lower():find(query, 1, true) then
					local color = colorMap[anim.type] or "#FFFFFF"
					table.insert(results, {
						label = name,
						value = key,
						desc = "<br>To use this command type <span style='color:" .. color .. "'>/" .. Config.EmoteCommand .. " " .. key .. "</span>",
						cmd = Config.EmoteCommand .. " " .. key,
						emoteType = anim.type,
						playBackType = anim.playBackType
					})
				end
			end
		end

		for key, scenario in pairs(Config.Scenarios) do
			local name = (scenario.name or key)
			if name:lower():find(query, 1, true) or key:lower():find(query, 1, true) then
				local color = colorMap["scenario"] or "#FFFFFF"
				table.insert(results, {
					label = name,
					value = key,
					desc = "<br>To use this command type <span style='color:" .. color .. "'>/" .. Config.ScenarioCommand .. " " .. key .. "</span>",
					cmd = Config.ScenarioCommand .. " " .. key,
					emoteType = "scenario"
				})
			end
		end

		for key, ne in pairs(Config.NativeEmotes) do
			local name = (ne.name or key)
			if name:lower():find(query, 1, true) or key:lower():find(query, 1, true) then
				local color = colorMap["native"] or "#FFFFFF"
				table.insert(results, {
					label = name,
					value = key,
					desc = "<br>To use this command type <span style='color:" .. color .. "'>/" .. Config.NativeEmoteCommand .. " " .. key .. "</span>",
					cmd = Config.NativeEmoteCommand .. " " .. key,
					emoteType = "emote",
					playBackType = ne.playBackType
				})
			end
		end

		for key, interaction in pairs(Config.SitInteractionEntries or {}) do
			if IsSitInteractionVisibleForMenu(key, ped) then
				local name = (interaction.name or key)
				if name:lower():find(query, 1, true) or key:lower():find(query, 1, true) then
					local color = colorMap["sitinteraction"] or "#FFFFFF"
					table.insert(results, {
						label = name,
						value = key,
						desc = "<br>Sit interaction <span style='color:" .. color .. "'>" .. name .. "</span>",
						emoteType = "sitinteraction"
					})
				end
			end
		end

		if #results == 0 then
			mosquito.notify.objective("No emotes found matching your search.")
			openAnimationMenu()
			return
		end

		table.sort(results, function(a, b) return a.label:lower() < b.label:lower() end)

		MenuData.CloseAll()
		MenuData.Open('default', GetCurrentResourceName(), 'search_results', {
				title = "Search Results",
				align = "right",
				elements = results
			},
			function(data, menu)
				vorpMenuOpen = false
				ExecuteMenuAnimationChoice(data.current.emoteType, data.current.value, data.current.playBackType)
			end,
			function(data, menu)
				menu.close()
				openAnimationMenu()
			end)
	else
		mosquito.notify.objective("Invalid Input")
		openAnimationMenu()
	end
end

function openFavoriteMenu()
	startMenuThreadDisabler()
	MenuData.CloseAll()
	local elements = {}
	local ped = PlayerPedId()
	for index, favorite in pairs(favoriteEmoteCommandList) do
		if type(favorite) == "table" and favorite ~= "empty" then
			if favorite.emoteType == "sitinteraction" and not IsSitInteractionVisibleForMenu(favorite.emoteKey, ped) then
				goto continue_favorite
			end
			local color = colorMap[favorite.emoteType] or "#FFFFFF"
			local commandType = Config.EmoteCommand
			if favorite.emoteType == "scenario" then
				commandType = Config.ScenarioCommand
			elseif favorite.emoteType == "emote" then
				commandType = Config.NativeEmoteCommand
			elseif favorite.emoteType == "sitinteraction" then
				local interaction = Config.SitInteractionEntries and Config.SitInteractionEntries[favorite.emoteKey]
				commandType = (interaction and interaction.command == "ledge") and Config.SitLedgeCommand or Config.SitBehindCommand
			end
			local emoteData = Config.Emotes[favorite.emoteKey] or Config.Scenarios[favorite.emoteKey] or Config.NativeEmotes[favorite.emoteKey] or (Config.SitInteractionEntries and Config.SitInteractionEntries[favorite.emoteKey])
			if emoteData then
				favorite.emoteName = emoteData.name or favorite.emoteKey
			else
				favorite.emoteName = favorite.emoteKey
			end
			table.insert(elements, {
				label = favorite.emoteName,
				value = favorite.emoteKey,
				emoteType = favorite.emoteType,
				playBackType = favorite.playBackType,
				desc = "<br>To use this command type <span style='color:" .. color .. "'>/" .. commandType .. " " .. favorite.emoteKey .. "</span>",
				cmd = commandType .. " " .. favorite.emoteKey
			})
		else
			table.insert(elements, {
				label = "Empty",
				value = nil,
				emoteType = nil,
				playBackType = nil,
				desc = "<br>This favorite slot is empty.",
				cmd = " "
			})
		end
		::continue_favorite::
	end

	if #elements == 0 then
		mosquito.notify.objective("No favorite emotes available.")
		openAnimationMenu()
		return
	end

	MenuData.Open('default', GetCurrentResourceName(), 'favorite_emotes', {
			title = "Favorite Emotes",
			align = "right",
			elements = elements
		},
		function(data, menu)
			vorpMenuOpen = false
			ExecuteMenuAnimationChoice(data.current.emoteType, data.current.value, data.current.playBackType)
		end,
		function(data, menu)
			vorpMenuOpen = false
			menu.close()
			openAnimationMenu()
		end)
end

function openWalkAnimMenu()
	startMenuThreadDisabler()
	MenuData.CloseAll()
	local elements = {}
	local walkSpeedOptions = {
		{ label = "0.2", value = 0.2 },
		{ label = "0.3", value = 0.3 },
		{ label = "0.4", value = 0.4 },
		{ label = "0.5", value = 0.5 },
		{ label = "0.6", value = 0.6 },
		{ label = "0.7", value = 0.7 },
		{ label = "0.8", value = 0.8 },
		{ label = "0.9", value = 0.9 },
		{ label = "1.0 (off)", value = 1.0 }
	}

	maxBlendMoveRatio = tonumber(maxBlendMoveRatio) or tonumber(Config.MaxBlendMoveRatio) or tonumber(Config.AnimationWalkSpeed) or 1.0
	maxBlendMoveRatio = math.max(0.2, math.min(1.0, maxBlendMoveRatio))

	local closestWalkSpeedIndex = 1
	local smallestWalkSpeedDiff = math.abs(maxBlendMoveRatio - walkSpeedOptions[1].value)
	for i, speedOption in ipairs(walkSpeedOptions) do
		local diff = math.abs(maxBlendMoveRatio - speedOption.value)
		if diff < smallestWalkSpeedDiff then
			smallestWalkSpeedDiff = diff
			closestWalkSpeedIndex = i
		end
	end

	table.insert(elements, {
		label = "Max Walk Speed",
		value = "walk_speed",
		desc = "Adjust emote walk speed cap (0.2 - 1.0)",
		type = "text-slider",
		textIndex = closestWalkSpeedIndex,
		textList = walkSpeedOptions
	})

	for _, style in ipairs(WalkStyle) do
		table.insert(elements, {
			label = style.label,
			value = style.hash
		})
	end

	MenuData.Open('default', GetCurrentResourceName(), 'walk_anim_menu', {
			title = "Walk Animations",
			align = "right",
			elements = elements
		},
		function(data, menu)
			vorpMenuOpen = false
			local label = data.current.label or ""
			if label:find("Max Walk Speed") then
				if data.current.textIndex and data.current.textList and data.current.textList[data.current.textIndex] then
					maxBlendMoveRatio = tonumber(data.current.textList[data.current.textIndex].value) or maxBlendMoveRatio
				else
					maxBlendMoveRatio = math.max(0.2, math.min(1.0, tonumber(data.current.value) or maxBlendMoveRatio))
				end
			else
				TriggerEvent("mosquito:animations:setwalkanim", data.current.value, false, false, maxBlendMoveRatio)
			end
		end,
		function(data, menu)
			vorpMenuOpen = false
			TriggerServerEvent("mosquito:Server:animations:SaveWalkAnimToDB", CurrentWalkAnim or "noanim", maxBlendMoveRatio)
			menu.close()
			openAnimationMenu()
		end)
end

local tempOpenQuickMenu = false

local function KeepQuickMenuOpen()
	while tempOpenQuickMenu do
		Wait(0)
		DisableControlAction(0, Config_QuickMenu.MenuKeybind, true)
		DisableAllControlActions(0, true)
		drawEmoteMenu(5000)
	end
end

local function editMenuPosition()
	startMenuThreadDisabler()
	mosquito.notify.objective("Adjust the quick menu's position & scale using the sliders.", 10000)
	MenuData.CloseAll()
	tempOpenQuickMenu = true
	emoteMenuOpen = true
	Citizen.CreateThread(KeepQuickMenuOpen)
	menuPositionOffset = menuPositionOffset or { x = 0.5, y = 0.5 }

	menuScale = menuScale or 0.5

	menuTextScale = tonumber(menuTextScale) or 0.35
	menuTextScale = math.max(0.1, math.min(1.0, menuTextScale))

	menuTextOffset = menuTextOffset or { x = 0.0, y = 0.0 }

	menuFont = tonumber(menuFont) or 30
	menuFont = math.max(0, math.min(50, menuFont))

	local menuScaleOptions = { 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.4, 1.5 }
	local closestIndex = 1
	local smallestDiff = math.abs(menuScale - menuScaleOptions[1])
	for i, scaleValue in ipairs(menuScaleOptions) do
		local diff = math.abs(menuScale - scaleValue)
		if diff < smallestDiff then
			smallestDiff = diff
			closestIndex = i
		end
	end

	local elements = {
		[1] = {
			label = "X Position",
			value = menuPositionOffset.x * 10,
			desc = "Adjust menu X position (-10.0 - 10.0)",
			type = "slider",
			min = -10.0,
			max = 10.0,
			hop = 0.1
		},
		[2] = {
			label = "Y Position",
			value = menuPositionOffset.y * 10,
			desc = "Adjust menu Y position (-10.0 - 10.0)",
			type = "slider",
			min = -10.0,
			max = 10.0,
			hop = 0.1
		},
		[3] = {
			label = "Menu Scale",
			value = "menu_scale",
			desc = "Adjust menu scale (0.4 - 1.5)",
			type = "text-slider",
			textIndex = closestIndex,
			textList = {
				{ label = "0.4", value = 0.4 },
				{ label = "0.5", value = 0.5 },
				{ label = "0.6", value = 0.6 },
				{ label = "0.7", value = 0.7 },
				{ label = "0.8", value = 0.8 },
				{ label = "0.9", value = 0.9 },
				{ label = "1.0", value = 1.0 },
				{ label = "1.1", value = 1.1 },
				{ label = "1.2", value = 1.2 },
				{ label = "1.3", value = 1.3 },
				{ label = "1.4", value = 1.4 },
				{ label = "1.5", value = 1.5 }
			}
		},
		[4] = {
			label = "Text Scale",
			value = menuTextScale * 100,
			desc = "Adjust text scale (1 - 100)",
			type = "slider",
			min = 1,
			max = 100,
			hop = 1
		},
		[5] = {
			label = "Text X Offset",
			value = menuTextOffset.x * 100,
			desc = "Adjust text X offset (-100.0 - 100.0)",
			type = "slider",
			min = -100.0,
			max = 100.0,
			hop = 0.1
		},
		[6] = {
			label = "Text Y Offset",
			value = menuTextOffset.y * 100,
			desc = "Adjust text Y offset (-100.0 - 100.0)",
			type = "slider",
			min = -100.0,
			max = 100.0,
			hop = 0.1
		},
		-- [7] = {
		-- 	label = "Menu Font",
		-- 	value = menuFont,
		-- 	desc = "Adjust menu font (0 - 30)",
		-- 	type = "slider",
		-- 	min = 0,
		-- 	max = 30,
		-- 	hop = 1
		-- },
		[7] = {
			label = "Close",
			value = "close",
			desc = "Close this menu",
			type = "default"
		}
	}

	MenuData.Open('default', GetCurrentResourceName(), 'menu_position_edit', {
			title = "Edit Menu Position",
			align = "right",
			elements = elements
		},
		function(data, menu)
			vorpMenuOpen = false
			if data.current and data.current.value == "close" then
				tempOpenQuickMenu = false
				emoteMenuOpen = false
				vorpMenuOpen = false
				TriggerServerEvent("mosquito:Server:SaveQuickMenuPositionOffset", menuPositionOffset, menuScale, menuTextScale, menuTextOffset, menuFont)
			end

			local val = data.current.value
			local label = data.current.label or ""
			if label:find("^X Position") then
				menuPositionOffset.x = tonumber(val / 10) or menuPositionOffset.x
			elseif label:find("^Y Position") then
				menuPositionOffset.y = tonumber(val / 10) or menuPositionOffset.y
			elseif label:find("Menu Scale") and data.current.textIndex then
				menuScale = data.current.textList[data.current.textIndex].value or menuScale
			elseif label:find("^Text Scale") then
				menuTextScale = tonumber(val / 100) or menuTextScale
			elseif label:find("Text X Offset") then
				menuTextOffset.x = tonumber(val / 100) or menuTextOffset.x
			elseif label:find("Text Y Offset") then
				menuTextOffset.y = tonumber(val / 100) or menuTextOffset.y
			elseif label:find("Menu Font") then
				menuFont = tonumber(val) or menuFont
			end
		end,
		function(data, menu)
			vorpMenuOpen = false
			tempOpenQuickMenu = false
			emoteMenuOpen = false
			vorpMenuOpen = false
			TriggerServerEvent("mosquito:Server:SaveQuickMenuPositionOffset", menuPositionOffset, menuScale, menuTextScale, menuTextOffset, menuFont)
			mosquito.notify.objective(" ", 1000)
			menu.close()
		end)
end

openAnimationMenu = function()
	startMenuThreadDisabler()
	local elements = {}
	if IsPedHuman(PlayerPedId()) == 1 then
		elements = {
			{ label = iconPath:format("edit") .. "Edit Quick Menu",     value = "editposition" },
			{ label = iconPath:format("walk") .. "Walk Animations",     value = "walkanim" },
			{ label = iconPath:format("favorite") .. "Favorite Emotes", value = "favorite" },
			{ label = iconPath:format("shared") .. "Shared Emotes",     value = "shared" },
			{ label = iconPath:format("sitting") .. "Sit Interactions", value = "sitinteraction" },
			{ label = iconPath:format("prop") .. "Prop Emotes",         value = "prop" },
			{ label = iconPath:format("solo") .. "Solo Emotes",         value = "solo" },
			{ label = iconPath:format("scenario") .. "Scenarios",       value = "scenario" },
			{ label = iconPath:format("gesture") .. "Gestures",         value = "gesture" },
			{ label = iconPath:format("emote") .. "MP Emotes",          value = "emote" },
			{ label = iconPath:format("search") .. "Search Emotes",     value = "search" },
			{ label = iconPath:format("cancel") .. "Cancel Animation",  value = "cancel" }
		}
	else
		elements = {
			{ label = iconPath:format("edit") .. "Edit Menu Position",   value = "editposition" },
			{ label = iconPath:format("shared") .. "Shared Emotes",      value = "shared" },
			{ label = iconPath:format("prop") .. "Prop Emotes",          value = "prop" },
			{ label = iconPath:format("solo") .. "Solo Emotes",          value = "solo" },
			{ label = iconPath:format("search") .. "Search Emotes",      value = "search" },
			{ label = iconPath:format("cancel") .. "-Cancel Animation-", value = "cancel" }
		}
	end

	MenuData.Open('default', GetCurrentResourceName(), 'animation_menu', {
			title = Config.RegularVORPMenuTitle or "Animations",
			align = "right",
			elements = elements
		},
		function(data, menu)
			vorpMenuOpen = false
			if data.current.value == "cancel" then
				ExecuteCommand(Config.EmoteCommand)
				ClearPedTasks(PlayerPedId())
			elseif data.current.value == "scenario" then
				openScenarioMenu()
			elseif data.current.value == "emote" then
				openNativeEmoteMenu()
			elseif data.current.value == "search" then
				searchEmote()
			elseif data.current.value == "walkanim" then
				openWalkAnimMenu()
			elseif data.current.value == "favorite" then
				openFavoriteMenu()
			elseif data.current.value == "sitinteraction" then
				openSitInteractionMenu()
			elseif data.current.value == "editposition" then
				editMenuPosition()
			else
				openSubMenu(data.current.value)
			end
		end,
		function(data, menu)
			vorpMenuOpen = false
			menu.close()
		end)
end

RegisterCommand(Config_QuickMenu.SettingsMenuCommand, function()
	editMenuPosition()
end, false)

function handleMenuKeybind()
	local isPressed
	local optionType = IsUsingController and "Controller" or "Keyboard"
	if Config.RegularVORPMenuKeybind[optionType] then
		DisableControlAction(0, Config.RegularVORPMenuKeybind[optionType], true)
		isPressed = IsDisabledControlJustPressed(0, Config.RegularVORPMenuKeybind[optionType])
	else
		isPressed = false
	end
	if isPressed then
		MenuData.CloseAll()
		openAnimationMenu()
	end
end
