-- ============================================================
--  novalife_chat — server.lua
--  Distribue les messages RP en fonction de la distance.
-- ============================================================

local RP_RANGE = 12.0       -- distance /me /do
local OOC_RANGE = 25.0

-- Envoie un message à tous les joueurs dans la range du serveur
local function broadcastInRange(src, text, range, color, prefix)
    local c = GetEntityCoords(GetPlayerPed(src))
    for s, p in pairs(Core.Players) do
        if #(c - GetEntityCoords(GetPlayerPed(s))) <= range then
            TriggerClientEvent('novalife_chat:client:msg', s, prefix, text, color)
        end
    end
end

RegisterCommand('me', function(src, args)
    if #args == 0 then return end
    broadcastInRange(src, table.concat(args, ' '), RP_RANGE, '#00e5a0', '*')
end, false)

RegisterCommand('do', function(src, args)
    if #args == 0 then return end
    broadcastInRange(src, table.concat(args, ' '), RP_RANGE, '#58a6ff', '*')
end, false)

RegisterCommand('try', function(src, args)
    if #args == 0 then return end
    local ok = math.random(1, 2) == 1
    broadcastInRange(src, table.concat(args, ' ') .. ' → ' .. (ok and 'RÉUSSI' or 'ÉCHEC'), RP_RANGE, ok and '#3fb950' or '#ff5c5c', '*')
end, false)

RegisterCommand('ooc', function(src, args)
    if #args == 0 then return end
    for s, _ in pairs(Core.Players) do
        if #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(s))) <= OOC_RANGE then
            TriggerClientEvent('novalife_chat:client:msg', s, '[OOC] ' .. GetPlayerName(src), table.concat(args, ' '), '#8b949e')
        end
    end
end, false)

-- Urgences
RegisterCommand('911', function(src, args)
    if #args == 0 then return end
    local msg = table.concat(args, ' ')
    local name = GetPlayerName(src)
    for s, p in pairs(Core.Players) do
        if p.job.name == 'police' and p.job.onDuty then
            TriggerClientEvent('novalife_chat:client:msg', s, '📞 911 ' .. name, msg, '#ff5c5c')
        end
    end
    TriggerEvent('novalife_police:dispatch', '911', GetEntityCoords(GetPlayerPed(src)), msg)
end, false)

RegisterCommand('112', function(src, args)
    if #args == 0 then return end
    local msg = table.concat(args, ' ')
    local name = GetPlayerName(src)
    for s, p in pairs(Core.Players) do
        if (p.job.name == 'ambulance' or p.job.name == 'fire') and p.job.onDuty then
            TriggerClientEvent('novalife_chat:client:msg', s, '📞 112 ' .. name, msg, '#ff7b5c')
        end
    end
end, false)
