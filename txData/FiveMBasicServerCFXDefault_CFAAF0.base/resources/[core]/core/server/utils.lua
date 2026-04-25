
---@param msg string
function Log(msg)
    if Config.Debug == true then
        print(("[CoreUtils] %s"):format(msg))
    end
end

---@param source number
---@param type string "steam", "license", "xbl", "live", "discord", etc.
---@param callback function
---@return string|nil
function Core.GetIdFromSource(source, type, callback)
    local identifiers = GetPlayerIdentifiers(source)
    for _, identifier in ipairs(identifiers) do
        local id = identifier:match(type .. ":(.+)")
        if id then
            if callback then
                callback(id)
            end
            return id
        end
    end

    if callback then
        callback(nil) -- ไม่พบ identifier ที่ต้องการ
    end
    return nil
end

---@param discordId string
---@param callback function(success boolean, data table)
function Core.FetchDiscordData(discordId, callback)
    local url = ("https://discord.com/api/v10/guilds/%s/members/%s"):format(Config.Discord.SERVER_ID, discordId)

    PerformHttpRequest(url, function(statusCode, responseText, headers)
        if statusCode ~= 200 then
            local errMap = {
                [404] = "not_in_guild",
                [401] = "invalid_token",
                [403] = "no_permission",
            }
            local errKey = errMap[statusCode] or ("http_" .. tostring(statusCode))
            Log(("HTTP %d for discordId %s → %s"):format(statusCode, discordId, errKey))
            return callback(false, { error = errKey })
        end

        local ok, m = pcall(json.decode, responseText)
        if not ok or not m then
            Log("JSON decode failed for discordId: " .. discordId)
            return callback(false, { error = "json_decode_failed" })
        end

        local u = m.user or {}

        -- --------------------------------------------------------
        -- สร้าง Avatar URL (รองรับ animated gif ด้วย a_ prefix)
        -- --------------------------------------------------------
        local function buildAvatarUrl(userId, hash, size)
            if not hash then return nil end
            size = size or 1024
            local ext = hash:sub(1, 2) == "a_" and "gif" or "png"
            return ("https://cdn.discordapp.com/avatars/%s/%s.%s?size=%d"):format(userId, hash, ext, size)
        end

        -- Guild Avatar URL (override avatar เฉพาะ Server นี้)
        local function buildGuildAvatarUrl(guildId, userId, hash, size)
            if not hash then return nil end
            size = size or 1024
            local ext = hash:sub(1, 2) == "a_" and "gif" or "png"
            return ("https://cdn.discordapp.com/guilds/%s/users/%s/avatars/%s.%s?size=%d")
                    :format(guildId, userId, hash, ext, size)
        end

        -- Banner URL
        local function buildBannerUrl(userId, hash, size)
            if not hash then return nil end
            size = size or 1024
            local ext = hash:sub(1, 2) == "a_" and "gif" or "png"
            return ("https://cdn.discordapp.com/banners/%s/%s.%s?size=%d"):format(userId, hash, ext, size)
        end

        -- Default Avatar (ใช้เมื่อไม่มี Avatar)
        local function buildDefaultAvatarUrl(userId)
            -- ระบบใหม่: (userId >> 22) % 6
            local index = (tonumber(userId) >> 22) % 6
            return ("https://cdn.discordapp.com/embed/avatars/%d.png"):format(index)
        end

        local avatarHash      = u.avatar
        local memberAvatarHash = m.avatar   -- Guild-specific avatar
        local bannerHash      = u.banner

        local avatarUrl = buildAvatarUrl(u.id, avatarHash)
                       or buildDefaultAvatarUrl(u.id or discordId)

        local data = {
            -- ---------- Guild Member ----------
            roles           = m.roles        or {},
            nick            = m.nick,
            joinedAt        = m.joined_at,
            premiumSince    = m.premium_since,
            pending         = m.pending       or false,
            deaf            = m.deaf          or false,
            mute            = m.mute          or false,
            flags           = m.flags         or 0,

            -- ---------- User ----------
            id              = u.id            or discordId,
            username        = u.username      or "Unknown",
            globalName      = u.global_name,
            discriminator   = u.discriminator or "0",
            avatar          = avatarHash,
            avatarUrl       = avatarUrl,
            banner          = bannerHash,
            bannerUrl       = buildBannerUrl(u.id, bannerHash),
            accentColor     = u.accent_color,
            bot             = u.bot           or false,
            system          = u.system        or false,
            mfaEnabled      = u.mfa_enabled   or false,
            locale          = u.locale,
            premiumType     = u.premium_type  or 0,
            publicFlags     = u.public_flags  or 0,

            -- ---------- Guild Avatar ----------
            memberAvatar    = memberAvatarHash,
            memberAvatarUrl = buildGuildAvatarUrl(Config.Discord.SERVER_ID, u.id or discordId, memberAvatarHash),

            -- ---------- Helper: รูปที่ควรใช้แสดง (Guild Avatar > Avatar > Default) ----------
            displayAvatarUrl = buildGuildAvatarUrl(Config.Discord.SERVER_ID, u.id or discordId, memberAvatarHash)
                            or avatarUrl,
        }

        -- Log(("Fetched [%s#%s | globalName:%s | nick:%s | roles:%s | avatar:%s]"):format(
        --     data.username,
        --     data.discriminator,
        --     data.globalName or "-",
        --     data.nick or "-",
        --     json.encode(data.roles),
        --     data.avatarUrl
        -- ))

        callback(true, data)
    end, "GET", "", {
        ["Authorization"] = "Bot " .. Config.Discord.BOT_TOKEN,
        ["Content-Type"]  = "application/json",
    })
end

function Core.GetDiscordDataFromId(src)
    local discordId = nil
    Core.GetIdFromSource(src, "discord", function(id)
        discordId = id
    end)

    if not discordId then
        Log(("Cannot get Discord ID from source %d"):format(src))
        return nil
    end

    local result = nil
    local done = false

    Core.FetchDiscordData(discordId, function(success, data)
        if success then
            result = data
        else
            Log(("Failed to fetch Discord data for ID %s"):format(discordId))
        end
        done = true
    end)

    local start = GetGameTimer()
    while not done and (GetGameTimer() - start) <= 10000 do
        Log("Waiting for Discord data...") -- เพิ่มการแจ้งเตือนในคอนโซล
        Wait(1000) 
    end

    return result
end

function Core.GetDiscordAvatarUrl(discordId)
    Core.FetchDiscordData(discordId, function(success, data)
        if success then
            return data.avatarUrl
        else
            return nil
        end
    end)
end

function Core.GetDiscordAvatarUrlFromId(src)
    Core.GetIdFromSource(src, "discord", function(discordId)
        if discordId then
            return Core.GetDiscordAvatarUrl(discordId)
        else
            return nil
        end
    end)
end

function Core.GetPlayerPosition(src)
    local player = GetPlayerPed(src)
    if player then
        local coords = GetEntityCoords(player)
        local heading = GetEntityHeading(player)
        return { x = math.round(coords.x, 2), y = math.round(coords.y, 2), z = math.round(coords.z, 2), heading = math.round(heading, 2) }
    else
        Log(("Cannot get position for source %d: player not found"):format(src))
        return nil
    end
end

AddEventHandler("core/utils:fetchDiscordData", function(discordId, callback)
    Core.FetchDiscordData(discordId, callback)
end)

AddEventHandler("core/utils:getIdFromSource", function(playerSource, idType, callback)
    Core.GetIdFromSource(playerSource, idType, callback)
end)

exports("fetchDiscordData", Core.FetchDiscordData)
exports("getIdFromSource", Core.GetIdFromSource)
