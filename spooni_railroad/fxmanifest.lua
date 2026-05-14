fx_version 'adamant'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'
lua54 'yes'
this_is_a_map 'yes'
use_experimental_fxv2_oal 'yes'

author 'Spooni'
description 'Railroad'
version '3'

server_scripts {
	 'server/*.lua',
}

client_scripts {
	 'client/zone_manager.lua',
	 'shared/int_manzanita_bw_stations.lua',
	 'client/*.lua',
	'shared/config.lua',	
}

escrow_ignore {
'shared/int_manzanita_bw_stations.lua',
}

files {
  'data/traintracks.xml',
  'data/*.dat',
}
files {'timecycle_railroad.xml'}

replace_traintrack_file 'data/traintracks.xml'

data_file "TIMECYCLEMOD_FILE" "timecycle_railroad.xml"

dependency '/assetpacks'
dependency '/assetpacks-redm'