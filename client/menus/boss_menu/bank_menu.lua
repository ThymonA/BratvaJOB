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

function OpenBankMenu()
    ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:getBalance', function(balance)
        ESX.UI.Menu.Open(
            'ml',
            GetCurrentResourceName(),
            'bank_menu',
            {
                title       = _U('bank_menu'),
                align       = 'top-left',
                css         = Config.JobName,
                elements    = {
                    { label = _U('balance_money', format_num(balance.money, 0, '€ ')), value = '', disabled = true },
                    { label = _U('balance_black_money', format_num(balance.black_money, 0, '€ ')), value = '', disabled = true },
                    { label = _U('header_actions'), value = '', disabled = true },
                    { label = _U('get_money'), value = 'get_money' },
                    { label = _U('put_money'), value = 'put_money' },
                    { label = _U('get_black_money'), value = 'get_black_money' },
                }
            },
            function(data, menu)
                if (data.current.value == 'get_money') then
                    GetMoneyMenu()
                elseif (data.current.value == 'put_money') then
                    PutMoneyMenu()
                elseif (data.current.value == 'get_black_money') then
                    GetBlackMoneyMenu()
                end
            end,
            function(data, menu)
                menu.close()
            end)
    end)
end

function GetMoneyMenu()
    ESX.UI.Menu.Open(
        'ml_dialog',
        GetCurrentResourceName(),
        'withdraw_money',
        {
            title = _U('withdraw_money'),
            submit = _U('withdraw'),
            css = Config.JobName
        },
        function(data, menu)
            if (data.value == nil or
                data.value == '') then
                ESX.ShowNotification(_U('invalid_amount'))
            end

            local amount = tonumber(data.value)

            if (amount == nil or amount <= 0) then
                ESX.ShowNotification(_U('invalid_amount'))
            else
                ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:withdrawMoney', function()
                    menu.close()
                    OpenBankMenu()
                end, amount)
            end
        end,
        function(data, menu)
            menu.close()
        end)
end

function PutMoneyMenu()
    ESX.UI.Menu.Open(
        'ml_dialog',
        GetCurrentResourceName(),
        'put_money',
        {
            title = _U('put_money'),
            submit = _U('deposit'),
            css = Config.JobName
        },
        function(data, menu)
            if (data.value == nil or
                data.value == '') then
                ESX.ShowNotification(_U('invalid_amount'))
            end

            local amount = tonumber(data.value)

            if (amount == nil or amount <= 0) then
                ESX.ShowNotification(_U('invalid_amount'))
            else
                ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:depositMoney', function()
                    menu.close()
                    OpenBankMenu()
                end, amount)
            end
        end,
        function(data, menu)
            menu.close()
        end)
end

function GetBlackMoneyMenu()
    ESX.UI.Menu.Open(
        'ml_dialog',
        GetCurrentResourceName(),
        'withdraw_black_money',
        {
            title = _U('get_black_money'),
            submit = _U('withdraw'),
            css = Config.JobName
        },
        function(data, menu)
            if (data.value == nil or
                data.value == '') then
                ESX.ShowNotification(_U('invalid_amount'))
            end

            local amount = tonumber(data.value)

            if (amount == nil or amount <= 0) then
                ESX.ShowNotification(_U('invalid_amount'))
            else
                ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:withdrawBlackMoney', function()
                    menu.close()
                    OpenBankMenu()
                end, amount)
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