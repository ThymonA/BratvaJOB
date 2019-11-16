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

function OpenEmployeeMenu()
    local elements = {
        { label = _U('list_employee'), value = 'list_employee' },
        { label = _U('add_employee'), value = 'add_employee' },
        { label = _U('remove_employee'), value = 'remove_employee' },
        { label = _U('promote_employee'), value = 'promote_employee' },
        { label = _U('demote_employee'), value = 'demote_employee' },
    }

    ESX.UI.Menu.Open(
        'ml',
        GetCurrentResourceName(),
        'employee_menu',
        {
            title       = _U('employee_menu'),
            align       = 'top-left',
            css         = Config.JobName,
            elements    = elements
        },
        function(data, menu)
            if (data.current.value == 'list_employee') then
                OpenEmployeeList()
            elseif (data.current.value == 'add_employee') then
                OpenEmployeeHireMenu()
            elseif (data.current.value == 'remove_employee') then
                OpenEmployeeFireMenu()
            elseif (data.current.value == 'promote_employee') then
                OpenPromitionMenu()
            elseif (data.current.value == 'demote_employee') then
                OpenDemotionMenu()
            end
        end,
        function(data, menu)
            menu.close()
        end)
end

function OpenEmployeeList()
    ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:getWorkingEmployees', function(employees)
        local elements = {}

        for _, employee in pairs(employees) do
            local grade = _U('unknown')
            local isPrimaryJob = true

            if (string.lower(employee.job.name) == string.lower(Config.JobName)) then
                grade = employee.job.grade_label
                isPrimaryJob = true
            elseif (string.lower(employee.job2.name) == string.lower(Config.JobName)) then
                grade = employee.job2.grade_label
                isPrimaryJob = false
            end

            table.insert(elements, {
                data = employee,
                cols = {
                    employee.sname,
                    employee.name,
                    GetHTMLJobLabel(grade, isPrimaryJob),
                }
            })
        end

        table.sort(elements, SortPlayers)
        table.sort(elements, SortEmployees)

        ESX.UI.Menu.Open(
            'ml_list',
            GetCurrentResourceName(),
            'employee_list',
            {
                title       = _U('list_employee'),
                align       = 'top-left',
                css         = Config.JobName,
                head        = { _U('steam_name'), _U('character_name'), _U('rank_name') },
                rows        = elements,
            },
            function(data, menu)
            end,
            function(data, menu)
                menu.close()
            end)
    end)
end

function OpenEmployeeHireMenu()
    ESX.UI.Menu.Open(
        'ml_dialog',
        GetCurrentResourceName(),
        'hire_employee_search',
    {
        title   = _U('hire_employee_search'),
        css     = Config.JobName,
        submit  = _U('search')
    },
    function(data, menu)
        if (data.value == nil or string.len(tostring(data.value)) < 3) then
            ESX.ShowNotification(_U('search_query_to_short'))
            return
        end

        ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:searchPlayers', function(players)
            local elements = {}

            for _, player in pairs(players) do
                table.insert(elements, {
                    data = player,
                    cols = {
                        player.sname,
                        player.name,
                        '{{' .. _U('hire_primary') .. '|primary}} {{' .. _U('hire_secondary') .. '|secondary}}'
                    }
                })
            end

            table.sort(elements, SortPlayers)

            menu.close()

            ESX.UI.Menu.Open(
                'ml_list',
                GetCurrentResourceName(),
                'hire_employee',
                {
                    title       = _U('add_employee'),
                    align       = 'top-left',
                    css         = Config.JobName,
                    buttonClass = 'red',
                    head        = { _U('steam_name'), _U('character_name'), _U('recruit_as') },
                    rows        = elements
                },
                function (data2, menu2)
                    local employee = data2.data

                    if (data2.value == 'primary') then
                        ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:setJob', function()
                            ESX.ShowNotification(_U('you_have_hire', employee.name, Config.JobLabel))
                            ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:sendNotification', function()
                                    menu2.close()
                                    menu.close()
                                    OpenEmployeeHireMenu()
                            end, employee.identifier, _U('you_hired', Config.JobLabel))
                        end, employee, Config.JobName, 0)
                    elseif (data2.value == 'secondary') then
                        ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:setJob2', function()
                            ESX.ShowNotification(_U('you_have_hire', employee.name, Config.JobLabel))
                            ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:sendNotification', function()
                                    menu2.close()
                                    menu.close()
                                    OpenEmployeeHireMenu()
                            end, employee.identifier, _U('you_hired', Config.JobLabel))
                        end, employee, Config.JobName, 0)
                    end
                end,
                function(data, menu)
                    menu.close()
                end)
        end, data.value)
    end,
    function(data, menu)
        menu.close()
    end)
end

function OpenEmployeeFireMenu()
    ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:getWorkingEmployees', function(employees)
        local elements = {}

        for _, employee in pairs(employees) do
            local grade = _U('unknown')
            local isPrimaryJob = true

            if (string.lower(employee.job.name) == string.lower(Config.JobName)) then
                grade = employee.job.grade_label
                isPrimaryJob = true
            elseif (string.lower(employee.job2.name) == string.lower(Config.JobName)) then
                grade = employee.job2.grade_label
                isPrimaryJob = false
            end

            table.insert(elements, {
                data = employee,
                cols = {
                    employee.sname,
                    employee.name,
                    GetHTMLJobLabel(grade, isPrimaryJob),
                    '{{' .. _U('fire') .. '|fire}}'
                }
            })
        end

        table.sort(elements, SortPlayers)
        table.sort(elements, SortEmployees)

        ESX.UI.Menu.Open(
            'ml_list',
            GetCurrentResourceName(),
            'employee_fire',
            {
                title       = _U('employee_fire'),
                align       = 'top-left',
                css         = Config.JobName,
                buttonClass = 'fire',
                head        = { _U('steam_name'), _U('character_name'), _U('rank_name'), _U('actions') },
                rows        = elements
            }, 
            function(data, menu)
                local employee = data.data

                if (data.value == 'fire') then
                    if (string.lower(employee.job.name) == string.lower(Config.JobName)) then
                        if (string.lower(employee.job.grade_name) == string.lower('boss')) then
                            local jobGrade = employee.job.grade

                            ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:rankCount', function (count)
                                if (count <= 1) then
                                    ESX.ShowNotification(_U('you_cant_fire_boss', Config.JobLabel))
                                    return
                                end

                                ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:setJob', function()
                                    ESX.ShowNotification(_U('you_have_fired', employee.name, Config.JobLabel))
                                    ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:sendNotification', function()
                                        OpenEmployeeFireMenu()
                                    end, employee.identifier, _U('you_fired', Config.JobLabel))
                                end, employee, 'Kansloos', 0)

                                return
                            end, jobGrade)
                        else
                            ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:setJob', function()
                                ESX.ShowNotification(_U('you_have_fired', employee.name, Config.JobLabel))
                                ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:sendNotification', function()
                                    OpenEmployeeFireMenu()
                                end, employee.identifier, _U('you_fired', Config.JobLabel))
                            end, employee, 'Kansloos', 0)
                        end
                    end

                    if (string.lower(employee.job2.name) == string.lower(Config.JobName)) then
                        if (string.lower(employee.job2.grade_name) == 'boss') then
                            local jobGrade = employee.job2.grade

                            ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:rankCount', function (count)
                                if (count <= 1) then
                                    ESX.ShowNotification(_U('you_cant_fire_boss', Config.JobLabel))
                                    return
                                end
                                
                                ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:setJob2', function()
                                    ESX.ShowNotification(_U('you_have_fired', employee.name, Config.JobLabel))
                                    ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:sendNotification', function()
                                        OpenEmployeeFireMenu()
                                    end, employee.identifier, _U('you_fired', Config.JobLabel))
                                end, employee, 'Leeg', 0)

                                return
                            end, jobGrade)
                        else
                            ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:setJob2', function()
                                ESX.ShowNotification(_U('you_have_fired', employee.name, Config.JobLabel))
                                ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:sendNotification', function()
                                    OpenEmployeeFireMenu()
                                end, employee.identifier, _U('you_fired', Config.JobLabel))
                            end, employee, 'Leeg', 0)
                        end
                    end
                end
            end,
            function(data, menu)
                menu.close()
            end)
    end)
end

function OpenPromitionMenu()
    ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:loadGrades', function(grades)
        local elements = {}
        local highestGrade = 0

        for _, grade in pairs(grades) do
            if (highestGrade < grade.grade) then
                highestGrade = grade.grade
            end
        end

        ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:getWorkingEmployees', function(employees)
            for _, employee in pairs(employees) do
                local employeeLabel = ''
                local employeeGrade = 0
                local isPrimaryJob = true

                if (string.lower(employee.job.name) == string.lower(Config.JobName)) then
                    employeeGrade = employee.job.grade
                    employeeLabel = employee.job.grade_label
                    isPrimaryJob = true
                elseif (string.lower(employee.job2.name) == string.lower(Config.JobName)) then
                    employeeGrade = employee.job2.grade
                    employeeLabel = employee.job2.grade_label
                    isPrimaryJob = false
                end

                if (employeeGrade ~= highestGrade) then
                    table.insert(elements, {
                        data = employee,
                        cols = {
                            employee.sname,
                            employee.name,
                            GetHTMLJobLabel(employeeLabel, isPrimaryJob),
                            '{{' .. _U('promote') .. '|promote}}'
                        }
                    })
                end
            end

            table.sort(elements, SortPlayers)
            table.sort(elements, SortEmployees)

            ESX.UI.Menu.Open(
                'ml_list',
                GetCurrentResourceName(),
                'promote_employee',
                {
                    title       = _U('promote_employee'),
                    align       = 'top-left',
                    css         = Config.JobName,
                    buttonClass = 'red',
                    head        = { _U('steam_name'), _U('character_name'), _U('rank_name'), _U('actions') },
                    rows        = elements
                },
                function (data, menu)
                    if (data.value == 'promote') then
                        local employee = data.data
                        local gradeLabel = _U('unkown')
                        local gradeElements = {}

                        for _, grade in pairs(grades) do
                            local employeeGrade = 0

                            if (string.lower(employee.job.name) == string.lower(Config.JobName)) then
                                employeeGrade = employee.job.grade
                                gradeLabel = grade.label
                            elseif (string.lower(employee.job2.name) == string.lower(Config.JobName)) then
                                employeeGrade = employee.job2.grade
                                gradeLabel = grade.label
                            end

                            if (grade.grade > employeeGrade) then
                                table.insert(gradeElements, { label = grade.label, value = grade.grade })
                            else
                                table.insert(gradeElements, { label = grade.label, value = grade.grade, disabled = true })
                            end
                        end

                        local elements = {
                            { label = _U('employee_promote_name', data.data.name), value = '', disabled = true },
                            { label = _U('employee_promote_steam', data.data.sname), value = '', disabled = true },
                            { label = _U('employee_promote_grade', gradeLabel), value = '', disabled = true },
                            { label = _U('new_rank'), value = '', disabled = true },
                        }

                        for _, gradeElement in pairs(gradeElements) do
                            table.insert(elements, gradeElement)
                        end

                        menu.close()

                        ESX.UI.Menu.Open(
                            'ml',
                            GetCurrentResourceName(),
                            'promote_employee_rank',
                            {
                                title       = _U('promote_employee_rank'),
                                align       = 'top-left',
                                css         = Config.JobName,
                                elements    = elements
                            },
                            function(data2, menu2)
                                for _, grade in pairs(grades) do
                                    if (grade.grade == data2.current.value) then
                                        if (string.lower(employee.job.name) == string.lower(Config.JobName)) then
                                            ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:setJob', function()
                                                ESX.ShowNotification(_U('you_have_promote', employee.name, grade.label, Config.JobLabel))
                                                ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:sendNotification', function()
                                                        menu2.close()
                                                        menu.close()
                                                        OpenPromitionMenu()
                                                end, employee.identifier, _U('you_promoted', grade.label, Config.JobLabel))
                                            end, employee, Config.JobName, grade.grade)
                                        elseif (string.lower(employee.job2.name) == string.lower(Config.JobName)) then
                                            ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:setJob2', function()
                                                ESX.ShowNotification(_U('you_have_promote', employee.name, grade.label, Config.JobLabel))
                                                ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:sendNotification', function()
                                                        menu2.close()
                                                        menu.close()
                                                        OpenPromitionMenu()
                                                end, employee.identifier, _U('you_promoted', grade.label, Config.JobLabel))
                                            end, employee, Config.JobName, grade.grade)
                                        end
                                    end
                                end
                            end,
                            function(data2, menu2)
                                menu2.close()
                            end)
                    end
                end,
                function(data, menu)
                    menu.close()
                end)
        end)
    end)
end

function OpenDemotionMenu()
    ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:loadGrades', function(grades)
        local elements = {}
        local lowestGrade = 0

        for _, grade in pairs(grades) do
            if (lowestGrade > grade.grade) then
                lowestGrade = grade.grade
            end
        end

        ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:getWorkingEmployees', function(employees)
            for _, employee in pairs(employees) do
                local employeeLabel = ''
                local employeeGrade = 0
                local isPrimaryJob = true

                if (string.lower(employee.job.name) == string.lower(Config.JobName)) then
                    employeeGrade = employee.job.grade
                    employeeLabel = employee.job.grade_label
                    isPrimaryJob = true
                elseif (string.lower(employee.job2.name) == string.lower(Config.JobName)) then
                    employeeGrade = employee.job2.grade
                    employeeLabel = employee.job2.grade_label
                    isPrimaryJob = false
                end

                if (employeeGrade ~= lowestGrade) then
                    table.insert(elements, {
                        data = employee,
                        cols = {
                            employee.sname,
                            employee.name,
                            GetHTMLJobLabel(employeeLabel, isPrimaryJob),
                            '{{' .. _U('demote') .. '|demote}}'
                        }
                    })
                end
            end

            table.sort(elements, SortPlayers)
            table.sort(elements, SortEmployees)

            ESX.UI.Menu.Open(
                'ml_list',
                GetCurrentResourceName(),
                'demote_employee',
                {
                    title       = _U('demote_employee'),
                    align       = 'top-left',
                    css         = Config.JobName,
                    buttonClass = 'red',
                    head        = { _U('steam_name'), _U('character_name'), _U('rank_name'), _U('actions') },
                    rows        = elements
                },
                function (data, menu)
                    if (data.value == 'demote') then
                        local employee = data.data
                        local gradeLabel = _U('unkown')
                        local gradeElements = {}

                        for _, grade in pairs(grades) do
                            local employeeGrade = 0

                            if (string.lower(employee.job.name) == string.lower(Config.JobName)) then
                                employeeGrade = employee.job.grade
                                gradeLabel = grade.label
                            elseif (string.lower(employee.job2.name) == string.lower(Config.JobName)) then
                                employeeGrade = employee.job2.grade
                                gradeLabel = grade.label
                            end

                            if (grade.grade < employeeGrade) then
                                table.insert(gradeElements, { label = grade.label, value = grade.grade })
                            else
                                table.insert(gradeElements, { label = grade.label, value = grade.grade, disabled = true })
                            end
                        end

                        local elements = {
                            { label = _U('employee_demote_name', data.data.name), value = '', disabled = true },
                            { label = _U('employee_demote_steam', data.data.sname), value = '', disabled = true },
                            { label = _U('employee_demote_grade', gradeLabel), value = '', disabled = true },
                            { label = _U('new_rank'), value = '', disabled = true },
                        }

                        for _, gradeElement in pairs(gradeElements) do
                            table.insert(elements, gradeElement)
                        end

                        menu.close()

                        ESX.UI.Menu.Open(
                            'ml',
                            GetCurrentResourceName(),
                            'demote_employee_rank',
                            {
                                title       = _U('demote_employee_rank'),
                                align       = 'top-left',
                                css         = Config.JobName,
                                elements    = elements
                            },
                            function(data2, menu2)
                                for _, grade in pairs(grades) do
                                    if (grade.grade == data2.current.value) then
                                        if (string.lower(employee.job.name) == string.lower(Config.JobName)) then
                                            if (string.lower(employee.job.grade_name) == string.lower('boss')) then
                                                local jobGrade = employee.job.grade

                                                ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:rankCount', function (count)
                                                    if (count <= 1) then
                                                        ESX.ShowNotification(_U('you_cant_demote_boss', Config.JobLabel))
                                                        return
                                                    end

                                                    ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:setJob', function()
                                                        ESX.ShowNotification(_U('you_have_demote', employee.name, grade.label, Config.JobLabel))
                                                        ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:sendNotification', function()
                                                                menu2.close()
                                                                menu.close()
                                                                OpenDemotionMenu()
                                                        end, employee.identifier, _U('you_demoted', grade.label, Config.JobLabel))
                                                    end, employee, Config.JobName, grade.grade)

                                                    return
                                                end, jobGrade)
                                            else
                                                ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:setJob', function()
                                                    ESX.ShowNotification(_U('you_have_demote', employee.name, grade.label, Config.JobLabel))
                                                    ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:sendNotification', function()
                                                            menu2.close()
                                                            menu.close()
                                                            OpenDemotionMenu()
                                                    end, employee.identifier, _U('you_demoted', grade.label, Config.JobLabel))
                                                end, employee, Config.JobName, grade.grade)
                                            end
                                        elseif (string.lower(employee.job2.name) == string.lower(Config.JobName)) then
                                            if (string.lower(employee.job2.grade_name) == 'boss') then
                                                local jobGrade = employee.job2.grade

                                                ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:rankCount', function (count)
                                                    if (count <= 1) then
                                                        ESX.ShowNotification(_U('you_cant_demote_boss', Config.JobLabel))
                                                        return
                                                    end

                                                    ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:setJob2', function()
                                                        ESX.ShowNotification(_U('you_have_demote', employee.name, grade.label, Config.JobLabel))
                                                        ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:sendNotification', function()
                                                                menu2.close()
                                                                menu.close()
                                                                OpenDemotionMenu()
                                                        end, employee.identifier, _U('you_demoted', grade.label, Config.JobLabel))
                                                    end, employee, Config.JobName, grade.grade)

                                                    return
                                                end, jobGrade)
                                            else
                                                ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:setJob2', function()
                                                    ESX.ShowNotification(_U('you_have_demote', employee.name, grade.label, Config.JobLabel))
                                                    ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:sendNotification', function()
                                                            menu2.close()
                                                            menu.close()
                                                            OpenDemotionMenu()
                                                    end, employee.identifier, _U('you_demoted', grade.label, Config.JobLabel))
                                                end, employee, Config.JobName, grade.grade)
                                            end
                                        end
                                    end
                                end
                            end,
                            function(data2, menu2)
                                menu2.close()
                            end)
                    end
                end,
                function(data, menu)
                    menu.close()
                end)
        end)
    end)
end

function SortEmployees(item1, item2)
    local item1_grade = 0
    local item2_grade = 0

    if (string.lower(item1.data.job.name) == string.lower(Config.JobName)) then
        item1_grade = item1.data.job.grade
    elseif (string.lower(item1.data.job2.name) == string.lower(Config.JobName)) then
        item1_grade = item1.data.job2.grade
    end

    if (string.lower(item2.data.job.name) == string.lower(Config.JobName)) then
        item2_grade = item2.data.job.grade
    elseif (string.lower(item2.data.job2.name) == string.lower(Config.JobName)) then
        item2_grade = item2.data.job2.grade
    end

    return item1_grade > item2_grade
end

function SortPlayers(item1, item2)
    local steam_name = ''
    local steam_name2 = ''

    if (item1 ~= nil and item1.sname ~= nil) then
        steam_name = item1.sname
    end

    if (item2 ~= nil and item2.sname ~= nil) then
        steam_name2 = item2.sname
    end

    return steam_name > steam_name2
end

function GetHTMLJobLabel(label, isPrimaryJob)
    if (isPrimaryJob == nil) then
        isPrimaryJob = true
    end

    local html = '<small style="text-transform: uppercase; font-weight: bold;">' .. label .. '</small><br /><small style="color: red; text-transform: uppercase; font-weight: bold;">'

    if (isPrimaryJob) then
        html = html  .. _U('hire_primary')
    else
        html = html .. _U('hire_secondary')
    end

    html = html .. '</small>'

    return html
end

RegisterNetEvent('mlx:setJob')
AddEventHandler('mlx:setJob', function(job)
	PlayerData.job = job
end)

RegisterNetEvent('mlx:setJob2')
AddEventHandler('mlx:setJob2', function(job)
	PlayerData.job2 = job
end)