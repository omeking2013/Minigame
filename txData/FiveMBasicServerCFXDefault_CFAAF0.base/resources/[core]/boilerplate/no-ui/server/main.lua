-- ============================================================
--  server/main.lua
-- ============================================================

-- ══════════════════════════════════════════════════════════
--  1. STATE
-- ══════════════════════════════════════════════════════════

local Players = {}  ---@type table<number, table>

local function getPlayer(src)     return Players[src]  end
local function removePlayer(src)  Players[src] = nil   end

-- ══════════════════════════════════════════════════════════
--  2. PRIVATE
-- ══════════════════════════════════════════════════════════

local function loadPlayer(src, identifier)
    local row  = DB.get(identifier)
    local data = row and json.decode(row.data) or {}

    Players[src] = {
        source     = src,
        identifier = identifier,
        name       = GetPlayerName(src),
        data       = data,
    }
end

local function savePlayer(src)
    local p = getPlayer(src)
    if not p then return end
    DB.save(p.identifier, p.data)
end

-- ── Auto-save loop ────────────────────────────────────────
-- บันทึกทุกคนตาม interval แทนที่จะเขียน DB ทุก action
-- ลด load DB มาก โดยเฉพาะถ้ามีผู้เล่นเยอะ
CreateThread(function()
    while true do
        Wait(Config.SaveIntervalMs)
        for src in pairs(Players) do
            savePlayer(src)
        end
        print(('[mg_template_nui] Auto-saved %d players'):format(
            (function() local n=0; for _ in pairs(Players) do n=n+1 end; return n end)()
        ))
    end
end)

-- ══════════════════════════════════════════════════════════
--  3. EXPORTS
-- ══════════════════════════════════════════════════════════

exports('getPlayer', function(src)
    return getPlayer(src)
end)

exports('getData', function(src, key)
    local p = getPlayer(src)
    if not p then return nil end
    return p.data[key]
end)

exports('setData', function(src, key, value)
    local p = getPlayer(src)
    if not p then return false end
    p.data[key] = value
    return true
end)

-- ══════════════════════════════════════════════════════════
--  4. EVENTS
-- ══════════════════════════════════════════════════════════

RegisterNetEvent('mg_template_nui:clientAction', function(payload)
    local src = source
    local p   = getPlayer(src)
    if not p then return end

    -- validate
    if type(payload) ~= 'table' then return end

    -- ทำ logic
    print(('[mg_template_nui] action from %s'):format(p.name))
end)

-- ══════════════════════════════════════════════════════════
--  5. LIFECYCLE
-- ══════════════════════════════════════════════════════════

AddEventHandler('playerJoining', function()
    local src        = source
    local identifier = GetPlayerIdentifierByType(src, 'license')
                    or GetPlayerIdentifier(src, 0)
    if not identifier then return end
    loadPlayer(src, identifier)
end)

AddEventHandler('playerDropped', function()
    local src = source
    savePlayer(src)
    removePlayer(src)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    for src in pairs(Players) do
        savePlayer(src)
    end
end)
