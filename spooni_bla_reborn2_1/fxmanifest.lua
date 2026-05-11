fx_version 'adamant'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'
lua54 'yes'
this_is_a_map 'yes'
use_experimental_fxv2_oal 'yes'

author 'Spooni'
description 'Spooni Blackwater Reborn 2'
version '5'

server_scripts {
	 'server/*.lua',
}

client_scripts {
	'client/client.lua',
    'client/zone_manager.lua',
    'shared/int_bw.lua',
    'client/config*.lua',
	'shared/config.lua',
}


escrow_ignore {
	'shared/*.lua',
	'update/bla_fightclub/[landscape]/*.ydr',
	'update/bla_fightclub/*.ydr',
	'update/railroad/[landscape]/*.ydr',
	'update/railroad/*.ydr',
	'update/railroad/*.ydd',
	'update/railroad_and_bla_fightclub/[landscape]/*.ydr',
	'update/railroad_and_bla_fightclub/*.ydr',
	'update/railroad_and_bla_fightclub/*.ydd',
}

  files {
   'stream/[props]/*.ytyp'

  }  

  data_file 'DLC_ITYP_REQUEST' 'stream/[props]/*.ytyp'

files {'timecycle_bla_reborn2.xml'}

data_file "TIMECYCLEMOD_FILE" "timecycle_bla_reborn2.xml"

dependency '/assetpacks'
dependency '/assetpacks-redm'