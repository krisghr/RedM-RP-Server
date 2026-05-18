fx_version 'adamant'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'
lua54 'yes'
this_is_a_map 'yes'
use_experimental_fxv2_oal 'yes'

author 'Spooni'
description 'Van Horn Reborn'

server_scripts {
  'server/*.lua',
}

client_scripts {
  'client/zone_manager.lua',
	'shared/*.lua',
	'client/*.lua',
}

escrow_ignore {
  'shared/*.lua',
  'stream/[van_horn_hotel]/*.yft',
}


files {'timecycle_vanhorn_reborn_1.xml'}

data_file "TIMECYCLEMOD_FILE" "timecycle_vanhorn_reborn_1.xml"
dependency '/assetpacks'
dependency '/assetpacks-redm'