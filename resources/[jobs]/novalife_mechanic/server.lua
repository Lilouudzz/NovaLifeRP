-- ============================================================
--  novalife_mechanic — server.lua
--  Réparations validées serveur (santé moteur/carrosserie SQL).
-- ============================================================

local Prices = { repair = 1500, wash = 200, paint = 1200, engine = 4000, brakes = 2500, transmission = 3000, suspension = 2000, body = 1800 }

RegisterNetEvent('novalife_mechanic:toggleDuty', function()
    local src = source
    if not exports.novalife_core:HasJob(src, 'mechanic') then return end
    local p = exports.novalife_core:GetPlayer(src)
    p.job.onDuty = not p.job.onDuty
    TriggerClientEvent('novalife_core:client:updateJob', src, p.job)
end)

-- Réparation d'un véhicule (propriétaire ou service)
RegisterNetEvent('novalife_mechanic:repair', function(plate, kind)
    local src = source
    if not exports.novalife_core:HasJob(src, 'mechanic', 0) then return end
    plate = plate:gsub('%s+', '')
    local veh = GetVehiclePedIsIn(GetPlayerPed(src), false)
    if veh == 0 then return end
    -- vérifier que c'est bien le véhicule visé
    if GetVehicleNumberPlateText(veh):gsub('%s+', '') ~= plate then return end
    local cost = Prices[kind] or Prices.repair
    MySQL.update('UPDATE player_vehicles SET engine = 1000, body = 1000 WHERE plate = ?', { plate })
    TriggerClientEvent('novalife_mechanic:client:apply', src, kind)
    exports.novalife_core:Log('money', '🔧 Mécano', ('%s répare %s (%s, %d$)'):format(exports.novalife_core:GetPlayer(src).name, plate, kind, cost), 5763719)
end)

-- Facture mécano
RegisterNetEvent('novalife_mechanic:bill', function(targetSrc, amount, reason)
    local src = source
    if not exports.novalife_core:HasJob(src, 'mechanic', 0) then return end
    TriggerEvent('novalife_billing:send', targetSrc, amount, reason or 'Réparation')
end)

exports('Prices', Prices)
