local function checkWhitelistFromRoles(roles)
    for _, roleId in ipairs(roles) do
        if Config.Discord.ROLES_WHITELIST[roleId] then
            return true
        end
    end
    return false
end

AddEventHandler('playerConnecting', function(name, setCallback, deferrals)
    local src <const> = source
    local discordId = Core.GetIdFromSource(src, "discord")

    deferrals.defer()
    Wait(10)

    if Config.Debug == false then
        for i = 3, 1, -1 do
            deferrals.update(("\n\n⏳ กำลังเข้าสู่เซิร์ฟเวอร์... (%d) \nConnecting to the server..."):format(i))
            Wait(1000)
        end
    end
    
    if not discordId then
        deferrals.done("\n\n⚠️ การเชื่อมต่อล้มเหลว: ไม่พบ Discord ID ของคุณ กรุณาตรวจสอบว่าบัญชีของคุณเชื่อมต่อกับ Discord ของทาง Server แล้วและลองใหม่อีกครั้ง (Connection failed: Your Discord ID was not found, please make sure your account is linked with the Server's Discord and try again.)")
        return
    end

    Core.FetchDiscordData(discordId, function(success, data)
        if not success then
            deferrals.done("\n\n⚠️ การเชื่อมต่อล้มเหลว: ไม่สามารถดึงข้อมูล Discord ของคุณได้ กรุณาตรวจสอบว่าบัญชีของคุณเชื่อมต่อกับ Discord ของทาง Server แล้วและลองใหม่อีกครั้ง (Connection failed: Unable to fetch your Discord data, please make sure your account is linked with the Server's Discord and try again.)")
            return
        end

        deferrals.update(("\n\n🔍 ตรวจสอบสิทธิ์การเข้าถึง... (Discord:%s)"):format(data.username))
        Wait(1000)
        if checkWhitelistFromRoles(data.roles) then
            deferrals.update("\n✅ การตรวจสอบสิทธิ์เสร็จสิ้น! กำลังเข้าสู่เซิร์ฟเวอร์!")
            deferrals.done()
        else
            deferrals.done("\n\n⚠️ การเชื่อมต่อล้มเหลว: คุณไม่ได้รับอนุญาตให้เข้าร่วมเซิร์ฟเวอร์นี้ (Connection failed: You do not have permission to join this server.)")
        end
    end)
end)
