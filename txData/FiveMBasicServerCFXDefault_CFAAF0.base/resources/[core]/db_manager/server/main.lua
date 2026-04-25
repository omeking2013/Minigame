local DB = {}

local function buildMutationResult(action, tableName, extra)
    local result = {
        action = action,
        table = tableName,
        success = false
    }

    if extra then
        for key, value in pairs(extra) do
            result[key] = value
        end
    end

    return result
end

--- @param tableName string
--- @param data table
--[[
  data = {
    colname (string)
    type (string)
    notNull (boolean)
    primaryKey (boolean)
    unique (boolean)
  }  
--]]
function DB.create(tableName, data)
    local query_data = ""

    for i, value in pairs(data) do
        query_data = query_data .. string.format("%s %s", value.name, value.type)
        if value.null == false then
            query_data = query_data .. " NOT NULL"
        end
        if value.primary == true then
            query_data = query_data .. " PRIMARY KEY"
        end
        if value.unique == true then
            query_data = query_data .. " UNIQUE"
        end
        if value.default then
            query_data = query_data .. " DEFAULT " .. value.default
        end

        if #data > 1 and i < #data then
            query_data = query_data .. ", "
        end
    end

    -- ตรวจสอบ columns ที่มีอยู่แล้วใน table
    local existingColumns = MySQL.query.await(
        "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = ? AND TABLE_SCHEMA = DATABASE()",
        { tableName }
    )

    if next(existingColumns) == nil then
        local queryResult = MySQL.query.await(string.format("CREATE TABLE IF NOT EXISTS %s (%s)", tableName, query_data))
        print(string.format("'%s' created successfully!", tableName))
        return buildMutationResult("create", tableName, {
            success = queryResult ~= nil,
            created = true,
            addedColumns = 0,
            existingColumns = 0,
            rawResult = queryResult
        })
    else
        -- สร้าง set ของ column ที่มีอยู่แล้ว
        local existingSet = {}
        for _, row in pairs(existingColumns) do
            existingSet[row.COLUMN_NAME] = true
        end

        -- เพิ่ม column ที่ยังไม่มี
        local addedColumns = 0
        for _, value in pairs(data) do
            if not existingSet[value.name] then
                local colDef = string.format("%s %s", value.name, value.type)
                if value.null == false then
                    colDef = colDef .. " NOT NULL"
                end
                if value.unique == true then
                    colDef = colDef .. " UNIQUE"
                end
                -- PRIMARY KEY ไม่สามารถ ALTER ADD ได้ตรงๆ จึงข้ามไป
                MySQL.query.await(string.format("ALTER TABLE %s ADD COLUMN %s", tableName, colDef))
                addedColumns = addedColumns + 1
                print(string.format("Column '%s' added to table '%s' successfully!", value.name, tableName))
            end
        end

        return buildMutationResult("create", tableName, {
            success = true,
            created = false,
            addedColumns = addedColumns,
            existingColumns = #existingColumns,
            synced = addedColumns > 0
        })
    end
end
--- @param tableName string
--- @param data table
function DB.insert(tableName, data)
    local columns, placeholders, values = {}, {}, {}

    for colName, value in pairs(data) do
        table.insert(columns, colName)
        table.insert(placeholders, "?")
        table.insert(values, type(value) == "table" and json.encode(value) or value)
    end

    local insertId = MySQL.insert.await(
        string.format("INSERT INTO %s (%s) VALUES (%s)", tableName, table.concat(columns, ", "), table.concat(placeholders, ", ")),
        values
    )
    print(string.format("Data inserted into %s successfully!", tableName))
    return buildMutationResult("insert", tableName, {
        success = insertId ~= nil,
        insertId = insertId
    })
end

-- @param tableName string
-- @param key string ชื่อ column ที่ใช้ค้นหา (เช่น "identifier")
-- @param dataFinder any ค่าที่ใช้ค้นหา (เช่น player identifier)
function DB.getAll(tableName, key, dataFinder)
    local result = MySQL.query.await(
        string.format('SELECT * FROM %s WHERE %s = ?', tableName, key),
        { dataFinder }
    )
    return result
end

-- @param tableName string
-- @param selectKey string ชื่อ column ที่ต้องการเลือก (เช่น "name" หรือ "*" ถ้าต้องการเลือกทุก column)
-- @param key string ชื่อ column ที่ใช้ค้นหา (เช่น "identifier")
-- @param dataFinder any ค่าที่ใช้ค้นหา (เช่น player identifier)
function DB.get(tableName, selectKey, key, dataFinder)
    return MySQL.query.await(
        string.format('SELECT %s FROM %s WHERE %s = ?', selectKey, tableName, key),
        { dataFinder }
    )
end

-- @param tableName string
-- @param key string ชื่อ column ที่ใช้ค้นหา (เช่น "identifier")
-- @param dataFinder any ค่าที่ใช้ค้นหา (เช่น player identifier)
function DB.delete(tableName, key, dataFinder)
    local result = MySQL.query.await(
        string.format('DELETE FROM %s WHERE %s = ?', tableName, key),
        { dataFinder }
    )
    print(string.format("Data deleted from %s where %s = %s successfully!", tableName, key, dataFinder))
    return buildMutationResult("delete", tableName, {
        success = result ~= nil,
        affectedRows = result and result.affectedRows or 0,
        whereKey = key,
        whereValue = dataFinder
    })
end

-- @param tableName string
-- @param key string ชื่อ column ที่ใช้ค้นหา (เช่น "identifier")
-- @param dataFinder any ค่าที่ใช้ค้นหา (เช่น player identifier)
-- @param data table ข้อมูลที่ต้องการอัพเดท
function DB.update(tableName, key, dataFinder, data)
    local setData = {}
    local values = {}

    for colName, value in pairs(data) do
        table.insert(setData, string.format("%s = ?", colName))
        table.insert(values, type(value) == "table" and json.encode(value) or value)
    end

    table.insert(values, dataFinder)

    local query = string.format("UPDATE %s SET %s WHERE %s = ?", tableName, table.concat(setData, ", "), key)

    MySQL.query(query, values, function(result)
        print(string.format("Data updated in %s where %s = %s successfully!", tableName, key, tostring(dataFinder)))
    end)

    return buildMutationResult("update", tableName, {
        success = true,
        whereKey = key,
        whereValue = dataFinder
    })
end

exports("getSharedObj", function()
    return DB
end)
