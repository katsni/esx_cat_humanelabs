ESX = nil
local timer = false
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent("esx_cat_humanelabs:aloita")
AddEventHandler("esx_cat_humanelabs:aloita", function()
    local _source = source
    local xPlayers = ESX.GetPlayers()
    local cops = 0
    for i=1, #xPlayers, 1 do
     local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
     if xPlayer.job.name == 'police' then
            cops = cops + 1
        end
    end

    if cops >= Config.RequiredCops then
        if not timer then
            TriggerClientEvent("esx_cat_humanelabs:animation", _source)
            Timer()
        else
            TriggerClientEvent("esx:showNotification", _source, "Minulla ei ole juuri nyt töitä!")
        end
    else
        TriggerClientEvent("esx:showNotification", _source, "Poliiseja ei ole tarpeeksi vuorossa")
    end
end)

RegisterServerEvent("esx_cat_humanelabs:jobFinished")
AddEventHandler("esx_cat_humanelabs:jobFinished", function() --Jos modaajia pelkäät niin tän voit muuttaa callbackiksi
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local Reward = Config.Reward
    xPlayer.addAccountMoney("black_money", Reward)
    xPlayer.showNotification("Myit tiedot ja tienasit ~r~$"..Reward)
    Wait(50)
    TriggerClientEvent("esx_cat_humanelabs:kaikkiNollille", _source)
end)

Timer = function() -- Cooldown systeemi suoraa Rainbowin tehtaalta
    timer = true
    ESX.SetTimeout(2100000, function()
        timer = false
    end)
end

RegisterServerEvent("esx_cat_humanelabs:ihmetys")
AddEventHandler("esx_cat_humanelabs:ihmetys", function()
    local _source = source
    TriggerClientEvent("esx_cat_humanelabs:juttu", _source)
end)
