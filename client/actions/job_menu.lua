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

function OpenActionMenu()
  ESX.UI.Menu.CloseAll()

  ESX.UI.Menu.Open(
    'ml',
    GetCurrentResourceName(),
    'job_' .. Config.JobName .. '_actions',
    {
      title   = _U('actions'),
      align   = 'top-left',
      css     = Config.JobName .. '_actions',
      elements = {
        { label = _U('person'), value = '', disabled = true },
        { label = _U('handcuff'), value = 'handcuff' },
        { label = _U('drag'), value = 'drag' },
        { label = _U('id_card'), value = 'id_card' },
        { label = _U('player_search'), value = 'player_search' },
        { label = _U('vehicle'), value = '', disabled = true },
        { label = _U('hijack_vehicle'), value = 'hijack_vehicle' },
      }
    },
    function(data, menu)
      if (data.current.value == nil or
          data.current.value == '') then
          return
      end

      if (data.current.value == 'handcuff') then
        HandcuffPlayer()
      elseif (data.current.value == 'drag') then
        DragPlayer()
      elseif (data.current.value == 'id_card') then
        OpenIDCard()
      elseif (data.current.value == 'player_search') then
        OpenPlayerInventory()
      elseif (data.current.value == 'hijack_vehicle') then
        HijackVehicle()
      end
    end,
    function(data, menu)
        menu.close()
    end)
end

function HandcuffPlayer()
  local targetPlayer, targetDistance = ESX.Game.GetClosestPlayer()

  if (targetPlayer == -1 or targetDistance > 1.5) then
    ESX.ShowNotification(_U('no_player_close'))
    return
  end

  ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:handcuffPlayer', function()
  end, GetPlayerServerId(targetPlayer))
end

function DragPlayer()
  local targetPlayer, targetDistance = ESX.Game.GetClosestPlayer()

  if (targetPlayer == -1 or targetDistance > 1.5) then
    ESX.ShowNotification(_U('no_player_close'))
    return
  end

  ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:drag', function()
  end, GetPlayerServerId(targetPlayer))
end

function OpenIDCard()
  local targetPlayer, targetDistance = ESX.Game.GetClosestPlayer()

  if (targetPlayer == -1 or targetDistance > 1.5) then
    ESX.ShowNotification(_U('no_player_close'))
    return
  end

  ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:getTargetPlayerInfo', function(targetInfo)
    ESX.UI.Menu.Open(
      'ml',
      GetCurrentResourceName(),
      'job_' .. Config.JobName .. '_id_card',
      {
        title = _U('target_info'),
        align = 'top-left',
        css = Config.JobName .. '_actions',
        elements = {
          { label = _U('target_firstname', targetInfo.firstname), value = '', disabled = true },
          { label = _U('target_lastname', targetInfo.lastname), value = '', disabled = true },
          { label = _U('target_sex_' .. targetInfo.sex), value = '', disabled = true },
          { label = _U('target_dateOfBirth', targetInfo.dateOfBirth), value = '', disabled = true },
          { label = _U('target_length', targetInfo.height), value = '', disabled = true },
          { label = _U('target_steam', targetInfo.name), value = '', disabled = true },
          { label = _U('back'), value = 'back' }
        }
      },
      function(data, menu)
        if (data.current.value == nil or
            data.current.value == '') then
          return
        end

        menu.close()
        OpenPersonalActions()
      end,
      function(data, menu)
        menu.close()
      end)
  end, GetPlayerServerId(targetPlayer))
end

function OpenPlayerInventory()
  local targetPlayer, targetDistance = ESX.Game.GetClosestPlayer()

  if (targetPlayer == -1 or targetDistance > 1.5) then
    ESX.ShowNotification(_U('no_player_close'))
    return
  end

  TargetPlayerInventory(targetPlayer)
end

function TargetPlayerInventory(targetPlayer)
  ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:getPlayerInventory', function(targetInventory)
    local elements = {
      { label = _U('target_steam', targetInventory.player.name), value = '', disabled = true },
    }

    if (#targetInventory.items > 0) then
      table.insert(elements, { label = _U('products'), value = '', disabled = true })

      for _, item in pairs(targetInventory.items) do
        if (item.count > 0) then
            local productLabel = '<strong>' .. item.label .. '</strong> ' .. item.count

            table.insert(elements, { label = productLabel, value = item.name })
        end
      end
    end

    if (targetInventory.blackMoney > 0) then
      table.insert(elements, { label = _U('black_money_label'), value = '', disabled = true })
      table.insert(elements, { label = _U('black_money', format_num(targetInventory.blackMoney, 0, '€ ')), value = 'black_money' })
    end

    if (#targetInventory.weapons > 0) then
      table.insert(elements, { label = _U('weapons_label'), value = '', disabled = true })

      for _, weapon in pairs(targetInventory.weapons) do
          local label = ESX.GetWeaponLabel(weapon.name)
          table.insert(elements, { label = _U('trunk_weapon', label, weapon.ammo ), value = weapon.name })
      end
    end

    ESX.UI.Menu.Open(
      'ml',
      GetCurrentResourceName(),
      'job_' .. Config.JobName .. '_inventory',
      {
        title = _U('target_inventory'),
        align = 'top-left',
        css = Config.JobName .. '_actions',
        elements = elements
      },
      function(data, menu)
        if (data.current.value == nil or
            data.current.value == '') then
          return
        end

        ESX.TriggerServerCallback('ml_' .. Config.JobName .. 'job:stealItemFromPlayer', function(done, item, count)
          TargetPlayerInventory(targetPlayer)
        end, GetPlayerServerId(targetPlayer), data.current.value)
      end,
      function(data, menu)
        menu.close()
      end)
  end, GetPlayerServerId(targetPlayer))
end

function HijackVehicle()
  local playerPed = GetPlayerPed(-1)
  local coords    = GetEntityCoords(playerPed)

  if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 3.0) then
    local vehicle = GetClosestVehicle(coords.x,  coords.y,  coords.z,  3.0,  0,  71)

    if DoesEntityExist(vehicle) then
      Citizen.CreateThread(function()
        TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_WELDING", 0, true)

        Wait(8000)

        ClearPedTasksImmediately(playerPed)

        SetVehicleDoorsLocked(vehicle, 1)
        SetVehicleDoorsLockedForAllPlayers(vehicle, false)
        PlayVehicleDoorOpenSound(vehicle, 0)

        ESX.ShowNotification(_U('vehicle_is_open'))
      end)
    else
      ESX.ShowNotification(_U('no_vehicle_close'))
    end
  end
end

RegisterNetEvent('mlx:setJob')
AddEventHandler('mlx:setJob', function(job)
	PlayerData.job = job
end)

RegisterNetEvent('mlx:setJob2')
AddEventHandler('mlx:setJob2', function(job)
	PlayerData.job2 = job
end)