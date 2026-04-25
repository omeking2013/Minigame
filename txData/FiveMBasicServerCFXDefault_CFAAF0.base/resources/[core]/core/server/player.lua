---@class Player : OxClass
---@field name string
---@field src number
---@field identifier string
---@field avatarUrl string
---@field discordName string
---@field account table
---@field position table
---@field skin table
---@field saveDatabase function
---@field getAccount function
---@field setAccount function
---@field addAccount function
---@field removeAccount function

function CreateCorePlayer(src)
    local self = {} ---@type Player
    self.src = src
    self.identifier = Core.GetIdFromSource(src, "license")
    self.name = GetPlayerName(src)
    self.avatarUrl = ""
    self.discordName = ""
    self.account = Config.DefaultAccount or {}
    self.position = {}
    self.skin = {}
    local discordData = Core.GetDiscordDataFromId(src)
    
    if discordData then
        self.avatarUrl = discordData.avatarUrl
        self.discordName = discordData.username .. "#" .. discordData.discriminator
    else
        Log(("Failed to load Discord data for player %d"):format(src))
    end

    Log(("Self identifier %s"):format(self.identifier))
    local playerDbResult = DB.getAll(Config.StartDB.name, "identifier", self.identifier)

    if playerDbResult and #playerDbResult > 0 then
        self.account = playerDbResult[1].account and json.decode(playerDbResult[1].account)
        if not self.account or next(self.account) == nil then
            Log(("Failed to decode account data for player %s (ID: %d). Using default account."):format(self.name, self.src))
            self.account = Config.DefaultAccount or {}
        end

        self.skin = playerDbResult[1].skin and json.decode(playerDbResult[1].skin) or {}
        self.position = playerDbResult[1].position and json.decode(playerDbResult[1].position) or {}
    else
        DB.insert(Config.StartDB.name, {
            identifier = self.identifier,
            account = json.encode(Config.DefaultAccount),
            skin = json.encode({}),
            position = json.encode({})
        })
    end

    function self.saveDatabase()
        local result = DB.update(Config.StartDB.name, "identifier", self.identifier, {
            account = json.encode(self.account),
            name = self.name,
            skin = json.encode(self.skin),
            position = json.encode(Core.GetPlayerPosition(self.src)),
        })
        if result.success then
            Log(("Player data for %s (ID: %d) saved successfully."):format(self.name, self.src))
        else
            Log(("Failed to save player data for %s (ID: %d)."):format(self.name, self.src))
        end
    end

    ---@param type string
    function self.getAccount(type)
        return self.account[type]
    end

    ---@param type string
    ---@param amount number
    function self.setAccount(type, amount)
        self.account[type] = amount
    end

    ---@param type string
    ---@param amount number
    function self.addAccount(type, amount)
        if not self.account[type] then
            self.account[type] = 0
        end
        self.account[type] = self.account[type] + amount
    end

    ---@param type string
    ---@param amount number
    function self.removeAccount(type, amount)
        if not self.account[type] then
            self.account[type] = 0
        end
        self.account[type] = self.account[type] - amount
    end

    Log(("Loaded player: %s (ID: %d)"):format(self.name, self.src))
    return self
end

---@param src number
---@return Player
---@public
function Core.GetPlayerFromId(src)
    for _, player in pairs(Core.Players) do
        if player.src == src then
            return player
        end
    end

    -- If player data is not found, create a new one
    local newPlayer = CreateCorePlayer(src)
    Core.Players[src] = newPlayer
    return newPlayer
end

function Core.GetPlayerCleanDataFromId(src)
    local player = Core.GetPlayerFromId(src)
    local cleanData = {}

    for key, value in pairs(player) do
        if type(value) ~= "function" then
            cleanData[key] = value
        end
    end
    return cleanData
end

---@param src number
---@param cb function
---@public
function Core.SavePlayer(src, cb)
    local player = Core.GetPlayerFromId(src)

    Log(("Saving data for player: %s (ID: %d)"):format(player.name, player.src))
    if player then
        player.saveDatabase()
        if cb then
            cb()
        end
        Log(("Saved data for player: %s (ID: %d)"):format(player.name, player.src))
    else
        Log(("Player data not found for source %d, cannot save."):format(src))
    end
end

---@public Save All Players Data
function Core.SavePlayers()
    for _, player in pairs(Core.Players) do
        if player then
            player.saveDatabase()
        end
    end
end

RegisterNetEvent('core/player:getPlayerData')
AddEventHandler('core/player:getPlayerData', function()
    local src <const> = source
    local playerData = Core.GetPlayerCleanDataFromId(src)
    if playerData then
        TriggerClientEvent("core/player:receivePlayerData", src, playerData)
    else
        Log(("Player data not found for source %d"):format(src))
    end
end)
