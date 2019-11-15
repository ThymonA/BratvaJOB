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

ESX.RegisterServerCallback('ml_' .. Config.JobName .. 'job:removeItem', function(source, cb, plate, item_name)
    
end)