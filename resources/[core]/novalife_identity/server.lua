-- ============================================================
--  novalife_identity — server.lua
--  Création d'identité, multi-personnages, permis.
--  Validation serveur: format des champs, unicité, anti-doublon.
-- ============================================================

local function validateIdentity(data)
    if type(data) ~= 'table' then return false, 'format' end
    if not data.firstname or #data.firstname < 2 or #data.firstname > 40 then return false, 'prénom' end
    if not data.lastname or #data.lastname < 2 or #data.lastname > 40 then return false, 'nom' end
    if not data.dob or not data.dob:match('^%d%d%d%d%-%d%d%-%d%d$') then return false, 'date de naissance' end
    if data.sex ~= 'homme' and data.sex ~= 'femme' then return false, 'sexe' end
    local h = tonumber(data.height)
    if not h or h < 120 or h > 220 then return false, 'taille' end
    if not data.nationality or #data.nationality < 2 then return false, 'nationalité' end
    return true
end

-- Liste des personnages existants pour un license
lib.callback.register('novalife_identity:getCharacters', function(src)
    local license = GetPlayerIdentifierByType(src, 'license')
    local rows = MySQL.query.await('SELECT char_id, citizenid, identity FROM characters WHERE license = ? ORDER BY char_id', { license })
    local chars = {}
    for _, r in ipairs(rows or {}) do
        chars[#chars + 1] = { charId = r.char_id, citizenid = r.citizenid, identity = json.decode(r.identity) }
    end
    return chars
end)

-- Création d'un nouveau personnage
lib.callback.register('novalife_identity:createCharacter', function(src, data)
    local ok, err = validateIdentity(data)
    if not ok then return { success = false, error = err } end
    local license = GetPlayerIdentifierByType(src, 'license')

    -- nombre de persos max
    local count = MySQL.query.await('SELECT COUNT(*) AS c FROM characters WHERE license = ?', { license })
    local n = count and count[1] and count[1].c or 0
    if n >= Config.Identity.MaxChars then return { success = false, error = 'max_persos' } end

    local cid = exports.novalife_core:GenCitizenId()
    local charId = n + 1
    local identity = {
        firstname = data.firstname, lastname = data.lastname, dob = data.dob,
        sex = data.sex, height = tonumber(data.height), nationality = data.nationality,
        appearance = data.appearance or nil,  -- sauvegardé depuis illenium-appearance (côté client)
    }
    MySQL.insert('INSERT INTO characters (license, char_id, citizenid, identity, money, job) VALUES (?, ?, ?, ?, ?, ?)',
        { license, charId, cid, json.encode(identity),
          json.encode({ cash = Config.StartCash or 500, bank = Config.StartBank or 5000 }),
          json.encode({ name = 'unemployed', grade = 0 }) })

    -- aussi dans identities (permis + apparence)
    MySQL.insert('INSERT INTO identities (citizenid, firstname, lastname, dob, sex, height, nationality, appearance, licenses) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        { cid, data.firstname, data.lastname, data.dob, data.sex, tonumber(data.height), data.nationality, json.encode(data.appearance or {}), json.encode(Config.Identity.DefaultLicenses) })

    -- appliquer au joueur courant
    local p = exports.novalife_core:GetPlayer(src)
    if p then
        p.citizenid = cid
        p.charId = charId
        p.identity = identity
        p.money = { cash = Config.StartCash or 500, bank = Config.StartBank or 5000 }
        p.job = { name = 'unemployed', grade = 0, label = 'Sans emploi', payment = 0, onDuty = false }
        exports.novalife_core:SavePlayer(src)
    end
    return { success = true, citizenid = cid, charId = charId }
end)

-- Sélection d'un personnage existant
lib.callback.register('novalife_identity:selectCharacter', function(src, charId)
    local license = GetPlayerIdentifierByType(src, 'license')
    local row = MySQL.query.await('SELECT * FROM characters WHERE license = ? AND char_id = ?', { license, charId })
    if not row or not row[1] then return { success = false } end
    local r = row[1]
    local p = exports.novalife_core:GetPlayer(src)
    if p then
        p.citizenid = r.citizenid
        p.charId = r.char_id
        p.identity = json.decode(r.identity)
        p.money = json.decode(r.money) or p.money
        p.job = json.decode(r.job) or p.job
        exports.novalife_core:SavePlayer(src)
    end
    -- récupérer l'apparence sauvegardée (table identities)
    local idr = MySQL.query.await('SELECT appearance FROM identities WHERE citizenid = ?', { r.citizenid })
    local appearance = idr and idr[1] and json.decode(idr[1].appearance) or nil
    return { success = true, citizenid = r.citizenid, appearance = appearance }
end)

-- Commandes /id et /permis
RegisterCommand('id', function(src)
    local p = exports.novalife_core:GetPlayer(src)
    if not p or not p.identity then NLNotify(src, 'error', 'Identité', 'Aucune identité.'); return end
    local i = p.identity
    TriggerClientEvent('novalife_identity:showId', src, {
        firstname = i.firstname, lastname = i.lastname, dob = i.dob, sex = i.sex,
        height = i.height, nationality = i.nationality, citizenid = p.citizenid
    })
end)

RegisterCommand('permis', function(src)
    local p = exports.novalife_core:GetPlayer(src)
    if not p then return end
    local row = MySQL.query.await('SELECT licenses FROM identities WHERE citizenid = ?', { p.citizenid })
    local lic = row and row[1] and json.decode(row[1].licenses) or Config.Identity.DefaultLicenses
    TriggerClientEvent('novalife_identity:showLicenses', src, lic)
end)

-- Export: donner / retirer un permis (serveur uniquement, vérif appelant)
exports('SetLicense', function(citizenid, type, value)
    if not citizenid or not type then return false end
    local row = MySQL.query.await('SELECT licenses FROM identities WHERE citizenid = ?', { citizenid })
    if not row or not row[1] then return false end
    local lic = json.decode(row[1].licenses) or {}
    lic[type] = value
    MySQL.update('UPDATE identities SET licenses = ? WHERE citizenid = ?', { json.encode(lic), citizenid })
    return true
end)

exports('GetLicense', function(citizenid, type)
    local row = MySQL.query.await('SELECT licenses FROM identities WHERE citizenid = ?', { citizenid })
    if not row or not row[1] then return false end
    local lic = json.decode(row[1].licenses) or {}
    return lic[type] or false
end)
