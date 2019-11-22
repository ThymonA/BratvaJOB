local PlayerData    = {}
ESX                 = nil

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

function OpenMoneyWashMenu()
    ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:getWashBalance', function(balance)
        ESX.UI.Menu.Open(
            'ml',
            GetCurrentResourceName(),
            'wash_menu',
            {
                title       = _U('wash_menu'),
                align       = 'top-left',
                css         = Config.JobName,
                elements    = {
                    { label = _U('balance_black_money', format_num(balance.black_money, 0, '€ ')), value = '', disabled = true },
                    { label = _U('wash_money', format_num(balance.wash_money, 0, '€ ')), value = '', disabled = true },
                    { label = _U('header_actions'), value = '', disabled = true },
                    { label = _U('wash_all_black_money', format_num(balance.black_money, 0, '€ ')), value = 'wash_all_black_money' },
                    { label = _U('wash_black_money'), value = 'wash_black_money' }
                }
            },
            function(data, menu)
                if (data.current.value == 'wash_all_black_money') then
                    ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:washAllMoney', function(done, error, money)
                        if (done) then
                            ESX.ShowNotification(_U('wash_money_amount', money))
                            menu.close()
                            OpenMoneyWashMenu()
                        else
                            ESX.ShowNotification(_U('wash_error'))
                            menu.close()
                            OpenMoneyWashMenu()
                        end
                    end)
                elseif (data.current.value == 'wash_black_money') then
                    ESX.UI.Menu.Open(
                        'ml_dialog',
                        GetCurrentResourceName(),
                        'wash_menu_amount',
                        {
                            title = _U('wash_amount'),
                            submit = _U('wash'),
                            css = Config.JobName
                        },
                        function(data2, menu2)
                            ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:washMoney', function(done, error, money)
                                if (done) then
                                    ESX.ShowNotification(_U('wash_money_amount', money))
                                    menu2.close()
                                    menu.close()
                                    OpenMoneyWashMenu()
                                elseif (error == 'invalid') then
                                    ESX.ShowNotification(_U('wash_invalid'))
                                    menu2.close()
                                    menu.close()
                                    OpenMoneyWashMenu()
                                else
                                    ESX.ShowNotification(_U('wash_error'))
                                    menu2.close()
                                    menu.close()
                                    OpenMoneyWashMenu()
                                end
                            end, data2.value)
                        end,
                        function(data2, menu2)
                            menu2.close()
                        end
                    )
                end
            end,
            function(data, menu)
                menu.close()
            end)
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