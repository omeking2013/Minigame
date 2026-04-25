RegisterNetEvent("skinchanger:savePlayerSkin")
AddEventHandler("skinchanger:savePlayerSkin", function(skin)
    -- local src = source
    -- local xPlayer = ESX.GetPlayerFromId(src)
    -- if xPlayer then
    --     MySQL.Async.execute("UPDATE users SET skin = @skin WHERE identifier = @identifier", {
    --         ["@skin"] = json.encode(skin),
    --         ["@identifier"] = xPlayer.identifier
    --     })
    -- end
end)