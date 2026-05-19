author "JUMP ON studios : https://jumpon-studios.com"
documentation "https://docs.jumpon-studios.com"

fx_version "cerulean"

this_is_a_map "yes"

rdr3_warning "I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."

game "rdr3"
lua54 "yes"

shared_scripts {
    "stream/**/*.lua",
}

files {
    "stream/**/*.ytyp",
    "stream/**/*.ymt"
}

data_file "DLC_ITYP_REQUEST" "stream/**/*.ytyp"
data_file "CPopulationDataFileMounter" "stream/**/*.ymt"

dependency '/assetpacks'
dependency '/assetpacks-redm'