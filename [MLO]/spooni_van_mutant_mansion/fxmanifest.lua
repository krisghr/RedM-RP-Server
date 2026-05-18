fx_version 'adamant'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'
lua54 'yes'
this_is_a_map 'yes'
use_experimental_fxv2_oal 'yes'

author 'Spooni'
description 'Mutant Mansion'
version '1'

client_scripts {
	"client/*.lua",
}

escrow_ignore {
	'stream/[props]/*.ydr',
}

files {
	'stream/[props]/*.ytyp',
	'timecycle_van_mutant_mansion_1.xml',
} 


data_file "TIMECYCLEMOD_FILE" "timecycle_van_mutant_mansion_1.xml"
data_file 'DLC_ITYP_REQUEST' 'stream/[props]/*.ytyp'
dependency '/assetpacks'
dependency '/assetpacks-redm'