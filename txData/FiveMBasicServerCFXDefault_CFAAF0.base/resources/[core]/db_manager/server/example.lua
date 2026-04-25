-- TestArray = {
--     {
--         name = "identifier", 
--         type = "VARCHAR(60)",
--         null = false,
--         primary = true,
--     },
--     {
--         name = "name", 
--         type = "VARCHAR(100)",
--         null = false,
--     },
--     {
--         name = "skin", 
--         type = "LONGTEXT",
--         null = false,
--     },
--     {
--         name = "updated_at", 
--         type = "TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP",
--     }
-- }

-- local DB = exports["db_manager"]:getSharedObj()
-- DB.create("mg_players", TestArray)

-- local result = DB.get("mg_players", "identifier", "7030c3c917405804e3f7bdff9900af6ff0869bdb")
-- print(json.encode(result))
-- DB = exports["db_manager"]:getSharedObj()

-- local result = DB.get("core_players", "name", "identifier", "ABCD1234")
-- print(json.encode(result))

-- local result = DB.getAll("core_players", "identifier", "ABCD1234")
-- print(json.encode(result))

-- DB.insert("mg_players", {
--     identifier = "7030c3c917405804e3f7bdff9900af6ff0869bdb",
--     name = "John Doe",
--     skin = {model = "mp_m_freemode_01", components = {}, props = {}}
-- })


-- DB.update("mg_players", "identifier", "7030c3c917405804e3f7bdff9900af6ff0869bdb", {
--     name = "Jane Doe",
--     skin = {model = "mp_f_freemode_01", components = {}, props = {}}
-- })


-- DB.delete("mg_players", "identifier", "7030c3c917405804e3f7bdff9900af6ff0869bdb")
