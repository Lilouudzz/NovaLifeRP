-- ============================================================
--  novalife_billing — server.lua
--  Émission de facture (serveur = source de vérité).
--  Le serveur vérifie le job de l'émetteur.
-- ============================================================

local AllowedSenders = {
    police = 'Police', ambulance = 'EMS', fire = 'Pompiers',
    mechanic = 'Mécano', cardealer = 'Concessionnaire', taxi = 'Taxi'
}

RegisterNetEvent('novalife_billing:send', function(targetSrc, amount, reason)
    local src = source
    local p = exports.novalife_core:GetPlayer(src)
    local tp = exports.novalife_core:GetPlayer(targetSrc)
    if not p or not tp then return end
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 or amount > 1000000 then
        TriggerClientEvent('novalife_core:client:notify', src, { type = 'error', title = 'Facture', description = 'Montant invalide.' })
        return
    end
    local sender = AllowedSenders[p.job.name]
    if not sender then
        TriggerClientEvent('novalife_core:client:notify', src, { type = 'error', title = 'Facture', description = 'Métier non autorisé.' })
        return
    end
    if not exports.novalife_core:CanDo(src, 'fine') then return end
    MySQL.insert('INSERT INTO bills (citizenid, sender, sender_citizenid, amount, reason) VALUES (?, ?, ?, ?, ?)',
        { tp.citizenid, sender, p.citizenid, amount, reason })
    TriggerClientEvent('novalife_core:client:notify', src, { type = 'success', title = 'Facture', description = ('Facture %d$ envoyée.'):format(amount) })
    TriggerClientEvent('novalife_core:client:notify', targetSrc, { type = 'inform', title = 'Facture', description = ('Nouvelle facture: %d$ (%s)'):format(amount, reason) })
    exports.novalife_core:Log('money', '🧾 Facture émise', ('%s → %s : %d$ (%s)'):format(p.name, tp.name, amount, reason), 16776960)
end)

-- Commande /facture [id] [montant] [raison]
RegisterCommand('facture', function(src, args)
    local target = tonumber(args[1])
    local amount = tonumber(args[2])
    local reason = table.concat(args, ' ', 3)
    if not target or not amount then NLNotify(src, 'error', 'Facture', 'Usage: /facture [id] [montant] [raison]'); return end
    TriggerServerEvent('novalife_billing:send', target, amount, reason or 'Facture')
end, false)

exports('SendBill', function(src, targetSrc, amount, reason)
    TriggerEvent('novalife_billing:send', targetSrc, amount, reason) -- appel interne
end)
