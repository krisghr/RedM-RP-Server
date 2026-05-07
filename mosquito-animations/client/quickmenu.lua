local calledBack = false
local mapPropHandle = nil
emoteMenuOpen = false
exports("IsQuickEmoteMenuOpen", function()
    return emoteMenuOpen == true
end)

favoriteEmoteCommandList = {}
local gestureCommandList = {}
local nativeEmoteCommandList = {}
local soloEmoteCommandList = {}
local sharedEmoteCommandList = {}
local propEmoteCommandList = {}
local scenarioCommandList = {}
local sitInteractionCommandList = {}
local sitInteractionLastRefreshAt = 0
local sitInteractionRefreshIntervalMs = 1250
local sitInteractionRevision = 0
local pageRows = {}
local pageRowsCache = { valid = false }
menuScale = Config_QuickMenu.MenuScale or 0.8
menuTextScale = Config_QuickMenu.MenuTextScale or 0.35
menuTextOffset = Config_QuickMenu.MenuTextOffset or { x = 0.0, y = 0.0 }
menuPositionOffset = Config_QuickMenu.MenuPositionOffset or { x = 0.0, y = 0.0 }
menuFont = Config_QuickMenu.MenuFont or 30
maxBlendMoveRatio = tonumber(Config.MaxBlendMoveRatio) or tonumber(Config.AnimationWalkSpeed) or 1.5


function DrawTexture(textureStreamed, textureName, x, y, width, height, rotation, r, g, b, a, p11)
    if not HasStreamedTextureDictLoaded(textureStreamed) then
        RequestStreamedTextureDict(textureStreamed, false);
    else
        DrawSprite(textureStreamed, textureName, x, y, width, height, rotation, r, g, b, a, p11);
    end
end

function Draw3DRect(x, y, width, height, r, g, b, a)
    local alphaFactor = math.ceil(a / 255) or 1
    local resX, resY = GetCurrentScreenResolution()
    local pixelW = 1.0 / resX
    local pixelH = 1.0 / resY

    local shadowThickness = 2
    local shadowOffset = 1

    local tW = shadowThickness * pixelW
    local tH = shadowThickness * pixelH
    local offX = shadowOffset * pixelW
    local offY = shadowOffset * pixelH

    DrawRect(x, y, width, height, r, g, b, a)

    DrawRect(x + (width / 2) + offX, y + offY / 2, tW, height, 5, 5, 5, 200 * alphaFactor)

    DrawRect(x + offX / 2, y + (height / 2) + offY, width, tH, 5, 5, 5, 100 * alphaFactor)
end

local gamePadTextDict = "gamepad_icons_pc"

local function computePromptPixel(resX, resY)
    local a = 8 / 360
    local b = 24
    local px = a * resY + b
    return px
end

function DrawPromptButtonIcon(controlString, x, y, scale, alpha)
    scale = scale or 1
    local resX, resY = GetCurrentScreenResolution()
    local px = computePromptPixel(resX, resY)
    local w, h = (px / resX) * scale, (px / resY) * scale

    local textScale = 0.4 * scale
    local yOffset = textScale / 30

    if #controlString > 3 then
        local charRatio = #controlString / 3.5
        textScale = textScale / charRatio
        yOffset = textScale / 30
    end

    Draw3DRect(x, y, w, h, 255, 255, 255, alpha)
    SetTextScale(textScale, textScale)
    SetTextFontForCurrentCommand(9)
    SetTextColor(5, 5, 5, alpha or 255)
    SetTextCentre(1)
    DisplayText(CreateVarString(10, "LITERAL_STRING", controlString), x, y - yOffset)
end

function DrawControllerPromptButtonIcon(textureName, textureDict, x, y, scale, alpha)
    scale = scale or 1
    local resX, resY = GetCurrentScreenResolution()
    local px = computePromptPixel(resX, resY)
    local w, h = (px / resX) * scale, (px / resY) * scale

    local textScale = 0.4 * scale
    local yOffset = textScale / 30

    DrawTexture(textureDict, textureName, x, y, w, h, 0.0, 255, 255, 255, alpha or 255, 0)
end

function PlaySoundEffect(soundset, soundname)
    local frontend_soundset_ref = soundset or "HUD_DOMINOS_SOUNDSET"
    local frontend_soundset_name = soundname or "YES"

    Citizen.CreateThread(function()
        Citizen.InvokeNative(0x67C540AA08E4A6F5, frontend_soundset_name, frontend_soundset_ref, true, 0)
    end)
end

local function GetEmoteDataByType(emoteType, emoteKey)
    if emoteType == "emote" then
        return Config.NativeEmotes[emoteKey]
    elseif emoteType == "scenario" then
        return Config.Scenarios[emoteKey]
    elseif emoteType == "sitinteraction" then
        return Config.SitInteractionEntries and Config.SitInteractionEntries[emoteKey] or nil
    end
    return Config.Emotes[emoteKey]
end

local function IsSitInteractionVisibleForPed(interactionKey, ped)
    local interaction = Config.SitInteractionEntries and Config.SitInteractionEntries[interactionKey]
    if not interaction then
        return false
    end
    if interaction.command ~= "behind" then
        return true
    end
    return IsSitBehindScenarioAllowedForPed(interaction.scenario, ped, interaction.sex)
end

local function RefreshSitInteractionCommandList(ped, force)
    ped = ped or PlayerPedId()
    local now = GetGameTimer()
    if not force and (now - sitInteractionLastRefreshAt) < sitInteractionRefreshIntervalMs then
        return false
    end
    for idx = #sitInteractionCommandList, 1, -1 do
        sitInteractionCommandList[idx] = nil
    end
    for sitInteractionKey, _ in pairs(Config.SitInteractionEntries or {}) do
        if IsSitInteractionVisibleForPed(sitInteractionKey, ped) then
            table.insert(sitInteractionCommandList, sitInteractionKey)
        end
    end
    table.sort(sitInteractionCommandList, function(a, b)
        local dataA = Config.SitInteractionEntries and Config.SitInteractionEntries[a] or nil
        local dataB = Config.SitInteractionEntries and Config.SitInteractionEntries[b] or nil
        local isLedgeA = dataA and dataA.command == "ledge"
        local isLedgeB = dataB and dataB.command == "ledge"
        if isLedgeA ~= isLedgeB then
            return isLedgeA
        end
        local nameA = (dataA and dataA.name) or a
        local nameB = (dataB and dataB.name) or b
        return tostring(nameA):lower() < tostring(nameB):lower()
    end)
    sitInteractionLastRefreshAt = now
    sitInteractionRevision = sitInteractionRevision + 1
    return true
end

RegisterNetEvent('mosquito:client:receiveFavoriteAnimations')
AddEventHandler('mosquito:client:receiveFavoriteAnimations', function(recieved, favorite, favoriteAnimations, animation_command, animation_type, menuPos)
    if recieved then
        for i = 1, Config_QuickMenu.FavoriteEmotesMenuLimit do
            local favoriteAnim = favoriteAnimations[tostring(i)]
            if favoriteAnim then
                favoriteEmoteCommandList[i] = { emoteKey = favoriteAnim.animation_command, emoteType = favoriteAnim.animation_type }
            else
                favoriteEmoteCommandList[i] = "empty"
            end
        end
        if favorite and animation_command and animation_type then
            local emoteData = GetEmoteDataByType(animation_type, animation_command)
            local emoteName = emoteData and (emoteData.name or animation_command) or animation_command or "Empty"
            local text = "~q~Added ~COLOR_GOLD~" .. emoteName .. "~q~ to favorites!"
            local dict = "itemtype_textures"      -- itemtype_upgrades / blips_mp
            local icon = "itemtype_player_health" -- itemtype_upgrades / itemtype_hire / blip_health / itemtype_player_health
            local duration = 4000
            local soundset_ref = "HUD_POKER"
            local soundset_name = "BET_AMOUNT"
            local color = "COLOR_PURE_WHITE"
            mosquito.notify.right(text, dict, icon, color, duration, soundset_ref, soundset_name)
        end
        -- Since menuPos = menuPostToSend:       {"MenuPositionOffset":{"x":0.0,"y":0.2},"MenuScale":0.8}
        if menuPos and type(menuPos) == "table" then
            menuPositionOffset = menuPos.MenuPositionOffset or { x = 0.0, y = 0.0 }
            menuScale = menuPos.MenuScale or 0.8
            menuTextScale = menuPos.MenuTextScale or 0.35
            menuTextOffset = menuPos.MenuTextOffset or { x = 0.0, y = 0.0 }
            menuFont = menuPos.MenuFont or 30
        end
    else
        local count = 0
        for k, v in pairs(Config.PresetFavoriteEmotes) do
            count = count + 1
            if count >= Config_QuickMenu.FavoriteEmotesMenuLimit then break end;
            favoriteEmoteCommandList[k] = { emoteKey = v.animation_command, emoteType = v.animation_type }
        end
        favoriteEmoteCommandList = Config.PresetFavoriteEmotes
    end
    calledBack = true
    pageRowsCache.valid = false
end)

TriggerServerEvent('mosquito:server:getFavoriteAnimations')
while not calledBack do
    Wait(100)
end

calledBack = false

for emote, info in pairs(Config.NativeEmotes) do
    table.insert(nativeEmoteCommandList, emote)
    -- table.insert(favoriteEmoteCommandList, { emoteKey = emote, emoteType = "emote" })
end

for gesture, info in pairs(Config.Emotes) do
    local typ = info.type
    if typ == "gesture" then
        table.insert(gestureCommandList, gesture)
    elseif typ == "prop" then
        table.insert(propEmoteCommandList, gesture)
    elseif typ == "solo" then
        table.insert(soloEmoteCommandList, gesture)
    elseif typ == "shared" then
        table.insert(sharedEmoteCommandList, gesture)
    end
end

for scenario, info in pairs(Config.Scenarios) do
    table.insert(scenarioCommandList, scenario)
end

emoteTableIndexMap = {
    [1] = "favorite",
    [2] = "gesture",
    [3] = "prop",
    [4] = "solo",
    [5] = "scenario",
    [6] = "emote",
    [7] = "shared",
    [8] = "sitinteraction"
}

local emoteCommandList = {
    [1] = favoriteEmoteCommandList,
    [2] = gestureCommandList,
    [3] = propEmoteCommandList,
    [4] = soloEmoteCommandList,
    [5] = scenarioCommandList,
    [6] = nativeEmoteCommandList,
    [7] = sharedEmoteCommandList,
    [8] = sitInteractionCommandList
}

table.sort(nativeEmoteCommandList, function(a, b)
    local nameA = (Config.NativeEmotes[a] and Config.NativeEmotes[a].name) or a
    local nameB = (Config.NativeEmotes[b] and Config.NativeEmotes[b].name) or b
    return nameA:lower() < nameB:lower()
end)

local function emoteSortKey(item)
    local key
    if type(item) == "table" then
        key = item.emoteKey or ""
    else
        key = item or ""
    end

    local name = key
    if key ~= "" then
        local data = Config.Emotes[key] or Config.Scenarios[key] or Config.NativeEmotes[key] or (Config.SitInteractionEntries and Config.SitInteractionEntries[key])
        if data and data.name and data.name ~= "" then
            name = data.name
        end
    end

    return tostring(name):lower()
end

for _, emoteTbl in pairs(emoteCommandList) do
    if emoteTbl ~= favoriteEmoteCommandList then
        table.sort(emoteTbl, function(a, b)
            return emoteSortKey(a) < emoteSortKey(b)
        end)
    end
end

table.sort(scenarioCommandList, function(a, b)
    local nameA = (Config.Scenarios[a] and Config.Scenarios[a].name) or a
    local nameB = (Config.Scenarios[b] and Config.Scenarios[b].name) or b
    return nameA:lower() < nameB:lower()
end)

RefreshSitInteractionCommandList(PlayerPedId(), true)

-----------------------------------------------------------

local currentEmoteTableIndex = 1
local controlIconsGamepadDict = "gamepad_icons_pc"

IsUsingController = false
ControllerType = Config_QuickMenu.DefaultControllerLayout
local ControllerTypeTexts = {
    [1] = "XBOX",
    [2] = "PlayStation",
}
local emoteMenuPage = 1
local emotesPerPage = Config_QuickMenu.EmotesPerPage["keyboard"]
local playBackType = 1 -- 0 - Upperbody, 1 - Looped, 2 - Fullbody
local playbackTypes = { "Upperbody", "Looped", "Fullbody" }

function getEmoteMenuPageCount()
    local pageCount = math.ceil(#emoteCommandList[currentEmoteTableIndex] / emotesPerPage)
    return math.max(1, pageCount)
end

local function DrawPromptButtonIconPerType(key, x, y, scale, alpha)
    local controlString
    if IsUsingController then
        local textName = Config_QuickMenu.controlIconsGamepad[ControllerType][key]
        local textureDict = "gamepad_icons_pc"
        DrawControllerPromptButtonIcon(textName, textureDict, x, y, scale, alpha)
    else
        controlString = Config_QuickMenu.KeyboardMenuControlsText[key]
        DrawPromptButtonIcon(controlString, x, y, scale, alpha)
    end
end

local buttonCount = 0
local startIdx
local endIdx
local totalEmotesInPage = Config_QuickMenu.EmotesPerPage.keyboard
pageRowsCache = {
    valid = false,
    tableIndex = nil,
    page = nil,
    perPage = nil,
    sourceLength = nil,
    sitRevision = nil,
}
local favoriting = false
local currentEmoteToFavorite = nil
local colorFadeMin = 50

local function invalidatePageRowsCache()
    pageRowsCache.valid = false
end

local function shouldTrackSitRevision(tableType)
    return tableType == "sitinteraction" or tableType == "favorite"
end

local function rebuildCurrentPageRows(ped)
    ped = ped or PlayerPedId()
    local currentTable = emoteCommandList[currentEmoteTableIndex]
    local sourceLength = #currentTable
    local pageCount = math.max(1, math.ceil(sourceLength / emotesPerPage))
    if emoteMenuPage > pageCount then
        emoteMenuPage = pageCount
    elseif emoteMenuPage < 1 then
        emoteMenuPage = 1
    end

    startIdx = (emoteMenuPage - 1) * emotesPerPage + 1
    endIdx = math.min(startIdx + emotesPerPage - 1, sourceLength)
    totalEmotesInPage = math.max(0, endIdx - startIdx + 1)

    local tableType = emoteTableIndexMap[currentEmoteTableIndex]
    for idx = 1, totalEmotesInPage do
        local emoteIdx = startIdx + idx - 1
        local row = pageRows[idx] or {}
        row.index = idx
        row.emoteIdx = emoteIdx
        row.key = nil
        row.typ = nil
        row.data = nil
        row.name = "Empty"
        row.enabled = false

        if tableType == "favorite" then
            local favoriteEntry = currentTable[emoteIdx]
            if type(favoriteEntry) == "table" then
                local key = favoriteEntry.emoteKey
                local typ = favoriteEntry.emoteType
                local data = GetEmoteDataByType(typ, key)
                local available = true
                if typ == "sitinteraction" and not IsSitInteractionVisibleForPed(key, ped) then
                    available = false
                end
                row.key = available and key or nil
                row.typ = available and typ or nil
                row.data = available and data or nil
                row.name = (available and data and (data.name or key)) or (available and key) or "Empty"
                row.enabled = available and key ~= nil
            end
        else
            local key = currentTable[emoteIdx]
            local typ = tableType
            local data = GetEmoteDataByType(typ, key)
            row.key = key
            row.typ = typ
            row.data = data
            row.name = data and (data.name or key) or key or "Empty"
            row.enabled = key ~= nil
        end
        pageRows[idx] = row
    end

    for idx = totalEmotesInPage + 1, #pageRows do
        pageRows[idx] = nil
    end

    pageRowsCache.valid = true
    pageRowsCache.tableIndex = currentEmoteTableIndex
    pageRowsCache.page = emoteMenuPage
    pageRowsCache.perPage = emotesPerPage
    pageRowsCache.sourceLength = sourceLength
    pageRowsCache.sitRevision = shouldTrackSitRevision(tableType) and sitInteractionRevision or -1
end

local function ensureCurrentPageRows(ped)
    local tableType = emoteTableIndexMap[currentEmoteTableIndex]
    local currentTable = emoteCommandList[currentEmoteTableIndex]
    local requiredSitRevision = shouldTrackSitRevision(tableType) and sitInteractionRevision or -1
    local needsRebuild =
        not pageRowsCache.valid
        or pageRowsCache.tableIndex ~= currentEmoteTableIndex
        or pageRowsCache.page ~= emoteMenuPage
        or pageRowsCache.perPage ~= emotesPerPage
        or pageRowsCache.sourceLength ~= #currentTable
        or pageRowsCache.sitRevision ~= requiredSitRevision

    if needsRebuild then
        rebuildCurrentPageRows(ped)
    end
end

local function GetColorFade(idx)
    local t = GetGameTimer() / 1000
    local period = 2.5
    local phase = (idx - 1) * 0.25
    local norm = 0.5 * (1 + math.sin((2 * math.pi / period) * t + phase))

    local minRatio = math.max(0, math.min(1, colorFadeMin / 255))
    local scaled = minRatio + (1 - minRatio) * norm
    local value = math.floor(math.max(colorFadeMin, math.min(255, scaled * 255)))

    return value
end

local menuTimeOutBeing = 1000

local function MultiplyWithOpacityFactor(alpha, globalOpacityFactor)
    return math.max(1, math.ceil(alpha * globalOpacityFactor))
end

local function EaseOutCubic(t)
    t = math.max(0.0, math.min(1.0, t))
    return 1.0 - (1.0 - t) * (1.0 - t) * (1.0 - t)
end

local function EaseInQuad(t)
    t = math.max(0.0, math.min(1.0, t))
    return t * t
end

local function Lerp(a, b, t)
    return a + (b - a) * t
end

local aspectRatio = 4.5 / 1.0

local buttonPromptsLocation = {
    ["exitMenu"] = { x = 0.0, y = 0.0 },
    ["openMenu"] = { x = 0.0, y = 0.0 },
    ["switchPlayBackType"] = { x = 0.0, y = 0.0 },
    ["switchEmoteTable"] = { x = 0.0, y = 0.0 },
    ["switchControllerLayout"] = { x = 0.0, y = 0.0 },
    ["favoriteEmote"] = { x = 0.0, y = 0.0 }
}

local function BuildColorWithAlpha(sourceColor, alpha)
    return { sourceColor[1], sourceColor[2], sourceColor[3], alpha }
end

local function GetPromptIconY(baseY, totalItems, buttonIndex, itemSpacing, yCoordDiff, textToIconOffset)
    return baseY + itemSpacing * (totalItems + buttonIndex) + yCoordDiff + textToIconOffset
end

local function DrawMenuPromptRow(promptKey, text, textColor, layout, buttonIndex)
    local iconY = GetPromptIconY(layout.baseY, layout.totalItems, buttonIndex, layout.itemSpacing, layout.yCoordDiff, layout.textToIconOffset)
    DrawPromptButtonIconPerType(promptKey, layout.iconX, iconY, layout.promptButtonScale, layout.buttonOpacity)
    DrawText2D(layout.textX, iconY - layout.textToIconOffset + layout.textOffsetY, text, textColor, nil, layout.instructScale, menuFont)
    buttonPromptsLocation[promptKey] = { x = layout.iconX, y = iconY }
end

function drawEmoteMenu(menuTimeLeft, emoteIndex)
    local menuTimeOutBeing = 1000
    local globalOpacityFactor = 1
    if menuTimeLeft <= menuTimeOutBeing then
        globalOpacityFactor = menuTimeLeft / menuTimeOutBeing
    end
    local pageCount = getEmoteMenuPageCount()
    local resW, resH = GetCurrentScreenResolution()
    local aspectRatio = resW / resH
    local y = 0.12 + 0.1 + menuPositionOffset.y -- top
    local x = 0.015 + menuPositionOffset.x      -- Left side
    local textOffset = { x = menuTextOffset.x, y = menuTextOffset.y }
    local scale = { 0.7 * menuScale, 0.7 * menuScale }
    local titleColorFromConfig = Config_QuickMenu.emoteTablesTitlesColors[emoteTableIndexMap[currentEmoteTableIndex]] or { 255, 255, 255, 255 }
    local titleColor = { titleColorFromConfig[1], titleColorFromConfig[2], titleColorFromConfig[3], titleColorFromConfig[4] }
    titleColor[4] = MultiplyWithOpacityFactor(titleColor[4], globalOpacityFactor)
    local scaleFactor = 1.15
    local instructScale = { menuTextScale * menuScale, menuTextScale * menuScale }
    local promptButtonScale = 0.7 * menuScale

    local bgWidth = 0.28

    local itemSpacing = 0.03 * menuScale
    local padding = 0.10 * menuScale
    local paddingPerButton = 0.045 * menuScale
    local buttonPadding = buttonCount * paddingPerButton

    local bgHeight = totalEmotesInPage * itemSpacing + padding + buttonPadding

    local bgX = (x - 0.02) + bgWidth / 2 - 0.01
    local bgY = y + bgHeight / 2 - (0.075 * menuScale)
    local xOffset = 0.015

    local tex
    local dic
    local iconScale = 1.15 * menuScale
    local iconX = x + 0.005
    local iconY
    local iconW = 0.018 * iconScale
    local iconH = 0.018 * aspectRatio * iconScale
    local controllerIconDescaler = 0.75
    local magicPower = (-0.46497)
    DrawTexture("landing_page", "gradient", bgX, bgY, bgWidth, bgHeight, 0.0, 0, 0, 0, MultiplyWithOpacityFactor(100, globalOpacityFactor), false)
    local textureX = x
    local textureY = y - 0.035 * menuScale
    local textureSize = 0.02 * menuScale
    local textureWidth = textureSize
    local textureHeight = textureSize * aspectRatio
    local emoteTableTextureInfo = Config_QuickMenu.emoteTablesTextures[emoteTableIndexMap[currentEmoteTableIndex]]
    DrawTexture(emoteTableTextureInfo.dict, emoteTableTextureInfo.texture, textureX, textureY, textureWidth, textureHeight, 0.0, 255, 255, 255, MultiplyWithOpacityFactor(255, globalOpacityFactor), false)
    DrawText2D(x + 0.01 + textOffset.x, y - 0.06 * menuScale + textOffset.y, Config_QuickMenu.emoteTablesTitles[emoteTableIndexMap[currentEmoteTableIndex]], titleColor, 0, scale, 1)
    local text
    if pickingFavoriteIndex then
        text = Config_QuickMenu.MenuLanguage.pickAnEmoteSpot.text:format(currentEmoteToFavorite.emoteName)
        local color = { Config_QuickMenu.MenuLanguage.pickAnEmoteSpot.color[1], Config_QuickMenu.MenuLanguage.pickAnEmoteSpot.color[2], Config_QuickMenu.MenuLanguage.pickAnEmoteSpot.color[3], Config_QuickMenu.MenuLanguage.pickAnEmoteSpot.color[4] }
        color[4] = MultiplyWithOpacityFactor(color[4], globalOpacityFactor)
        DrawTexture("itemtype_textures", "itemtype_upgrades", iconX, y, iconW * 0.75, iconH * 0.75, 0.0, 255, 215, 0, MultiplyWithOpacityFactor(255, globalOpacityFactor), false)
        DrawText2D((pickingFavoriteIndex) and (x + 0.015 + textOffset.x) or (x + textOffset.x), y - 0.012 * menuScale + textOffset.y, text, color, 0, { menuTextScale * menuScale, menuTextScale * menuScale }, menuFont)
    elseif favoriting then
        text = Config_QuickMenu.MenuLanguage.pickAnEmoteToFavorite.text
        local color = { Config_QuickMenu.MenuLanguage.pickAnEmoteToFavorite.color[1], Config_QuickMenu.MenuLanguage.pickAnEmoteToFavorite.color[2], Config_QuickMenu.MenuLanguage.pickAnEmoteToFavorite.color[3], Config_QuickMenu.MenuLanguage.pickAnEmoteToFavorite.color[4] }
        color[4] = MultiplyWithOpacityFactor(GetColorFade(4), globalOpacityFactor)
        DrawTexture("itemtype_textures", "itemtype_player_health", iconX, y, iconW * 0.75, iconH * 0.75, 0.0, 255, 255, 255, MultiplyWithOpacityFactor(255, globalOpacityFactor), false)
        DrawText2D(favoriting and (x + 0.015 + textOffset.x) or (x + textOffset.x), (y - 0.012 * menuScale + textOffset.y) or (y - 0.015 + textOffset.y), text, color, 0, { menuTextScale * menuScale, menuTextScale * menuScale }, menuFont)
    else
        text = Config_QuickMenu.MenuLanguage.pickAnEmoteSubtitle.text
        local color = { Config_QuickMenu.MenuLanguage.pickAnEmoteSubtitle.color[1], Config_QuickMenu.MenuLanguage.pickAnEmoteSubtitle.color[2], Config_QuickMenu.MenuLanguage.pickAnEmoteSubtitle.color[3], Config_QuickMenu.MenuLanguage.pickAnEmoteSubtitle.color[4] }
        color[4] = MultiplyWithOpacityFactor(color[4], globalOpacityFactor)
        DrawText2D(x + textOffset.x, y - 0.012 * menuScale + textOffset.y, text, color, 0, { menuTextScale * menuScale, menuTextScale * menuScale }, menuFont)
    end
    y = y + 0.015 * menuScale
    for idx = 1, totalEmotesInPage do
        local row = pageRows[idx]
        local iconOffsetFromText = 0.022
        iconY = y + (idx - (1 * menuScale ^ magicPower)) * itemSpacing + iconOffsetFromText
        local fadeColor = GetColorFade(idx)
        local color = { 255, 255, 255, (favoriting or pickingFavoriteIndex) and fadeColor or 255 }
        color[4] = MultiplyWithOpacityFactor(color[4], globalOpacityFactor)
        local emoteKey = row and row.key or nil
        local emoteType = row and row.typ or nil
        local emoteData = row and row.data or nil
        local emoteName = row and row.name or "Empty"
        local textureColor = Config_QuickMenu.ColorEachMenuKeybindByType and Config_QuickMenu.emoteTablesTitlesColors[emoteType] or { 255, 255, 255 }
        local iconAlpha = MultiplyWithOpacityFactor(row and row.enabled and 255 or 115, globalOpacityFactor)
        if IsUsingController then
            dic = controlIconsGamepadDict
            tex = Config_QuickMenu.controlIconsGamepad[ControllerType][idx]
            DrawTexture(dic, tex, iconX, iconY, iconW * controllerIconDescaler, iconH * controllerIconDescaler, 0.0, textureColor[1], textureColor[2], textureColor[3], iconAlpha, false)
        else
            dic = "keyboard_num_controls"
            if Config_QuickMenu.controlIconsKeyboard then
                tex = Config_QuickMenu.controlIconsKeyboard[idx]
            else
                tex = "button" .. idx
            end
            DrawTexture(dic, tex, iconX, iconY, iconW * controllerIconDescaler, iconH * controllerIconDescaler, 0.0, textureColor[1], textureColor[2], textureColor[3], iconAlpha, false)
        end
        DrawText2D(x + xOffset + textOffset.x, y + (idx - 1) * itemSpacing + 0.01 + textOffset.y, emoteName .. "~q~", { color[1], color[2], color[3], row and row.enabled and color[4] or 115 }, nil, instructScale, menuFont)
        if emoteIndex == idx then
            local StartTime    = GetGameTimer()
            local animDuration = 1300
            local slideDist    = 0.1
            local baseAlpha    = (row and row.enabled and color[4] or 115)

            CreateThread(function()
                while true do
                    Wait(0)

                    local elapsed = GetGameTimer() - StartTime
                    local t = elapsed / animDuration

                    if t >= 1.0 then
                        t = 1.0
                    end

                    local slideT        = EaseOutCubic(t)
                    local xOffset       = slideDist * slideT

                    local fadeT         = EaseInQuad(t)
                    local fadeOut       = 1.0 - fadeT
                    local adjustedAlpha = math.max(Lerp(baseAlpha, 0.0, fadeT), 0.0)

                    DrawText2D(
                        x + xOffset,
                        y + (idx - 1) * itemSpacing + 0.01,
                        emoteName .. "~q~",
                        { color[1], color[2], color[3], adjustedAlpha },
                        nil,
                        instructScale,
                        30
                    )

                    if elapsed >= animDuration then
                        break
                    end
                end
            end)
            return
        end
    end

    local pbTypeText = playbackTypes[playBackType + 1] .. (emoteTableIndexMap[currentEmoteTableIndex] == "favorite" and Config_QuickMenu.MenuLanguage.emotesOnly.text or "")
    local pbTypeColorFromConfig = Config_QuickMenu.playbackColors[playBackType + 1] or { 255, 255, 255, 255 }
    local pbTypeColor = BuildColorWithAlpha(pbTypeColorFromConfig, MultiplyWithOpacityFactor(pbTypeColorFromConfig[4], globalOpacityFactor))
    local yPaddingAdd = 0.008 * menuScale
    local yCoordDiff = 0.030 * menuScale
    local textToIconOffset = 0.012 * menuScale
    local function addButtonSpacing()
        buttonCount = buttonCount + 1
        yCoordDiff = yCoordDiff + yPaddingAdd
    end
    buttonCount = 0
    local buttonOpacity = MultiplyWithOpacityFactor(255, globalOpacityFactor)
    local promptLayout = {
        baseY = y,
        totalItems = totalEmotesInPage,
        itemSpacing = itemSpacing,
        yCoordDiff = yCoordDiff,
        textToIconOffset = textToIconOffset,
        iconX = iconX,
        textX = x + xOffset + textOffset.x,
        textOffsetY = textOffset.y,
        promptButtonScale = promptButtonScale,
        buttonOpacity = buttonOpacity,
        instructScale = instructScale,
    }
    local stopEmoteColor = BuildColorWithAlpha(Config_QuickMenu.MenuLanguage.exitMenu.color, buttonOpacity)
    DrawMenuPromptRow("exitMenu", Config_QuickMenu.MenuLanguage.exitMenu.text, stopEmoteColor, promptLayout, buttonCount)
    addButtonSpacing()
    promptLayout.yCoordDiff = yCoordDiff
    local pageNumberColor = BuildColorWithAlpha(Config_QuickMenu.MenuLanguage.pageNumber.color, buttonOpacity)
    DrawMenuPromptRow("openMenu", Config_QuickMenu.MenuLanguage.pageNumber.text .. emoteMenuPage .. "/~COLOR_GREYLIGHT~" .. pageCount, pageNumberColor, promptLayout, buttonCount)
    addButtonSpacing()
    if not (favoriting or pickingFavoriteIndex) then
        if emoteTableIndexMap[currentEmoteTableIndex] == "emote" or emoteTableIndexMap[currentEmoteTableIndex] == "favorite" then
            promptLayout.yCoordDiff = yCoordDiff
            DrawMenuPromptRow("switchPlayBackType", pbTypeText, pbTypeColor, promptLayout, buttonCount)
            addButtonSpacing()
        end
        promptLayout.yCoordDiff = yCoordDiff
        local switchTableColor = BuildColorWithAlpha(Config_QuickMenu.MenuLanguage.switchEmoteTable.color, buttonOpacity)
        DrawMenuPromptRow("switchEmoteTable", Config_QuickMenu.MenuLanguage.switchEmoteTable.text .. " ~q~" .. currentEmoteTableIndex .. "/~COLOR_GREYLIGHT~" .. #emoteTableIndexMap, switchTableColor, promptLayout, buttonCount)
        addButtonSpacing()
        if IsUsingController and Config_QuickMenu.ControllerMenuControls.switchControllerLayout then
            promptLayout.yCoordDiff = yCoordDiff
            local switchLayoutColor = BuildColorWithAlpha(Config_QuickMenu.MenuLanguage.switchControllerLayout.color, buttonOpacity)
            DrawMenuPromptRow("switchControllerLayout", "~q~" .. Config_QuickMenu.MenuLanguage.switchControllerLayout.text .. ControllerTypeTexts[ControllerType], switchLayoutColor, promptLayout, buttonCount)
            buttonCount = buttonCount + 1
        end
    else
        buttonCount = buttonCount + 1
    end
    local favoriteEmoteColorFromConfig = (favoriting or pickingFavoriteIndex) and Config_QuickMenu.MenuLanguage.stopFavoriting.color or Config_QuickMenu.MenuLanguage.favoriteAnEmote.color
    local favoriteEmoteColor = BuildColorWithAlpha(favoriteEmoteColorFromConfig, buttonOpacity)
    promptLayout.yCoordDiff = yCoordDiff
    DrawMenuPromptRow("favoriteEmote", (favoriting or pickingFavoriteIndex) and Config_QuickMenu.MenuLanguage.stopFavoriting.text or Config_QuickMenu.MenuLanguage.favoriteAnEmote.text, favoriteEmoteColor, promptLayout, buttonCount)
    buttonCount = buttonCount + 1
end

local emoteMenuTimer = 0
local emoteMenuTimeout = Config_QuickMenu.MenuTimeout

local function resetEmoteMenuTimer()
    emoteMenuTimer = GetGameTimer() + emoteMenuTimeout
end

function checkControlInput(index)
    if IsUsingController then
        DisableControlAction(0, Config_QuickMenu.ControllerMenuControls[index], true)
        return not IsDisabledControlPressed(0, Config.PointControl["Controller"]) and IsDisabledControlJustReleased(0, Config_QuickMenu.ControllerMenuControls[index])
    else
        return IsRawKeyPressed(Config_QuickMenu.KeyboardMenuControls[index])
    end
end

function checkControlHeld(index)
    if IsUsingController then
        DisableControlAction(0, Config_QuickMenu.ControllerMenuControls[index], true)
        return not IsDisabledControlPressed(0, Config.PointControl["Controller"]) and IsDisabledControlJustReleased(0, Config_QuickMenu.ControllerMenuControls[index])
    else
        return IsRawKeyDown(Config_QuickMenu.KeyboardMenuControls[index])
    end
end

function checkControlInputWithoutDisabling(index)
    if IsUsingController then
        return not IsControlPressed(0, Config.PointControl["Controller"]) and IsControlJustReleased(0, Config_QuickMenu.ControllerMenuControls[index])
    else
        return IsRawKeyPressed(Config_QuickMenu.KeyboardMenuControls[index])
    end
end

local function handleEmoteSelection()
    local ped = PlayerPedId()
    for i = 1, totalEmotesInPage do
        local isPressed = checkControlInput(i)
        if isPressed then
            resetEmoteMenuTimer()
            local row = pageRows[i]
            local emoteIdx = row and row.emoteIdx or (startIdx + i - 1)
            local key = row and row.key or nil
            local typ = row and row.typ or emoteTableIndexMap[currentEmoteTableIndex]
            if pickingFavoriteIndex then
                TriggerServerEvent('mosquito:server:favoriteNewAnimation', emoteIdx, currentEmoteToFavorite.emoteKey, currentEmoteToFavorite.emoteType)

                pickingFavoriteIndex = false
                favoriting = false
                currentEmoteToFavorite = nil
                emoteMenuOpen = false
                return false
            end
            if key then
                if typ == "sitinteraction" and not IsSitInteractionVisibleForPed(key, ped) then
                    mosquito.notify.right_tip("~COLOR_RED~This sit scenario is not available for your character.~q~")
                    return false
                end
                if favoriting then
                    local emoteData = (row and row.data) or GetEmoteDataByType(typ, key)
                    local name = emoteData and (emoteData.name or key) or key or "Empty"
                    currentEmoteToFavorite = { emoteKey = key, emoteType = typ, emoteName = name }
                    currentEmoteTableIndex = 1
                    while emoteTableIndexMap[currentEmoteTableIndex] ~= "favorite" do
                        currentEmoteTableIndex = currentEmoteTableIndex + 1
                    end
                    emoteMenuPage = 1
                    pickingFavoriteIndex = true
                    favoriting = false
                    invalidatePageRowsCache()
                    return false
                else
                    if typ == "sitinteraction" then
                        ExecuteSitInteraction(key)
                    elseif typ == "scenario" and not IsPedOnMount(ped) then
                        ScenarioCommand(_, { key })
                    elseif typ == "emote" then
                        NativeEmoteCommand(_, { key, playBackType })
                    else
                        local info = Config.Emotes[key]
                        if not IsPedOnMount(ped) or (info and info.animation and info.animation.flag > 5) then
                            EmoteCommand(_, { key })
                        end
                    end
                end
                emoteMenuOpen = false
                return true, i
            end
        end
    end
    return false
end

local function disableControls()
    local nameOfTableToDisable = IsUsingController and "controller" or "keyboard"
    local tableToDisable = Config_QuickMenu.ControlsToDisable[nameOfTableToDisable]
    for _, control in ipairs(tableToDisable) do
        DisableControlAction(0, control, true)
    end
end

local function handlePageSwitch()
    local isPressed = checkControlInput("openMenu")
    if isPressed then
        emoteMenuPage = emoteMenuPage % getEmoteMenuPageCount() + 1
        invalidatePageRowsCache()
        return true
    end
    return false
end

local function controlHeldForAWhile(controlName)
    local holdTime = 0
    while true do
        Wait(5)
        holdTime = holdTime + 5
        if not checkControlHeld(controlName) then
            return false
        end
        if holdTime >= 100 then
            return true
        end
    end
    return false
end

local function handleEscape()
    CreateThread(function()
        local doEscape = false
        local isPressed = checkControlInput("exitMenu")
        if isPressed then
            doEscape = not controlHeldForAWhile("exitMenu")
        end
        if isPressed then
            local ped = PlayerPedId()
            if doEscape then
                StopUsingEmote()
                ClearPedTasks(ped)
                StopCurrentScenario(ped, true)
                if Config_InteractionMenu.EnableInteractionMenu and CurrentInteraction then
                    StopInteraction(false)
                    SendNUIMessage({
                        type = "hideInteractionPicker"
                    })
                    SetInteractionMarker()
                    PickerIsOpen = false
                    DeleteInteractPrompt()
                end
                if CurrentlySitting then
                    stopInteraction(ped)
                end
            end
            emoteMenuOpen = false
            PlaySoundEffect("HUD_DOMINOS_SOUNDSET", "YES")
            return true
        end
        return false
    end)
end

local function handlePlaybackTypeToggle()
    local isPressed = checkControlInputWithoutDisabling("switchPlayBackType")
    if isPressed then
        playBackType = (playBackType + 1) < #playbackTypes and (playBackType + 1) or 0
        return true
    end
    return false
end

local function handleTableSwitch()
    local isPressed = checkControlInput("switchEmoteTable")
    if isPressed then
        currentEmoteTableIndex = currentEmoteTableIndex < #emoteTableIndexMap and currentEmoteTableIndex + 1 or 1
        if favoriting then
            if emoteTableIndexMap[currentEmoteTableIndex] == "favorite" then
                currentEmoteTableIndex = currentEmoteTableIndex < #emoteTableIndexMap and currentEmoteTableIndex + 1 or 1
            end
        end
        emoteMenuPage = 1
        invalidatePageRowsCache()
        return true
    end
    return false
end

local function handleLayoutSwitch()
    if not IsUsingController then
        return false
    end

    local isPressed = checkControlInput("switchControllerLayout")
    if isPressed then
        if ControllerType == 1 then
            ControllerType = 2
        elseif ControllerType == 2 then
            ControllerType = 1
        end
        resetEmoteMenuTimer()
        return true
    end
    return false
end

local function handleFavoriting()
    local isPressed = checkControlInput("favoriteEmote")
    if isPressed then
        if emoteTableIndexMap[currentEmoteTableIndex] == "favorite" then
            while emoteTableIndexMap[currentEmoteTableIndex] == "favorite" do
                currentEmoteTableIndex = currentEmoteTableIndex < #emoteTableIndexMap and currentEmoteTableIndex + 1 or 1
            end
            emoteMenuPage = 1
        end
        favoriting = not favoriting
        pickingFavoriteIndex = false
        currentEmoteToFavorite = nil
        invalidatePageRowsCache()
    end
    return false
end

local function openEmoteMenuIfKeyPressed()
    local isPressed = checkControlInput("openMenu")
    if isPressed and not IsPedDeadOrDying(PlayerPedId()) then
        local ped = PlayerPedId()
        RefreshSitInteractionCommandList(ped, true)
        resetEmoteMenuTimer()
        emoteMenuOpen = true
        emoteMenuPage = 1
        favoriting = false
        pickingFavoriteIndex = false
        currentEmoteToFavorite = nil
        invalidatePageRowsCache()
        return true
    end
    return false
end


local wasOpen = false
local mapOpened = false
local paperOpened = false

function QuickEmoteMenuHandler()
    if emoteMenuOpen then
        local ped = PlayerPedId()
        local tableType = emoteTableIndexMap[currentEmoteTableIndex]
        if tableType == "sitinteraction" or tableType == "favorite" then
            if RefreshSitInteractionCommandList(ped, false) then
                invalidatePageRowsCache()
            end
        end

        emotesPerPage = Config_QuickMenu.EmotesPerPage[IsUsingController and "controller" or "keyboard"]
        ensureCurrentPageRows(ped)
        local interacted = false
        local playedEmote = false
        local menuTimeLeft = emoteMenuTimer - GetGameTimer()
        local emotePlayed, emoteIndex = handleEmoteSelection()
        disableControls()
        if emoteIndex then
            drawEmoteMenu(menuTimeLeft, emoteIndex)
        else
            drawEmoteMenu(menuTimeLeft, false)
        end

        if emotePlayed then
            if not pickingFavoriteIndex then
                interacted = true
                playedEmote = true
            end
        end

        if handlePageSwitch() then
            interacted = true
        end


        handleEscape()

        if not pickingFavoriteIndex then
            if emoteTableIndexMap[currentEmoteTableIndex] == "emote" or emoteTableIndexMap[currentEmoteTableIndex] == "favorite" then
                if handlePlaybackTypeToggle() then
                    interacted = true
                end
            end

            if handleTableSwitch() then
                interacted = true
            end

            if handleLayoutSwitch() then
                interacted = true
            end
        end

        if handleFavoriting() then
            interacted = true
        end

        if emoteMenuTimer > 0 and GetGameTimer() > emoteMenuTimer then
            favoriting = false
            pickingFavoriteIndex = false
            currentEmoteToFavorite = nil
            emoteMenuOpen = false
        end

        if interacted then
            resetEmoteMenuTimer()
            if playedEmote then
                frontend_soundset_ref = "HUD_POKER"
                frontend_soundset_name = "BET_AMOUNT"
            else
                frontend_soundset_ref = "HUD_DOMINOS_SOUNDSET"
                frontend_soundset_name = "YES"
            end
            PlaySoundEffect(frontend_soundset_ref, frontend_soundset_name)
        end
        interacted = false
        playedEmote = false
    else
        if openEmoteMenuIfKeyPressed() then
            PlaySoundEffect("HUD_DOMINOS_SOUNDSET", "YES")
        end
    end
end
