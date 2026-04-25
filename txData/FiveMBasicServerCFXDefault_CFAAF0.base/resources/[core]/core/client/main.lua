AddEventHandler('onClientResourceStart', function(res)
    if res ~= GetCurrentResourceName() then
        return 
    end

    Log(("Resource %s started, requesting player data..."):format(res))
    TriggerServerEvent("core/player:getPlayerData")
end)


Citizen.CreateThread(function()
    while true do
        if Core.LocalPlayerGame and Core.LocalPlayerGame.Ped
        and IsPedDeadOrDying(Core.LocalPlayerGame.Ped, 0) == 1 then
            RespawnPlayer()
        end

        if Config.Debug == true then
            Draw2DText("This is a development server.", 0.45, 0.95, 0.3, 200, 200, 200, 255)
        end
        Citizen.Wait(0)
    end
end)