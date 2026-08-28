-- ============================================================
--  novalife_admin — server.lua
--  Toutes les commandes admin. Vérification ACE + niveau + logs.
-- ============================================================

local function logAdmin(src, action, target, extra)
    local name = exports.novalife_core:GetPlayer(src)
    exports.novalife_core:Log('admin', '🛡 Admin: ' .. action,
        ('%s → %s %s'):format(name and name.name or ('src'..src), target or '-', extra or ''), 16776960)
end

-- Helper: résoudre cible
local function getSrc(query)
    return exports.novalife_utils:FindPlayer(query)
end

RegisterCommand('kick', function(src, args)
    if not exports.novalife_core:HasPermission(src, 2) then NLNotify(src,'error','Admin','Permission.'); return end
    local t = getSrc(args[1]); if not t then return end
    local reason = table.concat(args, ' ', 2) or 'Kick'
    DropPlayer(t, 'Kick par admin: ' .. reason)
    logAdmin(src, 'kick', GetPlayerName(t), reason)
end, false)

RegisterCommand('ban', function(src, args)
    if not exports.novalife_core:HasPermission(src, 3) then NLNotify(src,'error','Admin','Permission.'); return end
    local t = getSrc(args[1]); if not t then return end
    local lic = GetPlayerIdentifierByType(t, 'license')
    local reason = table.concat(args, ' ', 2) or 'Ban'
    MySQL.insert('INSERT INTO bans (license, reason, banned_by) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE reason=?, banned_by=?',
        { lic, reason, GetPlayerName(src), reason, GetPlayerName(src) })
    DropPlayer(t, 'Banni: ' .. reason)
    logAdmin(src, 'ban', GetPlayerName(t), reason)
end, false)

RegisterCommand('unban', function(src, args)
    if not exports.novalife_core:HasPermission(src, 3) then return end
    MySQL.update('DELETE FROM bans WHERE license = ?', { args[1] })
    logAdmin(src, 'unban', args[1] or '-')
end, false)

RegisterCommand('freeze', function(src, args)
    if not exports.novalife_core:HasPermission(src, 2) then return end
    local t = getSrc(args[1]); if not t then return end
    TriggerClientEvent('novalife_admin:client:freeze', t)
    logAdmin(src, 'freeze', GetPlayerName(t))
end, false)

RegisterCommand('goto', function(src, args)
    if not exports.novalife_core:HasPermission(src, 2) then return end
    local t = getSrc(args[1]); if not t then return end
    TriggerClientEvent('novalife_admin:client:goto', src, GetEntityCoords(GetPlayerPed(t)))
    logAdmin(src, 'goto', GetPlayerName(t))
end, false)

RegisterCommand('bring', function(src, args)
    if not exports.novalife_core:HasPermission(src, 2) then return end
    local t = getSrc(args[1]); if not t then return end
    TriggerClientEvent('novalife_admin:client:bring', t, GetEntityCoords(GetPlayerPed(src)))
    logAdmin(src, 'bring', GetPlayerName(t))
end, false)

RegisterCommand('revive', function(src, args)
    if not exports.novalife_core:HasPermission(src, 2) then return end
    local t = getSrc(args[1]) or src
    TriggerClientEvent('novalife_ems:client:revive', t)
    logAdmin(src, 'revive', GetPlayerName(t))
end, false)

RegisterCommand('heal', function(src, args)
    if not exports.novalife_core:HasPermission(src, 2) then return end
    local t = getSrc(args[1]) or src
    TriggerClientEvent('novalife_ems:client:heal', t, 'heal')
    logAdmin(src, 'heal', GetPlayerName(t))
end, false)

RegisterCommand('tpm', function(src)
    if not exports.novalife_core:HasPermission(src, 3) then return end
    TriggerClientEvent('novalife_admin:client:tpm', src)
    logAdmin(src, 'tpm', GetPlayerName(src))
end, false)

RegisterCommand('giveitem', function(src, args)
    if not exports.novalife_core:HasPermission(src, 3) then return end
    local t = getSrc(args[1]); local item = args[2]; local count = tonumber(args[3]) or 1
    if not t or not item then return end
    exports.novalife_inventory:GiveItem(src, t, item, count)
    logAdmin(src, 'giveitem', GetPlayerName(t), item .. ' x' .. count)
end, false)

RegisterCommand('givemoney', function(src, args)
    if not exports.novalife_core:HasPermission(src, 4) then return end
    local t = getSrc(args[1]); local mtype = args[2] or 'cash'; local amount = tonumber(args[3]) or 0
    if not t or amount <= 0 then return end
    exports.novalife_core:AddMoney(t, mtype, amount, 'admin givemoney')
    logAdmin(src, 'givemoney', GetPlayerName(t), amount .. '$ ' .. mtype)
end, false)

RegisterCommand('setjob', function(src, args)
    if not exports.novalife_core:HasPermission(src, 4) then return end
    local t = getSrc(args[1]); local job = args[2]; local grade = tonumber(args[3]) or 0
    if not t or not job then return end
    exports.novalife_core:SetJob(t, job, grade)
    logAdmin(src, 'setjob', GetPlayerName(t), job .. ' ' .. grade)
end, false)

RegisterCommand('setgrade', function(src, args)
    if not exports.novalife_core:HasPermission(src, 4) then return end
    local t = getSrc(args[1]); local grade = tonumber(args[2]) or 0
    if not t then return end
    local p = exports.novalife_core:GetPlayer(t)
    exports.novalife_core:SetJob(t, p.job.name, grade)
    logAdmin(src, 'setgrade', GetPlayerName(t), 'grade ' .. grade)
end, false)

RegisterCommand('car', function(src, args)
    if not exports.novalife_core:HasPermission(src, 3) then return end
    local model = args[1]
    if not model then return end
    TriggerClientEvent('novalife_admin:client:spawnCar', src, model)
    logAdmin(src, 'car', GetPlayerName(src), model)
end, false)

RegisterCommand('dv', function(src)
    if not exports.novalife_core:HasPermission(src, 2) then return end
    TriggerClientEvent('novalife_admin:client:dv', src)
    logAdmin(src, 'dv', GetPlayerName(src))
end, false)

-- Menu admin ouvert par commande /admin
RegisterCommand('admin', function(src)
    if not exports.novalife_core:HasPermission(src, 2) then NLNotify(src,'error','Admin','Permission.'); return end
    TriggerClientEvent('novalife_admin:client:open', src)
end, false)
