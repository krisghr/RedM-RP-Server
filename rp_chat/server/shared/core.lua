print("[RP_CHAT] server modules loaded")

local VORPcore = exports.vorp_core:GetCore()

RPChat = RPChat or {}
RPChat.DEBUG_CHAT = false
RPChat.VORPcore = VORPcore
RPChat.RANGES = {
    lower = 2.0,
    low = 5.0,
    normal = 15.0,
    shout = 35.0,
    farshout = 40.0
}

function RPChat.Trim(str)
    return (str or ""):gsub("^%s*(.-)%s*$", "%1")
end

function RPChat.GetCharacterName(src)
    local state = Player(src) and Player(src).state
    if state and type(state.maskedAlias) == "string" and state.maskedAlias ~= "" then
        return state.maskedAlias
    end
    local User = VORPcore.getUser(src)
    if not User then return GetPlayerName(src) end

    local Character = User.getUsedCharacter
    if not Character then return GetPlayerName(src) end

    local firstname = Character.firstname or Character.firstName or ""
    local lastname = Character.lastname or Character.lastName or ""

    local fullName = RPChat.Trim(firstname .. " " .. lastname)

    if fullName == "" then
        return GetPlayerName(src)
    end

    return fullName
end

function RPChat.GetBrightness(distance, maxRange)
    local t = distance / maxRange

    if t < 0.0 then t = 0.0 end
    if t > 1.0 then t = 1.0 end

    return 1.0 - (t * 0.5)
end

function RPChat.AppendSlashFormatted(template, args, index, text, colorStyle)
    local pos = 1

    while true do
        local startI = text:find('/', pos, true)

        if not startI then
            local remaining = text:sub(pos)

            if remaining ~= "" then
                template = template .. '<span style="' .. colorStyle .. '">{' .. index .. '}</span>'
                table.insert(args, remaining)
                index = index + 1
            end

            break
        end

        local endI = text:find('/', startI + 1, true)

        if not endI then
            local remaining = text:sub(pos)

            if remaining ~= "" then
                template = template .. '<span style="' .. colorStyle .. '">{' .. index .. '}</span>'
                table.insert(args, remaining)
                index = index + 1
            end

            break
        end

        local before = text:sub(pos, startI - 1)
        local italicText = text:sub(startI + 1, endI - 1)

        if before ~= "" then
            template = template .. '<span style="' .. colorStyle .. '">{' .. index .. '}</span>'
            table.insert(args, before)
            index = index + 1
        end

        if italicText ~= "" then
            template = template .. '<span style="' .. colorStyle .. '; font-style: italic;">{' .. index .. '}</span>'
            table.insert(args, italicText)
            index = index + 1
        end

        pos = endI + 1
    end

    return template, index
end

function RPChat.BuildSpeechMessage(charName, verb, message, r, g, b, emoteR, emoteG, emoteB)
    local template = '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')">{0} ' .. verb .. ', </span>'
    local args = { charName }

    local index = 1
    local pos = 1

    while true do
        local startE, endE = message:find("%*", pos)

        if not startE then
            local remaining = RPChat.Trim(message:sub(pos))

            if remaining ~= "" then
                template = template .. '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')">"</span>'
                template, index = RPChat.AppendSlashFormatted(template, args, index, remaining, 'color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')')
                template = template .. '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')">"</span>'
            end

            break
        end

        local endE2 = message:find("%*", endE + 1)

        if not endE2 then
            local remaining = RPChat.Trim(message:sub(pos))

            if remaining ~= "" then
                template = template .. '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')">"</span>'
                template, index = RPChat.AppendSlashFormatted(template, args, index, remaining, 'color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')')
                template = template .. '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')">"</span>'
            end

            break
        end

        local before = RPChat.Trim(message:sub(pos, startE - 1))
        local emote = RPChat.Trim(message:sub(endE + 1, endE2 - 1))

        if before ~= "" then
            template = template .. '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')">"</span>'
            template, index = RPChat.AppendSlashFormatted(template, args, index, before, 'color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')')
            template = template .. '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')">" </span>'
        end

        if emote ~= "" then
            template, index = RPChat.AppendSlashFormatted(template, args, index, emote, 'color: rgb(' .. emoteR .. ',' .. emoteG .. ',' .. emoteB .. ')')
            template = template .. '<span style="color: rgb(' .. emoteR .. ',' .. emoteG .. ',' .. emoteB .. ')"> </span>'
        end

        pos = endE2 + 1
    end

    return { template = template, args = args }
end

function RPChat.BuildMeMessage(charName, message, r, g, b)
    local template = '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')">* {0}</span>'
    local args = { charName }
    local index = 1
    local pos = 1

    while true do
        local startQ, endQ = message:find('"', pos)
        if not startQ then
            local remaining = message:sub(pos)
            if remaining ~= "" then
                template = template .. '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')"> </span>'
                template, index = RPChat.AppendSlashFormatted(template, args, index, remaining, 'color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')')
            end
            break
        end

        local endQ2 = message:find('"', endQ + 1)
        if not endQ2 then
            local remaining = message:sub(pos)
            if remaining ~= "" then
                template = template .. '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')"> </span>'
                template, index = RPChat.AppendSlashFormatted(template, args, index, remaining, 'color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')')
            end
            break
        end

        local before = message:sub(pos, startQ - 1)
        local quoted = message:sub(endQ + 1, endQ2 - 1)
        if before ~= "" then
            template = template .. '<span style="color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')"> </span>'
            template, index = RPChat.AppendSlashFormatted(template, args, index, before, 'color: rgb(' .. r .. ',' .. g .. ',' .. b .. ')')
        end

        template = template .. '<span style="color: white">"</span>'
        template, index = RPChat.AppendSlashFormatted(template, args, index, quoted, 'color: white')
        template = template .. '<span style="color: white">"</span>'
        pos = endQ2 + 1
    end

    return { template = template, args = args }
end