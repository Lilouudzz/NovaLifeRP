-- ============================================================
--  novalife_business — server.lua
--  CRUD entreprise (serveur = source de vérité). Verif patron.
-- ============================================================

local function isOwner(src, name)
    local p = exports.novalife_core:GetPlayer(src)
    if not p then return false end
    local row = MySQL.query.await('SELECT owner FROM businesses WHERE name = ?', { name })
    return row and row[1] and row[1].owner == p.citizenid
end

local function isEmployee(src, name)
    local p = exports.novalife_core:GetPlayer(src)
    if not p then return false end
    if isOwner(src, name) then return true end
    local row = MySQL.query.await('SELECT employees FROM businesses WHERE name = ?', { name })
    if not row or not row[1] or not row[1].employees then return false end
    local emp = json.decode(row[1].employees) or {}
    for _, e in ipairs(emp) do if e.citizenid == p.citizenid then return true end end
    return false
end

-- Créer une entreprise (admin/owner uniquement)
lib.callback.register('novalife_business:create', function(src, name, label)
    if not exports.novalife_core:HasPermission(src, 4) then return { error = 'perm' } end
    MySQL.insert('INSERT IGNORE INTO businesses (name, label, balance, owner) VALUES (?, ?, 0, ?)',
        { name, label, exports.novalife_core:GetPlayer(src).citizenid })
    return { success = true }
end)

lib.callback.register('novalife_business:hire', function(src, name, targetSrc, grade)
    if not isOwner(src, name) then return { error = 'patron' } end
    local tp = exports.novalife_core:GetPlayer(targetSrc)
    if not tp then return { error = 'cible' } end
    local row = MySQL.query.await('SELECT employees FROM businesses WHERE name = ?', { name })
    local emp = row and row[1] and json.decode(row[1].employees) or {}
    emp[#emp + 1] = { citizenid = tp.citizenid, grade = tonumber(grade) or 0 }
    MySQL.update('UPDATE businesses SET employees = ? WHERE name = ?', { json.encode(emp), name })
    exports.novalife_core:SetJob(targetSrc, name, tonumber(grade) or 0)
    return { success = true }
end)

lib.callback.register('novalife_business:fire', function(src, name, targetCid)
    if not isOwner(src, name) then return { error = 'patron' } end
    local row = MySQL.query.await('SELECT employees FROM businesses WHERE name = ?', { name })
    local emp = row and row[1] and json.decode(row[1].employees) or {}
    local out = {}
    for _, e in ipairs(emp) do if e.citizenid ~= targetCid then out[#out + 1] = e end end
    MySQL.update('UPDATE businesses SET employees = ? WHERE name = ?', { json.encode(out), name })
    return { success = true }
end)

lib.callback.register('novalife_business:deposit', function(src, name, amount)
    if not isEmployee(src, name) then return { error = 'acces' } end
    if not exports.novalife_core:RemoveMoney(src, 'bank', amount, 'dépôt entreprise ' .. name) then return { error = 'fonds' } end
    MySQL.update('UPDATE businesses SET balance = balance + ? WHERE name = ?', { amount, name })
    return { success = true }
end)

lib.callback.register('novalife_business:withdraw', function(src, name, amount)
    if not isOwner(src, name) then return { error = 'patron' } end
    local row = MySQL.query.await('SELECT balance FROM businesses WHERE name = ?', { name })
    if not row or row[1].balance < amount then return { error = 'fonds' } end
    MySQL.update('UPDATE businesses SET balance = balance - ? WHERE name = ?', { amount, name })
    exports.novalife_core:AddMoney(src, 'bank', amount, 'retrait entreprise ' .. name)
    return { success = true }
end)

lib.callback.register('novalife_business:info', function(src, name)
    if not isEmployee(src, name) then return { error = 'acces' } end
    local row = MySQL.query.await('SELECT * FROM businesses WHERE name = ?', { name })
    if not row or not row[1] then return { error = 'introuvable' } end
    return { name = row[1].name, label = row[1].label, balance = row[1].balance, owner = row[1].owner, employees = json.decode(row[1].employees) or {} }
end)
