Config = {}
-- Config.Debug = GetConvar('debug_mode', 'false') == 'true'
Config.Debug = true
Config.StartDB = {
    name = "core_players",
    columns = {
        { 
            name = "identifier", 
            type = "VARCHAR(255)", 
            primary = true, 
            null = false
        },
        {
            name = "name", 
            type = "VARCHAR(100)", 
            null = false
        },
        {
            name = "skin", 
            type = "LONGTEXT", 
            null = false
        },
        {
            name = "account",
            type = "LONGTEXT",
            null = false
        },
        {
            name = "position",
            type = "VARCHAR(255)",
            null = true
        },
        {
            name = "updated_at", 
            type = "TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP"
        }
    }
}

Config.Discord = {
    BOT_TOKEN = "MTQ5NTMzMzk3OTI5MTkxMDIxNA.GB4tWG.MtDK_3styjfY1U452GIXUAKIhWb6KHdFQXDbXs",
    SERVER_ID = "948570824732979241",
    ROLES_WHITELIST = {
        ["948572792276807700"] = true, --เจ้าที่เซิฟเวอร์
    }
}

Config.DefaultSpawn = {
    x = 100.0,
    y = 100.0,
    z = 80.0,
    heading = 0.0
}

Config.DefaultAccount = {
    money = 1000,
    bank = 5000,
}