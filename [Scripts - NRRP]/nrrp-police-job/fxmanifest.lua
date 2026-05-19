fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'sss

name 'nrrp-police'
author 'NRRP'
description 'Lightweight text-only police jail and cell management for RedM RP servers.'
version '1.0.0'

shared_script 'config.lua'
client_script 'client.lua'
server_script 'server.lua'

files {
    'data/cells.json'
}
