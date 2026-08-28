-- ============================================================
--  novalife_garages — server.lua
--  Sortie / rangement véhicules (SQL + sécu serveur).
--  Un joueur ne sort QUE ses propres véhicules (ou service métier).
-- ============================================================

local function canUseGarage(src, g)
    if g.type == 'public' then return true end
    if g.type == 'business' and g.job then return exports.novalife_core:HasJob(src, g.job) end
    if g.type == 'police' then return exports.novalife_core:HasJob(src, 'police') end
    if g.type == 'ems' then return exports.novalife_core:HasJob(src, 'ambulance') end
    if g.type == 'fire' then return exports.novalife_core:HasJob(src, 'fire') end
    if g.type == 'mechanic' then return exports.novalife_core:HasJob(src, 'mechanic') end
    return false
end

-- Liste véhicules dispo pour ce joueur dans ce garage
lib.callback.register('novalife_garages:list', function(src, garageId)
    local g = nil
    for _, v in ipairs(Garages) do if v.id == garageId then g = v end end
    if not g or not canUseGarage(src, g) then return { error = 'acces' } end
    local p = exports.novalife_core:GetPlayer(src)
    if not p then return { error = 'joueur' } end

    if g.job then
        -- véhicules de service pour le métier
        local models = Vehicles.serviceVehicles[g.job] or {}
        local out = {}
        for _, m in ipairs(models) do
            local def = Vehicles.list[m]
            out[#out + 1] = { plate = 'SERVICE', vehicle = m, label = def and def.name or m, service = true, fuel = 100, engine = 1000, body = 1000 }
        end
        return { vehicles = out, garage = g }
    end

    local rows = MySQL.query.await('SELECT * FROM player_vehicles WHERE citizenid = ? AND garage = ? AND state = 1', { p.citizenid, g.id })
    local out = {}
    for _, r in ipairs(rows or {}) do
        out[#out + 1] = { plate = r.plate, vehicle = r.vehicle, fuel = r.fuel, engine = r.engine, body = r.body, insurance = r.insurance }
    end
    return { vehicles = out, garage = g }
end)

-- Sortir un véhicule
lib.callback.register('novalife_garages:spawn', function(src, garageId, plate)
    local g = nil
    for _, v in ipairs(Garages) do if v.id == garageId then g = v end end
    if not g or not canUseGarage(src, g) then return { error = 'acces' } end
    if not exports.novalife_core:CanDo(src, 'garageOut') then return { error = 'cooldown' } end
    local p = exports.novalife_core:GetPlayer(src)
    if not p then return { error = 'joueur' } end

    local model, fuel, engine, body
    if plate == 'SERVICE' then
        -- choix d'un modèle de service via menu client (on reçoit vehicle dans data)
        return { error = 'choisir_modele' }
    end
    local row = MySQL.query.await('SELECT * FROM player_vehicles WHERE plate = ? AND citizenid = ? AND state = 1', { plate, p.citizenid })
    if not row or not row[1] then return { error = 'introuvable' } end
    row = row[1]
    model, fuel, engine, body = row.vehicle, row.fuel, row.engine, row.body
    MySQL.update('UPDATE player_vehicles SET state = 0 WHERE plate = ?', { plate })
    -- donner la clé
    MySQL.insert('INSERT IGNORE INTO vehicle_keys (plate, citizenid, have_key) VALUES (?, ?, 1)', { plate, p.citizenid })
    return { success = true, vehicle = model, plate = plate, coords = { x = g.spawn.x, y = g.spawn.y, z = g.spawn.z }, fuel = fuel, engine = engine, body = body }
end)

-- Spawn service (méthode)
lib.callback.register('novalife_garages:spawnService', function(src, garageId, model)
    local g = nil
    for _, v in ipairs(Garages) do if v.id == garageId then g = v end end
    if not g or not canUseGarage(src, g) then return { error = 'acces' } end
    local allowed = Vehicles.serviceVehicles[g.job] or {}
    local ok = false
    for _, m in ipairs(allowed) do if m == model then ok = true end end
    if not ok then return { error = 'modele_interdit' } end
    local plate = 'NV' .. math.random(1000, 9999)
    return { success = true, vehicle = model, plate = plate, coords = { x = g.spawn.x, y = g.spawn.y, z = g.spawn.z }, fuel = 100, engine = 1000, body = 1000, service = true }
end)

-- Ranger un véhicule
RegisterNetEvent('novalife_garages:store', function(plate, garageId, state)
    local src = source
    local p = exports.novalife_core:GetPlayer(src)
    if not p then return end
    -- vérifier propriété OU service
    local row = MySQL.query.await('SELECT * FROM player_vehicles WHERE plate = ?', { plate })
    if row and row[1] and row[1].citizenid == p.citizenid then
        MySQL.update('UPDATE player_vehicles SET state = 1, garage = ?, fuel = ?, engine = ?, body = ? WHERE plate = ?',
            { garageId or row[1].garage, state.fuel or row[1].fuel, state.engine or row[1].engine, state.body or row[1].body, plate })
        TriggerClientEvent('novalife_core:client:notify', src, { type = 'success', title = 'Garage', description = 'Véhicule rangé.' })
    elseif plate:sub(1,2) == 'NV' and (exports.novalife_core:HasJob(src, 'police') or exports.novalife_core:HasJob(src, 'ambulance') or exports.novalife_core:HasJob(src, 'fire') or exports.novalife_core:HasJob(src, 'mechanic')) then
        TriggerClientEvent('novalife_core:client:notify', src, { type = 'success', title = 'Garage', description = 'Véhicule de service rangé.' })
    else
        TriggerClientEvent('novalife_core:client:notify', src, { type = 'error', title = 'Garage', description = 'Ce véhicule ne vous appartient pas.' })
    end
end)
