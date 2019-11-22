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

ESX.RegisterServerCallback('ml_' .. Config.JobName .. 'job:updateBlips', function(source, cb)
    local players = GetOnlinePlayers()

    for _, player in pairs(players) do
        if (player.job ~= nil and string.lower(player.job.name) == string.lower(Config.JobName)) or
            (player.job2 ~= nil and string.lower(player.job2.name) == string.lower(Config.JobName)) then
            local xPlayer = ESX.GetPlayerFromId(player.source)

            TriggerClientEvent('ml_' .. Config.JobName .. 'job:updateBlip', xPlayer.source)
        end
    end

    if (cb ~= nil) then
        cb()
    end
end)

function GetOnlinePlayers()
    local xPlayers = ESX.GetPlayers()
	local players  = {}

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		table.insert(players, {
			source     = xPlayer.source,
			identifier = xPlayer.identifier,
			name       = xPlayer.name,
			job        = xPlayer.job,
			job2        = xPlayer.job2
		})
    end

    return players
end