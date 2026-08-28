-- ============================================================
--  novalife_phone — server.lua
--  Apps: contacts, SMS, annonces, urgences. (Appels = VoIP via resource vocale)
--  Données persistées en SQL (table phone_*).
-- ============================================================

-- Table phones créée à la volée si absente
CreateThread(function()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS phone_contacts (
            id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            citizenid VARCHAR(12) NOT NULL,
            name VARCHAR(40) NOT NULL,
            number VARCHAR(20) NOT NULL,
            KEY idx_cid (citizenid)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS phone_messages (
            id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            from_cid VARCHAR(12) NOT NULL,
            to_number VARCHAR(20) NOT NULL,
            body TEXT NOT NULL,
            ts DATETIME DEFAULT CURRENT_TIMESTAMP,
            KEY idx_to (to_number)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS phone_announces (
            id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            author VARCHAR(40) NOT NULL,
            body TEXT NOT NULL,
            ts DATETIME DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
end)

lib.callback.register('novalife_phone:getContacts', function(src)
    local p = exports.novalife_core:GetPlayer(src)
    if not p then return {} end
    return MySQL.query.await('SELECT * FROM phone_contacts WHERE citizenid = ?', { p.citizenid }) or {}
end)

lib.callback.register('novalife_phone:addContact', function(src, name, number)
    local p = exports.novalife_core:GetPlayer(src)
    if not p then return { error = true } end
    MySQL.insert('INSERT INTO phone_contacts (citizenid, name, number) VALUES (?, ?, ?)', { p.citizenid, name, number })
    return { success = true }
end)

lib.callback.register('novalife_phone:sendSMS', function(src, number, body)
    local p = exports.novalife_core:GetPlayer(src)
    if not p then return { error = true } end
    MySQL.insert('INSERT INTO phone_messages (from_cid, to_number, body) VALUES (?, ?, ?)', { p.citizenid, number, body })
    -- notifier le destinataire si connecté (lookup par numéro approximatif: ici par citizenid stocké dans number)
    for s, pl in pairs(Core.Players) do
        if pl.citizenid == number then
            TriggerClientEvent('novalife_core:client:notify', s, { type = 'inform', title = 'SMS', description = body })
        end
    end
    return { success = true }
end)

lib.callback.register('novalife_phone:announce', function(src, body)
    local p = exports.novalife_core:GetPlayer(src)
    if not p then return { error = true } end
    if not exports.novalife_core:HasPermission(src, 2) and p.job.name == 'unemployed' then
        -- tout le monde peut poster une petite annonce
    end
    MySQL.insert('INSERT INTO phone_announces (author, body) VALUES (?, ?)', { p.name, body })
    return { success = true }
end)

lib.callback.register('novalife_phone:getAnnounces', function(_)
    return MySQL.query.await('SELECT * FROM phone_announces ORDER BY ts DESC LIMIT 20') or {}
end)

-- Infos banque pour l'app téléphone
lib.callback.register('novalife_phone:bankInfo', function(src)
    local p = exports.novalife_core:GetPlayer(src)
    if not p then return nil end
    return { balance = p.money.bank, cash = p.money.cash }
end)

-- Urgences depuis le téléphone
RegisterNetEvent('novalife_phone:emergency', function(service, msg)
    if service == 'police' then TriggerEvent('novalife_police:dispatch', '911', GetEntityCoords(GetPlayerPed(source)), msg)
    else ExecuteCommand(('112 %s'):format(msg)) end
end)
