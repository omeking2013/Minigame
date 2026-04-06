fx_version 'cerulean'
game 'gta5'

name        'mg_template_nui'
description 'Boilerplate — resource ที่ไม่มี NUI'
version     '1.0.0'
author      'yourname'

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
