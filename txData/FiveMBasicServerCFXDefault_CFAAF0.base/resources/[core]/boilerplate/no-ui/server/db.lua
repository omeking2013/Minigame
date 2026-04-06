-- ============================================================
--  server/db.lua  (เหมือน with-ui แต่ตัดส่วนที่ไม่ใช้ออก)
--  SQL ทั้งหมดอยู่ที่นี่ที่เดียว
-- ============================================================

DB = {}

CreateThread(function()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS template_noui (
            identifier VARCHAR(60) NOT NULL PRIMARY KEY,
            data       JSON,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
    ]])
end)

function DB.get(identifier)
    return MySQL.single.await(
        'SELECT * FROM template_noui WHERE identifier = ?',
        { identifier }
    )
end

function DB.save(identifier, data)
    MySQL.query([[
        INSERT INTO template_noui (identifier, data)
        VALUES (?, ?)
        ON DUPLICATE KEY UPDATE data = VALUES(data)
    ]], { identifier, json.encode(data) })
end

function DB.delete(identifier)
    MySQL.query(
        'DELETE FROM template_noui WHERE identifier = ?',
        { identifier }
    )
end
