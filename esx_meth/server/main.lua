local playersProcessingmeth = {}
local outofbound = true
local alive = true

RegisterServerEvent('esx_meth:sellDrug')
AddEventHandler('esx_meth:sellDrug', function(itemName, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	local price = Config.DrugDealerItems[itemName]
	local xItem = xPlayer.getInventoryItem(itemName)

	if not price then
		print(('esx_meth: %s attempted to sell an invalid drug!'):format(xPlayer.identifier))
		return
	end

	if xItem.count < amount then
		xPlayer.showNotification(_U('dealer_notenough'))
		return
	end

	price = ESX.Math.Round(price * amount)

	if Config.GiveBlack then
		xPlayer.addAccountMoney('black_money', price)
	else
		xPlayer.addMoney(price)
	end

	xPlayer.removeInventoryItem(xItem.name, amount)
	xPlayer.showNotification(_U('dealer_sold', amount, xItem.label, ESX.Math.GroupDigits(price)))
end)

ESX.RegisterServerCallback('esx_meth:buyLicense', function(source, cb, licenseName)
	local xPlayer = ESX.GetPlayerFromId(source)
	local license = Config.LicensePrices[licenseName]

	if license then
		if xPlayer.getMoney() >= license.price then
			xPlayer.removeMoney(license.price)

			TriggerEvent('esx_license:addLicense', source, licenseName, function()
				cb(true)
			end)
		else
			cb(false)
		end
	else
		print(('esx_meth: %s attempted to buy an invalid license!'):format(xPlayer.identifier))
		cb(false)
	end
end)

RegisterServerEvent('esx_meth:pickedUpmeth')
AddEventHandler('esx_meth:pickedUpmeth', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	local cime = math.random(5,10)

	if xPlayer.canCarryItem('meth', cime) then
		xPlayer.addInventoryItem('meth', cime)
	else
		xPlayer.showNotification(_U('meth_inventoryfull'))
	end
end)

ESX.RegisterServerCallback('esx_meth:canPickUp', function(source, cb, item)
	local xPlayer = ESX.GetPlayerFromId(source)
	cb(xPlayer.canCarryItem(item, 1))
end)

RegisterServerEvent('esx_meth:outofbound')
AddEventHandler('esx_meth:outofbound', function()
	outofbound = true
end)

RegisterServerEvent('esx_meth:quitprocess')
AddEventHandler('esx_meth:quitprocess', function()
	can = false
end)

ESX.RegisterServerCallback('esx_meth:meth_count', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xmeth = xPlayer.getInventoryItem('meth').count
	cb(xmeth)
end)

RegisterServerEvent('esx_meth:processmeth')
AddEventHandler('esx_meth:processmeth', function()
  if not playersProcessingmeth[source] then
		local _source = source
		local xPlayer = ESX.GetPlayerFromId(_source)
		local xmeth = xPlayer.getInventoryItem('meth')
		local can = true
		outofbound = false
    if xmeth.count >= 3 then
      while outofbound == false and can do
				if playersProcessingmeth[_source] == nil then
					playersProcessingmeth[_source] = ESX.SetTimeout(Config.Delays.methProcessing , function()
            if xmeth.count >= 3 then
              if xPlayer.canSwapItem('meth', 3, 'packed_meth', 1) then
                xPlayer.removeInventoryItem('meth', 3)
                xPlayer.addInventoryItem('packed_meth', 1)
								xPlayer.showNotification(_U('meth_processed'))
							else
								can = false
								xPlayer.showNotification(_U('meth_processingfull'))
								TriggerEvent('esx_meth:cancelProcessing')
							end
						else						
							can = false
							xPlayer.showNotification(_U('meth_processingenough'))
							TriggerEvent('esx_meth:cancelProcessing')
						end

						playersProcessingmeth[_source] = nil
					end)
				else
					Wait(Config.Delays.methProcessing)
				end	
			end
		else
			xPlayer.showNotification(_U('meth_processingenough'))
			TriggerEvent('esx_meth:cancelProcessing')
		end	
			
	else
		print(('esx_meth: %s attempted to exploit meth processing!'):format(GetPlayerIdentifiers(source)[1]))
	end
end)

function CancelProcessing(playerId)
	if playersProcessingmeth[playerId] then
		ESX.ClearTimeout(playersProcessingmeth[playerId])
		playersProcessingmeth[playerId] = nil
	end
end

RegisterServerEvent('esx_meth:cancelProcessing')
AddEventHandler('esx_meth:cancelProcessing', function()
	CancelProcessing(source)
end)

AddEventHandler('esx:playerDropped', function(playerId, reason)
	CancelProcessing(playerId)
end)

RegisterServerEvent('esx:onPlayerDeath')
AddEventHandler('esx:onPlayerDeath', function(data)
	CancelProcessing(source)
end)
