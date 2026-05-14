fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game "rdr3"
lua54 'yes'

author 'D-Labs'
version '2.5.0'
description 'Train Script V2 (Unlocked)'

escrow_ignore {
	'config.lua',
    'server/*.lua',
    'client/*.lua',
    'shared/*.lua',
}

shared_script {
    'config.lua', 
    'shared/utils.lua',
    'shared/bridge.lua',
}

client_scripts {
    'not.js',
    'client/client_open.lua',
    'client/prompt.lua',
	'client/client.lua',
    'client/client_sit.lua',
    'client/track_open.lua',
    'client/track.lua',
    'client/menu.lua',
    'client/track_addons.lua'
}

ui_page 'html/index.html'

files {
    'not.js',
    "html/*.*",
    "html/css/*",
    "html/js/*",
    "html/image/*",
}

server_script {
    '@oxmysql/lib/MySQL.lua',
    'server/functions.lua',
    'server/server.lua',
    'server/server_open.lua',
}

dependency '/assetpacks'
dependency '/assetpacks'
dependency '/assetpacks-redm'