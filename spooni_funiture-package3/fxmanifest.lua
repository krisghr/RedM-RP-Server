fx_version "adamant"
game "rdr3"
rdr3_warning "I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."
this_is_a_map "yes"
lua54 "yes"
author "Spooni-Mapping"

 files {
    'stream/*.ytyp',
}
  
 escrow_ignore {
     'stream/*.ydr', 
 }

data_file 'DLC_ITYP_REQUEST' 'stream/platforms.ytyp';
data_file 'DLC_ITYP_REQUEST' 'stream/pbr_materials.ytyp';
dependency '/assetpacks'