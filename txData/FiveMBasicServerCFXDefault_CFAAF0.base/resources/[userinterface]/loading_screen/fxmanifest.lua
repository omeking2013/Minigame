fx_version 'cerulean'
game 'gta5'

name        'loading_screen'
description 'A custom loading screen for FiveM servers.'
version     '1.0.0'
author      'KODev'

-- ── NUI ───────────────────────────────────────────────────
loadscreen 'ui/index.html'
files {
    'ui/index.html',
    'ui/style.css',
    'ui/config.js',
    'ui/app.js',
    'ui/assets/*/*.*',
}
loadscreen_cursor 'yes'
loadscreen_manual_shutdown 'yes'

client_script 'client.lua'