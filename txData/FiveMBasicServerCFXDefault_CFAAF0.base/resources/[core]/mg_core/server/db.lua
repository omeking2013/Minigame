-- ============================================================
--  server/db.lua  (เหมือน with-ui แต่ตัดส่วนที่ไม่ใช้ออก)
--  SQL ทั้งหมดอยู่ที่นี่ที่เดียว
-- ============================================================

DB = {}

CreateThread(function()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS mg_players (
            identifier VARCHAR(60) NOT NULL PRIMARY KEY,
            name       VARCHAR(100) NOT NULL,
            skin       JSON,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
    ]])
end)

-- @param tableName ชื่อ table ใน DB
-- @param key ชื่อ column ที่ใช้ค้นหา (เช่น "identifier")
-- @param dataFinder ค่าที่ใช้ค้นหา (เช่น player identifier)
function DB.get(tableName, key, dataFinder)
    return MySQL.single.await(
        string.format('SELECT * FROM %s WHERE %s = ?', tableName, key),
        { dataFinder }
    )
end

function DB.save(tableName, data)
    local columns, placeholders, values = {}, {}, {}

    for col, val in pairs(data) do
        table.insert(columns, col)
        table.insert(placeholders, "?")
        table.insert(values, type(val) == "table" and json.encode(val) or val)
    end

    local updates = {}
    for _, col in ipairs(columns) do
        table.insert(updates, col .. " = VALUES(" .. col .. ")")
    end

    MySQL.query(string.format([[
        INSERT INTO %s (%s)
        VALUES (%s)
        ON DUPLICATE KEY UPDATE %s
    ]],
        tableName,
        table.concat(columns, ", "),
        table.concat(placeholders, ", "),
        table.concat(updates, ", ")
    ), values)
end


function DB.delete(tableName, key, dataFinder)
    MySQL.query(
        string.format('DELETE FROM %s WHERE %s = ?', tableName, key),
        { dataFinder }
    )
end
