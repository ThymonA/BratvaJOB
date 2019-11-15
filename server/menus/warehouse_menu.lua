ESX = nil

TriggerEvent('mlx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('ml_' .. Config.JobName .. 'job:getTrunk', function(source, cb, plate)
    TriggerEvent(
        'mlx_trunk:getSharedDataStore',
        plate,
        function(store)
            local blackMoney = 0
            local items = {}
            local weapons = {}

            weapons = (store.get('weapons') or {})

            local blackAccount = (store.get('black_money') or 0)

            if (blackAccount ~= 0) then
                blackMoney = blackAccount[1].amount
            end

            local trunk = (store.get('coffre') or {})

            for _, item in pairs(trunk) do
                table.insert(items, { name = item.name, count = item.count, label = ESX.GetItemLabel(item.name) })
            end

            if (cb ~= nil) then
                cb({
                    blackMoney = blackMoney,
                    items = items,
                    weapons = weapons
                })
            end
        end)
end)

ESX.RegisterServerCallback('ml_' .. Config.JobName .. 'job:updateTrunkItem', function(source, cb, plate, item_name)
    TriggerEvent('mlx_trunk:getSharedDataStore', plate, function(store)
        if (item_name == 'black_money') then
            local blackMoney = 0
            local blackAccount = (store.get('black_money') or 0)

            if (blackAccount ~= 0) then
                blackMoney = blackAccount[1].amount
            end

            if (blackMoney < 0 or blackMoney == nil) then
                cb(false, 'no_black_money', format_num(0, 0, '€ '))
                return
            end

            store.set('black_money', {
                { amount = 0 }
            })

            store.save()

            TriggerEvent('mlx_addonaccount:getSharedAccount', 'society_' .. Config.JobName .. '_black_money', function(account)
                account.addMoney(blackMoney)
    
                cb(true, _U('blackmoney'), format_num(blackMoney, 0, '€ '))
                return
            end)

            cb(true, _U('blackmoney'), format_num(blackMoney, 0, '€ '))
            return
        end

        local _weapons = {}

        _weapons = (store.get('weapons') or {})

        for i = 1, #_weapons, 1 do
            if (_weapons[i].name == item_name) then
                local weapon_name = _weapons[i].name
                local weapon_label = _weapons[i].label

                table.remove(_weapons, i)

                TriggerEvent('mlx_datastore:getSharedDataStore', 'society_' .. Config.JobName, function(jobStore)
                    local weapons = jobStore.get('weapons')

                    if (weapons == nil or #weapons == 0) then
                        weapons = {}
                    end

                    local weaponFound = false

                    for i = 1, #weapons, 1 do
                        if (string.lower(weapons[i].name) == string.lower(weapon_name)) then
                            weapons[i].count = weapons[i].count + 1
                            weaponFound = true
                        end
                    end

                    if (not weaponFound) then
                        table.insert(weapons, {
                            name = weapon_name,
                            count = 1
                        })
                    end

                    store.set('weapons', _weapons)
                    jobStore.set('weapons', weapons)

                    cb(true, weapon_label, format_num(1, 0, ''))
                    return
                end)
            end
        end

        local _trunk = (store.get('coffre') or {})

        for i = 1, #_trunk, 1 do
            if (_trunk[i].name == item_name) then
                local item = _trunk[i]

                if (item.count <= 0) then
                    cb(false, 'no_item', format_num(0, 0, ''))
                    return
                end

                table.remove(_trunk, i)

                TriggerEvent('mlx_addoninventory:getSharedInventory', 'society_' .. Config.JobName, function(inventory)
                    local trunk = (store.get('coffre') or {})

                    if (trunk == nil or #trunk == 0) then
                        trunk = {}
                    end

                    store.set('coffre', _trunk)
                    inventory.addItem(item.name, item.count)

                    cb(true, item.name, format_num(item.count, 0, ''))
                    return
                end)

                return
            end
        end

        cb(false, 'no_item', format_num(0, 0, ''))
    end)
end)