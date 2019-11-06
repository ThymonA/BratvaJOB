resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'ESX Maffia job created by Tigo#0001'

version '1.0.0'

client_scripts {
    '@es_extended/locale.lua',
    'locales/nl.lua',
    'config.lua',
    'shared/price_function.lua',
    'client/menus/vehicle_menu.lua',
    'client/menus/garage_menu.lua',
    'client/menus/clothing_menu.lua',
    'client/menus/safe_menu.lua',
    'client/menus/boss_menu.lua',
    'client/main.lua',
}

server_scripts {
    '@es_extended/locale.lua',
    '@mysql-async/lib/MySQL.lua',
    'locales/nl.lua',
    'config.lua',
    'shared/price_function.lua',
    'server/menus/vehicle_menu.lua',
    'server/menus/garage_menu.lua',
    'server/menus/clothing_menu.lua',
    'server/menus/safe_menu.lua',
    'server/menus/boss_menu.lua',
    'server/main.lua'
}

dependencies {
    'es_extended',
    'mysql-async'
}