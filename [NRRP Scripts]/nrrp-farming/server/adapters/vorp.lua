FrameworkServer = FrameworkServer or {}

if Config.Framework == 'vorp' then
    local Core = exports.vorp_core:GetCore()
    local Inventory = exports.vorp_inventory:vorp_inventoryApi()

    function FrameworkServer.Notify(src, message, duration)
        local timeMs = duration or 4000
        Core.NotifyRightTip(src, message, timeMs)
    end

    function FrameworkServer.AddItem(src, itemName, amount, metadata)
        local meta = metadata or {}
        return Inventory.addItem(src, itemName, amount, meta)
    end

    function FrameworkServer.GetCharacterId(src)
        local user = Core.getUser(src)
        if not user or not user.getUsedCharacter then
            return nil
        end

        return user.getUsedCharacter.charIdentifier
    end
end
