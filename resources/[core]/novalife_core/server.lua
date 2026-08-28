-- ============================================================
--  novalife_core — server.lua
--  Joueurs, économie (validée serveur), sécurité, logs, callbacks.
--  PRIORITÉ: jamais confiance au client. Tout passe par ici.
-- ============================================================

local Core = {}
Core.Players = {}        -- [src] = player object
Core.Cooldowns = {}      -- [src..":"..action] = timestamp
Core.Ready = false

-- Chargement des configs externes (config/*.lua) depuis la racine du serveur
-- On expose les tables globales jobs/vehicles/garages/locations/economy/permissions
local function loadConfigFiles()
    local files = { 'jobs', 'vehicles', 'garages', 'locations', 'economy', 'permissions' }
    for _, f in ipairs(files) do
        local path = ('../../config/%s.lua'):format(f)
        local ok, err = pcall(function()
            local chunk = LoadResourceFile(GetCurrentResourceName(), path) or LoadResourceFile('novalife_core', path)
            if chunk then
                local fn = load(chunk, ('novalife_%s'):format(f))
                if fn then fn() end
            end
        end)
        if not ok and Config.Debug then
            print(('[NovaLife] config %s non chargé: %s'):format(f, tostring(err)))
        end
    end
end

-- Lire les webhooks depuis les Convars (jamais exposés au client)
local function loadWebhooks()
    Config.Webhooks.connect  = GetConvar('NovaLife_Webhook_Connect', '')
    Config.Webhooks.money    = GetConvar('NovaLife_Webhook_Money', '')
    Config.Webhooks.admin    = GetConvar('NovaLife_Webhook_Admin', '')
    Config.Webhooks.arrest   = GetConvar('NovaLife_Webhook_Arrest', '')
    Config.Webhooks.errors   = GetConvar('NovaLife_Webhook_Errors', '')
    Config.Webhooks.vehicle  = GetConvar('NovaLife_Webhook_Vehicle', '')
end

-------------------------------------------------------------------------------
-- Utilitaires sécurité
-------------------------------------------------------------------------------

-- Cooldown: renvoie true si autorisé (et pose le cooldown)
function Core.CanDo(src, action)
    local key = src .. ':' .. action
    local now = os.time()
    local last = Core.Cooldowns[key] or 0
    local cd = (Config.Cooldowns[action] or 1)
    if now - last < cd then return false end
    Core.Cooldowns[key] = now
    return true
end

-- Vérification distance (serveur): compare positions
function Core.CheckDistance(src, targetCoords, maxDist)
    maxDist = maxDist or Config.DefaultInteractDistance
    local ped = GetPlayerPed(src)
    if not ped then return false end
    local pcoords = GetEntityCoords(ped)
    return #(pcoords - targetCoords) <= maxDist
end

-- Niveau de permission du joueur (groupe ACE + groupe NovaLife en DB)
function Core.GetPermissionLevel(src)
    if IsPlayerAceAllowed(src, 'command.givemoney') then return 4 end
    if IsPlayerAceAllowed(src, 'command.ban')      then return 3 end
    if IsPlayerAceAllowed(src, 'command.kick')     then return 2 end
    if IsPlayerAceAllowed(src, 'command.*')       then return 5 end
    local p = Core.Players[src]
    if p and p.adminGroup then
        return Permissions and GetGroupLevel(p.adminGroup) or 0
    end
    return 0
end

function Core.HasPermission(src, requiredLevel)
    return Core.GetPermissionLevel(src) >= (requiredLevel or 0)
end

-- Job check
function Core.HasJob(src, job, minGrade)
    local p = Core.Players[src]
    if not p then return false end
    if p.job.name ~= job then return false end
    if minGrade and p.job.grade < minGrade then return false end
    return true
end

-------------------------------------------------------------------------------
-- Logging Discord (webhook serveur uniquement)
-------------------------------------------------------------------------------

function Core.Log(kind, title, message, color)
    local url = Config.Webhooks[kind]
    if not url or url == '' or url == 'CHANGE_ME_WEBHOOK' then return end
    local embed = {
        {
            ["title"] = title,
            ["description"] = message,
            ["color"] = color or 3447003,
            ["footer"] = { ["text"] = Config.ServerName .. ' | ' .. os.date('%Y-%m-%d %H:%M:%S') }
        }
    }
    PerformHttpRequest(url, function() end, 'POST', json.encode({ username = Config.ServerName, embeds = embed }),
        { ['Content-Type'] = 'application/json' })
end

-------------------------------------------------------------------------------
-- Joueurs
-------------------------------------------------------------------------------

local function genCitizenId()
    local charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local id = 'NV'
    for i = 1, 8 do id = id .. charset[math.random(1, #charset)] end
    return id
end

local function defaultPlayer(src, license)
    return {
        source = src,
        license = license,
        citizenid = genCitizenId(),
        charId = 1,
        name = GetPlayerName(src) or 'Unknown',
        money = { cash = Config.StartCash, bank = Config.StartBank },
        job = { name = 'unemployed', grade = 0, label = 'Sans emploi', payment = 0, onDuty = false },
        identity = nil,           -- rempli par novalife_identity
        position = { x = 0, y = 0, z = 0, heading = 0 },
        isDead = false,
        adminGroup = nil,
    }
end

function Core.GetPlayer(src)
    return Core.Players[src]
end

function Core.GetPlayerByCitizenId(cid)
    for _, p in pairs(Core.Players) do
        if p.citizenid == cid then return p end
    end
    return nil
end

-- Sauvegarde SQL d'un joueur
function Core.SavePlayer(src)
    local p = Core.Players[src]
    if not p then return end
    local money = json.encode(p.money)
    local job = json.encode({ name = p.job.name, grade = p.job.grade })
    local identity = p.identity and json.encode(p.identity) or nil
    local position = json.encode(p.position)
    MySQL.update.await([[
        INSERT INTO players (citizenid, license, name, money, job, identity, position, last_seen)
        VALUES (?, ?, ?, ?, ?, ?, ?, NOW())
        ON DUPLICATE KEY UPDATE
            name = VALUES(name), money = VALUES(money), job = VALUES(job),
            identity = VALUES(identity), position = VALUES(position), last_seen = NOW()
    ]], { p.citizenid, p.license, p.name, money, job, identity, position })
end

function Core.SaveAll()
    for src, _ in pairs(Core.Players) do
        Core.SavePlayer(src)
    end
end

-------------------------------------------------------------------------------
-- Économie (TOUT validé côté serveur)
-------------------------------------------------------------------------------

function Core.GetMoney(src, mtype)
    local p = Core.Players[src]
    if not p then return 0 end
    mtype = mtype or 'cash'
    return p.money[mtype] or 0
end

local function setMoney(src, mtype, amount)
    local p = Core.Players[src]
    if not p then return false end
    p.money[mtype] = math.max(0, math.floor(amount))
    return true
end

function Core.AddMoney(src, mtype, amount, reason)
    local p = Core.Players[src]
    if not p or amount <= 0 then return false end
    mtype = mtype or 'cash'
    local cap = mtype == 'cash' and Economy.MaxCash or Economy.MaxBank
    local new = p.money[mtype] + amount
    if new > cap then new = cap end
    setMoney(src, mtype, new)
    TriggerClientEvent('novalife_core:updateMoney', src, p.money)
    Core.Log('money', '💰 Argent ajouté',
        ('%s (%s) +%d$ [%s] — %s'):format(p.name, p.citizenid, amount, mtype, reason or 'n/a'), 5763719)
    Core.SavePlayer(src)
    return true
end

function Core.RemoveMoney(src, mtype, amount, reason)
    local p = Core.Players[src]
    if not p or amount <= 0 then return false end
    mtype = mtype or 'cash'
    if p.money[mtype] < amount then
        NLNotify(src, 'error', 'Fonds insuffisants', ('Il vous manque %d$'):format(amount - p.money[mtype]))
        return false
    end
    setMoney(src, mtype, p.money[mtype] - amount)
    TriggerClientEvent('novalife_core:updateMoney', src, p.money)
    Core.Log('money', '💸 Argent retiré',
        ('%s (%s) -%d$ [%s] — %s'):format(p.name, p.citizenid, amount, mtype, reason or 'n/a'), 15548997)
    Core.SavePlayer(src)
    return true
end

function Core.Deposit(src, amount)
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then return false end
    if amount > Economy.MaxDeposit then
        NLNotify(src, 'error', 'Plafond', ('Dépôt max: %d$'):format(Economy.MaxDeposit)); return false
    end
    if not Core.CanDo(src, 'giveMoney') then return false end
    if not Core.RemoveMoney(src, 'cash', amount, 'dépôt banque') then return false end
    Core.AddMoney(src, 'bank', amount, 'dépôt banque')
    return true
end

function Core.Withdraw(src, amount)
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then return false end
    if amount > Economy.MaxWithdraw then
        NLNotify(src, 'error', 'Plafond', ('Retrait max: %d$'):format(Economy.MaxWithdraw)); return false
    end
    if not Core.CanDo(src, 'giveMoney') then return false end
    if not Core.RemoveMoney(src, 'bank', amount, 'retrait banque') then return false end
    Core.AddMoney(src, 'cash', amount, 'retrait banque')
    return true
end

function Core.Transfer(src, targetSrc, amount)
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then return false end
    if amount > Economy.MaxTransfer then
        NLNotify(src, 'error', 'Plafond', ('Virement max: %d$'):format(Economy.MaxTransfer)); return false
    end
    if not Core.CanDo(src, 'giveMoney') then return false end
    local tp = Core.Players[targetSrc]
    if not tp then NLNotify(src, 'error', 'Erreur', 'Destinataire introuvable'); return false end
    if not Core.RemoveMoney(src, 'bank', amount, 'virement → ' .. tp.name) then return false end
    Core.AddMoney(targetSrc, 'bank', amount, 'virement ← ' .. Core.Players[src].name)
    -- Historique SQL
    MySQL.insert('INSERT INTO bank_transactions (citizenid, type, amount, counterparty, ts) VALUES (?, ?, ?, ?, NOW())',
        { Core.Players[src].citizenid, 'transfer_out', amount, tp.citizenid })
    MySQL.insert('INSERT INTO bank_transactions (citizenid, type, amount, counterparty, ts) VALUES (?, ?, ?, ?, NOW())',
        { tp.citizenid, 'transfer_in', amount, Core.Players[src].citizenid })
    return true
end

-------------------------------------------------------------------------------
-- Jobs
-------------------------------------------------------------------------------

function Core.SetJob(src, jobName, grade)
    local p = Core.Players[src]
    if not p then return false end
    local jobDef = Jobs[jobName]
    if not jobDef then NLNotify(src, 'error', 'Erreur', 'Métier inconnu'); return false end
    grade = math.min(math.max(tonumber(grade) or jobDef.default or 0, 0), #jobDef.grades)
    p.job = {
        name = jobName,
        grade = grade,
        label = jobDef.label,
        payment = jobDef.grades[grade] and jobDef.grades[grade].payment or 0,
        onDuty = false,
    }
    TriggerClientEvent('novalife_core:updateJob', src, p.job)
    Core.SavePlayer(src)
    return true
end

-------------------------------------------------------------------------------
-- Events / Callbacks
-------------------------------------------------------------------------------

RegisterNetEvent('novalife_core:server:savePosition', function(pos)
    local src = source
    local p = Core.Players[src]
    if not p or type(pos) ~= 'table' then return end
    -- validation basique des coordonnées
    if pos.x and pos.y and pos.z and math.abs(pos.x) < 100000 and math.abs(pos.y) < 100000 then
        p.position = { x = pos.x, y = pos.y, z = pos.z, heading = pos.heading or 0 }
    end
end)

-- Le joueur signale que son personnage est prêt (après identity/spawn)
RegisterNetEvent('novalife_core:server:playerLoaded', function(citizenid)
    local src = source
    local p = Core.Players[src]
    if p and citizenid then p.citizenid = citizenid end
    TriggerClientEvent('novalife_core:client:playerReady', src, p)
end)

-- Callbacks exposés au client (lecture seule / actions sécurisées)
lib.callback.register('novalife_core:getPlayer', function(src)
    local p = Core.Players[src]
    if not p then return nil end
    return { citizenid = p.citizenid, name = p.name, money = p.money, job = p.job, identity = p.identity }
end)

lib.callback.register('novalife_core:deposit', function(src, amount) return Core.Deposit(src, amount) end)
lib.callback.register('novalife_core:withdraw', function(src, amount) return Core.Withdraw(src, amount) end)
lib.callback.register('novalife_core:transfer', function(src, targetSrc, amount) return Core.Transfer(src, targetSrc, amount) end)

-------------------------------------------------------------------------------
-- Connexion / Déconnexion
-------------------------------------------------------------------------------

AddEventHandler('playerConnecting', function(name, setKick, deferrals)
    local src = source
    deferrals.defer()
    Wait(0)
    deferrals.update(('Bienvenue sur %s…'):format(Config.ServerName))
    local license = GetPlayerIdentifierByType(src, 'license') or 'license:unknown'
    if Config.EnableWhitelist then
        local wl = MySQL.query.await('SELECT 1 FROM whitelist WHERE license = ?', { license })
        if not wl or #wl == 0 then
            deferrals.done('❌ Accès refusé : serveur en whitelist. Rejoignez le Discord.')
            return
        end
    end
    Wait(100)
    deferrals.done()
end)

AddEventHandler('playerJoining', function()
    local src = source
    local license = GetPlayerIdentifierByType(src, 'license') or 'license:unknown'
    local p = defaultPlayer(src, license)
    -- Charger le dernier personnage (ou laisser identity gérer la sélection)
    local row = MySQL.query.await('SELECT * FROM players WHERE license = ? ORDER BY last_seen DESC LIMIT 1', { license })
    if row and row[1] then
        p.citizenid = row[1].citizenid
        p.money = json.decode(row[1].money) or p.money
        local j = json.decode(row[1].job) or {}
        p.job = { name = j.name or 'unemployed', grade = j.grade or 0,
                  label = Jobs[j.name] and Jobs[j.name].label or 'Sans emploi',
                  payment = Jobs[j.name] and Jobs[j.name].grades[j.grade] and Jobs[j.name].grades[j.grade].payment or 0, onDuty = false }
        p.identity = row[1].identity and json.decode(row[1].identity) or nil
        if row[1].position then p.position = json.decode(row[1].position) end
    end
    Core.Players[src] = p
    Core.Log('connect', '🔌 Connexion',
        ('%s (%s) — %s'):format(p.name, p.citizenid, license), 5763719)
    TriggerClientEvent('novalife_core:client:init', src, Config.ServerName)
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    local p = Core.Players[src]
    if p then
        Core.SavePlayer(src)
        Core.Log('connect', '🔌 Déconnexion',
            ('%s (%s) — %s'):format(p.name, p.citizenid, reason or 'n/a'), 15548997)
    end
    Core.Players[src] = nil
    Core.Cooldowns[src] = nil
end)

-- Sauvegarde périodique (pas de Wait(0))
CreateThread(function()
    while true do
        Wait(120000) -- toutes les 2 min
        Core.SaveAll()
    end
end)

-- Versement des salaires (configurable: Economy.SalaryIntervalMinutes)
CreateThread(function()
    local interval = (Economy and Economy.SalaryIntervalMinutes or 15) * 60000
    while true do
        Wait(interval)
        for src, p in pairs(Core.Players) do
            if p.job and p.job.name ~= 'unemployed' and p.job.payment and p.job.payment > 0 then
                Core.AddMoney(src, 'bank', p.job.payment, 'salaire: ' .. p.job.label)
            end
        end
    end
end)

-- Au démarrage
AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    loadConfigFiles()
    loadWebhooks()
    Core.Ready = true
    print('^2[NovaLife] novalife_core démarré.^7')
end)

-------------------------------------------------------------------------------
-- Exports (utilisés par les autres ressources)
-------------------------------------------------------------------------------
exports('GetPlayer', Core.GetPlayer)
exports('GetPlayerByCitizenId', Core.GetPlayerByCitizenId)
exports('AddMoney', Core.AddMoney)
exports('RemoveMoney', Core.RemoveMoney)
exports('GetMoney', Core.GetMoney)
exports('Deposit', Core.Deposit)
exports('Withdraw', Core.Withdraw)
exports('Transfer', Core.Transfer)
exports('SetJob', Core.SetJob)
exports('HasPermission', Core.HasPermission)
exports('HasJob', Core.HasJob)
exports('CheckDistance', Core.CheckDistance)
exports('CanDo', Core.CanDo)
exports('Log', Core.Log)
exports('SavePlayer', Core.SavePlayer)
exports('GenCitizenId', genCitizenId)
