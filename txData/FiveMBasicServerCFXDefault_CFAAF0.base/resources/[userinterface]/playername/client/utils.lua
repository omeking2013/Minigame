-- ============================================================
--  client/utils.lua
--  Helper functions ฝั่ง client
--
--  กฎ:
--  - ทุก function ในนี้ต้องไม่มี side effect
--  - ไม่มี TriggerServerEvent ในไฟล์นี้
--  - ไม่มี State จาก main.lua ในนี้
--  - แค่รับ input → คืน output หรือทำงาน UI ล้วนๆ
-- ============================================================

---แสดง notification แบบ GTA native (fallback เมื่อ NUI ปิด)
---@param msg string
function Notify(msg)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(msg)
    DrawNotification(false, true)
end

---แปลงตัวเลขเป็น string มี comma (1000 → "1,000")
---@param n number
---@return string
function FormatNumber(n)
    local s = tostring(math.floor(n))
    local result = ''
    local count  = 0
    for i = #s, 1, -1 do
        count = count + 1
        result = s:sub(i, i) .. result
        if count % 3 == 0 and i ~= 1 then
            result = ',' .. result
        end
    end
    return result
end

---ตรวจว่า player อยู่ใน radius ของ position หรือไม่
---@param pos vector3
---@param radius number
---@return boolean
function IsNearPosition(pos, radius)
    local myPos = GetEntityCoords(PlayerPedId())
    return #(myPos - pos) <= radius
end

---Debounce: ป้องกัน function ถูกเรียกบ่อยเกิน
---@param fn function
---@param delayMs number
---@return function
function Debounce(fn, delayMs)
    local lastCall = 0
    return function(...)
        local now = GetGameTimer()
        if (now - lastCall) < delayMs then return end
        lastCall = now
        fn(...)
    end
end
