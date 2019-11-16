ESX = nil

TriggerEvent('mlx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('ml_' .. Config.JobName .. 'job:getTargetPlayerInfo', function(source, cb, targetPlayer)
    local xTarget = ESX.GetPlayerFromId(targetPlayer)

    TriggerClientEvent('mlx:showNotification', xTarget.source, _U('your_id_has_stolen', Config.JobLabel))

    MySQL.Async.fetchAll('SELECT * FROM `users` WHERE `identifier` = @identifier', {
        ['@identifier'] = xTarget.identifier
    }, function(results)
        local user = results[1]

        if (user ~= nil) then
            cb({
                name        = xTarget.name,
                firstname   = user.firstname,
                lastname    = user.lastname,
                sex         = user.sex,
                dateOfBirth = user.dateofbirth,
                height      = user.height
            })
        else
            cb({
                name        = '',
                firstname   = '',
                lastname    = '',
                sex         = 'm',
                dateOfBirth = '',
                height      = 200
            })
        end
    end)
end)

ESX.RegisterServerCallback('ml_' .. Config.JobName .. 'job:getPlayerInventory', function(source, cb, targetPlayer)
    local xTarget = ESX.GetPlayerFromId(targetPlayer)

    TriggerClientEvent('mlx:showNotification', xTarget.source, _U('check_player_inventory', Config.JobLabel))

    if (xTarget == nil and cb ~= null) then
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
    local blackAccount = (xTarget.getAccount('black_money') or 0)

    if (blackAccount ~= 0) then
        blackMoney = blackAccount.money
    end

    if (xTarget ~= nil) then
        if (cb ~= nil) then
            cb({
                blackMoney = blackMoney,
                items = xTarget.inventory,
                weapons = xTarget.loadout,
                player = xTarget
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

ESX.RegisterServerCallback('ml_' .. Config.JobName .. 'job:stealItemFromPlayer', function(source, cb, targetPlayer, item_name)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(targetPlayer)

    if (xTarget == nil) then
        cb(false, 'no_player', format_num(0, 0, '€ '))
        return
    end

    if (item_name == 'black_money') then
        local blackMoneyAccount = nil

        for _, account in pairs(xTarget.accounts) do
            if (account.name == 'black_money') then
                blackMoneyAccount = account
            end
        end

        if (blackMoneyAccount == nil) then
            cb(false, 'no_player', format_num(0, 0, '€ '))
            return
        end

        local amount = blackMoneyAccount.money

        xTarget.removeAccountMoney('black_money', amount)
        xPlayer.addAccountMoney('black_money', amount)

        TriggerClientEvent('mlx:showNotification', xTarget.source, _U('black_money_stolen', Config.JobLabel, format_num(amount, 0, '€ ')))
        TriggerClientEvent('mlx:showNotification', xPlayer.source, _U('black_money_token', format_num(amount, 0, '€ '), xTarget.name))

        cb(true, _U('blackmoney'), format_num(amount, 0, '€ '))
        return
    end

    local item = xTarget.getInventoryItem(item_name)

    if (item ~= nil and item.count <= 0) then
        cb(false, 'no_item', format_num(amount, 0, ''))
        return
    end

    if (item ~= nil and item.count > 0) then
        xTarget.removeInventoryItem(item.name, item.count)
        xPlayer.addInventoryItem(item.name, item.count)

        TriggerClientEvent('mlx:showNotification', xTarget.source, _U('item_stolen', Config.JobLabel, format_num(item.count, 0, ''), item.label))
        TriggerClientEvent('mlx:showNotification', xPlayer.source, _U('item_token', format_num(item.count, 0, ''), item.label, xTarget.name))

        cb(true, item.label, format_num(item.count, 0, ''))
        return
    end

    if (xPlayer.loadout ~= nil) then
        for _, _weapon in pairs(xPlayer.loadout) do
            if (string.lower(_weapon.name) == string.lower(item_name)) then
                TriggerClientEvent('mlx:showNotification', xPlayer.source, _U('weapon_already_inv', _weapon.label))
                cb(false, 'already_exist', format_num(amount, 0, ''))
                return
            end
        end
    end

    local weapon = nil
    local weaponFound = false

    if (xTarget.loadout ~= nil) then
        for _, _weapon in pairs(xTarget.loadout) do
            if (string.lower(_weapon.name) == string.lower(item_name)) then
                weapon = _weapon
                weaponFound = true
            end
        end
    end

    if (weaponFound == false) then
        cb(false, 'no_item', format_num(amount, 0, ''))
        return
    end

    xTarget.removeWeapon(weapon.name, weapon.ammo)
    xPlayer.addWeapon(weapon.name, weapon.ammo)

    TriggerClientEvent('mlx:showNotification', xTarget.source, _U('weapon_stolen', Config.JobLabel, weapon.label, format_num(weapon.ammo, 0, '')))
    TriggerClientEvent('mlx:showNotification', xPlayer.source, _U('weapon_token', xTarget.name, weapon.label, format_num(weapon.ammo, 0, '')))

    cb(true, weapon.label, format_num(weapon.ammo, 0, ''))
end)

ESX.RegisterServerCallback('ml_' .. Config.JobName .. 'job:handcuffPlayer', function(source, cb, targetPlayer)
    local xTarget = ESX.GetPlayerFromId(targetPlayer)
    TriggerClientEvent('ml_' .. Config.JobName .. 'job:handcuff', xTarget.source)
    cb()
end)

ESX.RegisterServerCallback('ml_' .. Config.JobName .. 'job:drag', function(source, cb, targetPlayer)
	local xTarget = ESX.GetPlayerFromId(targetPlayer)
    TriggerClientEvent('ml_' .. Config.JobName .. 'job:drag', xTarget.source, source)
    cb()
end)