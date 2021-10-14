ESX = nil
local ryostetaan = false
local lopettanut = false
local jutellaan = false
local hackkeringgi = false
local Juteltu = false
local myyty = false
local hacked = false
local tallennettuSalasana = {}
local tallennettuPinKoodi = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) 
			ESX = obj 
		end)
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
	RequestModel(GetHashKey("a_m_m_hasjew_01"))
	while not HasModelLoaded(GetHashKey("a_m_m_hasjew_01")) do
	  	Wait(1)
	end

	ped =  CreatePed(4, "a_m_m_hasjew_01", Config.StartPed.Coords.x, Config.StartPed.Coords.y, Config.StartPed.Coords.z-0.98, 3374176, false, true) -- miinus 0.98 asettaa npc pedin maahan
	SetEntityHeading(ped, Config.StartPed.Heading)
	FreezeEntityPosition(ped, true)
	SetEntityInvincible(ped, true)
	SetBlockingOfNonTemporaryEvents(ped, true)
    while true do
        Citizen.Wait(0)
        local xPly = PlayerPedId()
        local pedcoords = GetEntityCoords(xPly)
		local npcC = GetEntityCoords(ped)
        if Vdist(pedcoords, npcC) <= 1.5 then
			if not jutellaan then
				Texti(npcC.x, npcC.y, npcC.z, "E - Juttele Pasille")
				if IsControlJustPressed(0,38) then
					if not ryostetaan then
						TriggerServerEvent("esx_cat_humanelabs:aloita")
					end
				end
			end
		end

		if Juteltu then
			if Vdist(pedcoords, Config.LaptopCoords) <= 1.2 then
				if not hackkeringgi then
					Texti(Config.LaptopCoords.x, Config.LaptopCoords.y, Config.LaptopCoords.z, "E - Hakkeroi")
					if IsControlJustPressed(0, 38) then
						if not hacked then
							Wait(500)
							maxLength = 8
							AddTextEntry("Panos!", "Syötä salasana")
							DisplayOnscreenKeyboard(1, "Panos!", "", "", "", "", "", maxLength)

							while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
								Citizen.Wait( 0 )
							end
							local salasana = GetOnscreenKeyboardResult()

							if salasana ~= tallennettuSalasana then
								ESX.ShowNotification("~r~Salasana oli väärä!")
								--Tähän voi lisätä halutessaan jonku sähköisku eventin
							else
								hackkeringgi = true
								--Tähän kohtaan omat poliisinotifyt, mulla on tossa alhaalla lindenin versioon
								TriggerServerEvent("dispatch:lab", Config.LaptopCoords)
								SetEntityHeading(PlayerPedId(), 162.01419067383)
								exports['progbar']:Progress({
									name = "hakkinggi",
									duration = Config.KauankoKestaa,
									label = 'Hakkeroidaan!',
									useWhileDead = true,
									canCancel = true,
									controlDisables = {
										disableMovement = true,
										disableCarMovement = true,
										disableMouse = false,
										disableCombat = true,
									},
									animation = {
										animDict = "mp_prison_break",
										anim = "hack_loop",
										flags = 49,
									},
								}, function(cancelled)
									if not cancelled then
										hackkeringgi = false
										local randomPassword = math.random(10000, 99999)
										tallennettuPinKoodi = randomPassword
										hacked = true
										NotifyAndCreatePed(tallennettuPinKoodi)
									else
										hackkeringgi = false
									end
								end)
							end
						else
							ESX.ShowNotification("Tietokone ollaan jo murrettu!")
						end
					end
				end
			end
		end

		if sombreroUkko then
			if not myyty then
				if Vdist(pedcoords, GetEntityCoords(sombreroUkko)) <= 1.2 then
					Texti(GetEntityCoords(sombreroUkko).x, GetEntityCoords(sombreroUkko).y, GetEntityCoords(sombreroUkko).z, "E - Juttele Jykälle")
					if IsControlJustPressed(0, 38) then
						print(tallennettuPinKoodi)
						Wait(500)
						AddTextEntry("Panos!", "Anna pinkoodi")
						DisplayOnscreenKeyboard(1, "Panos!", "", "", "", "", "", 5)

						while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
							Citizen.Wait( 0 )
						end
						local pinCode = GetOnscreenKeyboardResult()
						pinCode = tonumber(pinCode)
						if pinCode == tallennettuPinKoodi then
							myyty = true
							exports['progbar']:Progress({
								name = "sellInfo",
								duration = 25000,
								label = 'Myydään tietoja',
								useWhileDead = true,
								canCancel = true,
								controlDisables = {
									disableMovement = true,
									disableCarMovement = true,
									disableMouse = false,
									disableCombat = true,
								},
								animation = {
									animDict = "oddjobs@assassinate@vice@hooker",
									anim = "argue_a",
									flags = 49,
								},
							}, function(cancelled)
								if not cancelled then
									Wait(150)
									TriggerServerEvent("esx_cat_humanelabs:jobFinished")
								end
							end)
						else
							ESX.ShowNotification("~r~Jykä: Mulle ei väärää tietoa myydä!")
							SetPedToRagdoll(PlayerPedId(), 20000, 20000, 2, false, false, false)
							DoScreenFadeOut(200)
							-- Tähän voipi lisätä jonku esim verenvuoto eventin
							Wait(15000)
							DoScreenFadeIn(700)
						end
					end
				end
			end
		end
	end
end)

function Texti(x, y, z, text)
	local onScreen,_x,_y=World3dToScreen2d(x,y,z)
	local factor = #text / 370
	local px,py,pz=table.unpack(GetGameplayCamCoords())
	
	SetTextScale(0.35, 0.35)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 215)
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(_x,_y)
	DrawRect(_x,_y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 120)
end

NotifyAndCreatePed = function(passu)
	tallennettuPinKoodi = passu
	ESX.ShowNotification("Käy myymässä salasana ~g~"..tallennettuPinKoodi.."~s~ karttaan merkatulla alueella!")
	local ve = Config.FakAlue[math.random(1, #Config.FakAlue)] --Luo sijainnin randomilla, Näitä voi muokata / lisätä Configista :P
	local blipi = AddBlipForRadius(ve.x, ve.y, ve.z, 500.0)
	CreateNPC(ve)
	SetBlipColour(blipi, 1)
	SetBlipAlpha(blipi, 50)
	Wait(15000)
	SetBlipAlpha(blipi, 25)
	Wait(15000)
	RemoveBlip(blipi)
end

RegisterNetEvent("esx_cat_humanelabs:kaikkiNollille")
AddEventHandler("esx_cat_humanelabs:kaikkiNollille", function()
	FreezeEntityPosition(sombreroUkko, false)
	SetEntityInvincible(sombreroUkko, false)
	SetBlockingOfNonTemporaryEvents(sombreroUkko, false)
	SetPedAsNoLongerNeeded(sombreroUkko)
	tallennettuPinKoodi = nil
	tallennettuSalasana = nil
	sombreroUkko = false
	Juteltu = false
	myyty = false
	hacked = false
end)

RegisterNetEvent("esx_cat_humanelabs:animation")
AddEventHandler("esx_cat_humanelabs:animation", function()
	jutellaan = true
    exports['progbar']:Progress({
        name = "talkking",
        duration = 9999,
        label = 'Jutellaan pasille!',
        useWhileDead = true,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "oddjobs@assassinate@vice@hooker",
            anim = "argue_a",
            flags = 49,
        },
    }, function(cancelled)
        if not cancelled then
			jutellaan = false
			local randomPassu = TehdaanSalasana()
			ESX.ShowNotification("Mene merkattuun sijaintiin ja syötä salasana "..randomPassu)
			Juteltu = true
			SetWaypointOff()
			Wait(50)
			SetNewWaypoint(3536.19, 3659.5)
		end
	end)
end)

CreateNPC = function(coord)
	RequestModel(GetHashKey("s_m_m_mariachi_01"))
	while not HasModelLoaded(GetHashKey("s_m_m_mariachi_01")) do
	  	Wait(1)
	end

	sombreroUkko =  CreatePed(4, "s_m_m_mariachi_01", coord.x, coord.y, coord.z-0.98, 3374176, false, true)
	SetEntityHeading(sombreroUkko, 168.48135375977)
	FreezeEntityPosition(sombreroUkko, true)
	SetEntityInvincible(sombreroUkko, true)
	SetBlockingOfNonTemporaryEvents(sombreroUkko, true)
end

TehdaanSalasana = function()
	local randomNumerot = math.random(1000, 9999)
	local Kirjaimet = "LAB-"
	local finalPlate = (Kirjaimet..""..randomNumerot)
	tallennettuSalasana = finalPlate
	return finalPlate
end





