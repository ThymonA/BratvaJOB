ESX = nil

TriggerEvent('mlx:getSharedObject', function(obj) ESX = obj end)

TriggerEvent('mlx_society:registerSociety', Config.JobName, Config.JobLabel, 'society_' .. Config.JobName, 'society_' .. Config.JobName, 'society_' .. Config.JobName, {type = 'public'})