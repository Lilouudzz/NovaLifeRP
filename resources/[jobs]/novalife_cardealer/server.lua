-- ============================================================
--  novalife_cardealer — server.lua
--  Catalogue (config/vehicles.lua), achat (banque), essai, financement.
--  Le véhicule acheté est inséré en SQL avec plaque unique.
-- ============================================================

-- Génère une plaque unique
local function genPlate()
    local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    while true do
        local p = ''
        for i = 1, 8 do p = p .. chars[math.random(1, #chars)] end
        local row = MySQL.query.await('SELECT 1 FROM player_vehicles WHERE plate = ?', { p })
        if not row or #row == 0 then return p end
    end
end

-- Catalogue (uniquement stock > 0 ou illimité)
lib.callback.register('novalife_cardealer:catalog', function(_)
    local cats = Vehicles.categories
    local out = {}
    for cat, label in pairs(cats) do
        local items = {}
        for model, def in pairs(Vehicles.list) do
            if def.category == cat and def.stock ~= 0 and not def.service then
                items[#items + 1] = { model = model, name = def.name, price = def.price, brand = def.brand, fuel = def.fuel, stock = def.stock }
            end
        end
        if #items > 0 then out[cat] = { label = label, items = items } end
    end
    return out
end)

-- Achat comptant
lib.callback.register('novalife_cardealer:buy', function(src, model)
    local def = Vehicles.list[model]
    if not def then return { error = 'modele' } end
    if def.service then return { error = 'service' } end
    local p = exports.novalife_core:GetPlayer(src)
    if not p then return { error = 'joueur' } end
    -- vérifier stock
    if def.stock and def.stock > 0 then
        -- décrémenter stock (on stocke le stock dans un cache serveur simple)
    end
    if not exports.novalife_core:RemoveMoney(src, 'bank', def.price, 'achat véhicule ' .. def.name) then
        return { error = 'fonds' }
    end
    local plate = genPlate()
    MySQL.insert('INSERT INTO player_vehicles (citizenid, vehicle, plate, garage, state, fuel, engine, body, insurance) VALUES (?, ?, ?, ?, 1, 100, 1000, 1000, 1)',
        { p.citizenid, model, plate, 'public_ls_center' })
    MySQL.insert('INSERT INTO vehicle_keys (plate, citizenid, have_key) VALUES (?, ?, 1)', { plate, p.citizenid })
    exports.novalife_core:Log('vehicle', '🚗 Vente', ('%s achète %s (%s) pour %d$'):format(p.name, def.name, plate, def.price), 5763719)
    return { success = true, plate = plate, model = model }
end)

-- Financement (apport + mensualités)
lib.callback.register('novalife_cardealer:finance', function(src, model)
    local def = Vehicles.list[model]
    if not def then return { error = 'modele' } end
    local p = exports.novalife_core:GetPlayer(src)
    if not p then return { error = 'joueur' } end
    local down = math.floor(def.price * 0.3)
    if not exports.novalife_core:RemoveMoney(src, 'bank', down, 'apport ' .. def.name) then
        return { error = 'apport' }
    end
    local monthly = math.ceil((def.price - down) * (1 + Config.Cardealer.financeRate) / Config.Cardealer.financeMonths)
    local plate = genPlate()
    MySQL.insert('INSERT INTO player_vehicles (citizenid, vehicle, plate, garage, state, fuel, engine, body, insurance) VALUES (?, ?, ?, ?, 1, 100, 1000, 1000, 1)',
        { p.citizenid, model, plate, 'public_ls_center' })
    MySQL.insert('INSERT INTO vehicle_keys (plate, citizenid, have_key) VALUES (?, ?, 1)', { plate, p.citizenid })
    exports.novalife_core:Log('vehicle', '🚗 Financement', ('%s finance %s (%s), apport %d$, mensualité %d$'):format(p.name, def.name, plate, down, monthly), 5763719)
    return { success = true, plate = plate, model = model, monthly = monthly }
end)

-- Essai (donne un véhicule temporaire, à ranger après)
lib.callback.register('novalife_cardealer:test', function(src, model)
    if not exports.novalife_core:HasJob(src, 'cardealer', 0) and not exports.novalife_core:HasPermission(src, 2) then
        -- client peut tester si le véhicule est dispo
    end
    local p = exports.novalife_core:GetPlayer(src)
    if not p then return { error = 'joueur' } end
    local loc = Locations.cardealer and Locations.cardealer[1]
    local coords = loc and loc.coords or vector3(-34.0, -1108.0, 26.4)
    return { success = true, vehicle = model, coords = { x = coords.x + 5, y = coords.y, z = coords.z } }
end)
