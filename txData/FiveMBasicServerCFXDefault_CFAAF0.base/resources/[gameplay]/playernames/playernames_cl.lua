-- ============================================================
-- playernames_cl.lua  (Client-side)
-- แสดงชื่อผู้เล่นเหนือหัวโดยใช้ MP Gamer Tag system
-- ============================================================

-- ============================================================
-- Constants: ID ของแต่ละ component ใน Gamer Tag
-- ============================================================
local GamerTagComponent = {
    GAMER_NAME           = 0,
    CREW_TAG             = 1,
    HEALTH_ARMOUR        = 2,
    BIG_TEXT             = 3,
    AUDIO_ICON           = 4,
    MP_USING_MENU        = 5,
    MP_PASSIVE_MODE      = 6,
    WANTED_STARS         = 7,
    MP_DRIVER            = 8,
    MP_CO_DRIVER         = 9,
    MP_TAGGED            = 10,
    GAMER_NAME_NEARBY    = 11,
    ARROW                = 12,
    MP_PACKAGES          = 13,
    INV_IF_PED_FOLLOWING = 14,
    RANK_TEXT            = 15,
    MP_TYPING            = 16,
}

-- ============================================================
-- State
-- ============================================================

-- gamer tag ที่ถูกสร้างแล้วของแต่ละ player
-- [playerIndex] = { tag = tagId, ped = pedHandle }
local activeTags = {}

-- settings ต่อ player (รับมาจาก server ผ่าน playernames:configure)
-- [playerIndex] = settings table
local tagSettings = {}

-- template string ปัจจุบัน (รับมาจาก server)
local templateStr = nil

-- ============================================================
-- Settings helpers
-- ============================================================
local function makeDefaultSettings()
    return {
        alphas      = {},
        colors      = {},
        toggles     = {},
        healthColor = false,
        wantedLevel = false,
        serverName  = nil,    -- ชื่อที่ถูก sync มาจาก server (ใช้ใน template {{serverName}})
        rename      = false,  -- flag: ต้อง rebuild ชื่อใหม่
    }
end

local function getOrCreateSettings(playerId)
    if not tagSettings[playerId] then
        tagSettings[playerId] = makeDefaultSettings()
    end
    return tagSettings[playerId]
end

-- ============================================================
-- Main loop: อัปเดต gamer tag ทุก frame
-- ============================================================
function updatePlayerNames()
    SetTimeout(0, updatePlayerNames)

    -- ยังไม่มี template → รอก่อน
    if not templateStr then return end

    local localPed    = PlayerPedId()
    local localCoords = GetEntityCoords(localPed)
    local localId     = PlayerId()

    for _, playerId in ipairs(GetActivePlayers()) do
        -- ข้ามตัวเอง
        -- if playerId ~= localId then
            local ped       = GetPlayerPed(playerId)
            local pedCoords = GetEntityCoords(ped)
            local settings  = getOrCreateSettings(playerId)
            local current   = activeTags[playerId]

            -- ตรวจว่าต้องสร้าง gamer tag ใหม่หรือไม่
            -- (ped เปลี่ยนเมื่อ model เปลี่ยน หรือ tag ถูก game ลบทิ้ง)
            local needsRebuild = not current
                              or current.ped ~= ped
                              or not IsMpGamerTagActive(current.tag)

            if needsRebuild then
                if current then
                    RemoveMpGamerTag(current.tag)
                end

                local displayName = formatPlayerNameTag(playerId, templateStr)
                activeTags[playerId] = {
                    tag = CreateMpGamerTag(ped, displayName, false, false, '', 0),
                    ped = ped,
                }
                current = activeTags[playerId]
            end

            local tag = current.tag

            -- อัปเดตชื่อถ้า server ส่งชื่อใหม่มา
            if settings.rename then
                SetMpGamerTagName(tag, formatPlayerNameTag(playerId, templateStr))
                settings.rename = false
            end

            -- ตรวจสอบระยะและ line-of-sight
            local dist    = #(pedCoords - localCoords)
            local visible = dist < PlayerNamesConfig.visibleDistance
                         and HasEntityClearLosToEntity(localPed, ped, 17)

            if visible then
                -- แสดง components หลัก
                SetMpGamerTagVisibility(tag, GamerTagComponent.GAMER_NAME,    true)
                SetMpGamerTagVisibility(tag, GamerTagComponent.HEALTH_ARMOUR, IsPlayerTargettingEntity(localId, ped))
                SetMpGamerTagVisibility(tag, GamerTagComponent.AUDIO_ICON,    NetworkIsPlayerTalking(playerId))

                SetMpGamerTagAlpha(tag, GamerTagComponent.AUDIO_ICON,    255)
                SetMpGamerTagAlpha(tag, GamerTagComponent.HEALTH_ARMOUR, 255)

                -- ใช้ settings ที่ถูก override จาก server/script อื่น
                for k, v in pairs(settings.toggles) do
                    SetMpGamerTagVisibility(tag, GamerTagComponent[k], v)
                end

                for k, v in pairs(settings.alphas) do
                    SetMpGamerTagAlpha(tag, GamerTagComponent[k], v)
                end

                for k, v in pairs(settings.colors) do
                    SetMpGamerTagColour(tag, GamerTagComponent[k], v)
                end

                if settings.wantedLevel then
                    SetMpGamerTagWantedLevel(tag, settings.wantedLevel)
                end

                if settings.healthColor then
                    SetMpGamerTagHealthBarColour(tag, settings.healthColor)
                end
            else
                -- ซ่อนทุก component เมื่อไกลเกินกำหนด
                SetMpGamerTagVisibility(tag, GamerTagComponent.GAMER_NAME,    false)
                SetMpGamerTagVisibility(tag, GamerTagComponent.HEALTH_ARMOUR, false)
                SetMpGamerTagVisibility(tag, GamerTagComponent.AUDIO_ICON,    false)
            end

        -- elseif activeTags[playerId] then
        --     -- player ออกจาก active list แล้ว → ลบ tag
        --     RemoveMpGamerTag(activeTags[playerId].tag)
        --     activeTags[playerId] = nil
        -- end
    end
end

-- ============================================================
-- Network Events
-- ============================================================

-- รับ config จาก server (setName, setComponentColor ฯลฯ)
RegisterNetEvent('playernames:configure')
AddEventHandler('playernames:configure', function(serverId, key, ...)
    local args     = table.pack(...)
    local playerId = GetPlayerFromServerId(tonumber(serverId))
    local settings = getOrCreateSettings(playerId)

    if key == 'tglc' then
        settings.toggles[args[1]] = args[2]

    elseif key == 'seta' then
        settings.alphas[args[1]] = args[2]

    elseif key == 'setc' then
        settings.colors[args[1]] = args[2]

    elseif key == 'setw' then
        settings.wantedLevel = args[1]

    elseif key == 'sehc' then
        settings.healthColor = args[1]

    elseif key == 'name' then
        -- server ส่งชื่อ custom มา → เก็บไว้ใน serverName แล้ว mark ว่าต้อง rebuild
        settings.serverName = args[1]
        settings.rename     = true

    elseif key == 'tpl' then
        -- template เปลี่ยน → mark ทุก player ว่าต้อง rebuild ชื่อ
        for _, s in pairs(tagSettings) do
            s.rename = true
        end
        templateStr = args[1]
    end
end)

-- inject {{serverName}} ให้ formatPlayerNameTag ใช้ได้ใน template
AddEventHandler('playernames:extendContext', function(playerId, cb)
    local settings = getOrCreateSettings(GetPlayerFromServerId(GetPlayerServerId(playerId)))
    cb('serverName', settings.serverName)
end)

-- ลบ gamer tag ทั้งหมดเมื่อ resource หยุดทำงาน
AddEventHandler('onResourceStop', function(name)
    if name == GetCurrentResourceName() then
        for _, entry in pairs(activeTags) do
            RemoveMpGamerTag(entry.tag)
        end
    end
end)

-- ============================================================
-- เริ่มทำงาน
-- ============================================================
SetTimeout(0, function()
    TriggerServerEvent('playernames:init')
end)

SetTimeout(0, updatePlayerNames)
