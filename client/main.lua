local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local PlayerData                = {}
local CurrentAction             = nil
local LastAction                = nil
local Blips                     = {}
local BlipsUpdated              = false
local IsHandcuffed              = false
local DraggedBy = -1
local Drag = false
local WasDragged = false
local Action                    = {
    SpawnVehicle    = 'SpawnVehicle',
    ParkInGarage    = 'ParkInGarage',
    ChangeClothes   = 'ChangeClothes',
    OpenSafe        = 'OpenSafe',
    OpenWeaponSafe  = 'OpenWeaponSafe',
    BossActions     = 'BossActions',
    Warehouse       = 'Warehouse'
}

ESX                         = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('mlx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	PlayerData = ESX.GetPlayerData()
end)

-- Draw markers
Citizen.CreateThread(function()
    while true do
        if (PlayerContainsJob()) then
            local playerPed = GetPlayerPed(-1)
            local coords = GetEntityCoords(playerPed)
          
            -- Markers
            local marker = Config.Marker
            local defaultMarker = marker.Default
            local garageMarker = marker.Garage
            local clothingMarker = marker.Clothing
            local safeMarker = marker.Safe
            local bossMarker = marker.Boss
            local warehouse = marker.Warehouse

            -- Locations
            local vehicleCircle = Config.Locations.VehicleCircleLocation
            local garageParkingCircle = Config.Locations.GarageParkingCircleLocation
            local clothingCircle = Config.Locations.ClothingCircleLocation
            local safeCircle = Config.Locations.SafeCircleLocation
            local weaponSafeCircle = Config.Locations.WeaponSafeCircleLocation
            local bossSafeCircle = Config.Locations.BossCircleLocation
            local warehouseCircle = Config.Locations.WarehouseLocation

            if (Config.CanSpawnCars) then
                if (GetDistanceBetweenCoords(coords, vehicleCircle.x, vehicleCircle.y, vehicleCircle.z, true) < Config.DrawDistance) then
                    DrawMarker(marker.Type, vehicleCircle.x, vehicleCircle.y, vehicleCircle.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, defaultMarker.x, defaultMarker.y, defaultMarker.z, defaultMarker.r, defaultMarker.g, defaultMarker.b, 100, false, true, 2, false, false, false, false)
                end
            end

            if (GetDistanceBetweenCoords(coords, garageParkingCircle.x, garageParkingCircle.y, garageParkingCircle.z, true) < Config.DrawDistance) then
                DrawMarker(marker.Type, garageParkingCircle.x, garageParkingCircle.y, garageParkingCircle.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, garageMarker.x, garageMarker.y, garageMarker.z, garageMarker.r, garageMarker.g, garageMarker.b, 100, false, true, 2, false, false, false, false)
            end

            if (GetDistanceBetweenCoords(coords, clothingCircle.x, clothingCircle.y, clothingCircle.z, true) < Config.DrawDistance) then
                DrawMarker(marker.Type, clothingCircle.x, clothingCircle.y, clothingCircle.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, clothingMarker.x, clothingMarker.y, clothingMarker.z, clothingMarker.r, clothingMarker.g, clothingMarker.b, 100, false, true, 2, false, false, false, false)
            end

            if (GetDistanceBetweenCoords(coords, safeCircle.x, safeCircle.y, safeCircle.z, true) < Config.DrawDistance) then
                DrawMarker(marker.Type, safeCircle.x, safeCircle.y, safeCircle.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, safeMarker.x, safeMarker.y, safeMarker.z, safeMarker.r, safeMarker.g, safeMarker.b, 100, false, true, 2, false, false, false, false)
            end

            if (GetDistanceBetweenCoords(coords, weaponSafeCircle.x, weaponSafeCircle.y, weaponSafeCircle.z, true) < Config.DrawDistance) then
                DrawMarker(marker.Type, weaponSafeCircle.x, weaponSafeCircle.y, weaponSafeCircle.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, safeMarker.x, safeMarker.y, safeMarker.z, safeMarker.r, safeMarker.g, safeMarker.b, 100, false, true, 2, false, false, false, false)
            end
            
            if (HasAccess(Config.RequiredGradesForBossActions) and GetDistanceBetweenCoords(coords, bossSafeCircle.x, bossSafeCircle.y, bossSafeCircle.z, true) < Config.DrawDistance) then
                DrawMarker(marker.Type, bossSafeCircle.x, bossSafeCircle.y, bossSafeCircle.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, bossMarker.x, bossMarker.y, bossMarker.z, bossMarker.r, bossMarker.g, bossMarker.b, 100, false, true, 2, false, false, false, false)
            end

            if (GetDistanceBetweenCoords(coords, warehouseCircle.x, warehouseCircle.y, warehouseCircle.z, true) < Config.DrawDistance) then
                DrawMarker(marker.Type, warehouseCircle.x, warehouseCircle.y, warehouseCircle.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, warehouse.x, warehouse.y, warehouse.z, warehouse.r, warehouse.g, warehouse.b, 100, false, true, 2, false, false, false, false)
            end
        end

        Citizen.Wait(0)
    end
end)

-- Enter markers
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local isInMarker = false

        if (PlayerContainsJob()) then
            local playerPed = GetPlayerPed(-1)
            local coords = GetEntityCoords(playerPed)

            -- Markers
            local marker = Config.Marker
            local defaultMarker = marker.Default
            local garageMarker = marker.Garage
            local clothingMarker = marker.Clothing
            local safeMarker = marker.Safe
            local bossMarker = marker.Boss
            local warehouse = marker.Warehouse

            -- Locations
            local vehicleCircle = Config.Locations.VehicleCircleLocation
            local garageParkingCircle = Config.Locations.GarageParkingCircleLocation
            local clothingCircle = Config.Locations.ClothingCircleLocation
            local safeCircle = Config.Locations.SafeCircleLocation
            local weaponSafeCircle = Config.Locations.WeaponSafeCircleLocation
            local bossSafeCircle = Config.Locations.BossCircleLocation
            local warehouseCircle = Config.Locations.WarehouseLocation
            
            if (Config.CanSpawnCars) then
                if (GetDistanceBetweenCoords(coords, vehicleCircle.x, vehicleCircle.y, vehicleCircle.z, true) < defaultMarker.x) then
                    isInMarker = true
                    CurrentAction = Action.SpawnVehicle
                end
            end

            if (GetDistanceBetweenCoords(coords, garageParkingCircle.x, garageParkingCircle.y, garageParkingCircle.z, true) < garageMarker.x) then
                isInMarker = true
                CurrentAction = Action.ParkInGarage
            end

            if (GetDistanceBetweenCoords(coords, clothingCircle.x, clothingCircle.y, clothingCircle.z, true) < clothingMarker.x) then
                isInMarker = true
                CurrentAction = Action.ChangeClothes
            end

            if (GetDistanceBetweenCoords(coords, safeCircle.x, safeCircle.y, safeCircle.z, true) < safeMarker.x) then
                isInMarker = true
                CurrentAction = Action.OpenSafe
            end

            if (GetDistanceBetweenCoords(coords, weaponSafeCircle.x, weaponSafeCircle.y, weaponSafeCircle.z, true) < safeMarker.x) then
                isInMarker = true
                CurrentAction = Action.OpenWeaponSafe
            end

            if (HasAccess(Config.RequiredGradesForBossActions) and GetDistanceBetweenCoords(coords, bossSafeCircle.x, bossSafeCircle.y, bossSafeCircle.z, true) < bossMarker.x) then
                isInMarker = true
                CurrentAction = Action.BossActions
            end

            if (GetDistanceBetweenCoords(coords, warehouseCircle.x, warehouseCircle.y, warehouseCircle.z, true) < warehouse.x) then
                isInMarker = true
                CurrentAction = Action.Warehouse
            end

            if (isInMarker and LastAction == nil) then
                TriggerEvent('ml_' .. Config.JobName .. 'job:hasEnteredMarker')
            end

            if (not isInMarker and LastAction ~= nil) then
                TriggerEvent('ml_' .. Config.JobName .. 'job:hasExitedMarker')
            end
        end
        
        Citizen.Wait(0)
    end
end)

-- Key Controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if CurrentAction ~= nil then
            if IsControlJustReleased(0, Keys['E']) then
                LastAction = CurrentAction
                CurrentAction = nil

                if (Config.CanSpawnCars and IsCurrentAction(Action.SpawnVehicle) or
                    IsLastAction(Action.SpawnVehicle)) then
                    OpenVehicleMenu()
                end

                if (IsCurrentAction(Action.ParkInGarage) or
                    IsLastAction(Action.ParkInGarage)) then
                    local playerPed  = GetPlayerPed(-1)
                    if IsPedInAnyVehicle(playerPed,  false) then
                        local vehicle      = GetVehiclePedIsIn(playerPed, false)

                        if (GetPedInVehicleSeat(vehicle, -1) ~= playerPed) then
                            ESX.ShowNotification(_U('must_seat_driver'))
                            return
                        end

                        ESX.Game.DeleteVehicle(vehicle)
                    else
                        ESX.ShowNotification(_U('no_vehicle_to_enter'))
                    end
                end

                if (Config.CanChangeClothes and IsCurrentAction(Action.ChangeClothes) or
                    IsLastAction(Action.ChangeClothes)) then
                    OpenClothingMenu()
                end

                if (IsCurrentAction(Action.OpenSafe) or
                    IsLastAction(Action.OpenSafe)) then
                    OpenSafeMenu()
                end

                if (IsCurrentAction(Action.OpenWeaponSafe) or
                    IsLastAction(Action.OpenWeaponSafe)) then
                    OpenWeaponSafeMenu()
                end

                if (HasAccess(Config.RequiredGradesForBossActions) and IsCurrentAction(Action.BossActions) or
                    HasAccess(Config.RequiredGradesForBossActions) and IsLastAction(Action.BossActions)) then
                    OpenBossMenu()
                end

                if (IsCurrentAction(Action.Warehouse) or
                    IsLastAction(Action.Warehouse)) then
                    OpenWarehouseMenu()
                end

                CurrentAction = nil
            end
		else
			Citizen.Wait(0)
        end
	end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if (IsControlPressed(0, Keys['F6']) and JobIsPrimaryJob()) then
            OpenActionMenu()
        end

        if (IsControlPressed(0, Keys['F5']) and JobIsSecondaryJob()) then
            OpenActionMenu()
        end
    end
end)

-- Update Blips when first loaded
Citizen.CreateThread(function()
    Citizen.Wait(0)

    while not BlipsUpdated do
        if (ESX ~= nil and PlayerData ~= nil) then
            TriggerEvent('ml_' .. Config.JobName .. 'job:updateBlip')
        end
    end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

        DisableControls(IsHandcuffed)

        if IsHandcuffed and not IsEntityPlayingAnim(GetPlayerPed(PlayerId()), "mp_arresting", "idle", 3) then
            Citizen.Wait(100)
            TaskPlayAnim(GetPlayerPed(PlayerId()), "mp_arresting", "idle", 8.0, -8, -1, 49, 0, 0, 0, 0)
		end
	end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if Drag then
            WasDragged = true
            AttachEntityToEntity(PlayerPedId(-1), GetPlayerPed(GetPlayerFromServerId(DraggedBy)), 11816, 0.35, 0.35, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
        else
            if not IsPedInParachuteFreeFall(PlayerPedId(-1)) and WasDragged then
                WasDragged = false
                DetachEntity(PlayerPedId(-1), true, false)
            end
        end
    end
end)

AddEventHandler('ml_' .. Config.JobName .. 'job:hasEnteredMarker', function()
    if (LastAction == nil) then
        if (Config.CanSpawnCars and IsCurrentAction(Action.SpawnVehicle)) then
            ESX.ShowHelpNotification(_U('spawn_' .. Config.JobName .. '_vehicle'))
        end

        if (IsCurrentAction(Action.ParkInGarage)) then
            ESX.ShowHelpNotification(_U('parking_' .. Config.JobName .. '_garage'))
        end

        if (IsCurrentAction(Action.ChangeClothes)) then
            ESX.ShowHelpNotification(_U('open_' .. Config.JobName .. '_clothes'))
        end

        if (IsCurrentAction(Action.OpenSafe)) then
            ESX.ShowHelpNotification(_U('open_' .. Config.JobName .. '_safe'))
        end

        if (IsCurrentAction(Action.OpenWeaponSafe)) then
            ESX.ShowHelpNotification(_U('open_' .. Config.JobName .. '_weapon_safe'))
        end

        if (HasAccess(Config.RequiredGradesForBossActions) and IsCurrentAction(Action.BossActions)) then
            ESX.ShowHelpNotification(_U('open_' .. Config.JobName .. '_boss_menu'))
        end

        if (IsCurrentAction(Action.Warehouse)) then
            ESX.ShowHelpNotification(_U('open_' .. Config.JobName .. '_warehouse'))
        end
    end
end)

AddEventHandler('ml_' .. Config.JobName .. 'job:hasExitedMarker', function()
	ESX.UI.Menu.CloseAll()
    CurrentAction = nil
    LastAction = nil
end)

RegisterNetEvent('ml_' .. Config.JobName .. 'job:updateBlip')
AddEventHandler('ml_' .. Config.JobName .. 'job:updateBlip', function()
    for _, playerBlip in pairs(Blips) do
        RemoveBlip(playerBlip)
    end

    Blips = {}

    if (PlayerContainsJob()) then
        ESX.TriggerServerCallback('mlx_society:getOnlinePlayers', function(players)
            for _, player in pairs(players) do
                if (player.job ~= nil and string.lower(player.job.name) == string.lower(Config.JobName)) or
                    (player.job2 ~= nil and string.lower(player.job2.name) == string.lower(Config.JobName)) then
                    local playerId = GetPlayerFromServerId(player.source)

                    if (NetworkIsPlayerActive(playerId)) then
                        CreateJobBlip(playerId)
                    end
                end
            end
        end)
    end

    BlipsUpdated = true
end)

RegisterNetEvent('ml_' .. Config.JobName .. 'job:handcuff')
AddEventHandler('ml_' .. Config.JobName .. 'job:handcuff', function()
    local playerPed = GetPlayerPed(-1)

    if (DoesEntityExist(playerPed)) then
        if (IsHandcuffed) then
                ClearPedSecondaryTask(playerPed)
                SetEnableHandcuffs(playerPed, false)
                SetCurrentPedWeapon(playerPed, GetHashKey("WEAPON_UNARMED"), true)
                SetPedCanPlayGestureAnims(playerPed, true)
                IsHandcuffed = false
        else
            if IsEntityPlayingAnim(playerPed, "mp_arresting", "idle", 3) then
                ClearPedSecondaryTask(playerPed)
                SetEnableHandcuffs(playerPed, false)
                SetCurrentPedWeapon(playerPed, GetHashKey("WEAPON_UNARMED"), true)
                SetPedCanPlayGestureAnims(playerPed, false)
                IsHandcuffed = false
            else
                RequestAnimDict("mp_arresting")
                while not HasAnimDictLoaded("mp_arresting") do
                    Citizen.Wait(100)
                end

                TaskPlayAnim(playerPed, "mp_arresting", "idle", 8.0, -8, -1, 49, 0, 0, 0, 0)
                SetEnableHandcuffs(playerPed, true)
                SetCurrentPedWeapon(playerPed, GetHashKey("WEAPON_UNARMED"), true)
                IsHandcuffed = true
            end
        end
    end
end)

RegisterNetEvent('ml_' .. Config.JobName .. 'job:drag')
AddEventHandler('ml_' .. Config.JobName .. 'job:drag', function(dragger)
    DraggedBy = dragger
    Drag = not Drag
end)

function DisableControls(status)
    if (status) then
        ClearPedSecondaryTask(playerPed)
        SetEnableHandcuffs(playerPed, false)
        SetCurrentPedWeapon(playerPed, GetHashKey("WEAPON_UNARMED"), true)
        SetPedCanPlayGestureAnims(playerPed, true)

        SetPedPathCanUseLadders(playerPed, false)

        if IsPedInAnyVehicle(playerPed, false) then
            DisableControlAction(0, 59, true)
        end

        DisableControlAction(0, 142, status)
        DisableControlAction(0, 30,  status)
        DisableControlAction(0, 31,  status)
        DisableControlAction(0, 170, status)
        DisableControlAction(0, 167, status)
        DisableControlAction(0, 5, status)
        DisableControlAction(0, 6, status)
        DisableControlAction(0, 45, status)
        DisableControlAction(0, 142, status)
        DisableControlAction(0, 141, status)
        DisableControlAction(0, 140, status)
        DisableControlAction(0, 263, status)
        DisableControlAction(0, 264, status)
    end
end

function CreateJobBlip(playerId)
    local currentPlayer = PlayerPedId(-1)
    local playerPed = GetPlayerPed(playerId)
    local playerBlip = GetBlipFromEntity(playerPed)

    if (DoesBlipExist(playerBlip) == false and currentPlayer ~= playerPed) then
        playerBlip = AddBlipForEntity(playerPed)

        SetBlipSprite(playerBlip, 1)
        ShowHeadingIndicatorOnBlip(playerBlip, true)
        SetBlipRotation(playerBlip, math.ceil(GetEntityHeading(ped)))
		SetBlipNameToPlayerName(playerBlip, playerId)
		SetBlipScale(playerBlip, 0.85)
        SetBlipAsShortRange(playerBlip, true)

        table.insert(Blips, playerBlip)
    end
end

function RemoveVehicles()
    local spots = Config.Locations.GarageSpotLocations

    for i = 1, #spots, 1 do
        local veh, distance = ESX.Game.GetClosestVehicle(spots[i])

        if (veh ~= nil and DoesEntityExist(veh) and distance <= 5.0) then
            DeleteEntity(veh)
        end
    end
end

function PlayerContainsJob()
    return (PlayerData.job ~= nil and string.lower(PlayerData.job.name) == string.lower(Config.JobName)) or
        (PlayerData.job2 ~= nil and string.lower(PlayerData.job2.name) == string.lower(Config.JobName))
end

function JobIsPrimaryJob()
    return (PlayerData.job ~= nil and string.lower(PlayerData.job.name) == string.lower(Config.JobName))
end

function JobIsSecondaryJob()
    return (PlayerData.job2 ~= nil and string.lower(PlayerData.job2.name) == string.lower(Config.JobName))
end


function IsCurrentAction(action)
    return CurrentAction ~= nil and string.lower(CurrentAction) == string.lower(action)
end

function IsLastAction(action)
    return LastAction ~= nil and string.lower(LastAction) == string.lower(action)
end

function HasAccess(array, default)
    local access = default

    if (array == nil) then
        return access
    end

    if(#array > 0) then
        access = false

        for i = 1, #array, 1 do
            if (array[i] ~= nil and HasGrade(array[i])) then
                access = true
            end
        end
    end

    return access
end

function HasGrade(grade)
    local playerGrade = nil

    if (PlayerData ~= nil and PlayerData.job ~= nil and string.lower(PlayerData.job.name) == string.lower(Config.JobName)) then
        playerGrade = string.lower(PlayerData.job.grade_name)
    elseif (PlayerData ~= nil and PlayerData.job2 ~= nil and string.lower(PlayerData.job2.name) == string.lower(Config.JobName)) then
        playerGrade = string.lower(PlayerData.job2.grade_name)
    end

    return string.lower(grade) == playerGrade
end

function LoadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end 

RegisterNetEvent('mlx:setJob')
AddEventHandler('mlx:setJob', function(job)
	PlayerData.job = job
end)

RegisterNetEvent('mlx:setJob2')
AddEventHandler('mlx:setJob2', function(job)
	PlayerData.job2 = job
end)