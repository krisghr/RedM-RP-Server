-- This resource is part of the default Cfx.re asset pack (cfx-server-data)
-- Altering or recreating for local use only is strongly discouraged.

version '1.0.0'
author 'Cfx.re <root@cfx.re>'
description 'Provides baseline chat functionality using a NUI-based interface.'
repository 'https://github.com/citizenfx/cfx-server-data'

client_script 'cl_chat.lua'
server_script 'sv_chat.lua'

ui_page 'html/index.html'

files {
  'html/index.html',
  'html/index.css',
  'html/vendor/*.css',
  'html/vendor/fonts/*.woff2',
}

chat_theme 'gtao' {
    styleSheet = 'html/index.css',
}

fx_version 'adamant'
games { 'rdr3' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

dependencies {
  'yarn',
  'webpack'
}

webpack_config 'webpack.config.js'
