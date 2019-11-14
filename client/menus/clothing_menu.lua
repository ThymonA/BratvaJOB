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

function OpenClothingMenu()
  ESX.UI.Menu.CloseAll()

  local elements = LoadPlayerClothes()

  ESX.UI.Menu.Open('ml', GetCurrentResourceName(), 'clothing_menu',
    {
      title       = _U('clothing_menu'),
      align       = 'top-left',
      css         = Config.JobName,
      elements    = elements
    },
    function (data, menu)
      local index = data.current.value
      local playerPed = GetPlayerPed(-1)

      SetPedArmour(playerPed, 0)
      ClearPedBloodDamage(playerPed)
      ResetPedVisibleDamage(playerPed)
      ClearPedLastWeaponDamage(playerPed)
      ResetPedMovementClipset(playerPed, 0)

      if (index ~= nil and index > 0 and Config.Outfits[index] ~= nil) then
        local outfit = Config.Outfits[index]

        if outfit ~= nil then
          ESX.TriggerServerCallback('mlx_skin:getPlayerSkin', function(skin, jobSkin)
            local isMale = skin.sex == 0

            TriggerEvent('skinchanger:loadDefaultModel', isMale, function()
              ESX.TriggerServerCallback('mlx_skin:getPlayerSkin', function(skin)
                TriggerEvent('skinchanger:loadClothes', skin, outfit.clothes)
                TriggerEvent('mlx:restoreLoadout')
              end)
            end)
          end)

          TriggerEvent('mlx:restoreLoadout')
        else
          ESX.ShowNotification(_U('no_outfit'))
        end
      else
        ESX.TriggerServerCallback('mlx_skin:getPlayerSkin', function(skin, jobSkin)
					local isMale = skin.sex == 0

					TriggerEvent('skinchanger:loadDefaultModel', isMale, function()
						ESX.TriggerServerCallback('mlx_skin:getPlayerSkin', function(skin)
							TriggerEvent('skinchanger:loadSkin', skin)
							TriggerEvent('mlx:restoreLoadout')
						end)
					end)

				end)
				
				TriggerEvent('mlx:restoreLoadout')
      end
    end,
    function(data, menu)
        menu.close()
    end)
end

function LoadPlayerClothes()
  local clothes = Config.Outfits
  local elements = {}

  for i = 1, #clothes, 1 do
    local name = clothes[i].name

    if (clothes[i].grades ~= nil) then
      local access = true
      local grades = clothes[i].grades

      if (#grades > 0) then
        access = false
        
        for i = 1, #grades, 1 do
          if (grades[i] ~= nil and HasGrade(grades[i])) then
            access = true
          end
        end
      end

      if (access) then
        table.insert(elements, { label = name, value = i })
      end
    else
      table.insert(elements, { label = name, value = i })
    end
  end

  if (#elements > 0) then
    table.insert(elements, { label = _U('default_clothes'), value = 0 })
  end

  return elements
end

function HasGrade(grade)
  local playerGrade = nil
  
  if (PlayerData ~= nil and PlayerData.job ~= nil and PlayerData.job.grade_name ~= nil) then
    playerGrade = string.lower(PlayerData.job.grade_name)
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