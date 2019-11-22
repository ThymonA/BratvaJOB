ESX = nil

TriggerEvent('mlx:getSharedObject', function(obj) ESX = obj end)

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('mlx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	WashTick()
end)

ESX.RegisterServerCallback('ml_' .. Config.JobName .. 'job:getWashBalance', function(source, cb)
    local result = {
        black_money = 0,
        wash_money = 0
    }

    TriggerEvent('mlx_addonaccount:getSharedAccount', 'society_' .. Config.JobName .. '_black_money', function(account)
		result.black_money = account.money
    end)

    TriggerEvent('mlx_addonaccount:getSharedAccount', 'society_' .. Config.JobName .. '_money_wash', function(account)
		result.wash_money = account.money
    end)

    cb(result)
end)

ESX.RegisterServerCallback('ml_' .. Config.JobName .. 'job:washAllMoney', function(source, cb)
    TriggerEvent('mlx_addonaccount:getSharedAccount', 'society_' .. Config.JobName .. '_black_money', function(blackMoneyAccount)
        if (blackMoneyAccount.money <= 0) then
            cb(false, 'no_money', format_num(0, 0, '€ '))
            return
        end

        TriggerEvent('mlx_addonaccount:getSharedAccount', 'society_' .. Config.JobName .. '_money_wash', function(washAccount)
            blackMoneyAccount.removeMoney(blackMoneyAccount.money)
            washAccount.addMoney(blackMoneyAccount.money)

            cb(true, 'added', format_num(blackMoneyAccount.money, 0, '€ '))
            return
        end)
    end)

    cb(false, 'no_money', format_num(0, 0, '€ '))
end)

ESX.RegisterServerCallback('ml_' .. Config.JobName .. 'job:washMoney', function(source, cb, amount)
    amount = tonumber(amount or '0')

    if (amount <= 0) then
        cb(false, 'invalid', format_num(0, 0, '€ '))
    end

    TriggerEvent('mlx_addonaccount:getSharedAccount', 'society_' .. Config.JobName .. '_black_money', function(blackMoneyAccount)
        if (blackMoneyAccount.money < amount) then
            cb(false, 'no_money', format_num(0, 0, '€ '))
            return
        end

        TriggerEvent('mlx_addonaccount:getSharedAccount', 'society_' .. Config.JobName .. '_money_wash', function(washAccount)
            blackMoneyAccount.removeMoney(amount)
            washAccount.addMoney(amount)

            cb(true, 'added', format_num(amount, 0, '€ '))
            return
        end)
    end)

    cb(false, 'no_money', format_num(0, 0, '€ '))
end)

function WashTick()
    TriggerEvent('mlx_addonaccount:getSharedAccount', 'society_' .. Config.JobName .. '_money_wash', function(moneyWashAccount)
        if (moneyWashAccount.money <= 0) then
            SetTimeout(60000, WashTick)
            return
        end

        TriggerEvent('mlx_addonaccount:getSharedAccount', 'society_' .. Config.JobName, function(accountMoney)
            if (moneyWashAccount.money <= (Config.WashEverySecond * 60)) then
                moneyWashAccount.removeMoney(moneyWashAccount.money)
                accountMoney.addMoney(moneyWashAccount.money)

                SetTimeout(60000, WashTick)
                return
            end

            local amount = Config.WashEverySecond * 60

            moneyWashAccount.removeMoney(amount)
            accountMoney.addMoney(amount)

            SetTimeout(60000, WashTick)
            return
        end)
    end)
end