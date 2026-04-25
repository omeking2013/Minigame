-- ============================================================
--  client/utils.lua  (เหมือนกันทั้งสอง boilerplate)
-- ============================================================

function FormatNumber(n)
    local s      = tostring(math.floor(n))
    local result = ''
    local count  = 0
    for i = #s, 1, -1 do
        count  = count + 1
        result = s:sub(i, i) .. result
        if count % 3 == 0 and i ~= 1 then
            result = ',' .. result
        end
    end
    return result
end

function IsNearPosition(pos, radius)
    return #(GetEntityCoords(PlayerPedId()) - pos) <= radius
end

function Debounce(fn, delayMs)
    local lastCall = 0
    return function(...)
        local now = GetGameTimer()
        if (now - lastCall) < delayMs then return end
        lastCall = now
        fn(...)
    end
end

function Notify(msg)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(msg)
    DrawNotification(false, true)
end

function Draw2DText(msg, x, y, scale, r, g, b, a)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(msg)
    DrawText(x, y)
end

function Log(msg)
    if Config.Debug == true then
        print(("[Core Utils] %s"):format(msg))
    end
end

function SafeTeleport(coords, heading)
    local playerPed = PlayerPedId()
    local isPedInVehicle = IsPedInAnyVehicle(playerPed, false)
    local targetEntity = playerPed
    local zOffset = 1.0

    if isPedInVehicle then
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        if vehicle and vehicle ~= 0 then
            targetEntity = vehicle
            zOffset = 2.5
        end
    end

    DoScreenFadeOut(200)
    while not IsScreenFadedOut() do
        Citizen.Wait(0)
    end

    SetFocusPosAndVel(coords.x, coords.y, coords.z, 0.0, 0.0, 0.0)
    NewLoadSceneStartSphere(coords.x, coords.y, coords.z, 50.0, 0)
    local sceneLoadStart = GetGameTimer()
    while not IsNewLoadSceneLoaded() and (GetGameTimer() - sceneLoadStart) < 4000 do
        RequestCollisionAtCoord(coords.x, coords.y, coords.z + 1.0)
        Citizen.Wait(0)
    end

    local groundZ = FindZGroundOnCoords(coords)
    FreezeEntityPosition(targetEntity, true)
    SetEntityCoordsNoOffset(targetEntity, coords.x, coords.y, groundZ + zOffset, false, false, false)

    local collisionStart = GetGameTimer()
    while not HasCollisionLoadedAroundEntity(targetEntity) and (GetGameTimer() - collisionStart) < 5000 do
        local entityCoords = GetEntityCoords(targetEntity)
        RequestCollisionAtCoord(entityCoords.x, entityCoords.y, entityCoords.z)
        Citizen.Wait(50)
    end
    FreezeEntityPosition(targetEntity, false)

    if heading then
        SetEntityHeading(targetEntity, heading)
    end

    NewLoadSceneStop()
    ClearFocus()

    if IsScreenFadedOut() then
        DoScreenFadeIn(500)
        while not IsScreenFadedIn() do
            Citizen.Wait(0)
        end
    end
end

function FindZGroundOnCoords(coords, cb)
    local startTick = GetGameTimer()
    local timeoutMs = 4000

    while (GetGameTimer() - startTick) < timeoutMs do
        RequestCollisionAtCoord(coords.x, coords.y, coords.z + 1.0)

        for i = 200, 1, -1 do
            local foundGround, z = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z + i, false)
            if foundGround then
                if cb then
                    cb(z)
                end
                return z
            end
        end

        Citizen.Wait(50)
    end

    if cb then
        cb(coords.z)
    end
    return coords.z
end