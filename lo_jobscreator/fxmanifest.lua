fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

name 'lo_jobscreator'
description 'Dynamic Job & Gang Creator & Public actions for RedM'
version '1.0.1'
author 'DVR'

lua54 'yes'

-- -----------------------------------------------------------------------------
-- UI page
-- -----------------------------------------------------------------------------
-- Default (with jo_libs menus): the jo_libs multiplexer hosts our Vue admin
-- panel as a child iframe so jo_menu / jo_input can coexist with it. Our UI
-- attaches at runtime via jo.nui.load() in client/main.lua.
-- ui_page 'nui://jo_libs/nui/index.html'
-- Without jo_libs (VORP / ox_lib menus only): comment the line above AND
-- uncomment the line below. Panel continues to work unchanged. Also comment
-- '@jo_libs/init.lua' in shared_scripts and the `jo_libs { ... }` block at
-- the bottom of this file.
ui_page 'web/build/index.html'

shared_scripts {
    '@ox_lib/init.lua', -- Uncomment if you want to use ox_lib's progress / menus providers
    -- comment to disable VORP Lib progress provider.
    '@vorp_lib/import.lua',
    -- Uncomment to enable jo_libs menu/input provider (also uncomment the
    -- `jo_libs { 'menu', 'input' }` block below).
    -- '@jo_libs/init.lua',
    'config.lua',
    'modules/editable/shared.lua',
    'shared/main.lua',
    'data/blipslist.lua',
    'data/pedlist.lua',
    'data/proplist.lua',
    'data/vehlist.lua',
    'data/weapons.lua',
    'data/usables.lua',
}

client_scripts {
    'client/main.lua',
    'client/visual.lua',
    'modules/editable/client.lua',
    'client/interactions.lua',
    'client/keys.lua',
    'client/personalmenu.lua',
    'client/nui.lua',
    'modules/stash/client.lua',
    'modules/farm/client.lua',
    'modules/sell/client.lua',
    'modules/process/client.lua',
    'modules/craft/client.lua',
    'modules/shop/client.lua',
    'modules/vehicles/client.lua',
    'modules/duty/client.lua',
    'modules/witness/client.lua',
    'modules/delivery/client.lua',
    'modules/phone/client.lua',
    'modules/peds/client.lua',
    'modules/actions/client.lua',
    'modules/usables/effect.lua',
    'modules/usables/client.lua',
    'modules/gizmo/client.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'modules/editable/server.lua',
    'modules/editable/framework.lua',
    'modules/editable/templates.lua',
    'server/settings.lua',
    'server/registry.lua',
    'server/version.lua',
    'server/main.lua',
    'server/vorp_sync.lua',
    'server/callbacks.lua',
    'server/events.lua',
    'server/inventory.lua',
    'server/paycheck.lua',
    'server/duty.lua',
    'server/nui.lua',
    'modules/delivery/server.lua',
    'modules/phone/server.lua',
    'modules/shop/server.lua',
    'modules/actions/server.lua',
    'modules/witness/server.lua',
}

files {
    'locales/*.json',
    'patchnote.txt',
    'web/build/index.html',
    'web/build/**/*',
}

-- Framework: VORP only (vorp_core / vorp_inventory). Other RedM frameworks are
-- not supported out of the box — modules/editable/* is yours to wire your own.
-- Hard dep: oxmysql (data persistence) + vorp_core.
-- Soft deps (detected at runtime, optional): ox_lib, jo_libs, vorp_menu, vorp_lib, ox_target.
-- Prompts, raycast placement and the in-game progress bar are built in.
dependencies {
    'oxmysql',
}

-- Uncomment below if you enabled '@jo_libs/init.lua' in shared_scripts.
-- jo_libs { 'menu', 'input' }

escrow_ignore {
    "config.lua",
    "data/*",
    "modules/editable/*",
}

dependency '/assetpacks'
dependency '/assetpacks-redm'