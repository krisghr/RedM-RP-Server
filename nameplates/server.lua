local VORPcore = exports.vorp_core:GetCore()
local typingStates = {}
local afkStates = {}

local function GetCharacterName(src)
    local playerState = Player(src) and Player(src).state
    if playerState and playerState.maskedAlias then
        return playerState.maskedAlias
    end
    local User = VORPcore.getUser(src)
    if not User then return GetPlayerName(src) end

    local Character = User.getUsedCharacter
    if not Character then return GetPlayerName(src) end

    local firstname = Character.firstname or Character.firstName or ""
    local lastname = Character.lastname or Character.lastName or ""

    local fullName = (firstname .. " " .. lastname):gsub("^%s*(.-)%s*$", "%1")

    if fullName == "" then
        return GetPlayerName(src)
    end

    return fullName
end

RegisterNetEvent("player_names:requestNames", function()
    local src = source
    local names = {}

    for _, playerId in ipairs(GetPlayers()) do
        local id = tonumber(playerId)

        names[id] = {
            id = id,
            name = GetCharacterName(id),
            isTyping = typingStates[id] == true,
            isAfk = afkStates[id] == true,
            isEditor = (Player(id) and Player(id).state and Player(id).state.editorModeActive) == true
        }
    end

    TriggerClientEvent("player_names:receiveNames", src, names)
end)

RegisterNetEvent("player_names:setTypingState", function(isTyping)
    local src = source
    local newState = isTyping == true

    typingStates[src] = newState
    TriggerClientEvent("player_names:updateTypingState", -1, src, newState)
end)

RegisterNetEvent("player_names:setAfkState", function(isAfk)
    local src = source
    local newState = isAfk == true

    afkStates[src] = newState
    TriggerClientEvent("player_names:updateAfkState", -1, src, newState)
end)

AddEventHandler("playerDropped", function()
    local src = source

    -- clear server cache
    typingStates[src] = nil
    afkStates[src] = nil

    -- immediately clear client-side typing indicator for this player
    TriggerClientEvent("player_names:updateTypingState", -1, src, false)
    TriggerClientEvent("player_names:updateAfkState", -1, src, false)
end)
