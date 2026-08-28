-- ============================================================
--  novalife_police — server.lua
--  Toute la logique serveur. Sécu: job vérifié, distance, cooldown.
-- ============================================================

local Cuffed = {}        -- [targetSrc] = copSrc
local Escorting = {}     -- [copSrc] = targetSrc

-- Prise / fin de service
RegisterNetEvent('novalife_police:toggleDuty', function()
    local src = source
    if not exports.novalife_core:HasJob(src, 'police') then return end
    local p = exports.novalife_core:GetPlayer(src)
    p.job.onDuty = not p.job.onDuty
    TriggerClientEvent('novalife_core:client:updateJob', src, p.job)
    TriggerClientEvent('novalife_police:client:setDuty', src, p.job.onDuty)
    NLNotify(src, 'inform', 'Police', p.job.onDuty and 'Prise de service.' or 'Fin de service.')
end)

-- Menotter (distance check)
RegisterNetEvent('novalife_police:cuff', function(targetSrc)
    local src = source
    if not exports.novalife_core:HasJob(src, 'police', 0) then return end
    local tp = exports.novalife_core:GetPlayer(targetSrc)
    if not tp then return end
    if not exports.novalife_core:CheckDistance(src, GetEntityCoords(GetPlayerPed(targetSrc)), 3.0) then
        NLNotify(src, 'error', 'Police', 'Trop loin.'); return
    end
    Cuffed[targetSrc] = Cuffed[targetSrc] and nil or src
    TriggerClientEvent('novalife_police:client:cuff', targetSrc, Cuffed[targetSrc] ~= nil)
    exports.novalife_core:Log('arrest', '🔗 Menottes', ('%s menotte %s'):format(exports.novalife_core:GetPlayer(src).name, tp.name), 16776960)
end)

-- Escorter
RegisterNetEvent('novalife_police:escort', function(targetSrc)
    local src = source
    if not Cuffed[targetSrc] or Cuffed[targetSrc] ~= src then return end
    Escorting[src] = Escorting[src] == targetSrc and nil or targetSrc
    TriggerClientEvent('novalife_police:client:escort', targetSrc, src, Escorting[src] == targetSrc)
end)

-- Fouille (inventaire du joueur)
lib.callback.register('novalife_police:search', function(src, targetSrc)
    if not exports.novalife_core:HasJob(src, 'police', 0) then return { error = 'job' } end
    local tp = exports.novalife_core:GetPlayer(targetSrc)
    if not tp then return { error = 'joueur' } end
    if not exports.novalife_core:CheckDistance(src, GetEntityCoords(GetPlayerPed(targetSrc)), 3.0) then return { error = 'distance' } end
    local items = exports.ox_inventory:Search(targetSrc, 'slots') or {}
    return { items = items, identity = tp.identity, name = tp.name }
end)

-- Saisir un item
RegisterNetEvent('novalife_police:seizeItem', function(targetSrc, item, count)
    local src = source
    if not exports.novalife_core:HasJob(src, 'police', 0) then return end
    if not exports.novalife_core:CheckDistance(src, GetEntityCoords(GetPlayerPed(targetSrc)), 3.0) then return end
    exports.ox_inventory:RemoveItem(targetSrc, item, count or 1)
    exports.novalife_core:Log('arrest', '📦 Saisie', ('%s saisit %dx %s à %s'):format(exports.novalife_core:GetPlayer(src).name, count or 1, item, exports.novalife_core:GetPlayer(targetSrc).name), 16776960)
end)

-- Amende (via facture)
RegisterNetEvent('novalife_police:fine', function(targetSrc, amount, reason)
    local src = source
    if not exports.novalife_core:HasJob(src, 'police', 0) then return end
    if not exports.novalife_core:CheckDistance(src, GetEntityCoords(GetPlayerPed(targetSrc)), 5.0) then return end
    TriggerEvent('novalife_billing:send', targetSrc, amount, reason or 'Amende')
end)

-- Arrestation / cellule
RegisterNetEvent('novalife_police:arrest', function(targetSrc, time)
    local src = source
    if not exports.novalife_core:HasJob(src, 'police', 0) then return end
    if not exports.novalife_core:CanDo(src, 'arrest') then return end
    local tp = exports.novalife_core:GetPlayer(targetSrc)
    if not tp then return end
    if not exports.novalife_core:CheckDistance(src, GetEntityCoords(GetPlayerPed(targetSrc)), 5.0) then return end
    time = math.min(math.max(tonumber(time) or 60, 30), 600)
    MySQL.insert('INSERT INTO criminal_records (citizenid, charges, officer, date) VALUES (?, ?, ?, NOW())',
        { tp.citizenid, ('Arrestation %d min'):format(time), exports.novalife_core:GetPlayer(src).name })
    TriggerClientEvent('novalife_police:client:jail', targetSrc, time)
    exports.novalife_core:Log('arrest', '🔒 Arrestation', ('%s arrête %s (%d min)'):format(exports.novalife_core:GetPlayer(src).name, tp.name, time), 10038562)
end)

-- Recherche plaque
lib.callback.register('novalife_police:plate', function(src, plate)
    if not exports.novalife_core:HasJob(src, 'police', 0) then return { error = 'job' } end
    plate = plate:gsub('%s+', '')
    local v = MySQL.query.await('SELECT * FROM player_vehicles WHERE plate = ?', { plate })
    if not v or not v[1] then return { found = false } end
    local owner = MySQL.query.await('SELECT identity FROM identities WHERE citizenid = ?', { v[1].citizenid })
    local name = owner and owner[1] and (owner[1].identity and json.decode(owner[1].identity).firstname .. ' ' .. json.decode(owner[1].identity).lastname) or 'Inconnu'
    return { found = true, vehicle = v[1].vehicle, owner = name, citizenid = v[1].citizenid, stolen = (v[1].state == 2) }
end)

-- Casier judiciaire
lib.callback.register('novalife_police:records', function(src, citizenid)
    if not exports.novalife_core:HasJob(src, 'police', 0) then return { error = 'job' } end
    local rows = MySQL.query.await('SELECT * FROM criminal_records WHERE citizenid = ? ORDER BY date DESC', { citizenid })
    return rows or {}
end)

-- Mandat
lib.callback.register('novalife_police:warrants', function(src)
    if not exports.novalife_core:HasJob(src, 'police', 0) then return { error = 'job' } end
    local rows = MySQL.query.await('SELECT * FROM warrants WHERE active = 1')
    return rows or {}
end)

lib.callback.register('novalife_police:addWarrant', function(src, citizenid, reason)
    if not exports.novalife_core:HasJob(src, 'police', 2) then return { error = 'grade' } end
    MySQL.insert('INSERT INTO warrants (citizenid, reason, issued_by, active) VALUES (?, ?, ?, 1)', { citizenid, reason, exports.novalife_core:GetPlayer(src).name })
    return { success = true }
end)

-- Fourrière
lib.callback.register('novalife_police:impound', function(src, plate)
    if not exports.novalife_core:HasJob(src, 'police', 0) then return { error = 'job' } end
    plate = plate:gsub('%s+', '')
    MySQL.update('UPDATE player_vehicles SET state = 2 WHERE plate = ?', { plate })
    MySQL.insert('INSERT INTO impound (plate, citizenid, reason, fee) VALUES (?, (SELECT citizenid FROM player_vehicles WHERE plate = ?), ?, 500) ON DUPLICATE KEY UPDATE reason = ?',
        { plate, plate, 'Fourrière police', 'Fourrière police' })
    exports.novalife_core:Log('vehicle', '🚓 Fourrière', ('%s met %s en fourrière'):format(exports.novalife_core:GetPlayer(src).name, plate), 10038562)
    return { success = true }
end)

-- Dispatch (log + notif équipes)
RegisterNetEvent('novalife_police:dispatch', function(code, coords, info)
    local src = source
    if not exports.novalife_core:HasJob(src, 'police', 0) and not exports.novalife_core:HasJob(src, 'ambulance', 0) then return end
    local msg = ('🚨 DISPATCH [%s] %s'):format(code, info or '')
    -- notifier tous les LEO/EMS en service
    for s, pl in pairs(Core.Players) do
        if (pl.job.name == 'police' or pl.job.name == 'ambulance') and pl.job.onDuty then
            TriggerClientEvent('novalife_core:client:notify', s, { type = 'inform', title = 'Dispatch', description = msg })
        end
    end
    exports.novalife_core:Log('arrest', '🚨 Dispatch', msg, 16776960)
end)

-- Radar (vitesse) — le client envoie la vitesse du véhicule visé
RegisterNetEvent('novalife_police:radar', function(plate, speed)
    local src = source
    if not exports.novalife_core:HasJob(src, 'police', 0) then return end
    if speed > 130 then
        exports.novalife_core:Log('arrest', '📡 Radar', ('%s à %d km/h'):format(plate, speed), 16776960)
    end
    TriggerClientEvent('novalife_police:client:radarResult', src, plate, speed)
end)

-- Export: plaque via MDT
exports('RunPlate', function(src, plate) return lib.callback.await('novalife_police:plate', src, plate) end)
