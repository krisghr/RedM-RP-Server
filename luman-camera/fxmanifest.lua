fx_version "cerulean"
games { 'rdr3' }

rdr3_warning "I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."

lua54 'yes'

author 'Luman Studio'
description 'Luman Cinematic Camera Tool for RedM'
version '0.1.1'

ui_page 'web/dist/index.html'

files {
  'web/dist/index.html',
  'web/dist/**/*'
}

shared_scripts {
  'shared/config.lua',
  'dataview.lua'
}

client_scripts {
  'client/utils.lua',
  'client/camera.lua',
  'client/interpolation.lua',
  'client/keyframes.lua',
  'client/editor.lua',
  'client/playback.lua',
  'client/visualizer.lua',
  'client/gizmo.lua',
  'client/entity_attach.lua',
  'client/nui_bridge.lua',
  'client/nui_callbacks_editor.lua',
  'client/nui_callbacks_keyframes.lua',
  'client/nui_callbacks_playback.lua',
  'client/nui_callbacks_routes.lua',
  'client/nui_callbacks_entity.lua',
  'client/main.lua'
}

server_scripts {
  'server/main.lua'
}

escrow_ignore {
    'shared/*.lua',
}
dependency '/assetpacks'
dependency '/assetpacks-redm'