FrameworkClient = FrameworkClient or {}

if Config.Framework == 'vorp' then
    local Core = exports.vorp_core:GetCore()

    function FrameworkClient.Notify(message, duration)
        local timeMs = duration or 4000
        Core.NotifyRightTip(message, timeMs)
    end
end