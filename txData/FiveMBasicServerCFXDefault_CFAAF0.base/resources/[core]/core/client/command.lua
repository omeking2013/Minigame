RegisterCommand("tpm", function(source, args, rawCommand)
    local markerPoint = GetBlipInfoIdCoord(GetFirstBlipInfoId(8)) -- 8 = blip type for waypoints

    if markerPoint and markerPoint.x ~= 0.0 and markerPoint.y ~= 0.0 then
        local playerPed = PlayerPedId()
        SafeTeleport(markerPoint, GetEntityHeading(playerPed))
        Notify("Teleported to waypoint!")
    else
        Notify("No waypoint found! Please set a waypoint on the map.")
    end
end, false)

RegisterCommand("car", function(source, args, rawCommand)
    local model = args[1] or "adder"
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    lib.requestModel(model, 5000)

    local vehicle = CreateVehicle(model, playerCoords.x, playerCoords.y, playerCoords.z + 2.0, true, false)
    SetPedIntoVehicle(playerPed, vehicle, -1)
    Notify(("Spawned vehicle: ~g~%s~s~"):format(model))
end, false)

RegisterCommand("suicide", function(source, args, rawCommand)
    local playerPed = PlayerPedId()
    SetEntityHealth(playerPed, 0)
end, false)

RegisterCommand("setarmor", function(source, args, rawCommand)
    local playerPed = PlayerPedId()
    local armorAmount = tonumber(args[1]) or 100
    SetPedArmour(playerPed, armorAmount)
    Notify(("Armor set to ~g~%d~s~."):format(armorAmount))
end, false)