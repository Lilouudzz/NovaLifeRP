-- ============================================================
--  novalife_fire — server.lua
-- ============================================================

RegisterNetEvent('novalife_fire:toggleDuty', function()
    local src = source
    if not exports.novalife_core:HasJob(src, 'fire') then return end
    local p = exports.novalife_core:GetPlayer(src)
    p.job.onDuty = not p.job.onDuty
    TriggerClientEvent('novalife_core:client:updateJob', src, p.job)
    TriggerClientEvent('novalife_fire:client:setDuty', src, p.job.onDuty)
    NLNotify(src, 'inform', 'Pompiers', p.job.onDuty and 'Prise de service.' or 'Fin de service.')
end)

-- Sauvetage (réanimation + soin)
RegisterNetEvent('novalife_fire:rescue', function(targetSrc)
    local src = source
    if not exports.novalife_core:HasJob(src, 'fire', 0) then return end
    if not exports.novalife_core:CheckDistance(src, GetEntityCoords(GetPlayerPed(targetSrc)), 5.0) then return end
    TriggerClientEvent('novalife_ems:client:revive', targetSrc)
    exports.novalife_core:Log('arrest', '🔥 Sauvetage', ('%s sauve %s'):format(exports.novalife_core:GetPlayer(src).name, exports.novalife_core:GetPlayer(targetSrc).name), 16776960)
end)
