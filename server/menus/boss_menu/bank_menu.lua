ESX = nil

TriggerEvent('mlx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('ml_' .. Config.JobName .. 'job:withdrawMoney', function(source, cb, amount)
    local xPlayer = ESX.GetPlayerFromId(source)

	TriggerEvent('mlx_addonaccount:getSharedAccount', 'society_' .. Config.JobName, function(account)
		if amount > 0 and account.money >= amount then
			account.removeMoney(amount)
			xPlayer.addMoney(amount)

			LogToDiscord(
				Config.DiscordLogs.MoneyLog,
				_U('discord_withdraw_money', Config.JobLabel), 
				xPlayer.name .. ' > ' .. format_num(amount, 0, '€ ') .. ' ' .. _U('discord_money'),
				Config.DiscordLogs.Colors.Red,
				xPlayer.identifier)

			TriggerClientEvent('mlx:showNotification', xPlayer.source, _U('money_withdrawed', format_num(amount, 0, '€ '), Config.JobLabel))
		else
			TriggerClientEvent('mlx:showNotification', xPlayer.source, _U('invalid_amount'))
        end

        cb()
	end)
end)

ESX.RegisterServerCallback('ml_' .. Config.JobName .. 'job:depositMoney', function(source, cb, amount)
    local xPlayer = ESX.GetPlayerFromId(source)

	if amount > 0 and xPlayer.get('money') >= amount then
		TriggerEvent('mlx_addonaccount:getSharedAccount', 'society_' .. Config.JobName, function(account)
			xPlayer.removeMoney(amount)
			account.addMoney(amount)
		end)

		LogToDiscord(
			Config.DiscordLogs.MoneyLog,
			_U('discord_deposit_money', Config.JobLabel), 
			xPlayer.name .. ' > ' .. format_num(amount, 0, '€ ') .. ' ' .. _U('discord_money'),
			Config.DiscordLogs.Colors.Green,
			xPlayer.identifier)

		TriggerClientEvent('mlx:showNotification', xPlayer.source, _U('money_deposit', format_num(amount, 0, '€ '), Config.JobLabel))

	else
		TriggerClientEvent('mlx:showNotification', xPlayer.source, _U('invalid_amount'))
    end

    cb()
end)

ESX.RegisterServerCallback('ml_' .. Config.JobName .. 'job:withdrawBlackMoney', function(source, cb, amount)
    local xPlayer = ESX.GetPlayerFromId(source)

	TriggerEvent('mlx_addonaccount:getSharedAccount', 'society_' .. Config.JobName .. '_black_money', function(account)
		if amount > 0 and account.money >= amount then
			account.removeMoney(amount)
			xPlayer.addAccountMoney('black_money', amount)

			LogToDiscord(
				Config.DiscordLogs.MoneyLog,
				_U('discord_withdraw_black_money', Config.JobLabel), 
				xPlayer.name .. ' > ' .. format_num(amount, 0, '€ ') .. ' ' .. _U('discord_black_money'),
				Config.DiscordLogs.Colors.Red,
				xPlayer.identifier)

			TriggerClientEvent('mlx:showNotification', xPlayer.source, _U('black_money_withdrawed', format_num(amount, 0, '€ '), Config.JobLabel))
		else
			TriggerClientEvent('mlx:showNotification', xPlayer.source, _U('invalid_amount'))
        end
    end)

    cb()
end)

ESX.RegisterServerCallback('ml_' .. Config.JobName .. 'job:getBalance', function(source, cb)
    local result = {
        money = 0,
        black_money = 0
    }

	TriggerEvent('mlx_addonaccount:getSharedAccount', 'society_' .. Config.JobName, function(account)
		result.money = account.money
    end)

    TriggerEvent('mlx_addonaccount:getSharedAccount', 'society_' .. Config.JobName .. '_black_money', function(account)
		result.black_money = account.money
    end)

    cb(result)
end)