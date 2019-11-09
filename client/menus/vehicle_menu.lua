ESX                         = nil

Citizen.CreateThread(function()
    while ESX == nil do
      TriggerEvent('mlx:getSharedObject', function(obj) ESX = obj end)
      Citizen.Wait(0)
    end
  end)

function OpenVehicleMenu()
    local vehicles = Config.SpawnVehicles

    ESX.UI.Menu.CloseAll()

    if (Config.CanSpawnCars) then
        local elements = {}

        for i = 1, #vehicles, 1 do
            local vehicleName = vehicles[i].name
            local vehicleModel = vehicles[i].model

            table.insert(elements, { label = vehicleName, value = vehicleModel })
        end

        ESX.UI.Menu.Open(
            'default', GetCurrentResourceName(), 'vehicle_menu',
            {
                title       = _U('vehicle_menu'),
                align       = 'top-left',
                css         = Config.JobName,
                elements    = elements
            },
            function(data, menu)
                local model = data.current.value
                local veh, distence = ESX.Game.GetClosestVehicle(Config.Locations.VehicleSpawnLocation)

                if (veh ~= nil and DoesEntityExist(veh) and distence < Config.SpawnDistanceSpawnPoint) then
                    ESX.ShowNotification(_U('cant_spawn_entity'))
                    return
                end

                local hash = GetHashKey(model)
                
                RequestModel(hash)

                Citizen.CreateThread(function() 
                    local waiting = 0

                    while not HasModelLoaded(hash) do
                        waiting = waiting + 100
                        Citizen.Wait(100)
                        if waiting > 5000 then
                            ESX.ShowNotification(_U('cant_spawn_entity'))
                            break
                        end
                    end

                    local veh = CreateVehicle(
                        model,
                        Config.Locations.VehicleSpawnLocation.x,
                        Config.Locations.VehicleSpawnLocation.y,
                        Config.Locations.VehicleSpawnLocation.z,
                        Config.Locations.VehicleSpawnLocation.h,
                        1, 0)

                    while not DoesEntityExist(veh) do
                        Citizen.Wait(0)
                    end

                    TaskWarpPedIntoVehicle(GetPlayerPed(-1), veh, -1)
                    SetVehRadioStation(veh, "OFF")
                    
                    Config.VehicleProps['windowTint'] = Config.VehicleProps.modWindows

                    ESX.Game.SetVehicleProperties(veh, Config.VehicleProps)
                end)
            end
        )
    end
end