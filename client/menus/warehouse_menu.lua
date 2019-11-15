local PlayerData            = {}

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

function OpenWarehouseMenu()
    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open('ml', GetCurrentResourceName(), 'warehouse_menu',
    {
        title       = _U('warehouse_menu'),
        align       = 'top-left',
        css         = Config.JobName,
        elements    = {
            { label = _U('warehouse_vehicle_remove'), value = 'remove' },
            { label = _U('warehouse_vehicle_add'), value = 'add' }
        }
    },
    function (data, menu)
        local playerPed = GetPlayerPed(-1)

        if not (IsPedInAnyVehicle(playerPed, false)) then
            ESX.ShowNotification(_U('no_vehicle'))
            return
        end

        local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), true)
        local properties = ESX.Game.GetVehicleProperties(vehicle)

        if (data.current.value == 'remove') then
            local plate = (properties.plate or '')

            ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:getTrunk', function(trunkData)
                local elements = {
                    { label = _U('license_plate', plate), value = '', disabled = true },
                }

                if (#trunkData.items > 0) then
                    table.insert(elements, { label = _U('products'), value = '', disabled = true })
                    
                    for _, item in pairs(trunkData.items) do
                        if (item.count > 0) then
                            local productLabel = '<strong>' .. item.label .. '</strong> ' .. item.count

                            table.insert(elements, { label = productLabel, value = item.name })
                        end
                    end
                end

                if (trunkData.blackMoney > 0) then
                    table.insert(elements, { label = _U('black_money_label'), value = '', disabled = true })
                    table.insert(elements, { label = _U('black_money', format_num(trunkData.blackMoney, 0, '€ ')), value = 'black_money' })
                end

                if (#trunkData.weapons > 0) then
                    table.insert(elements, { label = _U('weapons_label'), value = '', disabled = true })

                    for _, weapon in pairs(trunkData.weapons) do
                        local label = ESX.GetWeaponLabel(weapon.name)
                        table.insert(elements, { label = _U('trunk_weapon', label, weapon.ammo ), value = weapon.name })
                    end
                end

                ESX.UI.Menu.Open('ml', GetCurrentResourceName(), 'warehouse_remove',
                {
                    title       = _U('warehouse_remove'),
                    align       = 'top-left',
                    css         = Config.JobName,
                    elements    = elements
                },
                function(data2, menu2)
                    ESX.UI.Menu.Open(
                        'ml_dialog',
                        GetCurrentResourceName(),
                        'warehouse_remove_amount',
                        {
                            title   = _U('warehouse_remove_amount'),
                            css     = Config.JobName,
                            submit  = _U('save')
                        },
                        function(data3, menu3)
                        end,
                        function(data3, menu3)
                            menu3.close()
                        end)
                end,
                function(data2, menu2)
                    menu2.close()
                end)
            end, plate)
        end
    end,
    function(data, menu)
        menu.close()
    end)
end

RegisterNetEvent('mlx:setJob')
AddEventHandler('mlx:setJob', function(job)
	PlayerData.job = job
end)

RegisterNetEvent('mlx:setJob2')
AddEventHandler('mlx:setJob2', function(job)
	PlayerData.job2 = job
end)