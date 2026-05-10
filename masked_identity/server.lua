print("masked_identity server started")
local maskedPlayers = {}

local function randomAlias()
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local out = {}
    for _ = 1, Config.AliasLength do
        local idx = math.random(1, #chars)
        out[#out + 1] = chars:sub(idx, idx)
    end
    return ("%s_%s"):format(Config.MaskAliasPrefix, table.concat(out))
end

RegisterNetEvent("masked_identity:setMaskedState", function(masked)
    local src = source

    if masked then
        local alias = randomAlias()
        maskedPlayers[src] = alias
        Player(src).state:set("maskedAlias", alias, true)
    else
        maskedPlayers[src] = nil
        Player(src).state:set("maskedAlias", nil, true)
    end
end)

AddEventHandler("playerDropped", function()
    local src = source
    maskedPlayers[src] = nil
end)

AddEventHandler("chatMessage", function(source, _, message)
    local alias = maskedPlayers[source]
    if not alias then return end

    CancelEvent()
    TriggerClientEvent("chat:addMessage", -1, {
        color = { 240, 240, 240 },
        args = { alias, message }
    })
end)
