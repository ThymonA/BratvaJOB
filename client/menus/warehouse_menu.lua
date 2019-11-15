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

    local playerPed = GetPlayerPed(-1)

    if not (IsPedInAnyVehicle(playerPed, false)) then
        ESX.ShowNotification(_U('no_vehicle'))
        return
    end

    local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), true)
    local properties = ESX.Game.GetVehicleProperties(vehicle)

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
            if(data2.current.value == nil or
                data2.current.value == '') then
                return
            end

            ESX.TriggerServerCallback(
                'ml_' .. Config.JobName .. 'job:updateTrunkItem',
                function(done, msg, number)
                    if (done) then
                        ESX.ShowNotification(_U('put_all_products', number, msg, Config.JobLabel))
                        menu2.close()
                        OpenWarehouseMenu()
                    elseif (msg == 'no_player') then
                        ESX.ShowNotification(_U('no_player'))
                    elseif (msg == 'no_black_money') then
                        ESX.ShowNotification(_U('no_black_money'))
                    elseif (msg == 'no_black_money') then
                        ESX.ShowNotification(_U('no_item'))
                    elseif (msg == 'cant_remove_item') then
                        ESX.ShowNotification(_U('cant_remove_item'))
                    end
                end,
                plate,
                data2.current.value)
        end,
        function(data2, menu2)
            menu2.close()
        end)
    end, plate)
end

RegisterNetEvent('mlx:setJob')
AddEventHandler('mlx:setJob', function(job)
	PlayerData.job = job
end)

RegisterNetEvent('mlx:setJob2')
AddEventHandler('mlx:setJob2', function(job)
	PlayerData.job2 = job
end)