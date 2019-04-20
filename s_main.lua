ESX = nil
local doorList = Config.Doors

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('stationLock:LockDoor')
AddEventHandler('stationLock:LockDoor', function(door, bool)
	doorList[door]["locked"] = bool
	TriggerClientEvent('stationLock:LockDoor', -1, door, bool)
end)

ESX.RegisterServerCallback('stationLock:checkDoor', function(source, cb)
	cb(doorList)
end)

RegisterServerEvent('stationLock:checkKey')
AddEventHandler('stationLock:checkKey', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xItem = xPlayer.getInventoryItem('stationkey')
	if xItem.count > 0 then
		TriggerClientEvent('stationLock:getKey', _source, true)
	else
		TriggerClientEvent('stationLock:getKey', _source, false)
	end
end)
