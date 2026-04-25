AddEventHandler('playerJoining', function()
    local src <const> = source
    Core.Players[src] = CreateCorePlayer(src)
end)

AddEventHandler('playerDropped', function()
    local src <const> = source

    print(("Player %s (ID: %d) has left the server. Saving data..."):format(Core.Players[src].name, src))
    Core.SavePlayer(src, function()
        Core.Players[src] = nil
    end)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        Core.SavePlayers()
    end
end)

AddEventHandler("txAdmin:events:scheduledRestart", function(eventData)
    if eventData.secondsRemaining == 60 then
        CreateThread(function()
            Wait(50000)
            Core.SavePlayers()
        end)
    end
end)

AddEventHandler("txAdmin:events:serverShuttingDown", function()
    Core.SavePlayers()
end)

