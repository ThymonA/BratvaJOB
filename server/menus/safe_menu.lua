ESX = nil

TriggerEvent('mlx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('ml_' .. Config.JobName .. 'job:buyWeapon', function(source, cb, weapon_name)
    local weapon = nil

    for i = 1, #Config.Weapons, 1 do
        local weaponConfig = Config.Weapons[i]

        if (weaponConfig.name == weapon_name) then
            weapon = weaponConfig
        end
    end

    if (weapon ~= nil) then
        TriggerEvent('mlx_addonaccount:getSharedAccount', 'society_' .. Config.JobName, function(account)
            if (account == nil or account.money < weapon.price) then
                cb(false, weapon.price - account.money)
                return
            else
                TriggerEvent('mlx_datastore:getSharedDataStore', 'society_' .. Config.JobName, function(store)
                    local weapons = store.get('weapons')

                    if (weapons == nil or #weapons == 0) then
                        weapons = {}
                    end

                    local weaponFound = false

                    for i = 1, #weapons, 1 do
                        if (weapons[i].name == weapon.name) then
                            weapons[i].count = weapons[i].count + 1
                            weaponFound = true
                        end
                    end

                    if (not weaponFound) then
                        table.insert(weapons, {
                            name = weapon.name,
                            count = 1
                        })
                    end

                    store.set('weapons', weapons)

                    account.removeMoney(weapon.price)
                end)

                cb(true, weapon.price)
                return
            end
        end)
    else
    end
end)

ESX.RegisterServerCallback('ml_' .. Config.JobName .. 'job:getWeapon', function(source, cb)
    TriggerEvent('mlx_datastore:getSharedDataStore', 'society_' .. Config.JobName, function(store)
        local weapons = store.get('weapons')

        if weapons == nil then
            weapons = {}
        end

        cb(weapons)
    end)
end)

ESX.RegisterServerCallback('ml_' .. Config.JobName .. 'job:removeWeapon', function(source, cb, weapon_name)
    local xPlayer = ESX.GetPlayerFromId(source)

    if (xPlayer == nil) then
        cb(false, 'no_player')
        return
    end

    if (xPlayer.loadout ~= nil) then
        for _, weapon in pairs(xPlayer.loadout) do
            if (string.lower(weapon.name) == string.lower(weapon_name)) then
                cb(false, 'already_exist')
                return
            end
        end
    end

    TriggerEvent('mlx_datastore:getSharedDataStore', 'society_' .. Config.JobName, function(store)
        local weaponFound = false
        local weapons = store.get('weapons')

        if weapons == nil then
            cb(false, 'not_exist')
            return
        end

        for i = 0, #weapons, 1 do
            local weapon = weapons[i]
 
            if (weapon ~= nil and 
                string.lower(weapon.name) == string.lower(weapon_name)) then
                if (weapon.count <= 0) then
                    cb(false, 'not_exist')
                    return
                else
                    weapons[i].count = weapons[i].count - 1
                    weaponFound = true
                end
            end
        end

        if (not weaponFound) then
            cb(false, 'not_exist')
            return
        end

        store.set('weapons', weapons)

        xPlayer.addWeapon(weapon_name, 1000)

        cb(true, 'added')
    end)
end)

ESX.RegisterServerCallback('ml_' .. Config.JobName .. 'job:getPlayerWeapons', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    if (xPlayer == nil) then
        cb({})
        return
    end

    if (xPlayer.loadout ~= nil) then
        cb(xPlayer.loadout)
        return
    end

    cb({})
end)

ESX.RegisterServerCallback('ml_' .. Config.JobName .. 'job:putPlayerWeapon', function(source, cb, weapon_name)
    local xPlayer = ESX.GetPlayerFromId(source)

    if (xPlayer == nil) then
        cb(false)
        return
    end

    if (xPlayer.loadout ~= nil) then
        for _, weapon in pairs(xPlayer.loadout) do
            if (string.lower(weapon.name) == string.lower(weapon_name)) then
                TriggerEvent('mlx_datastore:getSharedDataStore', 'society_' .. Config.JobName, function(store)
                    local weapons = store.get('weapons')

                    if (weapons == nil or #weapons == 0) then
                        weapons = {}
                    end

                    local weaponFound = false

                    for i = 1, #weapons, 1 do
                        if (string.lower(weapons[i].name) == string.lower(weapon.name)) then
                            weapons[i].count = weapons[i].count + 1
                            weaponFound = true
                        end
                    end

                    if (not weaponFound) then
                        table.insert(weapons, {
                            name = weapon.name,
                            count = 1
                        })
                    end

                    store.set('weapons', weapons)

                    xPlayer.removeWeapon(weapon.name)

                    cb(true)
                    return
                end)
            end
        end
    end

    cb(false)
end)