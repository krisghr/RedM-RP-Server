fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

name 'character_attributes'
author 'Warhead'
description 'Set and examine character attributes using NUI.'
version '1.0.0'

lua54 'yes'

dependency 'image_popup'
dependency 'oxmysql'
dependency 'ox_lib'

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/app.js',
    'ui/examine-bg.png',
    'ui/CHINESER.TTF'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}
