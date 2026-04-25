MySQL.ready(function()
    if Config.StartDB and next(Config.StartDB) ~= nil then
        DB.create(Config.StartDB.name, Config.StartDB.columns) 
    end
end)