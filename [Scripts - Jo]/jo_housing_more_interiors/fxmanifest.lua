author "JUMP ON studios : https://jumpon-studios.com"
documentation "https://docs.jumpon-studios.com"
version "1.0.2"
package_id "7017580"
dependencies_version_min "jo_housing:1.0.2"

fx_version "cerulean"

rdr3_warning "I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."

game "rdr3"
lua54 "yes"

jo_libs { "version-checker" }

files {
    "stream/**/*.ytyp",
    "stream/**/*.ymt"
}

data_file "DLC_ITYP_REQUEST" "stream/**/*.ytyp"
data_file "CPopulationDataFileMounter" "stream/**/*.ymt"

shared_scripts {
    "@jo_libs/init.lua",
    "shared.lua",
    "stream/**/*.lua",
}

dependency '/assetpacks'
dependency '/assetpacks-redm'