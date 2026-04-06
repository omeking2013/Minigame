-- ============================================================
--  server/main.lua
--  Logic หลักฝั่ง server
--
--  ลำดับในไฟล์นี้:
--  1. State   — ข้อมูล runtime ที่เก็บใน memory
--  2. Private  — helper function ที่ไม่ expose ออกไป
--  3. Exports  — API สาธารณะให้ resource อื่นเรียก
--  4. Events   — รับ event จาก client หรือ resource อื่น
--  5. Lifecycle — playerJoining, playerDropped, onResourceStop
-- ============================================================

-- ══════════════════════════════════════════════════════════
--  1. STATE
--  เก็บเป็น table เดียว ไม่ใช่ global ลอยๆ
--  ทำให้รู้ทันทีว่า runtime data ของ resource นี้มีอะไรบ้าง
-- ══════════════════════════════════════════════════════════

---@type table<number, table>  key = server source
local Players = {}

-- ── private helper อ่าน/เขียน State ─────────────────────────

local function getPlayer(src)
    return Players[src]
end

local function setPlayer(src, data)
    Players[src] = data
end

local function removePlayer(src)
    Players[src] = nil
end

-- ══════════════════════════════════════════════════════════
--  2. PRIVATE FUNCTIONS
--  ชื่อบอกว่าทำอะไร, ทำอย่างเดียว, ไม่มี side effect ซ่อน
-- ══════════════════════════════════════════════════════════

---โหลดข้อมูลผู้เล่นจาก DB แล้ว cache ไว้ใน Players
---@param src number  server source
---@param identifier string
local function loadPlayer(src, identifier)
    local row = DB.getRow(identifier)

    if not row then
        -- ผู้เล่นใหม่ — insert แล้วดึงกลับมา
        DB.insertRow(identifier, 0, nil)
        row = { identifier = identifier, value = 0 }
    end

    setPlayer(src, {
        source     = src,
        identifier = identifier,
        name       = GetPlayerName(src),
        value      = row.value,
    })
end

---บันทึกข้อมูลผู้เล่นกลับ DB
---@param src number
local function savePlayer(src)
    local p = getPlayer(src)
    if not p then return end
    DB.updateValue(p.identifier, p.value)
end

---แจ้ง client ว่าข้อมูลอัปเดต
---@param src number
local function syncPlayer(src)
    local p = getPlayer(src)
    if not p then return end
    TriggerClientEvent('mg_template_ui:sync', src, {
        value = p.value,
        name  = p.name,
    })
end

-- ══════════════════════════════════════════════════════════
--  3. EXPORTS
--  API ที่ resource อื่นเรียกได้
--  ตั้งชื่อแบบ verb + noun ให้ชัดว่าทำอะไร
-- ══════════════════════════════════════════════════════════

exports('getPlayer', function(src)
    return getPlayer(src)
end)

exports('getValue', function(src)
    local p = getPlayer(src)
    return p and p.value or 0
end)

exports('addValue', function(src, amount)
    local p = getPlayer(src)
    if not p then return false end

    p.value = p.value + amount
    DB.updateValue(p.identifier, p.value)
    syncPlayer(src)
    return true
end)

exports('removeValue', function(src, amount)
    local p = getPlayer(src)
    if not p then return false end
    if p.value < amount then return false end  -- ไม่พอ

    p.value = p.value - amount
    DB.updateValue(p.identifier, p.value)
    syncPlayer(src)
    return true
end)

-- ══════════════════════════════════════════════════════════
--  4. EVENTS (รับจาก client)
--  ทุก event ต้อง validate source ก่อนเสมอ
--  อย่าไว้ใจข้อมูลจาก client โดยไม่ตรวจ
-- ══════════════════════════════════════════════════════════

---ตัวอย่าง: client ขอทำ action
RegisterNetEvent('mg_template_ui:doAction', function(payload)
    local src = source

    -- ── Validate ──────────────────────────────────────────
    local p = getPlayer(src)
    if not p then return end

    -- ตรวจ payload จาก client เสมอ
    if type(payload) ~= 'table' then return end
    if type(payload.amount) ~= 'number' then return end
    if payload.amount <= 0 then return end

    -- ── Logic ─────────────────────────────────────────────
    local ok = exports['mg_template_ui']:addValue(src, payload.amount)

    -- ── Response ──────────────────────────────────────────
    if ok then
        TriggerClientEvent('mg_core:notification', src, {
            type = 'success',
            msg  = 'สำเร็จ +' .. payload.amount,
        })
    else
        TriggerClientEvent('mg_core:notification', src, {
            type = 'error',
            msg  = 'ไม่สำเร็จ',
        })
    end
end)

---ตัวอย่าง: client ขอ sync ข้อมูลตัวเอง
RegisterNetEvent('mg_template_ui:requestSync', function()
    local src = source
    if not getPlayer(src) then return end
    syncPlayer(src)
end)

-- ══════════════════════════════════════════════════════════
--  5. LIFECYCLE
-- ══════════════════════════════════════════════════════════

AddEventHandler('playerJoining', function()
    local src        = source
    local identifier = GetPlayerIdentifierByType(src, 'license')
                    or GetPlayerIdentifier(src, 0)
    if not identifier then return end

    loadPlayer(src, identifier)
    -- รอ 1 frame ให้ client พร้อมก่อน sync
    SetTimeout(100, function()
        syncPlayer(src)
    end)
end)

AddEventHandler('playerDropped', function()
    local src = source
    savePlayer(src)
    removePlayer(src)
end)

-- บันทึกทุกคนเมื่อ resource หยุด (เช่น restart)
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    for src in pairs(Players) do
        savePlayer(src)
    end
end)
