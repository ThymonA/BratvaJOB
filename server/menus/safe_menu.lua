ESX = nil

TriggerEvent('mlx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('ml_' .. Config.JobName .. 'job:getInventory', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    if (xPlayer == nil and cb ~= null) then
        cb({
            blackMoney = 0,
            items = {},
            weapons = {},
            player = {
                name = ''
            }
        })

        return
    end

    local blackMoney = 0
    local blackAccount = (xPlayer.getAccount('black_money') or 0)

    if (blackAccount ~= 0) then
        blackMoney = blackAccount.money
    end

    if (xPlayer ~= nil) then
        if (cb ~= nil) then
            cb({
                blackMoney = blackMoney,
                items = xPlayer.inventory,
                weapons = xPlayer.loadout,
                player = xPlayer
            })

            return
        end
    end

    if (cb ~= null) then
        cb({
            blackMoney = 0,
            items = {},
            weapons = {},
            player = {
                name = ''
            }
        })
    end
end)

ESX.RegisterServerCallback('ml_' .. Config.JobName .. 'job:storeItem', function(source, cb, itemName, count)
    count = tonumber(count) or 0

    local xPlayer = ESX.GetPlayerFromId(source)

    if (xPlayer == nil and cb ~= nil) then
        cb(false, 'no_player')
        return
    end

    if (itemName == 'black_money') then
        TriggerEvent('mlx_addonaccount:getSharedAccount', 'society_' .. Config.JobName .. '_black_money', function(account)
            local blackMoneyAccount = nil

            for _, _account in pairs(xPlayer.accounts) do
                if (_account.name == 'black_money') then
                    blackMoneyAccount = _account
                end
            end

            if (blackMoneyAccount == nil) then
                cb(false, 'no_player')
                return
            end

            if (blackMoneyAccount.money < count or count <= 0) then
                cb(false, 'no_black_money')
            end

            xPlayer.removeAccountMoney('black_money', count)
            account.addMoney(count)

            LogToDiscord(
                Config.DiscordLogs.MoneyLog,
                _U('discord_deposit_black_money', Config.JobLabel), 
                xPlayer.name .. ' > ' .. format_num(count, 0, '€ ') .. ' ' .. _U('discord_black_money'),
                Config.DiscordLogs.Colors.Green,
                xPlayer.identifier)

            cb(true, _U('blackmoney'))
            return
        end)
    end

    TriggerEvent('mlx_addoninventory:getSharedInventory', 'society_' .. Config.JobName, function(inventory)
        local item = inventory.getItem(itemName)
        local playerItem = xPlayer.getInventoryItem(itemName)

        if (item == nil or playerItem == nil or playerItem.count < count) then
            cb(false, 'no_item')
            return
        end

        if (not playerItem.canRemove) then
            cb(false, 'cant_remove_item')
            return
        end

        xPlayer.removeInventoryItem(playerItem.name, count)
        inventory.addItem(item.name, count)

        LogToDiscord(
            Config.DiscordLogs.SafeLog,
            _U('discord_deposit_item', Config.JobLabel),
            xPlayer.name .. ' > ' .. format_num(count, 0, '') .. 'x ' .. playerItem.label,
            Config.DiscordLogs.Colors.Green,
            xPlayer.identifier)

        cb(true, playerItem.label)
        return
    end)
end)

ESX.RegisterServerCallback('ml_' .. Config.JobName .. 'job:getItems', function(source, cb)
    TriggerEvent('mlx_addoninventory:getSharedInventory', 'society_' .. Config.JobName, function(inventory)
        cb((inventory.items or {}))
    end)
end)

ESX.RegisterServerCallback('ml_' .. Config.JobName .. 'job:getItem', function(source, cb, itemName, count)
    count = tonumber(count) or 0

    local xPlayer = ESX.GetPlayerFromId(source)

    if (xPlayer == nil and cb ~= nil) then
        cb(false, 'no_player')
        return
    end

    if (itemName == 'black_money') then
        TriggerEvent('mlx_addonaccount:getSharedAccount', 'society_' .. Config.JobName .. '_black_money', function(account)
            local blackMoneyAccount = nil

            for _, account in pairs(xPlayer.accounts) do
                if (account.name == 'black_money') then
                    blackMoneyAccount = account
                end
            end

            if (blackMoneyAccount == nil) then
                cb(false, 'no_player')
                return
            end

            if (blackMoneyAccount.money < count or count <= 0) then
                cb(false, 'no_black_money')
            end

            account.removeMoney(count)
            xPlayer.addAccountMoney('black_money', count)

            LogToDiscord(
                Config.DiscordLogs.MoneyLog,
                _U('discord_deposit_black_money', Config.JobLabel), 
                xPlayer.name .. ' > ' .. format_num(count, 0, '€ ') .. ' ' .. _U('discord_black_money'),
                Config.DiscordLogs.Colors.Green,
                xPlayer.identifier)

            cb(true, _U('blackmoney'))
            return
        end)
    end

    TriggerEvent('mlx_addoninventory:getSharedInventory', 'society_' .. Config.JobName, function(inventory)
        local item = inventory.getItem(itemName)
        local playerItem = xPlayer.getInventoryItem(item.name)

        inventory.removeItem(item.name, count)
        xPlayer.addInventoryItem(item.name, count)

        if (playerItem == nil) then
            playerItem = xPlayer.getInventoryItem(item.name)
        end

        LogToDiscord(
            Config.DiscordLogs.SafeLog,
            _U('discord_withdraw_item', Config.JobLabel),
            xPlayer.name .. ' > ' .. format_num(count, 0, '') .. 'x ' .. playerItem.label,
            Config.DiscordLogs.Colors.Red,
            xPlayer.identifier)

        cb(true, playerItem.label)
        return
    end)
end)

ESX.RegisterServerCallback('ml_' .. Config.JobName .. 'job:getBlackMoney', function(source, cb)
    TriggerEvent('mlx_addonaccount:getSharedAccount', 'society_' .. Config.JobName .. '_black_money', function(account)
        local blackMoneyAccount = nil

        for _, account in pairs(xPlayer.accounts) do
            if (account.name == 'black_money') then
                blackMoneyAccount = account
            end
        end

        if (blackMoneyAccount == nil or blackMoneyAccount.money <= 0) then
            cb(0)
            return
        end

        cb(account.money)
    end)
end)

ESX.RegisterServerCallback('ml_' .. Config.JobName .. 'job:removeBlackMoney', function(source, cb, count)
    count = tonumber(count) or 0

    local xPlayer = ESX.GetPlayerFromId(source)

    if (xPlayer == nil and cb ~= nil) then
        cb(false, 'no_player')
        return
    end

    TriggerEvent('mlx_addonaccount:getSharedAccount', 'society_' .. Config.JobName .. '_black_money', function(account)
        local blackMoneyAccount = nil

        for _, account in pairs(xPlayer.accounts) do
            if (account.name == 'black_money') then
                blackMoneyAccount = account
            end
        end

        if (blackMoneyAccount == nil or blackMoneyAccount.money <= 0) then
            cb(false, 'no_money')
            return
        end

        LogToDiscord(
            Config.DiscordLogs.MoneyLog,
            _U('discord_deposit_black_money', Config.JobLabel), 
            xPlayer.name .. ' > ' .. format_num(amount, 0, '€ ') .. ' ' .. _U('discord_black_money'),
            Config.DiscordLogs.Colors.Green,
            xPlayer.identifier)

        account.removeMoney(count)
        xPlayer.addAccountMoney('black_money', count)

        cb(true, '')
    end)
end)