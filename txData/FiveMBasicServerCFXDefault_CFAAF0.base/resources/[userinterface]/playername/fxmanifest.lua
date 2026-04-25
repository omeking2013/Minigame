fx_version 'cerulean'
game 'gta5'

name        'mg_template_ui'
description 'Boilerplate — resource ที่มี NUI'
version     '1.0.0'
author      'yourname'

-- ── Shared (โหลดทั้ง server และ client) ──────────────────
-- ลำดับสำคัญ: config ต้องมาก่อน เพราะไฟล์อื่นอาจใช้ค่าจาก Config
shared_scripts {
    'shared/config.lua',
}

-- ── Server-side ───────────────────────────────────────────
-- db.lua ต้องมาก่อน main.lua เสมอ เพราะ main.lua เรียกใช้ DB
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/db.lua',
    'server/main.lua',
}

-- ── Client-side ───────────────────────────────────────────
-- utils.lua ก่อน main.lua เพราะ main.lua อาจเรียก helper จาก utils
client_scripts {
    'client/utils.lua',
    'client/main.lua',
}

-- ── NUI ───────────────────────────────────────────────────
ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/app.js',
}
