-- ============================================================
--  novalife_ems — server.lua
-- ============================================================

RegisterNetEvent('novalife_ems:toggleDuty', function()
    local src = source
    if not exports.novalife_core:HasJob(src, 'ambulance') then return end
    local p = exports.novalife_core:GetPlayer(src)
    p.job.onDuty = not p.job.onDuty
    TriggerClientEvent('novalife_core:client:updateJob', src, p.job)
    TriggerClientEvent('novalife_ems:client:setDuty', src, p.job.onDuty)
    NLNotify(src, 'inform', 'EMS', p.job.onDuty and 'Prise de service.' or 'Fin de service.')
end)

-- Soins / réanimation
RegisterNetEvent('novalife_ems:heal', function(targetSrc, kind)
    local src = source
    if not exports.novalife_core:HasJob(src, 'ambulance', 0) then return end
    if not exports.novalife_core:CheckDistance(src, GetEntityCoords(GetPlayerPed(targetSrc)), 4.0) then return end
    TriggerClientEvent('novalife_ems:client:heal', targetSrc, kind)
    exports.novalife_core:Log('arrest', '🚑 Soin', ('%s soigne %s (%s)'):format(exports.novalife_core:GetPlayer(src).name, exports.novalife_core:GetPlayer(targetSrc).name, kind), 5763719)
end)

-- Facture EMS
RegisterNetEvent('novalife_ems:bill', function(targetSrc, amount, reason)
    local src = source
    if not exports.novalife_core:HasJob(src, 'ambulance', 0) then return end
    TriggerEvent('novalife_billing:send', targetSrc, amount, reason or 'Soins EMS')
end)

-- Respawn d'un joueur mort (serveur autorise)
RegisterNetEvent('novalife_ems:revive', function(targetSrc)
    local src = source
    if not exports.novalife_core:HasJob(src, 'ambulance', 0) then return end
    if not exports.novalife_core:CheckDistance(src, GetEntityCoords(GetPlayerPed(targetSrc)), 4.0) then return end
    TriggerClientEvent('novalife_ems:client:revive', targetSrc)
end)
