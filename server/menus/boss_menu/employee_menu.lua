ESX = nil

TriggerEvent('mlx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('ml_' .. Config.JobName .. 'job:rankCount', function(source, cb, grade)
	MySQL.Async.fetchAll('SELECT COUNT(*) AS count FROM users WHERE (job = @job and job_grade = @grade) OR (job2 = @job and job2_grade = @grade)', {
		['@job'] = Config.JobName,
		['@grade'] = grade
	}, function (results)
		local result = 0

		if (results[1] ~= nil and results[1].count > 0) then
			result = results[1].count
		end

        if (cb ~= nil) then
            cb(result)
        end
	end)
end)

ESX.RegisterServerCallback('ml_' .. Config.JobName .. 'job:getWorkingEmployees', function(source, cb)
    MySQL.Async.fetchAll('SELECT ' ..
        'user.firstname as firstname, user.lastname as lastname, user.identifier as identifier, user.name as name, user.job as job, user.job2 as job2, user.job_grade as job_grade, user.job2_grade as job2_grade, ' ..
        'primary_job.label as label, primary_job_grades.label as label2, primary_job_grades.name as job_name, secondary_job_grades.name as job2_name, primary_job_grades.label as job_label, secondary_job_grades.label as job2_label ' ..
        'FROM `users` AS user ' ..
        'LEFT JOIN `jobs` AS primary_job ON primary_job.name = user.job ' ..
        'LEFT JOIN `jobs` AS secondary_job ON secondary_job.name = user.job2 ' ..
        'LEFT JOIN `job_grades` AS primary_job_grades ON primary_job_grades.job_name = user.job and primary_job_grades.grade = user.job_grade ' ..
        'LEFT JOIN `job_grades` AS secondary_job_grades ON secondary_job_grades.job_name = user.job2 and secondary_job_grades.grade = user.job2_grade ' ..
        'WHERE user.job = @job or user.job2 = @job', {
        ['@job'] = Config.JobName
    }, function (results)
        local employees = {}

        for _, employee in pairs(results) do
            table.insert(employees, {
                name = employee.firstname .. ' ' .. employee.lastname,
                identifier = employee.identifier,
                sname = employee.name,
                job = {
                    name = employee.job,
                    label = employee.label,
                    grade = employee.job_grade,
                    grade_name = employee.job_name,
                    grade_label = employee.job_label,
                },
                job2 = {
                    name = employee.job2,
                    label = employee.label2,
                    grade = employee.job2_grade,
                    grade_name = employee.job2_name,
                    grade_label = employee.job2_label,
                }
            })
        end

        if (cb ~= nil) then
            cb(employees)
        end
    end)
end)

ESX.RegisterServerCallback('ml_' .. Config.JobName .. 'job:searchPlayers', function(source, cb, search)
    MySQL.Async.fetchAll('SELECT ' ..
        'user.firstname as firstname, user.lastname as lastname, user.identifier as identifier, user.name as name, user.job as job, user.job2 as job2, user.job_grade as job_grade, user.job2_grade as job2_grade, ' ..
        'primary_job.label as label, primary_job_grades.label as label2, primary_job_grades.name as job_name, secondary_job_grades.name as job2_name, primary_job_grades.label as job_label, secondary_job_grades.label as job2_label ' ..
        'FROM `users` AS user ' ..
        'LEFT JOIN `jobs` AS primary_job ON primary_job.name = user.job ' ..
        'LEFT JOIN `jobs` AS secondary_job ON secondary_job.name = user.job2 ' ..
        'LEFT JOIN `job_grades` AS primary_job_grades ON primary_job_grades.job_name = user.job and primary_job_grades.grade = user.job_grade ' ..
        'LEFT JOIN `job_grades` AS secondary_job_grades ON secondary_job_grades.job_name = user.job2 and secondary_job_grades.grade = user.job2_grade ' ..
        'WHERE (LOWER(CONCAT(user.firstname, \' \', user.lastname)) LIKE @search OR ' ..
        'LOWER(CONCAT(user.lastname, \' \', user.firstname)) LIKE @search OR ' ..
        'LOWER(user.name) LIKE @search) AND (LOWER(user.job) NOT LIKE @job AND LOWER(user.job2) NOT LIKE @job)', {
        ['@search'] = string.lower('%' .. search .. '%'),
        ['@job'] = string.lower('%' .. Config.JobName .. '%')
    }, function (results)
        local employees = {}

        for _, employee in pairs(results) do
            if (string.lower(employee.job) ~= string.lower(Config.JobName) or
                string.lower(employee.job2) ~= string.lower(Config.JobName)) then
                table.insert(employees, {
                    name = employee.firstname .. ' ' .. employee.lastname,
                    identifier = employee.identifier,
                    sname = employee.name,
                    job = {
                        name = employee.job,
                        label = employee.label,
                        grade = employee.job_grade,
                        grade_name = employee.job_name,
                        grade_label = employee.job_label,
                    },
                    job2 = {
                        name = employee.job2,
                        label = employee.label2,
                        grade = employee.job2_grade,
                        grade_name = employee.job2_name,
                        grade_label = employee.job2_label,
                    }
                })
            end
        end

        if (cb ~= nil) then
            cb(employees)
        end
    end)
end)

ESX.RegisterServerCallback('ml_' .. Config.JobName .. 'job:loadGrades', function(source, cb)
    MySQL.Async.fetchAll('SELECT * FROM `job_grades` WHERE `job_name` = @job',
    {
        ['@job'] = Config.JobName,
    }, function(results)
        local grades = {}

        for _, grade in pairs(results) do
            table.insert(grades, {
                grade = grade.grade,
                name = grade.name,
                label = grade.label,
                salary = grade.salary
            })
        end

        table.sort(grades, SortGrades)

        if (cb ~= nil) then
            cb(grades)
        end
    end)
end)

ESX.RegisterServerCallback('ml_' .. Config.JobName .. 'job:setJob', function(source, cb, identifier, job, grade)
    MySQL.Async.execute('UPDATE `users` SET `job` = @job, `job_grade` = @job_grade WHERE `identifier` = @identifier',
    {
        ['@job']        = job,
        ['@job_grade']  = grade,
        ['@identifier'] = identifier
    }, function(rowsChanged)
        local xTarget = ESX.GetPlayerFromIdentifier(identifier)

        if (xTarget ~= nil) then
            xTarget.setJob(job, grade)
        end

        if (cb ~= nil) then
            cb(rowsChanged)
        end
    end)
end)

ESX.RegisterServerCallback('ml_' .. Config.JobName .. 'job:setJob2', function(source, cb, identifier, job, grade)
    MySQL.Async.execute('UPDATE `users` SET `job2` = @job, `job2_grade` = @job_grade WHERE `identifier` = @identifier',
    {
        ['@job']        = job,
        ['@job_grade']  = grade,
        ['@identifier'] = identifier
    }, function(rowsChanged)
        local xTarget = ESX.GetPlayerFromIdentifier(identifier)

        if (xTarget ~= nil) then
            xTarget.setJob2(job, grade)
        end

        if (cb ~= nil) then
            cb(rowsChanged)
        end
    end)
end)

function SortGrades(item1, item2)
    local grade1 = 0
    local grade2 = 0

    if (item1 ~= nil and item1.grade ~= nil) then
        grade1 = item1.grade
    end

    if (item2 ~= nil and item2.grade ~= nil) then
        grade2 = item2.grade
    end

    return grade1 < grade2
end