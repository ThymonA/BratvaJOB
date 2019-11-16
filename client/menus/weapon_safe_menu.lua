local PlayerData            = {}
local Action                = {
    BuyWeapons      = 'BuyWeapons',
    WeaponDeposit   = 'WeaponDeposit',
    WeaponWithdraw  = 'WeaponWithdraw',
    Back            = 'Back',
    Confirm         = 'Yes'
}

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

function OpenWeaponSafeMenu()
    ESX.UI.Menu.CloseAll()

    local elements = {}

    if (Config.CanBuyWeapons and HasAccess(Config.RequiredGradesForWeapons, true)) then
        table.insert(elements, { label = _U('buy_weapons'), value = Action.BuyWeapons })
    end

    if (HasAccess(Config.GradesForDepoAndWithrawWeapons, true)) then
        table.insert(elements, { label = _U('deposit_weapons'), value = Action.WeaponDeposit })
        table.insert(elements, { label = _U('withdraw_weapons'), value = Action.WeaponWithdraw })
    end

    ESX.UI.Menu.Open(
        'ml', GetCurrentResourceName(), 'weapon_safe',
        {
            title       = _U('weapon_safe'),
            align       = 'top-left',
            css         = Config.JobName,
            elements    = elements
        },
        function(data, menu)
            if (data.current.value == Action.BuyWeapons and
                Config.CanBuyWeapons and HasAccess(Config.RequiredGradesForWeapons, true)) then
                OpenWeaponBuyMenu()
            elseif (HasAccess(Config.GradesForDepoAndWithrawWeapons) and data.current.value == Action.WeaponWithdraw) then
                OpenStoredWeaponSafe()
            elseif (HasAccess(Config.GradesForDepoAndWithrawWeapons) and data.current.value == Action.WeaponWithdraw or
                HasAccess(Config.RequiredGradesForWeaponDeposit) and data.current.value == Action.WeaponDeposit) then
                OpenWeaponDeposit()
            end
        end,
        function (data, menu)
            menu.close()
        end)
end

function OpenWeaponBuyMenu()
    local elements = {}

    for i = 1, #Config.Weapons, 1 do
        local weapon = Config.Weapons[i]
        local label = ESX.GetWeaponLabel(weapon.name)
        table.insert(elements, { label = _U('weapon_label', label, format_num(weapon.price, 0, '€ ')), value = weapon.name })
    end

    ESX.UI.Menu.Open(
        'ml', GetCurrentResourceName(), 'buy_weapons',
        {
            title       = _U('buy_weapons'),
            align       = 'top-left',
            css         = Config.JobName,
            elements    = elements
        },
        function(data, menu)
            if (Config.CanBuyWeapons and HasAccess(Config.RequiredGradesForWeapons, true)) then
                local weapon = nil

                for i = 1, #Config.Weapons, 1 do
                    local weaponConfig = Config.Weapons[i]

                    if(weaponConfig.name == data.current.value) then
                        weapon = weaponConfig
                    end
                end

                if (weapon ~= nil) then
                    menu.close()
                    BuyWeaponConfirm(weapon.name, weapon.price)
                end
            end
        end,
        function (data, menu)
            menu.close()
        end)
end

function BuyWeaponConfirm(weapon_name, weapon_price)
    local elements = {}
    local weapon_label = ESX.GetWeaponLabel(weapon_name)

    table.insert(elements, { label = _U('back_buy_weapon'), value = Action.Back })
    table.insert(elements, { label = _U('yes_buy', format_num(weapon_price, 0, '€ ')), value = Action.Confirm })

    ESX.UI.Menu.Open(
        'ml', GetCurrentResourceName(), 'buy_weapon_confirm',
        {
            title       = _U('buy_weapon', weapon_label),
            align       = 'top-left',
            css         = Config.JobName,
            elements    = elements
        },
        function(data, menu)
            if (data.current.value == Action.Confirm and
                Config.CanBuyWeapons and HasAccess(Config.RequiredGradesForWeapons, true)) then

                ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:buyWeapon', function(hasEnoughMoney, money)
                    if (hasEnoughMoney) then
                        ESX.ShowNotification(_U('item_buyed', Config.JobLabel, weapon_label, format_num(money, 0, '€ ')))
                    else
                        ESX.ShowNotification(_U('more_money_required', Config.JobLabel, format_num(money, 0, '€ '), weapon_label))
                    end
                end, weapon_name)
            end

            menu.close()
            OpenWeaponBuyMenu()
        end,
        function (data, menu)
            menu.close()
        end)
end

function OpenStoredWeaponSafe()
    local elements = {}

    ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:getWeapon', function(weapons)
        for i = 1, #weapons, 1 do
            local weapon = weapons[i]

            if (weapon ~= nil and weapon.count ~= nil and weapon.count > 0) then
                local weapon_label = ESX.GetWeaponLabel(weapon.name)
                table.insert(elements, { label = _U('weapon_label', weapon_label, weapon.count), value = weapon.name })
            end
        end

        ESX.UI.Menu.Open(
            'ml', GetCurrentResourceName(), 'store_weapon',
            {
                title    = _U('weapon_safe'),
                align    = 'top-left',
                css      = Config.JobName,
                elements = elements,
            },
            function(data, menu)
                ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:removeWeapon', function(weaponAdded, reason)
                    local weapon_label = ESX.GetWeaponLabel(data.current.value)

                    if (weaponAdded) then
                        ESX.ShowNotification(_U('weapon_withdraw', weapon_label, Config.JobLabel))
                    else
                        if (string.lower(reason) == 'already_exist') then
                            ESX.ShowNotification(_U('weapon_already_exist', weapon_label))
                        elseif (string.lower(reason) == 'not_exist') then
                            ESX.ShowNotification(_U('weapon_not_exist', Config.JobLabel, weapon_label))
                        end
                    end

                    menu.close()
                    OpenStoredWeaponSafe()
                end, data.current.value)
            end,
            function(data, menu)
                menu.close()
            end)
    end)
end

function OpenWeaponDeposit()
    local elements = {}

    ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:getPlayerWeapons', function(weapons)
        for i = 1, #weapons, 1 do
            local weapon = weapons[i]

            if (weapon ~= nil) then
                local weapon_label = ESX.GetWeaponLabel(weapon.name)
                table.insert(elements, { label = _U('weapon_inv_label', weapon_label), value = weapon.name })
            end
        end

        ESX.UI.Menu.Open(
            'ml', GetCurrentResourceName(), 'player_inventory',
            {
                title    = _U('player_inventory'),
                align    = 'top-left',
                css      = Config.JobName,
                elements = elements,
            },
            function(data, menu)
                ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:putPlayerWeapon', function(added)
                    local weapon_label = ESX.GetWeaponLabel(data.current.value)

                    if (added) then
                        ESX.ShowNotification(_U('weapon_added', weapon_label, Config.JobLabel))
                    else
                        ESX.ShowNotification(_U('weapon_not_added', weapon_label, Config.JobLabel))
                    end

                    menu.close()
                    OpenWeaponDeposit()
                end, data.current.value)
            end,
            function (data, menu)
                menu.close()
            end)
    end)
end

function HasAccess(array, default)
    local access = default

    if (array == nil) then
        return access
    end

    if(#array > 0) then
        access = false

        for i = 1, #array, 1 do
            if (array[i] ~= nil and HasGrade(array[i])) then
                access = true
            end
        end
    end

    return access
end

function HasGrade(grade)
    local playerGrade = nil

    if (PlayerData ~= nil and PlayerData.job ~= nil and string.lower(PlayerData.job.name) == string.lower(Config.JobName)) then
        playerGrade = string.lower(PlayerData.job.grade_name)
    elseif (PlayerData ~= nil and PlayerData.job2 ~= nil and string.lower(PlayerData.job2.name) == string.lower(Config.JobName)) then
        playerGrade = string.lower(PlayerData.job2.grade_name)
    end

    return string.lower(grade) == playerGrade
end

RegisterNetEvent('mlx:setJob')
AddEventHandler('mlx:setJob', function(job)
    PlayerData.job = job
end)

RegisterNetEvent('mlx:setJob2')
AddEventHandler('mlx:setJob2', function(job)
    PlayerData.job2 = job
end)