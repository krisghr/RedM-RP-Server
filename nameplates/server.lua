local VORPcore = exports.vorp_core:GetCore()

local function GetCharacterName(src)
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
            name = GetCharacterName(id)
        }
    end

    TriggerClientEvent("player_names:receiveNames", src, names)
end)