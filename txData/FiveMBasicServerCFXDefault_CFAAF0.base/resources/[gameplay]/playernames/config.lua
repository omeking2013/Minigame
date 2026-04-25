-- ============================================================
-- config.lua  (Shared – โหลดทั้ง client & server)
-- ตั้งค่าหลักของ resource และ override getPlayerDisplayName
-- ============================================================

PlayerNamesConfig = {
    -- Template ที่ใช้แสดงชื่อบน client HUD
    -- ตัวแปรที่ใช้ได้ใน template: {{name}}, {{id}}, {{serverName}}
    --   {{name}}       = ชื่อจาก GetPlayerName (native)
    --   {{id}}         = server source ID
    --   {{serverName}} = ชื่อที่ถูก sync มาจาก server ผ่าน setName()
    clientTemplate = '[{{id}}] {{name}}',

    -- Template สำหรับ server-side (เช่น log, chat)
    serverTemplate = '[{{id}}] {{name}}',

    -- ระยะ (game units) ที่จะแสดงชื่อเหนือหัว
    visibleDistance = 250,
}

-- ============================================================
-- getPlayerDisplayName(id)
--
-- ฟังก์ชันนี้ถูกเรียกทุกครั้งที่ต้องการชื่อผู้เล่น
--   Server: id = source (number)
--   Client: id = player index (number)
--
-- Default: ใช้ native GetPlayerName
-- Override: uncomment บล็อกด้านล่างเพื่อใช้ชื่อจาก core resource
-- ============================================================
function getPlayerDisplayName(id)
    return GetPlayerName(id)
end

-- -------------------------------------------------------
-- ตัวอย่าง: ใช้ชื่อจาก resource core ของคุณ (server only)
-- ต้อง export getPlayerData ออกมาจาก core ก่อน เช่น:
--   server_export 'getPlayerData' ใน fxmanifest ของ core
--
-- if IsDuplicityVersion() then
--     function getPlayerDisplayName(id)
--         local ok, data = pcall(exports['mg_core'].getPlayerData, exports['mg_core'], id)
--         if ok and data and data.name then
--             return data.name
--         end
--         return GetPlayerName(id)
--     end
-- end
-- -------------------------------------------------------
