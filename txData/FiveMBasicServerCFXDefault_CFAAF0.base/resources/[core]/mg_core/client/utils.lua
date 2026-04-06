-- ============================================================
--  client/utils.lua  (เหมือนกันทั้งสอง boilerplate)
-- ============================================================

function Notify(msg)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(msg)
    DrawNotification(false, true)
end

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
