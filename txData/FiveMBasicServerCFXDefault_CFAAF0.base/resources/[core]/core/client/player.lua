Core.LocalPlayer = {}
Core.LocalPlayerGame = {}

local function spawnPlayer(visible, freeze, model)
    ShutdownLoadingScreen()

    local playerId = PlayerId()
    local spawnCoords = vector3(Config.DefaultSpawn.x, Config.DefaultSpawn.y, Config.DefaultSpawn.z)
    local spawnHeading = Config.DefaultSpawn.heading
    
    if Core.LocalPlayer.position then
        if Core.LocalPlayer.position.x and Core.LocalPlayer.position.y and Core.LocalPlayer.position.z then
            spawnCoords = vector3(Core.LocalPlayer.position.x, Core.LocalPlayer.position.y, Core.LocalPlayer.position.z)
        end
        if Core.LocalPlayer.position.heading then
            spawnHeading = Core.LocalPlayer.position.heading
        end
    end

    NetworkResurrectLocalPlayer(spawnCoords.x, spawnCoords.y, spawnCoords.z, true, true, false)
    local model_ = model or "a_m_m_hillbilly_01"
    lib.requestModel(model_, 5000)
    SetPlayerModel(playerId, model_)
    SetModelAsNoLongerNeeded(model_)

    local playerPed = PlayerPedId()
    SafeTeleport(spawnCoords, spawnHeading)
    RemoveAllPedWeapons(playerPed, true)
    ClearPlayerWantedLevel(playerId)

    if visible == false then
        NetworkSetEntityInvisibleToNetwork(playerPed, true)
        SetEntityVisible(playerPed, false)
    elseif visible == true then
        NetworkSetEntityInvisibleToNetwork(playerPed, false)
        SetEntityVisible(playerPed, true)
    end
    
    if (freeze == true) then
        FreezeEntityPosition(playerPed, true)
        Log("Player position frozen.")
    elseif (freeze == false) then
        FreezeEntityPosition(playerPed, false)
        Log("Player position unfrozen.")
    end

    Core.LocalPlayerGame.Ped = playerPed
    Core.LocalPlayerGame.Id = playerId
    Core.LocalPlayerGame.ServerId = GetPlayerServerId(Core.LocalPlayerGame.Id)
    Log(("Ped :%s, Id: %d, ServerId: %d"):format(Core.LocalPlayerGame.Ped, Core.LocalPlayerGame.Id, Core.LocalPlayerGame.ServerId))
end

local respawnProcess = false
function RespawnPlayer()
    if respawnProcess == true then 
        return 
    end

    respawnProcess = true
    Wait(3000)

    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)

    DoScreenFadeOut(200)
    while not IsScreenFadedOut() do
        Citizen.Wait(0)
    end

    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, true, true, false)
    SafeTeleport(coords, heading)
    RemoveAllPedWeapons(playerPed, true)
    ClearPlayerWantedLevel(PlayerId())
    respawnProcess = false

    Notify("~g~Player respawned after death.~s~")
end

RegisterNetEvent("core/player:receivePlayerData")
AddEventHandler('core/player:receivePlayerData', function(playerData)
    Core.LocalPlayer = playerData

    spawnPlayer(true, false)
    Log(("Received player data: %s"):format(json.encode(playerData)))
end)

