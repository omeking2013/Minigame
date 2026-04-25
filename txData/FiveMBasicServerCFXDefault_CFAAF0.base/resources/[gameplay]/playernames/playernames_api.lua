-- ============================================================
-- playernames_api.lua  (Shared – โหลดทั้ง client & server)
-- ฟังก์ชันกลางสำหรับ API และ template engine
-- ============================================================

-- เก็บ config ต่อ player (server source → table of settings)
local savedSettings = {}

-- ============================================================
-- Internal: สร้าง trigger function ตาม key
-- ============================================================
local function makeTrigger(key)
    return function(id, ...)
        if not IsDuplicityVersion() then
            -- Client: ส่ง event ภายใน resource เอง
            TriggerEvent('playernames:configure', GetPlayerServerId(id), key, ...)
        else
            -- Server: บันทึกค่าแล้ว broadcast ให้ทุก client
            savedSettings[id]      = savedSettings[id] or {}
            savedSettings[id][key] = table.pack(...)
            TriggerClientEvent('playernames:configure', -1, id, key, ...)
        end
    end
end

-- ============================================================
-- Server only: ส่ง config ปัจจุบันทั้งหมดให้ client ที่เพิ่ง join
-- ============================================================
if IsDuplicityVersion() then
    function reconfigure(src)
        for id, settings in pairs(savedSettings) do
            for key, args in pairs(settings) do
                TriggerClientEvent('playernames:configure', src, id, key, table.unpack(args))
            end
        end
    end

    AddEventHandler('playerDropped', function()
        savedSettings[source] = nil
    end)
end

-- ============================================================
-- Public API
-- ============================================================
setComponentColor      = makeTrigger('setc')
setComponentAlpha      = makeTrigger('seta')
setComponentVisibility = makeTrigger('tglc')
setWantedLevel         = makeTrigger('setw')
setHealthBarColor      = makeTrigger('sehc')
setNameTemplate        = makeTrigger('tpl')
setName                = makeTrigger('name')

-- ============================================================
-- Template engine
-- (template.lua ถูกโหลดผ่าน LoadResourceFile เพราะเป็น files{})
-- ============================================================
if not io then io = { write = nil, open = nil } end

local templateEngine = load(LoadResourceFile(GetCurrentResourceName(), 'template/template.lua'))()

-- ============================================================
-- formatPlayerNameTag(id, templateStr)
--   สร้างข้อความชื่อโดยใช้ template engine
--   id = player index (client) หรือ source (server)
-- ============================================================
function formatPlayerNameTag(id, templateStr)
    local output = ''

    -- redirect การ print ของ template ให้เก็บลงตัวแปร
    templateEngine.print = function(txt)
        output = output .. txt
    end

    -- context ที่ template เข้าถึงได้ผ่าน {{variable}}
    local context = {
        name   = getPlayerDisplayName(id),   -- ← override ได้ใน config.lua
        i      = id,
        id     = IsDuplicityVersion() and id or GetPlayerServerId(id),
        global = _G,
    }

    -- อนุญาตให้ resource อื่น inject ตัวแปรเพิ่มเติม (เช่น serverName)
    TriggerEvent('playernames:extendContext', id, function(k, v)
        context[k] = v
    end)

    templateEngine.render(templateStr, context, nil, true)

    -- คืนค่า print กลับเป็นของเดิม
    templateEngine.print = print

    return output
end