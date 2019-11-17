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

function OpenSafeMenu()
    local elements = {
        { label = _U('add_items'), value = 'add_items' },
        { label = _U('remove_items'), value = 'remove_items' },
    }

    ESX.UI.Menu.Open(
        'ml',
        GetCurrentResourceName(),
        'safe_menu',
        {
            title       = _U('safe_menu'),
            align       = 'top-left',
            css         = Config.JobName,
            elements    = elements
        },
        function(data, menu)
            if (data.current.value == 'add_items') then
                OpenAddItemMenu()
            elseif (data.current.value == 'remove_items') then
                OpenRemoveItemMenu()
            end
        end,
        function(data, menu)
            menu.close()
        end)
end

function OpenAddItemMenu()
    ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:getInventory', function(data)
        local elements = {
            { label = _U('player_name', data.player.name), value = '', disabled = true },
        }

        if (#data.items > 0) then
            table.insert(elements, { label = _U('products'), value = '', disabled = true })

            for _, item in pairs(data.items) do
                if (item.count > 0) then
                    local productLabel = '<strong>' .. item.label .. '</strong> ' .. item.count

                    table.insert(elements, { label = productLabel, value = item.name })
                end
            end
        end

        if (data.blackMoney > 0) then
            table.insert(elements, { label = _U('black_money_label'), value = '', disabled = true })
            table.insert(elements, { label = _U('black_money', format_num(data.blackMoney, 0, '€ ')), value = 'black_money' })
        end

        ESX.UI.Menu.Open(
            'ml',
            GetCurrentResourceName(),
            'safe_menu_add',
            {
                title = _U('safe_menu_add'),
                align = 'top-left',
                css = Config.JobName,
                elements = elements
            },
            function(data, menu)
                ESX.UI.Menu.Open(
                    'ml_dialog',
                    GetCurrentResourceName(),
                    'safe_menu_add_amount',
                    {
                        title = _U('item_count'),
                        submit = _U('save'),
                        css = Config.JobName
                    },
                    function(data2, menu2)
                        ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:storeItem', function(done, msg)
                            if (done) then
                                menu2.close()
                                menu.close()

                                if (data.current.value == 'black_money') then
                                    ESX.ShowNotification(_U('put_black_money', format_num(data2.value, 0, '€ '), msg, Config.JobLabel))
                                else
                                    ESX.ShowNotification(_U('put_products', format_num(data2.value, 0, ''), msg, Config.JobLabel))
                                end

                                OpenAddItemMenu()
                            elseif (msg == 'no_player') then
                                ESX.ShowNotification(_U('no_player'))
                            elseif (msg == 'no_black_money') then
                                ESX.ShowNotification(_U('no_black_money'))
                            elseif (msg == 'no_black_money') then
                                ESX.ShowNotification(_U('no_item'))
                            elseif (msg == 'cant_remove_item') then
                                ESX.ShowNotification(_U('cant_remove_item'))
                            end
                        end, data.current.value, data2.value)
                    end,
                    function(data2, menu2)
                        menu2.close()
                    end)
            end,
            function(data, menu)
                menu.close()
            end)
    end)
end

function OpenRemoveItemMenu()
    ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:getItems', function(items)
        local elements = {
            { label = _U('society_name', Config.JobLabel), value = '', disabled = true },
        }

        if (#items > 0) then
            table.insert(elements, { label = _U('products'), value = '', disabled = true })

            for _, item in pairs(items) do
                if (item.count > 0) then
                    local productLabel = '<strong>' .. item.label .. '</strong> ' .. item.count

                    table.insert(elements, { label = productLabel, value = item.name })
                end
            end
        end

        ESX.UI.Menu.Open(
            'ml',
            GetCurrentResourceName(),
            'safe_menu_remove',
            {
                title = _U('safe_menu_remove'),
                align = 'top-left',
                css = Config.JobName,
                elements = elements
            },
            function(data, menu)
                ESX.UI.Menu.Open(
                    'ml_dialog',
                    GetCurrentResourceName(),
                    'safe_menu_remove_amount',
                    {
                        title = _U('item_count'),
                        submit = _U('get'),
                        css = Config.JobName
                    },
                    function(data2, menu2)
                        ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:getItem', function(done, msg)
                            if (done) then
                                menu2.close()
                                menu.close()

                                if (data.current.value == 'black_money') then
                                    ESX.ShowNotification(_U('get_black_money', format_num(data2.value, 0, '€ '), msg, Config.JobLabel))
                                else
                                    ESX.ShowNotification(_U('get_products', format_num(data2.value, 0, ''), msg, Config.JobLabel))
                                end

                                OpenRemoveItemMenu()
                            elseif (msg == 'no_player') then
                                ESX.ShowNotification(_U('no_player'))
                            elseif (msg == 'no_black_money') then
                                ESX.ShowNotification(_U('no_black_money'))
                            elseif (msg == 'no_black_money') then
                                ESX.ShowNotification(_U('no_item'))
                            elseif (msg == 'cant_remove_item') then
                                ESX.ShowNotification(_U('cant_remove_item'))
                            end
                        end, data.current.value, data2.value)
                    end,
                    function(data2, menu2)
                        menu2.close()
                    end)
            end,
            function(data, menu)
                menu.close()
            end)
    end)
end