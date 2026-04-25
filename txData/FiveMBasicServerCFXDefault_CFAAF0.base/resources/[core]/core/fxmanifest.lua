fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name        'mg_core'
description 'Core resource -> Server Management, Player Data, Items'
version     '1.0.0'
author      'KODev'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
    'shared/adjustments.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    '@db_manager/server/imports.lua',
    'server/common.lua',
    'server/utils.lua',
    'server/database.lua',
    'server/connecting.lua',
    'server/player.lua',
    'server/main.lua',
}

-- resource ที่ไม่มี UI อาจไม่ต้องมี client เลย
-- ใส่ก็ต่อเมื่อต้องการ keybind, marker, หรือ thread ฝั่ง client
client_scripts {
    'client/common.lua',
    'client/utils.lua',
    'client/command.lua',
    'client/player.lua',
    'client/adjustments.lua',
    'client/main.lua',
}

dependencies {
    'oxmysql',
    'db_manager',
}