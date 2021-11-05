Config = {}

Config.Locale = 'en'

Config.Delays = {
	methProcessing = 100 * 7
}

Config.DrugDealerItems = {
	marijuana = 8000,
	packed_meth = 8000,
}

Config.LicenseEnable = true -- enable processing licenses? The player will be required to buy a license in order to process drugs. Requires esx_license

Config.LicensePrices = {
	meth_processing = {label = _U('license_meth'), price = 15000}
}

Config.GiveBlack = true -- give black money? if disabled it'll give regular cash.

Config.CircleZones = {
	methField = {coords = vector3(-38.2, 3677.8, 39.0), name = _U('blip_methfield'), color = 25, sprite = 496, radius = 100.0},
	methProcessing = {coords = vector3(56.4, 3691.1, 39.9), name = _U('blip_methprocessing'), color = 25, sprite = 496},

	DrugDealer = {coords = vector3(-1172.02, -1571.98, 4.66), name = _U('blip_drugdealer'), color = 6, sprite = 378},
}