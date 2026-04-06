fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name        'mg_core'
description 'Core resource -> Server Management, Player Data, Items'
version     '1.0.0'
author      'DevOmmie90'

shared_scripts {
    'shared/config.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/db.lua',
    'server/main.lua',
}

-- resource ที่ไม่มี UI อาจไม่ต้องมี client เลย
-- ใส่ก็ต่อเมื่อต้องการ keybind, marker, หรือ thread ฝั่ง client
client_scripts {
    'client/utils.lua',
    'client/main.lua',
}
