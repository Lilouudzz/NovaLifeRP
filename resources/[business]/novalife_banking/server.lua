-- ============================================================
--  novalife_banking — server.lua
--  Toutes les opérations passent par novalife_core (validées serveur).
-- ============================================================

local function getBills(src)
    local p = exports.novalife_core:GetPlayer(src)
    if not p then return {} end
    local rows = MySQL.query.await('SELECT id, amount, reason, sender FROM bills WHERE citizenid = ? AND paid = 0', { p.citizenid })
    return rows or {}
end

local function getHistory(src)
    local p = exports.novalife_core:GetPlayer(src)
    if not p then return {} end
    local rows = MySQL.query.await('SELECT type, amount, counterparty, ts FROM bank_transactions WHERE citizenid = ? ORDER BY ts DESC LIMIT 15', { p.citizenid })
    return rows or {}
end

lib.callback.register('novalife_banking:open', function(src)
    local p = exports.novalife_core:GetPlayer(src)
    if not p then return nil end
    return { balance = p.money.bank, cash = p.money.cash, bills = getBills(src), history = getHistory(src) }
end)

lib.callback.register('novalife_banking:deposit', function(src, amount)
    return exports.novalife_core:Deposit(src, amount)
end)

lib.callback.register('novalife_banking:withdraw', function(src, amount)
    return exports.novalife_core:Withdraw(src, amount)
end)

lib.callback.register('novalife_banking:transfer', function(src, targetQuery, amount)
    local tgt = exports.novalife_utils:FindPlayer(targetQuery)
    if not tgt then return { success = false, error = 'destinataire' } end
    if tgt == src then return { success = false, error = 'soi' } end
    local ok = exports.novalife_core:Transfer(src, tgt, amount)
    return { success = ok }
end)

lib.callback.register('novalife_banking:payBill', function(src, billId)
    local p = exports.novalife_core:GetPlayer(src)
    if not p then return { success = false } end
    local row = MySQL.query.await('SELECT * FROM bills WHERE id = ? AND citizenid = ? AND paid = 0', { billId, p.citizenid })
    if not row or not row[1] then return { success = false, error = 'introuvable' } end
    if p.money.bank < row[1].amount then return { success = false, error = 'fonds' } end
    exports.novalife_core:RemoveMoney(src, 'bank', row[1].amount, 'facture: ' .. row[1].reason)
    MySQL.update('UPDATE bills SET paid = 1 WHERE id = ?', { billId })
    -- créditer l'émetteur (job/entreprise) si compte existe
    if row[1].sender then
        MySQL.query.await('UPDATE business_balances SET balance = balance + ? WHERE name = ?', { row[1].amount, row[1].sender })
    end
    exports.novalife_core:Log('money', '🧾 Facture payée', ('%s a payé %d$ (%s)'):format(p.name, row[1].amount, row[1].reason), 5763719)
    return { success = true }
end)

-- Rechargement des données (refresh NUI)
lib.callback.register('novalife_banking:refresh', function(src)
    local p = exports.novalife_core:GetPlayer(src)
    if not p then return nil end
    return { balance = p.money.bank, cash = p.money.cash, bills = getBills(src), history = getHistory(src) }
end)
