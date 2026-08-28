-- ============================================================
--  novalife_fuel — server.lua
--  Prix du carburant par type (config/economy.lua). Achat validé serveur.
-- ============================================================

lib.callback.register('novalife_fuel:buy', function(src, plate, litres)
    local p = exports.novalife_core:GetPlayer(src)
    if not p then return { error = 'joueur' } end
    if not exports.novalife_core:CanDo(src, 'fuel') then return { error = 'cooldown' } end
    litres = math.floor(tonumber(litres) or 0)
    if litres <= 0 then return { error = 'litres' } end
    -- type de carburant du véhicule
    local row = MySQL.query.await('SELECT vehicle FROM player_vehicles WHERE plate = ?', { plate })
    local vtype = 'essence'
    if row and row[1] then
        local def = Vehicles.list[row[1].vehicle]
        vtype = def and def.fuel or 'essence'
    end
    local price = Economy.Fuel.pricePerLitre[vtype] or Economy.Fuel.pricePerLitre.essence
    local cost = math.ceil(litres * price)
    if not exports.novalife_core:RemoveMoney(src, 'cash', cost, 'carburant') then
        return { error = 'fonds' }
    end
    MySQL.update('UPDATE player_vehicles SET fuel = LEAST(100, fuel + ?) WHERE plate = ?', { litres, plate })
    exports.novalife_core:Log('vehicle', '⛽ Carburant', ('%s a fait le plein: %dL / %d$'):format(p.name, litres, cost), 5763719)
    return { success = true, cost = cost }
end)

-- Sauvegarde du niveau (appelé par le client périodiquement)
RegisterNetEvent('novalife_fuel:save', function(plate, level)
    local src = source
    if type(level) ~= 'number' or level < 0 or level > 100 then return end
    MySQL.update('UPDATE player_vehicles SET fuel = ? WHERE plate = ?', { level, plate:gsub('%s+', '') })
end)
