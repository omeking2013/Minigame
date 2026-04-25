fx_version 'adamant'

game 'gta5'
description 'Saves/loads character appearances for ESX Legacy.'
version '1.13.4'
lua54 'yes'

shared_scripts {
	"shared/locale.lua",
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/*.lua',
	'config.lua',
	'client/main.lua'
}

server_scripts {
	'server/main.lua'
}