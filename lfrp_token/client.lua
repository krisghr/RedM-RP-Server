local lfrpBlips = {}
local lfrpTracking = false

local BLIP_STYLE = -1282792512
local BLIP_COLOR = GetHashKey("BLIP_MODIFIER_MP_COLOR_1") -- green-ish
local UPDATE_INTERVAL = 10000

local function SendMyLfrpCoords()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    TriggerServerEvent("lfrp:sendCoords", {
        x = coords.x,
        y = coords.y,
        z = coords.z
    })
end

RegisterNetEvent("lfrp:requestCoords", function()
    SendMyLfrpCoords()
end)

RegisterNetEvent("lfrp:startTracking", function()
    if lfrpTracking then return end

    lfrpTracking = true

    CreateThread(function()
        while lfrpTracking do
            SendMyLfrpCoords()
            Wait(UPDATE_INTERVAL)
        end
    end)
end)

RegisterNetEvent("lfrp:stopTracking", function()
    lfrpTracking = false
end)

RegisterNetEvent("lfrp:createOrUpdateBlip", function(serverId, nickname, coords)
    -- If it already exists, just move it instead of remaking it
    if lfrpBlips[serverId] then
        Citizen.InvokeNative(
            0x4FF674F5E23D49CE, -- SET_BLIP_COORDS
            lfrpBlips[serverId],
            coords.x,
            coords.y,
            coords.z
        )
        return
    end

local blip = Citizen.InvokeNative(
    0x554D9D53F696D002,
    -1282792512, -- sprite-compatible style
    coords.x,
    coords.y,
    coords.z
)

if not blip or blip == 0 then
    print("[LFRP] Failed to create blip")
    return
end

-- CHANGE THIS to try icons
SetBlipSprite(blip, GetHashKey("blip_hire_camp_follower"), true)

-- Name
Citizen.InvokeNative(
    0x9CB1A1623062F402,
    blip,
    CreateVarString(10, "LITERAL_STRING", nickname)
)

-- Green color
Citizen.InvokeNative(
    0x662D364ABF16DE2F,
    blip,
    GetHashKey("BLIP_MODIFIER_MP_COLOR_1")
)

Citizen.InvokeNative(0xAE9FC9EF6A9FAC79, blip, true)

    lfrpBlips[serverId] = blip
end)

RegisterNetEvent("lfrp:removeBlip", function(serverId)
    if lfrpBlips[serverId] then
        RemoveBlip(lfrpBlips[serverId])
        lfrpBlips[serverId] = nil
    end
end)

RegisterCommand("clearlfrp", function()
    for serverId, blip in pairs(lfrpBlips) do
        RemoveBlip(blip)
        lfrpBlips[serverId] = nil
    end

    print("[LFRP CLIENT] Cleared all LFRP blips")
end, false)