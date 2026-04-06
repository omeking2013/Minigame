-- ============================================================
--  client/main.lua  — resource ที่ไม่มี NUI
--  มีแค่ keybind, marker, thread ที่จำเป็น
-- ============================================================

-- ══════════════════════════════════════════════════════════
--  1. STATE
-- ══════════════════════════════════════════════════════════

local State = {
    nearZone = false,
}

-- ══════════════════════════════════════════════════════════
--  2. EVENTS
-- ══════════════════════════════════════════════════════════

-- รับ event จาก server (ถ้ามี)
RegisterNetEvent('mg_template_nui:notify', function(msg)
    Notify(msg)
end)

-- ══════════════════════════════════════════════════════════
--  3. THREADS
-- ══════════════════════════════════════════════════════════

-- ── ตัวอย่าง: zone + keybind โดยไม่มี NUI ────────────────
-- Pattern: sleep นานเมื่ออยู่ไกล, sleep สั้นเมื่ออยู่ใกล้
-- ป้องกัน CPU spike จาก Wait(0) ตลอดเวลา

local ZONE_POS    = vector3(0.0, 0.0, 0.0)   -- แก้ตาม config
local ZONE_RADIUS = 3.0

local doAction = Debounce(function()
    TriggerServerEvent('mg_template_nui:clientAction', { type = 'interact' })
end, 1000)

CreateThread(function()
    while true do
        local dist = #(GetEntityCoords(PlayerPedId()) - ZONE_POS)

        if dist < ZONE_RADIUS then
            State.nearZone = true

            -- วาด marker
            DrawMarker(1,
                ZONE_POS.x, ZONE_POS.y, ZONE_POS.z - 1.0,
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                ZONE_RADIUS * 2, ZONE_RADIUS * 2, 0.5,
                100, 150, 255, 180,
                false, false, 2, false, nil, nil, false
            )

            -- แสดง help text
            BeginTextCommandDisplayHelp('STRING')
            AddTextComponentSubstringPlayerName('[E] ทำ Action')
            EndTextCommandDisplayHelp(0, false, true, -1)

            -- กด E
            if IsControlJustPressed(0, 38) then
                doAction()
            end

            Wait(0)   -- ใกล้ zone → render ทุก frame
        else
            State.nearZone = false

            -- ไกล zone → sleep นาน ประหยัด CPU
            local sleepMs = dist < 50.0 and 500 or 2000
            Wait(sleepMs)
        end
    end
end)

-- ══════════════════════════════════════════════════════════
--  4. LIFECYCLE
-- ══════════════════════════════════════════════════════════

AddEventHandler('onClientResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    -- ทำอะไรบางอย่างตอน start ถ้าจำเป็น
end)
