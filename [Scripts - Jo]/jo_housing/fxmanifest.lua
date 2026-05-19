author "JUMP ON studios : https://jumpon-studios.com"
documentation "https://docs.jumpon-studios.com"
version "1.4.0"
package_id "7017575"
addon_scripts {
    "jo_housing_more_interiors"
}
dependencies_version_min "jo_libs:2.8.2"

fx_version "cerulean"

rdr3_warning "I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."

game "rdr3"
lua54 "yes"

jo_libs {
    "nui",
    "prompt-nui",
    "player",
    "blip",
    "menu", "callback", "hook",
    "framework-bridge", "notification", "gizmo",
    "database", "input", "screen", "waiter", "math", "utils", "emit",
    "version-checker", "camera"
}

ui_page "nui://jo_libs/nui/index.html"

files {
    "images/markers/*.png",
    "images/icons/**/*.png",
}

shared_scripts {
    "@jo_libs/init.lua",
    "config/**.lua",
    "shared/helpers/helpers.lua",
    "shared/houseClass.lua",
    "shared/furnitures/declaration.lua",
    "shared/furnitures/lists/*.lua",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/main.lua",
    "server/helpers/helpers.lua",
}

client_scripts {
    "client/main.lua",
    "client/helpers/*.lua",
    "client/commands.lua",
    "client/houseManager/menu/upsert/*.lua",
    "client/houseManager/menu/*.lua",
    "client/houseLocation/main.lua",
    "client/houseLocation/menu/**/*.lua",
    "client/houseInterior/main.lua",
    "client/houseInterior/buildMode.lua",
    "client/houseInterior/editFurnitures.lua",
    "client/houseInterior/menu/**/*.lua",
    "client/debug.lua"
}

dependencies {
    "jo_libs",
    "jo_housing_interiors"
}

escrow_ignore {
    "config/**",
}

dependency '/assetpacks'