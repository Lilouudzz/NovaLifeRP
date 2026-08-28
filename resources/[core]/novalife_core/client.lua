-- ============================================================
--  novalife_core — client.lua
--  Réception des infos joueur + helpers locaux (notif, etc.)
--  Le client ne fait JAMAIS d'opération sensible: tout passe par callbacks/events serveur.
-- ============================================================

local Player = nil

RegisterNetEvent('novalife_core:client:init', function(serverName)
    SendNUIMessage({ action = 'setServerName', data = serverName })
end)

RegisterNetEvent('novalife_core:client:playerReady', function(p)
    Player = p
end)

RegisterNetEvent('novalife_core:client:updateMoney', function(money)
    if Player then Player.money = money end
    SendNUIMessage({ action = 'updateMoney', data = money })
end)

RegisterNetEvent('novalife_core:client:updateJob', function(job)
    if Player then Player.job = job end
    SendNUIMessage({ action = 'updateJob', data = job })
end)

-- Helper local: notif (utilisé par d'autres ressources via event)
RegisterNetEvent('novalife_core:client:notify', function(data)
    if lib and lib.notify then
        lib.notify({ type = data.type or 'inform', title = data.title, description = data.description, duration = data.duration or 5000 })
    end
end)

exports('GetPlayer', function() return Player end)
