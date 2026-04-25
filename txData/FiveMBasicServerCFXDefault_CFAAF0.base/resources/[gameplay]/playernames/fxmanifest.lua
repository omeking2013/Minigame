fx_version 'adamant'
game 'gta5'

version '1.0.0'
author 'Cfx.re <root@cfx.re>'
description 'แสดงชื่อผู้เล่นเหนือหัว (Refactored)'

-- ลำดับการโหลด script สำคัญมาก
-- 1. playernames_api  → ฟังก์ชันกลาง / template engine (shared)
-- 2. config           → ตั้งค่า + override getPlayerDisplayName (shared)
-- 3. playernames_cl   → loop แสดงชื่อบน client
-- 4. playernames_sv   → poll อัปเดตชื่อบน server

client_script 'playernames_api.lua'
server_script 'playernames_api.lua'

client_script 'config.lua'
server_script 'config.lua'

client_script 'playernames_cl.lua'
server_script 'playernames_sv.lua'

-- Exports สำหรับ resource อื่นใช้งาน
local exportList = {
    'setComponentColor',
    'setComponentAlpha',
    'setComponentVisibility',
    'setWantedLevel',
    'setHealthBarColor',
    'setNameTemplate',
}

exports(exportList)
server_exports(exportList)

-- Template engine (ไฟล์ Lua ที่ถูก load ผ่าน LoadResourceFile)
files {
    'template/template.lua'
}
