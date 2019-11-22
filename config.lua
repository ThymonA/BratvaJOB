Config                                  = {}
Config.Locale                           = 'nl'
Config.DrawDistance                     = 100
Config.CanSpawnCars                     = true
Config.CanBuyWeapons                    = true
Config.RequiredGradesForWeapons         = { 'boss', 'sovietnik' }
Config.RequiredGradesForMoneyWash       = { 'boss', 'sovietnik' }
Config.RequiredGradesForEmployee        = { 'boss' }
Config.RequiredGradesForBankSystem      = { 'boss', 'sovietnik' }
Config.RequiredGradesForWeaponDeposit   = { 'boss', 'sovietnik', 'obshchak', 'restap' }
Config.GradesForDepoAndWithrawWeapons   = { 'boss', 'sovietnik', 'obshchak', 'restap' }
Config.RequiredGradesForBossActions     = { 'boss', 'sovietnik' }
Config.CanSellWeapons                   = true
Config.CanStoreOwnCars                  = true
Config.CanChangeClothes                 = true
Config.CanWashMoney                     = true
Config.SpawnDistanceSpawnPoint          = 5.0
Config.NumberOfBullets                  = 250
Config.MaxListSize                      = 15
Config.WashEverySecond                  = 40

Config.JobName                          = 'bratva'
Config.JobLabel                         = 'Bratva'

Config.Weapons = {                                          -- Weapons they can buy and the price for those weapons
    { name = 'WEAPON_PISTOL',           price = 125000 },   -- > Pistol             for € 125.000
    { name = 'WEAPON_PISTOL50',         price = 175000 },   -- > Pistol .50         for € 175.000
    { name = 'WEAPON_DBSHOTGUN',        price = 275000 },   -- > DB Shotgun         for € 275.000
    { name = 'WEAPON_MINISMG',          price = 350000 },   -- > Mini SMG           for € 350.000
    { name = 'WEAPON_ASSAULTRIFLE',     price = 400000 },   -- > Assault Riffle     for € 400.000
}

Config.SpawnVehicles = {                    	    -- Cars they can spawn
    { name = 'Audi RS7',    model = 'rs7' },   	    --> Audi RS7
    { name = 'Lexus SUV',   model = 'rx450h' }, 	--> Lexus SUV
    { name = 'Yamaha R1',   model = 'r1v2'}         --> Yamaha R1
}

Config.VehicleProps = {         -- Tune car when spawned
    modArmor            = 1,    -- > No armor on car
    modEngine           = 3,    -- > Engine on max level
    modBrakes           = 2,    -- > Brakes on max level
    modTransmission     = 2,    -- > Transmission on max level
    modSuspension       = 3,    -- > Suspension on max level
    modTurbo            = true, -- > Turbo on max level
    color1              = 22,   -- > Primary color
    color2              = 0,    -- > Secondary color
    pearlescentColor    = 132,  -- > Pearlescent color
    plateIndex          = 1,    -- > Plate color
    modAPlate           = 5,    -- > Plate mod
    modWindows          = 1,    -- > Window tint
    modXenon            = true  -- > Xenon light
}

Config.CustomVehicleMods = {
    ['r1v2'] = {
        modSpoilers     = 0,
        modFrontBumper  = -1,
        modRearBumper   = 0,
        modExhaust      = 2,
        modLivery       = 2,
        modRoof         = 0
    },
}

Config.Marker = {                           -- Markers
    Type = 1,                               -- Type

    Default = {                             -- Default Marker
        x = 1.5,    y = 1.5,    z = 0.5,    -- > Size
        r = 0,      g = 0,      b = 255     -- > Color
    },
    Garage = {                              -- Despawn Marker Garage
        x = 5.0,    y = 5.0,    z = 0.5,    -- > Size
        r = 255,    g = 0,      b = 0       -- > Color
    },
    Clothing = {                            -- Clothing Marker
        x = 1.5,    y = 1.5,    z = 0.5,    -- > Size
        r = 255,    g = 128,    b = 0       -- > Color
    },
    Safe = {                                -- Safe Marker
        x = 1.5,    y = 1.5,    z = 0.5,    -- > Size
        r = 75,     g = 75,     b = 255     -- > Color
    },
    Boss = {                                -- Boss Action Menu Marker
        x = 1.5,    y = 1.5,    z = 0.5,    -- > Size
        r = 255,    g = 255,    b = 0       -- > Color
    },
    Warehouse = {                           -- Boss Action Menu Marker
        x = 5.0,    y = 5.0,    z = 0.5,    -- > Size
        r = 0,      g = 255,    b = 0       -- > Color
    },
}

Config.Locations = {                                                                    -- All locations
    VehicleCircleLocation = { x = 503.83, y = -3121.95, z = 8.8 },                      -- Spawn car circle location
    VehicleSpawnLocation = { x = 489.37, y = -3130.89, z = 5.07, h = 359.5 },           -- Vehicle spawn location
    GarageParkingCircleLocation = { x = 475.61, y = -3149.61, z = 5.08, h = 164.5 },    -- Garage parking location
    GarageSpawnLocation = { x = 489.78, y = -3150.99, z = 5.1, h = 0.0 },               -- Garage spawn location
    ClothingCircleLocation = { x = 562.82, y = -3121.15, z = 17.78 },                   -- Clothing location
    SafeCircleLocation = { x = 563.5, y = -3127.04, z = 17.77 },                        -- Safe location
    WeaponSafeCircleLocation = { x = 575.41, y = -3121.4, z = 17.77 },                  -- Weapon safe location
    BossCircleLocation = { x = 569.88, y = -3126.8, z = 17.78 },                        -- Boss location
    WarehouseLocation = { x = 470.75, y = -3133.39, z = 5.08 },                         -- Warehouse location
}

Config.DiscordLogs = {
    Colors = {
        Green       = 3066993,
        Grey        = 9807270,
        Red         = 15158332,
        Orange      = 15105570,
        Blue        = 3447003,
        Purple      = 10181046,
        Yellow      = 15844367,
        DarkGreen   = 2600544,
        DarkRed     = 12597547
    },
    SafeLog         = { 'https://discordapp.com/api/webhooks/631433939935952899/oviAldjZ8O4D0ww4cve429tbTK8Hkd6cXmFi3TpaL297UbUSttQj-sjS_4nkfbpy71ih' },
    ActionLog       = { 'https://discordapp.com/api/webhooks/600985199374893056/4VHusG36bvhRmewAx0Gw1lykDoF_sGtlPMfv7tMFVYeaC8T_JxpVuZrE4XTuq8ghxmhB' },
    MoneyLog        = { 'https://discordapp.com/api/webhooks/631433939935952899/oviAldjZ8O4D0ww4cve429tbTK8Hkd6cXmFi3TpaL297UbUSttQj-sjS_4nkfbpy71ih' },
    EmployeeLog     = { 'https://discordapp.com/api/webhooks/600985199374893056/4VHusG36bvhRmewAx0Gw1lykDoF_sGtlPMfv7tMFVYeaC8T_JxpVuZrE4XTuq8ghxmhB' },
}

Config.Outfits = {
	{
        name = 'Standaard',
        clothes = {
            ['tshirt_1'] = 96,  ['tshirt_2'] = 2,   ['torso_1'] = 31,
            ['torso_2'] = 0,    ['decals_1'] = 0,   ['decals_2'] = 0,
            ['arms'] = 33,      ['pants_1'] = 50,   ['pants_2'] = 2,
            ['shoes_1'] = 10,   ['shoes_2'] = 0,    ['helmet_1'] = -1,
            ['helmet_2'] = 0,   ['chain_1'] = 22,   ['chain_2'] = 9,
            ['ears_1'] = -1,    ['mask_1'] = 121,   ['mask_2'] = 0,
			['glasses'] = 0,    ['glasses_1'] = 0,  ['glasses_2'] = 0,
            ['bproof_1'] = 0,   ['bproof_2'] = 0,   ['bags_1'] = 0,
            ['bags_2'] = 0,
        },
        grades = { }
    },
	{
        name = 'Black Force',
        clothes = {
            ['tshirt_1'] = 96,  ['tshirt_2'] = 2,   ['torso_1'] = 31,
            ['torso_2'] = 0,    ['decals_1'] = 0,   ['decals_2'] = 0,
            ['arms'] = 33,      ['pants_1'] = 50,   ['pants_2'] = 2,
            ['shoes_1'] = 10,   ['shoes_2'] = 0,   	['helmet_1'] = 39,
            ['helmet_2'] = 0,   ['chain_1'] = 22,  	['chain_2'] = 9,
            ['ears_1'] = -1,    ['mask_1'] = 89,    ['mask_2'] = 0,
            ['glasses'] = 0,    ['glasses_1'] = 24, ['glasses_2'] = 2,
            ['bproof_1'] = 0,   ['bproof_2'] = 0,   ['bags_1'] = 31,
            ['bags_2'] = 0,
        },
        grades = { }
    },
    {
        name = 'Air Force',
        clothes = {
            ['tshirt_1'] = 15,  ['tshirt_2'] = 0,   ['torso_1'] = 53,
            ['torso_2'] = 1,    ['decals_1'] = 0,   ['decals_2'] = 0,
            ['arms'] = 50,      ['pants_1'] = 31,   ['pants_2'] = 3,
            ['shoes_1'] = 25,   ['shoes_2'] = 0,   	['helmet_1'] = 115,
            ['helmet_2'] = 0,   ['chain_1'] = 0,  	['chain_2'] = 0,
            ['ears_1'] = -1,    ['mask_1'] = 0,     ['mask_2'] = 0,
            ['glasses'] = 0,    ['glasses_1'] = 0,  ['glasses_2'] = 0,
            ['bproof_1'] = 0,   ['bproof_2'] = 0,   ['bags_1'] = 61,
            ['bags_2'] = 9,
        },
        grades = { }
    }
}