fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

version '0.1a'
author 'Warhead'

client_script 'client.lua'
server_scripts {
    'server/shared/core.lua',
    'server/shared/proximity.lua',
    'server/shared/system.lua',
    'server/commands/speech.lua',
    'server/commands/low.lua',
    'server/commands/shout.lua',
    'server/commands/emotes.lua',
    'server/commands/ooc.lua',
    'server/commands/targeted.lua',
    'server/commands/npc.lua',
    'server/main.lua'
}
