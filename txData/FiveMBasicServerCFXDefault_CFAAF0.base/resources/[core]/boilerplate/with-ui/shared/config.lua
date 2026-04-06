-- ============================================================
--  shared/config.lua
--  โหลดทั้ง server และ client — ห้ามใส่ข้อมูล sensitive ที่นี่
--  เช่น password, token, key ใดๆ → ใส่ใน server/main.lua แทน
-- ============================================================

Config = {}

-- ── ตัวอย่างการจัดกลุ่ม config ─────────────────────────────
-- จัดเป็น sub-table ตาม concern ไม่ใช่ flat list ยาวๆ
-- ทุกค่าที่อาจเปลี่ยนในอนาคตต้องอยู่ที่นี่เท่านั้น
-- ห้ามฝัง magic number หรือ magic string ในโค้ด

Config.UI = {
    -- ระยะเวลา transition ของ NUI (ms)
    fadeMs = 200,
}

Config.Cooldowns = {
    -- cooldown ระหว่างกดปุ่ม (ms) — ป้องกัน spam
    actionMs = 1000,
}

-- ── ตัวอย่าง config ที่ควรเพิ่มตาม resource ─────────────────
--[[
Config.Zones = {
    myZone = { pos = vector3(0.0, 0.0, 0.0), radius = 2.0 },
}

Config.Rewards = {
    base  = 100,
    bonus = 50,
}
]]
