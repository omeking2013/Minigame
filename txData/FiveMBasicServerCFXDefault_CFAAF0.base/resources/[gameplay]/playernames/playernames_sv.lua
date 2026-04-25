-- ============================================================
-- playernames_sv.lua  (Server-side)
-- Poll template/ชื่อผู้เล่น ทุก 500ms แล้ว sync ไปยัง client
-- ============================================================

-- template ปัจจุบัน (ฝั่ง client HUD)
local currentClientTemplate = nil

-- template ปัจจุบัน (ฝั่ง server-side)
local currentServerTemplate = nil

-- cache ชื่อที่ sync ล่าสุดของแต่ละ player
local cachedPlayerTags = {}

-- รายชื่อ player ที่ online (source → true)
local activePlayers = {}

-- ============================================================
-- pollUpdates() – ทำงานทุก 500ms
-- ตรวจสอบ convar และอัปเดตชื่อถ้าเปลี่ยนแปลง
-- ============================================================
local function pollUpdates()
    SetTimeout(500, pollUpdates)

    -- อัปเดต template บน client ถ้า convar เปลี่ยน
    local newClientTemplate = GetConvar('playerNames_template', PlayerNamesConfig.clientTemplate)
    if currentClientTemplate ~= newClientTemplate then
        setNameTemplate(-1, newClientTemplate)
        currentClientTemplate = newClientTemplate
    end

    -- อัปเดตชื่อ server-side ของแต่ละ player ถ้าเปลี่ยน
    local newServerTemplate = GetConvar('playerNames_svTemplate', PlayerNamesConfig.serverTemplate)
    currentServerTemplate = newServerTemplate

    for src in pairs(activePlayers) do
        local newTag = formatPlayerNameTag(src, newServerTemplate)
        if newTag ~= cachedPlayerTags[src] then
            setName(src, newTag)
            cachedPlayerTags[src] = newTag
        end
    end

    -- ล้าง cache ของ player ที่ออกไปแล้ว
    for src in pairs(cachedPlayerTags) do
        if not activePlayers[src] then
            cachedPlayerTags[src] = nil
        end
    end
end

-- ============================================================
-- Events
-- ============================================================

-- player ออกจากเซิร์ฟเวอร์
AddEventHandler('playerDropped', function()
    cachedPlayerTags[source] = nil
    activePlayers[source]    = nil
end)

-- client ส่ง event มาบอกว่าพร้อมรับ config แล้ว
RegisterNetEvent('playernames:init')
AddEventHandler('playernames:init', function()
    reconfigure(source)             -- ส่ง config ทั้งหมดให้ client ที่ join
    activePlayers[source] = true
end)

-- ============================================================
-- เริ่ม poll
-- ============================================================
pollUpdates()
