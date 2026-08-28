-- ============================================================
--  novalife_keys — server.lua
--  Le serveur est la SEULE source de vérité des clés.
--  Un client ne peut JAMAIS créer de clé: tout passe par DB.
-- ============================================================

-- Le joueur a-t-il la clé de cette plaque ?
function HasKey(src, plate)
    local p = exports.novalife_core:GetPlayer(src)
    if not p then return false end
    plate = plate:gsub('%s+', '')
    local row = MySQL.query.await('SELECT have_key FROM vehicle_keys WHERE plate = ? AND citizenid = ?', { plate, p.citizenid })
    if row and row[1] then return row[1].have_key == 1 end
    -- propriétaire du véhicule = clé par défaut
    local v = MySQL.query.await('SELECT citizenid FROM player_vehicles WHERE plate = ?', { plate })
    if v and v[1] and v[1].citizenid == p.citizenid then
        MySQL.insert('INSERT IGNORE INTO vehicle_keys (plate, citizenid, have_key) VALUES (?, ?, 1)', { plate, p.citizenid })
        return true
    end
    return false
end

-- Donner une clé (seul le propriétaire peut donner)
RegisterNetEvent('novalife_keys:give', function(plate, targetSrc)
    local src = source
    local p = exports.novalife_core:GetPlayer(src)
    local tp = exports.novalife_core:GetPlayer(targetSrc)
    if not p or not tp then return end
    plate = plate:gsub('%s+', '')
    local v = MySQL.query.await('SELECT citizenid FROM player_vehicles WHERE plate = ?', { plate })
    if not v or not v[1] or v[1].citizenid ~= p.citizenid then
        TriggerClientEvent('novalife_core:client:notify', src, { type = 'error', title = 'Clés', description = 'Vous n’êtes pas propriétaire.' })
        return
    end
    MySQL.insert('INSERT IGNORE INTO vehicle_keys (plate, citizenid, have_key) VALUES (?, ?, 1)', { plate, tp.citizenid })
    TriggerClientEvent('novalife_core:client:notify', src, { type = 'success', title = 'Clés', description = 'Clé donnée.' })
    TriggerClientEvent('novalife_core:client:notify', targetSrc, { type = 'inform', title = 'Clés', description = 'On vous a donné une clé.' })
end)

-- Retirer une clé
RegisterNetEvent('novalife_keys:remove', function(plate, targetSrc)
    local src = source
    local p = exports.novalife_core:GetPlayer(src)
    if not p then return end
    plate = plate:gsub('%s+', '')
    local v = MySQL.query.await('SELECT citizenid FROM player_vehicles WHERE plate = ?', { plate })
    if not v or not v[1] or v[1].citizenid ~= p.citizenid then return end
    MySQL.update('DELETE FROM vehicle_keys WHERE plate = ? AND citizenid = ?', { plate, tp and tp.citizenid or targetSrc })
end)

-- Verrouillage: le serveur valide la clé avant d'autoriser
lib.callback.register('novalife_keys:canLock', function(src, plate)
    return HasKey(src, plate)
end)

-- Démarrage: le serveur valide la clé (anti-démarrage sans clé)
lib.callback.register('novalife_keys:canStart', function(src, plate)
    return HasKey(src, plate)
end)

exports('HasKey', HasKey)
