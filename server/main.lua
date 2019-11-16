ESX = nil

TriggerEvent('mlx:getSharedObject', function(obj) ESX = obj end)

TriggerEvent('mlx_society:registerSociety', Config.JobName, Config.JobLabel, 'society_' .. Config.JobName, 'society_' .. Config.JobName, 'society_' .. Config.JobName, {type = 'public'})

ESX.RegisterServerCallback('ml_' .. Config.JobName .. 'job:sendNotification', function(source, cb, idenfier, message)
    local xTarget = ESX.GetPlayerFromIdentifier(idenfier)

    if (xTarget == nil) then
        if (cb ~= nil) then
            cb()
        end

        return
    end

    TriggerClientEvent('mlx:showNotification', xTarget.source, message)

    if (cb ~= nil) then
        cb()
    end
end)