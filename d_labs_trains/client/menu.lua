local menu = nil

if GetResourceState('vorp_menu') == 'started' then
    menu = exports.vorp_menu:GetMenuData()
elseif GetResourceState('rsg-menubase') == 'started' then
    menu = exports['rsg-menubase']:GetMenuData()
else
    menu = {}
    TriggerEvent("redemrp_menu_base:getData",function(call)
        menu = call
    end)
end

-- ===================================================================== 
-- bridge
-- =====================================================================

function OpenMenu(data, onSelect, onClose)
    if MenuSystem == 'vorp' then
        BridgeVorpMenu(data, onSelect, onClose)
    elseif MenuSystem == 'rsg' then
        BridgeRsgMenu(data, onSelect, onClose)
    else
        BridgeRedemMenu(data, onSelect, onClose)
    end
end

function CloseMenu()
    if MenuSystem == 'vorp' then
        menu.CloseAll()
    elseif MenuSystem == 'rsg' then
        menu.CloseAll()
    else
        menu.CloseAll()
    end
end

-- ===================================================================== 
--  menu by name
-- =====================================================================

function BridgeVorpMenu(data, onSelect, onClose)
    menu.CloseAll()

    menu.Open(
        'default',
        GetCurrentResourceName(),
        'bridge_' .. tostring(math.random(10000, 99999)),
        {
            title = data.title,
            align = data.align or 'top-left',
            elements = data.elements
        },

        function(selected, currentMenu)

            if onSelect and selected and selected.current then
                onSelect(
                    { current = selected.current },
                    {
                        close = function()
                            currentMenu.close()
                        end
                    }
                )
            end
        end,

        function(selected, currentMenu)

            if onClose then
                onClose(
                    selected and { current = selected.current } or {},
                    {
                        close = function()
                            currentMenu.close()
                        end
                    }
                )
            end
        end
    )
end


function BridgeRedemMenu(data, onSelect, onClose)
    menu.CloseAll()

    menu.Open(
        'default',
        GetCurrentResourceName(),
        'bridge_' .. tostring(math.random(10000, 99999)),
        {
            title = data.title,
            align = data.align or 'top-left',
            elements = data.elements
        },

        function(selected, currentMenu)

            if onSelect and selected and selected.current then
                onSelect(
                    { current = selected.current },
                    {
                        close = function()
                            currentMenu.close()
                        end
                    }
                )
            end
        end,

        function(selected, currentMenu)

            if onClose then
                onClose(
                    selected and { current = selected.current } or {},
                    {
                        close = function()
                            currentMenu.close()
                        end
                    }
                )
            end
        end
    )
end


function BridgeRsgMenu(data, onSelect, onClose)
    menu.CloseAll()

    menu.Open(
        'default',
        GetCurrentResourceName(),
        'bridge_' .. tostring(math.random(10000, 99999)),
        {
            title = data.title,
            align = data.align or 'top-left',
            elements = data.elements
        },

        function(selected, currentMenu)
            if onSelect and selected and selected.current then
                onSelect(
                    { current = selected.current },
                    {
                        close = function()
                            currentMenu.close()
                        end
                    }
                )
            end
        end,

        function(selected, currentMenu)
            if onClose then
                onClose(
                    selected and { current = selected.current } or {},
                    {
                        close = function()
                            currentMenu.close()
                        end
                    }
                )
            end
        end
    )
end
