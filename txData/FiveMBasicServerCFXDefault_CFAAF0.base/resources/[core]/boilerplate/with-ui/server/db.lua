-- ============================================================
--  server/db.lua
--  SQL ทั้งหมดของ resource นี้อยู่ที่นี่ที่เดียว
--
--  กฎ:
--  - ไฟล์นี้รู้แค่เรื่อง database ไม่รู้เรื่อง player, event, export
--  - ทุก function รับ raw data เข้า → return raw data ออก
--  - ไม่มี TriggerEvent, ไม่มี exports ในไฟล์นี้
--  - main.lua เป็นคนเรียก DB แล้วตัดสินใจว่าจะทำอะไรต่อ
-- ============================================================

DB = {}

-- ── สร้างตารางเมื่อ resource start ──────────────────────────
-- ใช้ CreateThread เพราะ MySQL.query ต้องรอ connection พร้อมก่อน
CreateThread(function()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS template_data (
            id         INT          AUTO_INCREMENT PRIMARY KEY,
            identifier VARCHAR(60)  NOT NULL,
            value      INT          NOT NULL DEFAULT 0,
            metadata   JSON,
            created_at TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

            INDEX idx_identifier (identifier)
        )
    ]])
end)

-- ── READ ─────────────────────────────────────────────────────

---ดึงแถวของ identifier
---@param identifier string
---@return table|nil
function DB.getRow(identifier)
    return MySQL.single.await(
        'SELECT * FROM template_data WHERE identifier = ?',
        { identifier }
    )
end

---ดึงทุกแถวของ identifier
---@param identifier string
---@return table
function DB.getAllRows(identifier)
    return MySQL.query.await(
        'SELECT * FROM template_data WHERE identifier = ? ORDER BY created_at DESC',
        { identifier }
    ) or {}
end

-- ── WRITE ────────────────────────────────────────────────────

---สร้างแถวใหม่ — คืน id ที่เพิ่ง insert
---@param identifier string
---@param value number
---@param metadata table|nil
---@return number
function DB.insertRow(identifier, value, metadata)
    return MySQL.insert.await(
        'INSERT INTO template_data (identifier, value, metadata) VALUES (?, ?, ?)',
        { identifier, value, metadata and json.encode(metadata) or nil }
    )
end

---อัปเดตค่า
---@param identifier string
---@param value number
function DB.updateValue(identifier, value)
    MySQL.update(
        'UPDATE template_data SET value = ? WHERE identifier = ?',
        { value, identifier }
    )
end

---ลบแถว
---@param identifier string
function DB.deleteRow(identifier)
    MySQL.query(
        'DELETE FROM template_data WHERE identifier = ?',
        { identifier }
    )
end

-- ── UPSERT ───────────────────────────────────────────────────
-- เพิ่มถ้ายังไม่มี อัปเดตถ้ามีแล้ว

---@param identifier string
---@param value number
function DB.upsertRow(identifier, value)
    MySQL.query([[
        INSERT INTO template_data (identifier, value)
        VALUES (?, ?)
        ON DUPLICATE KEY UPDATE value = VALUES(value)
    ]], { identifier, value })
end
