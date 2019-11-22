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

function OpenBossMenu()
    ESX.UI.Menu.CloseAll()

    local elements = {}

    if (HasAccess(Config.RequiredGradesForEmployee)) then
        table.insert(elements, { label = _U('employee_menu'), value = 'employee_menu' })
    end

    if (HasAccess(Config.RequiredGradesForBankSystem)) then
        table.insert(elements, { label = _U('bank_menu'), value = 'bank_menu' })
    end

    if (HasAccess(Config.RequiredGradesForMoneyWash)) then
        table.insert(elements, { label = _U('wash_menu'), value = 'wash_menu' })
    end

    ESX.UI.Menu.Open(
        'ml',
        GetCurrentResourceName(),
        'boss_menu',
        {
            title       = _U('boss_menu'),
            align       = 'top-left',
            css         = Config.JobName,
            elements    = elements
        },
        function(data, menu)
            if (data.current.value == 'employee_menu' and
                HasAccess(Config.RequiredGradesForEmployee)) then
                OpenEmployeeMenu()
            elseif (data.current.value == 'bank_menu' and
                HasAccess(Config.RequiredGradesForBankSystem)) then
                OpenBankMenu()
            elseif (data.current.value == 'wash_menu' and
                Config.CanWashMoney and
                HasAccess(Config.RequiredGradesForMoneyWash)) then
                OpenMoneyWashMenu()
            end
        end,
        function(data, menu)
            menu.close()
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