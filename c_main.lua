local PlayerData              = {}

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

ESX = nil
Citizen.CreateThread( function()
	while ESX == nil do
		Citizen.Wait(500)
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
	end
end)

local doorList = Config.Doors
local key

function DrawText3d(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())

    if onScreen then
        SetTextScale(0.2, 0.2)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 55)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
		DrawText(_x,_y)
    end
end


Citizen.CreateThread(function()
	while true do
		local playerPed = GetPlayerPed(-1)
		local playerCoords = GetEntityCoords(playerPed)
		for i = 1, #doorList do
			
			local closeDoor = GetClosestObjectOfType(doorList[i]["x"], doorList[i]["y"], doorList[i]["z"], 1.0, GetHashKey(doorList[i]["objName"]), false, false, false)
			local objectCoordsDraw = GetEntityCoords(closeDoor)
			local playerDistance = GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, doorList[i]["x"], doorList[i]["y"], doorList[i]["z"], true)
			if (playerDistance < 1.2) then
				if doorList[i]["locked"] == true then
					DrawText3d(doorList[i]["txtX"], doorList[i]["txtY"], doorList[i]["txtZ"], "Mit [E] die Tür ~g~aufschließen~s~")
				else
					DrawText3d(doorList[i]["txtX"], doorList[i]["txtY"], doorList[i]["txtZ"], "Mit [E] die Tür ~r~zuschließen~s~")
				end
				if IsControlJustPressed(1,51) then
					TriggerServerEvent('stationLock:checkKey')
					TriggerEvent('esx:showNotification', 'Schlüssel wird gesucht...')
					TriggerEvent('stationLock:playAnim')
					Citizen.Wait(2000)
					if key then
						TriggerEvent('esx:showNotification', 'Schlüssel gefunden')
						if doorList[i]["locked"] == true then
							FreezeEntityPosition(closeDoor, false)
							if(i==10 or i==11) then
								TriggerServerEvent('stationLock:LockDoor', 10, false)
								TriggerServerEvent('stationLock:LockDoor', 11, false)
							elseif(i==12 or i==13) then
								TriggerServerEvent('stationLock:LockDoor', 12, false)
								TriggerServerEvent('stationLock:LockDoor', 13, false)
							else
								TriggerServerEvent('stationLock:LockDoor', i, false)
							end
						else
							FreezeEntityPosition(closeDoor, true)
							if(i==10 or i==11) then
								TriggerServerEvent('stationLock:LockDoor', 10, true)
								TriggerServerEvent('stationLock:LockDoor', 11, true)
							elseif(i==12 or i==13) then
								TriggerServerEvent('stationLock:LockDoor', 12, true)
								TriggerServerEvent('stationLock:LockDoor', 13, true)
							else
								
								TriggerServerEvent('stationLock:LockDoor', i, true)
							end
						end
					else
						TriggerEvent('esx:showNotification', 'Dir fehlt der Schlüssel')
					end
				end
			else
				FreezeEntityPosition(closeDoor, doorList[i]["locked"])
			end
		end
		Citizen.Wait(10)
    end
end)

RegisterNetEvent('stationLock:LockDoor')
AddEventHandler('stationLock:LockDoor', function(door, bool)
	doorList[door]["locked"] = bool
end)

RegisterNetEvent('stationLock:getKey')
AddEventHandler('stationLock:getKey', function(keyCheck)
	if keyCheck then
		key = keyCheck
	else
		key = false
	end
end)

RegisterNetEvent('stationLock:playAnim')
AddEventHandler('stationLock:playAnim', function()
	TaskStartScenarioInPlace(GetPlayerPed(-1), 'WORLD_HUMAN_STAND_MOBILE_UPRIGHT', 0, true)
    Citizen.Wait(3000)
	ClearPedTasksImmediately(GetPlayerPed(-1))
end)


AddEventHandler("playerSpawned", function()
	ESX.TriggerServerCallback('stationLock:checkDoor', function(doors)
		doorList = doors
	end)
end)

