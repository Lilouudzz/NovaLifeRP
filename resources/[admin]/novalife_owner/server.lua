-- ============================================================
--  novalife_owner — server.lua
--  Toutes les actions validées côté serveur. Le grade owner est
--  déterminé UNIQUEMENT par Config.OwnerIdentifiers (license).
--  AUCUNE permission client n'est acceptée.
-- ============================================================

local function getLicense(src)
    return GetPlayerIdentifierByType(src, 'license') or ('license:%s'):format(src)
end

-- VÉRIFICATION OWNER (source de vérité unique)
function IsOwner(src)
    local lic = getLicense(src)
    for _, id in ipairs(Config.OwnerIdentifiers) do
        if id == lic then return true end
    end
    -- fallback: groupe ACE owner
    if IsPlayerAceAllowed(src, 'command.*') then
        local p = exports.novalife_core:GetPlayer(src)
        if p and p.adminGroup == 'owner' then return true end
    end
    return false
end

-- Log owner dédié
local function ownerLog(kind, src, target, oldv, newv)
    local who = GetPlayerName(src) or ('src'..src)
    local lic = getLicense(src)
    local msg = ('Owner=%s | action=%s | cible=%s | old=%s | new=%s'):format(who, kind, target or '-', oldv or '-', newv or '-')
    exports.novalife_core:Log('admin', '👑 OWNER:' .. kind, msg, 16776960)
    MySQL.insert('INSERT INTO server_logs (kind, message, src, ts) VALUES (?, ?, ?, NOW())',
        { 'owner_' .. kind, msg, src })
end

-- =================== OUVERTURE ===================
RegisterCommand('owner', function(src)
    if not IsOwner(src) then
        NLNotify(src, 'error', 'Owner', 'Accès refusé.')
        TriggerClientEvent('novalife_core:client:notify', src, { type='error', title='Owner', description='Vous n’êtes pas le propriétaire.' })
        return
    end
    ownerLog('OWNER_LOGIN', src, nil, nil, nil)
    TriggerClientEvent('novalife_owner:client:open', src)
end, false)

-- =================== LISTE JOUEURS ===================
lib.callback.register('novalife_owner:getPlayers', function(src)
    if not IsOwner(src) then return nil end
    local out = {}
    for s, p in pairs(Core.Players) do
        out[#out+1] = {
            id = s, name = p.name, citizenid = p.citizenid,
            job = p.job.name, grade = p.job.grade,
            cash = p.money.cash, bank = p.money.bank,
            onDuty = p.job.onDuty
        }
    end
    return out
end)

-- =================== ARGENT ===================
RegisterNetEvent('novalife_owner:money', function(action, targetSrc, amount, confirm)
    local src = source
    if not IsOwner(src) then return end
    local t = exports.novalife_utils:FindPlayer(targetSrc)
    if not t then return end
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then return end
    if amount >= Config.Owner.ConfirmThreshold and not confirm then
        TriggerClientEvent('novalife_owner:client:confirmMoney', src, action, targetSrc, amount)
        return
    end
    local old = exports.novalife_core:GetMoney(t, 'cash') .. '/' .. exports.novalife_core:GetMoney(t, 'bank')
    if action == 'give_cash' then exports.novalife_core:AddMoney(t, 'cash', amount, 'owner') end
    if action == 'take_cash' then exports.novalife_core:RemoveMoney(t, 'cash', amount, 'owner') end
    if action == 'give_bank' then exports.novalife_core:AddMoney(t, 'bank', amount, 'owner') end
    if action == 'take_bank' then exports.novalife_core:RemoveMoney(t, 'bank', amount, 'owner') end
    if action == 'set_cash' then
        exports.novalife_core:RemoveMoney(t, 'cash', exports.novalife_core:GetMoney(t,'cash'), 'owner reset')
        exports.novalife_core:AddMoney(t, 'cash', amount, 'owner set')
    end
    if action == 'set_bank' then
        exports.novalife_core:RemoveMoney(t, 'bank', exports.novalife_core:GetMoney(t,'bank'), 'owner reset')
        exports.novalife_core:AddMoney(t, 'bank', amount, 'owner set')
    end
    ownerLog('OWNER_MONEY', src, exports.novalife_core:GetPlayer(t).name, old, action..':'..amount)
end)

-- =================== INVENTAIRE ===================
RegisterNetEvent('novalife_owner:item', function(action, targetSrc, item, count)
    local src = source
    if not IsOwner(src) then return end
    local t = exports.novalife_utils:FindPlayer(targetSrc)
    if not t then return end
    -- vérifier que l'item existe dans ox_inventory
    local def = exports.ox_inventory:Items(item)
    if not def then
        TriggerClientEvent('novalife_core:client:notify', src, { type='error', title='Owner', description='Item inexistant.' })
        return
    end
    count = math.floor(tonumber(count) or 1)
    if action == 'give' then exports.novalife_inventory:GiveItem(src, t, item, count) end
    if action == 'remove' then exports.ox_inventory:RemoveItem(t, item, count) end
    if action == 'set' then
        exports.ox_inventory:RemoveItem(t, item, exports.ox_inventory:Search(t,'count',item) or 0)
        exports.novalife_inventory:GiveItem(src, t, item, count)
    end
    ownerLog('OWNER_ITEM', src, exports.novalife_core:GetPlayer(t).name, item, action..':'..count)
end)

-- =================== JOBS ===================
RegisterNetEvent('novalife_owner:job', function(action, targetSrc, job, grade)
    local src = source
    if not IsOwner(src) then return end
    local t = exports.novalife_utils:FindPlayer(targetSrc)
    if not t then return end
    local old = exports.novalife_core:GetPlayer(t).job.name .. ':' .. exports.novalife_core:GetPlayer(t).job.grade
    if action == 'set' then exports.novalife_core:SetJob(t, job, tonumber(grade) or 0) end
    if action == 'promote' then
        local p = exports.novalife_core:GetPlayer(t)
        exports.novalife_core:SetJob(t, p.job.name, math.min(p.job.grade+1, #Jobs[p.job.name].grades))
    end
    if action == 'demote' then
        local p = exports.novalife_core:GetPlayer(t)
        exports.novalife_core:SetJob(t, p.job.name, math.max(p.job.grade-1, 0))
    end
    if action == 'remove' then exports.novalife_core:SetJob(t, 'unemployed', 0) end
    ownerLog('OWNER_JOB', src, exports.novalife_core:GetPlayer(t).name, old, action..':'..(job or '')..':'..(grade or ''))
end)

-- =================== VÉHICULES ===================
RegisterNetEvent('novalife_owner:vehicle', function(action, targetSrc, model, plate, data)
    local src = source
    if not IsOwner(src) then return end
    local t = targetSrc and exports.novalife_utils:FindPlayer(targetSrc) or src
    if action == 'spawn' then
        if not model then return end
        TriggerClientEvent('novalife_admin:client:spawnCar', src, model)  -- spawn devant owner
        ownerLog('OWNER_VEHICLE', src, 'self', '-', 'spawn:'..model)
    end
    if action == 'repair' or action == 'clean' or action == 'fuel' or action == 'lock' or action == 'unlock' then
        TriggerClientEvent('novalife_owner:client:vehAction', src, action, data or {})
    end
    if action == 'delete' then
        TriggerClientEvent('novalife_owner:client:dv', src)
        ownerLog('OWNER_VEHICLE', src, '-', '-', 'delete')
    end
    if action == 'give' and plate and t then
        MySQL.update('UPDATE player_vehicles SET citizenid = ? WHERE plate = ?', { exports.novalife_core:GetPlayer(t).citizenid, plate })
        MySQL.insert('INSERT IGNORE INTO vehicle_keys (plate, citizenid, have_key) VALUES (?, ?, 1)', { plate, exports.novalife_core:GetPlayer(t).citizenid })
        ownerLog('OWNER_VEHICLE', src, exports.novalife_core:GetPlayer(t).name, plate, 'give')
    end
    if action == 'plate' and plate and data then
        MySQL.update('UPDATE player_vehicles SET plate = ? WHERE plate = ?', { data.newplate, plate })
        ownerLog('OWNER_VEHICLE', src, '-', plate, 'newplate:'..data.newplate)
    end
end)

-- =================== TÉLÉPORTATION ===================
RegisterNetEvent('novalife_owner:tp', function(action, targetSrc)
    local src = source
    if not IsOwner(src) then return end
    local t = exports.novalife_utils:FindPlayer(targetSrc)
    if not t then return end
    if action == 'to' then
        TriggerClientEvent('novalife_admin:client:goto', src, GetEntityCoords(GetPlayerPed(t)))
    end
    if action == 'bring' then
        TriggerClientEvent('novalife_admin:client:bring', t, GetEntityCoords(GetPlayerPed(src)))
    end
end)

RegisterNetEvent('novalife_owner:tp:coords', function(x, y, z)
    local src = source
    if not IsOwner(src) then return end
    TriggerClientEvent('novalife_admin:client:goto', src, vector3(tonumber(x), tonumber(y), tonumber(z)))
end)

-- =================== SANCTIONS ===================
RegisterNetEvent('novalife_owner:sanction', function(action, targetSrc, reason)
    local src = source
    if not IsOwner(src) then return end
    local t = exports.novalife_utils:FindPlayer(targetSrc)
    if not t then return end
    local name = GetPlayerName(t)
    if action == 'kick' then
        DropPlayer(t, 'Kick Owner: ' .. (reason or '')); ownerLog('OWNER_KICK', src, name, '-', reason or '')
    end
    if action == 'ban' then
        local lic = GetPlayerIdentifierByType(t, 'license')
        MySQL.insert('INSERT INTO bans (license, reason, banned_by) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE reason=?, banned_by=?',
            { lic, reason or 'Ban Owner', GetPlayerName(src), reason or 'Ban Owner', GetPlayerName(src) })
        DropPlayer(t, 'Banni par le propriétaire.'); ownerLog('OWNER_BAN', src, name, '-', reason or '')
    end
    if action == 'unban' then
        MySQL.update('DELETE FROM bans WHERE license = ?', { reason })  -- reason = license ici
        ownerLog('OWNER_BAN', src, reason, '-', 'unban')
    end
    if action == 'freeze' then TriggerClientEvent('novalife_admin:client:freeze', t) end
    if action == 'unfreeze' then TriggerClientEvent('novalife_admin:client:freeze', t) end
    if action == 'revive' then TriggerClientEvent('novalife_ems:client:revive', t) end
    if action == 'heal' then TriggerClientEvent('novalife_ems:client:heal', t, 'heal') end
end)

-- =================== SPECTATE ===================
RegisterNetEvent('novalife_owner:spectate', function(targetSrc)
    local src = source
    if not IsOwner(src) then return end
    local t = exports.novalife_utils:FindPlayer(targetSrc)
    if not t then return end
    TriggerClientEvent('novalife_owner:client:spectate', src, t)
end)

-- =================== PROPRIÉTÉS ===================
-- Table créée à la volée
CreateThread(function()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS properties (
            id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(60) NOT NULL,
            price INT NOT NULL DEFAULT 0,
            owner_cid VARCHAR(12) NULL,
            entry JSON NOT NULL,
            exit_pos JSON NOT NULL,
            interior VARCHAR(40) NULL,
            garage JSON NULL,
            stash JSON NULL,
            created_by VARCHAR(40) NULL,
            ts DATETIME DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS property_keys (
            prop_id INT UNSIGNED NOT NULL,
            citizenid VARCHAR(12) NOT NULL,
            PRIMARY KEY (prop_id, citizenid)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
end)

lib.callback.register('novalife_owner:getProperties', function(src)
    if not IsOwner(src) then return nil end
    return MySQL.query.await('SELECT * FROM properties ORDER BY id') or {}
end)

lib.callback.register('novalife_owner:getPropertyKeys', function(src, propId)
    if not IsOwner(src) then return nil end
    return MySQL.query.await('SELECT citizenid FROM property_keys WHERE prop_id = ?', { propId }) or {}
end)

RegisterNetEvent('novalife_owner:property', function(action, data)
    local src = source
    if not IsOwner(src) then return end
    if action == 'create' then
        MySQL.insert('INSERT INTO properties (name, price, entry, exit_pos, interior, garage, stash, created_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
            { data.name, data.price or 0, json.encode(data.entry), json.encode(data.exit_pos), data.interior or '',
              json.encode(data.garage or {}), json.encode(data.stash or {}), GetPlayerName(src) })
        ownerLog('OWNER_PROPERTY', src, '-', '-', 'create:'..data.name)
    end
    if action == 'update' then
        MySQL.update('UPDATE properties SET name=?, price=?, entry=?, exit_pos=?, interior=?, garage=?, stash=? WHERE id=?',
            { data.name, data.price, json.encode(data.entry), json.encode(data.exit_pos), data.interior, json.encode(data.garage or {}), json.encode(data.stash or {}), data.id })
        ownerLog('OWNER_PROPERTY', src, tostring(data.id), '-', 'update')
    end
    if action == 'delete' then
        MySQL.update('DELETE FROM properties WHERE id = ?', { data.id })
        ownerLog('OWNER_PROPERTY', src, tostring(data.id), '-', 'DELETE')
    end
    if action == 'give' then
        MySQL.update('UPDATE properties SET owner_cid = ? WHERE id = ?', { data.cid, data.id })
        MySQL.insert('INSERT IGNORE INTO property_keys (prop_id, citizenid) VALUES (?, ?)', { data.id, data.cid })
        ownerLog('OWNER_PROPERTY', src, tostring(data.id), '-', 'give:'..data.cid)
    end
    if action == 'setkey' then
        MySQL.insert('INSERT IGNORE INTO property_keys (prop_id, citizenid) VALUES (?, ?)', { data.id, data.cid })
    end
    if action == 'delkey' then
        MySQL.update('DELETE FROM property_keys WHERE prop_id = ? AND citizenid = ?', { data.id, data.cid })
    end
end)

-- =================== GARAGES EN JEU ===================
RegisterNetEvent('novalife_owner:createGarage', function(data)
    local src = source
    if not IsOwner(src) then return end
    -- écrit dans config/garages.lua (append) OU en SQL; ici on log + on ajoute en SQL miroir
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS custom_garages (
            id VARCHAR(40) PRIMARY KEY, label VARCHAR(60), type VARCHAR(20),
            job VARCHAR(20), coords JSON, spawn JSON, radius FLOAT
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    MySQL.insert('INSERT INTO custom_garages (id, label, type, job, coords, spawn, radius) VALUES (?, ?, ?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE label=?, type=?, job=?, coords=?, spawn=?, radius=?',
        { data.id, data.label, data.type, data.job or nil, json.encode(data.coords), json.encode(data.spawn), data.radius or 5.0,
          data.label, data.type, data.job or nil, json.encode(data.coords), json.encode(data.spawn), data.radius or 5.0 })
    ownerLog('OWNER_CONFIG', src, data.id, '-', 'garage:'..data.type)
    TriggerClientEvent('novalife_core:client:notify', src, { type='success', title='Owner', description='Garage créé: '..data.label })
end)

-- =================== ENTREPRISES ===================
RegisterNetEvent('novalife_owner:business', function(action, data)
    local src = source
    if not IsOwner(src) then return end
    if action == 'create' then
        MySQL.insert('INSERT IGNORE INTO businesses (name, label, balance, owner) VALUES (?, ?, 0, ?)',
            { data.name, data.label, data.owner or nil })
        ownerLog('OWNER_BUSINESS', src, data.name, '-', 'create')
    end
    if action == 'delete' then
        MySQL.update('DELETE FROM businesses WHERE name = ?', { data.name }); ownerLog('OWNER_BUSINESS', src, data.name, '-', 'DELETE')
    end
    if action == 'setowner' then
        MySQL.update('UPDATE businesses SET owner = ? WHERE name = ?', { data.cid, data.name }); ownerLog('OWNER_BUSINESS', src, data.name, '-', 'owner:'..data.cid)
    end
    if action == 'balance' then
        MySQL.update('UPDATE businesses SET balance = ? WHERE name = ?', { data.balance, data.name }); ownerLog('OWNER_BUSINESS', src, data.name, '-', 'balance:'..data.balance)
    end
end)

-- =================== CONFIG EN JEU ===================
RegisterNetEvent('novalife_owner:config', function(key, value)
    local src = source
    if not IsOwner(src) then return end
    -- Modification serveur validée. On ne touche PAS aux fichiers de config (lecture seule au runtime),
    -- on applique en mémoire sur les tables globales (Jobs/Vehicles/Economy/Garages).
    if key == 'job_payment' and value.name and value.grade then
        if Jobs[value.name] and Jobs[value.name].grades[value.grade] then
            Jobs[value.name].grades[value.grade].payment = tonumber(value.payment)
        end
    elseif key == 'vehicle_price' and value.model then
        if Vehicles.list[value.model] then Vehicles.list[value.model].price = tonumber(value.price) end
    elseif key == 'economy_start' then
        Economy.StartCash = tonumber(value.cash) or Economy.StartCash
        Economy.StartBank = tonumber(value.bank) or Economy.StartBank
    elseif key == 'fuel_price' and value.type then
        Economy.Fuel.pricePerLitre[value.type] = tonumber(value.price)
    end
    ownerLog('OWNER_CONFIG', src, key, '-', json.encode(value))
end)

-- =================== LOGS ===================
lib.callback.register('novalife_owner:getJobs', function(src)
    if not IsOwner(src) then return nil end
    local out = {}
    for k, v in pairs(Jobs) do
        out[#out+1] = { name = k, grades = #v.grades }
    end
    return out
end)

lib.callback.register('novalife_owner:getLogs', function(src)
    if not IsOwner(src) then return nil end
    return MySQL.query.await("SELECT * FROM server_logs WHERE kind LIKE 'owner_%' ORDER BY ts DESC LIMIT 100") or {}
end)

exports('IsOwner', IsOwner)
