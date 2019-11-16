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

    local elements = {
        { label = _U('employee_menu'), value = 'employee_menu' },
        { label = _U('bank_menu'), value = 'bank_menu' },
    }

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
            if (data.current.value == 'employee_menu') then
                OpenEmployeeMenu()
            elseif (data.current.value == 'bank_menu') then
                OpenBankMenu()
            end
        end,
        function(data, menu)
            menu.close()
        end)
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