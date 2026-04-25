-- ============================================================
--  client/main.lua
--  Logic หลักฝั่ง client
--
--  ลำดับในไฟล์นี้:
--  1. State   — ข้อมูล runtime ฝั่ง client
--  2. NUI     — เปิด/ปิด, ส่ง/รับข้อมูลกับ JS
--  3. Events  — รับ event จาก server
--  4. NUI Callbacks — รับ action จาก JS
--  5. Threads — loop ที่ต้องทำงานต่อเนื่อง (marker, keybind)
--  6. Lifecycle
-- ============================================================

-- ══════════════════════════════════════════════════════════
--  1. STATE
-- ══════════════════════════════════════════════════════════

local State = {
    isOpen    = false,   -- NUI เปิดอยู่ไหม
    data      = {},      -- ข้อมูลที่ sync มาจาก server
    cooldown  = false,   -- กันกด spam
}

-- ══════════════════════════════════════════════════════════
--  2. NUI HELPERS
-- ══════════════════════════════════════════════════════════

---ส่งข้อมูลไปหา JS
---@param action string
---@param payload table|nil
local function sendUI(action, payload)
    SendNUIMessage({ action = action, data = payload or {} })
end

---เปิด NUI
local function openUI()
    if State.isOpen then return end
    State.isOpen = true
    SetNuiFocus(true, true)
    sendUI('open', State.data)
end

---ปิด NUI
local function closeUI()
    if not State.isOpen then return end
    State.isOpen = false
    SetNuiFocus(false, false)
    sendUI('close')
end

-- ══════════════════════════════════════════════════════════
--  3. EVENTS (รับจาก server)
-- ══════════════════════════════════════════════════════════

---server ส่งข้อมูลอัปเดตมา
RegisterNetEvent('mg_template_ui:sync', function(payload)
    State.data = payload
    -- ถ้า UI เปิดอยู่ให้อัปเดตทันที
    if State.isOpen then
        sendUI('update', State.data)
    end
end)

-- ══════════════════════════════════════════════════════════
--  4. NUI CALLBACKS (รับ action จาก JS)
--  ทุก callback ต้องเรียก cb() เสมอ ไม่งั้น JS จะ hang
-- ══════════════════════════════════════════════════════════

---JS กดปุ่มปิด
RegisterNUICallback('close', function(_, cb)
    closeUI()
    cb('ok')
end)

---JS ส่ง action มา
RegisterNUICallback('doAction', function(data, cb)
    -- cooldown กัน spam
    if State.cooldown then cb('cooldown'); return end
    State.cooldown = true
    SetTimeout(Config.Cooldowns.actionMs, function()
        State.cooldown = false
    end)

    -- validate ฝั่ง client ก่อน (server จะ validate อีกครั้ง)
    if type(data.amount) ~= 'number' or data.amount <= 0 then
        cb('invalid')
        return
    end

    TriggerServerEvent('mg_template_ui:doAction', data)
    cb('ok')
end)

---JS ขอ sync
RegisterNUICallback('requestSync', function(_, cb)
    TriggerServerEvent('mg_template_ui:requestSync')
    cb('ok')
end)

-- ══════════════════════════════════════════════════════════
--  5. THREADS
-- ══════════════════════════════════════════════════════════

-- ── ตัวอย่าง: กด E เปิด UI เมื่ออยู่ใกล้ zone ─────────────
-- ใช้ Debounce จาก utils.lua กัน spam
local tryOpenUI = Debounce(function()
    TriggerServerEvent('mg_template_ui:requestSync')
    openUI()
end, 500)

CreateThread(function()
    -- ตัวอย่าง: กด E (38) เปิด UI ถ้าไม่ได้อยู่ใน zone จริง
    -- ในโปรเจกต์จริงให้เช็ค IsNearPosition(Config.Zones.xxx.pos, radius) ด้วย
    while true do
        Wait(0)

        if IsControlJustPressed(0, 38) and not State.isOpen then
            tryOpenUI()
        end

        -- ถ้า NUI เปิดอยู่ให้ sleep นานขึ้นเพื่อประหยัด CPU
        if State.isOpen then
            Wait(200)
        end
    end
end)

-- ══════════════════════════════════════════════════════════
--  6. LIFECYCLE
-- ══════════════════════════════════════════════════════════

-- ขอ sync ทันทีเมื่อ resource start (เช่น restart resource ระหว่าง dev)
AddEventHandler('onClientResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    TriggerServerEvent('mg_template_ui:requestSync')
end)

-- ปิด NUI เมื่อ resource หยุด ไม่งั้น focus ค้าง
AddEventHandler('onClientResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    if State.isOpen then
        SetNuiFocus(false, false)
    end
end)
