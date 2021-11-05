local spawnedmeths = 0
local methPlants = {}
local isPickingUp, isProcessing = false, false

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(500)
		local coords = GetEntityCoords(PlayerPedId())

		if GetDistanceBetweenCoords(coords, Config.CircleZones.methField.coords, true) < 50 then
			SpawnmethPlants()
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)

		if GetDistanceBetweenCoords(coords, Config.CircleZones.methProcessing.coords, true) < 1 then
			if not isProcessing then
				ESX.ShowHelpNotification(_U('meth_processprompt'))
			end

			if IsControlJustReleased(0, 38) and not isProcessing then
				if Config.LicenseEnable then
					ESX.TriggerServerCallback('esx_license:checkLicense', function(hasProcessingLicense)
						if hasProcessingLicense then
							Processmeth()
						else
							OpenBuyLicenseMenu('meth_processing')
						end
					end, GetPlayerServerId(PlayerId()), 'meth_processing')
				else
					ESX.TriggerServerCallback('esx_meth:meth_count', function(xmeth)
						Processmeth(xmeth)
					end)
					
				end
			end
		else
			Citizen.Wait(500)
		end
	end
end)

function Processmeth(xmeth)
	isProcessing = true
	ESX.ShowNotification(_U('meth_processingstarted'))
  TriggerServerEvent('esx_meth:processmeth')
	if(xmeth <= 3) then
		xmeth = 0
	end
  local timeLeft = (Config.Delays.methProcessing * xmeth) / 1000
	local playerPed = PlayerPedId()

	while timeLeft > 0 do
		Citizen.Wait(1000)
		timeLeft = timeLeft - 1

		if GetDistanceBetweenCoords(GetEntityCoords(playerPed), Config.CircleZones.methProcessing.coords, false) > 4 then
			ESX.ShowNotification(_U('meth_processingtoofar'))
			TriggerServerEvent('esx_meth:cancelProcessing')
			TriggerServerEvent('esx_meth:outofbound')
			break
		end
	end

	isProcessing = false
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)
		local nearbyObject, nearbyID

		for i=1, #methPlants, 1 do
			if GetDistanceBetweenCoords(coords, GetEntityCoords(methPlants[i]), false) < 1 then
				nearbyObject, nearbyID = methPlants[i], i
			end
		end

		if nearbyObject and IsPedOnFoot(playerPed) then
			if not isPickingUp then
				ESX.ShowHelpNotification(_U('meth_pickupprompt'))
			end

			if IsControlJustReleased(0, 38) and not isPickingUp then
				isPickingUp = true

				ESX.TriggerServerCallback('esx_meth:canPickUp', function(canPickUp)
					if canPickUp then
						TaskStartScenarioInPlace(playerPed, 'world_human_gardener_plant', 0, false)

						Citizen.Wait(2000)
						ClearPedTasks(playerPed)
						Citizen.Wait(1500)
		
						ESX.Game.DeleteObject(nearbyObject)
		
						table.remove(methPlants, nearbyID)
						spawnedmeths = spawnedmeths - 1
		
						TriggerServerEvent('esx_meth:pickedUpmeth')
					else
						ESX.ShowNotification(_U('meth_inventoryfull'))
					end

					isPickingUp = false
				end, 'meth')
			end
		else
			Citizen.Wait(500)
		end
	end
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		for k, v in pairs(methPlants) do
			ESX.Game.DeleteObject(v)
		end
	end
end)

function SpawnmethPlants()
	while spawnedmeths < 25 do
		Citizen.Wait(0)
		local methCoords = GeneratemethCoords()

		ESX.Game.SpawnLocalObject('prop_weed_02', methCoords, function(obj)
			PlaceObjectOnGroundProperly(obj)
			FreezeEntityPosition(obj, true)

			table.insert(methPlants, obj)
			spawnedmeths = spawnedmeths + 1
		end)
	end
end

function ValidatemethCoord(plantCoord)
	if spawnedmeths > 0 then
		local validate = true

		for k, v in pairs(methPlants) do
			if GetDistanceBetweenCoords(plantCoord, GetEntityCoords(v), true) < 5 then
				validate = false
			end
		end

		if GetDistanceBetweenCoords(plantCoord, Config.CircleZones.methField.coords, false) > 50 then
			validate = false
		end

		return validate
	else
		return true
	end
end

function GeneratemethCoords()
	while true do
		Citizen.Wait(1)

		local methCoordX, methCoordY

		math.randomseed(GetGameTimer())
		local modX = math.random(-90, 90)

		Citizen.Wait(100)

		math.randomseed(GetGameTimer())
		local modY = math.random(-90, 90)

		methCoordX = Config.CircleZones.methField.coords.x + modX
		methCoordY = Config.CircleZones.methField.coords.y + modY

		local coordZ = GetCoordZ(methCoordX, methCoordY)
		local coord = vector3(methCoordX, methCoordY, coordZ)

		if ValidatemethCoord(coord) then
			return coord
		end
	end
end

function GetCoordZ(x, y)
	local groundCheckHeights = { 48.0, 49.0, 50.0, 51.0, 52.0, 53.0, 54.0, 55.0, 56.0, 57.0, 58.0 }

	for i, height in ipairs(groundCheckHeights) do
		local foundGround, z = GetGroundZFor_3dCoord(x, y, height)

		if foundGround then
			return z
		end
	end

	return 43.0
end
