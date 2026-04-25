fx_version 'cerulean'
game 'gta5'

name        'Database'
description 'Database Module for create and manage database operations'
version     '1.0.0'
author      'KODev'


server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}
