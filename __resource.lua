resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'ESX Bratva job created by Tigo#0001'

version '1.0.0'

client_scripts {
    '@es_extended/locale.lua',
    'locales/nl.lua',
    'config.lua',
    'shared/shared.lua',
    'client/menus/vehicle_menu.lua',
    'client/menus/clothing_menu.lua',
    'client/menus/safe_menu.lua',
    'client/menus/weapon_safe_menu.lua',
    'client/menus/warehouse_menu.lua',
    'client/menus/boss_menu/main.lua',
    'client/menus/boss_menu/employee_menu.lua',
    'client/menus/boss_menu/bank_menu.lua',
    'client/actions/job_menu.lua',
    'client/main.lua',
}

server_scripts {
    '@es_extended/locale.lua',
    '@mysql-async/lib/MySQL.lua',
    'locales/nl.lua',
    'config.lua',
    'shared/shared.lua',
    'server/menus/vehicle_menu.lua',
    'server/menus/clothing_menu.lua',
    'server/menus/safe_menu.lua',
    'server/menus/warehouse_menu.lua',
    'server/menus/weapon_safe_menu.lua',
    'server/menus/boss_menu/main.lua',
    'server/menus/boss_menu/employee_menu.lua',
    'server/menus/boss_menu/bank_menu.lua',
    'server/actions/job_menu.lua',
    'server/main.lua'
}

dependencies {
    'es_extended',
    'mysql-async'
}