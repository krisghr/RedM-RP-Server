mosquito = {
    notify = {}
}

if not DataView then
    require("dataview")
end

local function LoadTextureDict(dict, waiter)
    if DoesStreamedTextureDictExist(dict) then
        if not HasStreamedTextureDictLoaded(dict) then
            RequestStreamedTextureDict(dict, true)
            while waiter and not HasStreamedTextureDictLoaded(dict) do
                Wait(0)
            end
        end
    end
end

local function UiFeedPostSampleToastRight(...)
    return Citizen.InvokeNative(0xB249EBCB30DD88E0, ...)
end

local function UiFeedClearAllChannels(...)
    return Citizen.InvokeNative(0x6035E8FBCA32AC5E, ...)
end

---@param text string The text of the notification
---@param dict string The dictionary of the icon
---@param icon string The name of the icon
---@param color? string The color of the text
---@param duration? integer The duration of the notification in ms
---@param soundset_ref? string The dictionary of the soundset
---@param soundset_name? string The name of the soundset
function mosquito.notify.right(text, dict, icon, color, duration, soundset_ref, soundset_name)
    local message = {
        type = "notification_right",
        text = tostring(text or ""),
        dict = tostring(dict or ""),
        icon = tostring(icon or ""),
        color = tostring(color or "COLOR_WHITE"),
        duration = tonumber(duration or 3000),
        soundset_ref = soundset_ref or "Transaction_Feed_Sounds",
        soundset_name = soundset_name or "Transaction_Positive"
    }

    if not message then return end

    UiFeedClearAllChannels()
    LoadTextureDict(message.dict, true)

    message.text = CreateVarString(10, "LITERAL_STRING", message.text)
    message.dict = CreateVarString(10, "LITERAL_STRING", message.dict)
    message.soundset_ref = CreateVarString(10, "LITERAL_STRING", message.soundset_ref)
    message.soundset_name = CreateVarString(10, "LITERAL_STRING", message.soundset_name)

    local struct_config = DataView.ArrayBuffer(8 * 7)
    struct_config:SetInt32(8 * 0, message.duration)
    struct_config:SetInt64(8 * 1, bigInt(message.soundset_ref))
    struct_config:SetInt64(8 * 2, bigInt(message.soundset_name))

    local struct_data = DataView.ArrayBuffer(8 * 10)
    struct_data:SetInt64(8 * 1, bigInt(message.text))
    struct_data:SetInt64(8 * 2, bigInt(message.dict))
    struct_data:SetInt64(8 * 3, bigInt(joaat(message.icon)))
    struct_data:SetInt64(8 * 5, bigInt(joaat(message.color)))

    UiFeedPostSampleToastRight(struct_config:Buffer(), struct_data:Buffer(), 1)
end

function mosquito.notify.right_tip(tipMessage, duration)
    local structConfig = DataView.ArrayBuffer(8 * 7)
    structConfig:SetInt32(8 * 0, tonumber(duration or 3000))

    local structData = DataView.ArrayBuffer(8 * 3)
    structData:SetInt64(8 * 1, bigInt(VarString(10, "LITERAL_STRING", tipMessage)))

    Citizen.InvokeNative(0xB2920B9760F0F36B, structConfig:Buffer(), structData:Buffer(), 1)
end

function mosquito.notify.objective(message, duration)
    Citizen.InvokeNative("0xDD1232B332CBB9E7", 3, 1, 0)

    local structConfig = DataView.ArrayBuffer(8 * 7)
    structConfig:SetInt32(8 * 0, tonumber(duration or 3000))

    local structData = DataView.ArrayBuffer(8 * 3)
    local strMessage = VarString(10, "LITERAL_STRING", message)
    structData:SetInt64(8 * 1, bigInt(strMessage))

    Citizen.InvokeNative(0xCEDBF17EFCC0E4A4, structConfig:Buffer(), structData:Buffer(), 1)
end

---@param text string
function mosquito.notify.right_success(text)
    mosquito.notify.right(text, "hud_textures", "check", "COLOR_GREEN")
    return true
end

---@param text string
function mosquito.notify.right_error(text)
    mosquito.notify.right(text, "menu_textures", "cross", "COLOR_RED", nil, nil, "Transaction_Negative")
    return false
end

RegisterNetEvent(GetCurrentResourceName() .. ":client:notify_objective", function(message, duration)
    mosquito.notify.objective(message, duration)
end)

RegisterNetEvent(GetCurrentResourceName() .. ":client:notify_right_tip", function(tipMessage, duration)
    mosquito.notify.right_tip(tipMessage, duration)
end)

RegisterNetEvent(GetCurrentResourceName() .. ":client:notify_right", function(text, dict, icon, color, duration, soundset_ref, soundset_name)
    mosquito.notify.right(text, dict, icon, color, duration, soundset_ref, soundset_name)
end)
