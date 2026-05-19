fx_version 'cerulean'
game 'rdr3'

lua54 'yes'

name 'farming_system'
author 'NRRP'
description 'Skeleton farming gameplay system (plots, planting, growth, harvest)'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
version '0.1.0'

dependencies {
    'oxmysql',
    'vorp_core',
    'vorp_inventory'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/adapters/vorp.lua',
    'server/main.lua'
}

shared_scripts {
    'shared/config.lua'
}

client_scripts {
    'client/adapters/vorp.lua',
    'client/main.lua'
}
