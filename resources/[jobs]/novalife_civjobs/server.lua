-- ============================================================
--  novalife_civjobs — server.lua
--  Validation des récompenses serveur (distance + montant plafonné).
-- ============================================================

-- Récompense taxi (par course)
RegisterNetEvent('novalife_civjobs:taxiPay', function(distance)
    local src = source
    if not exports.novalife_core:HasJob(src, 'taxi') then return end
    local fare = math.min(math.floor((distance or 0) * 2 + 50), 5000) -- plafond anti-abus
    exports.novalife_core:AddMoney(src, 'cash', fare, 'course taxi')
    exports.novalife_core:Log('money', '🚕 Taxi', ('%s course: +%d$'):format(exports.novalife_core:GetPlayer(src).name, fare), 5763719)
end)

-- Livraison
RegisterNetEvent('novalife_civjobs:deliveryPay', function()
    local src = source
    if not exports.novalife_core:HasJob(src, 'delivery') then return end
    exports.novalife_core:AddMoney(src, 'cash', 350, 'livraison')
end)

-- Éboueur (par collecte)
RegisterNetEvent('novalife_civjobs:garbagePay', function()
    local src = source
    if not exports.novalife_core:HasJob(src, 'garbage') then return end
    exports.novalife_core:AddMoney(src, 'cash', 200, 'collecte déchets')
end)

-- Bus (par arrêt)
RegisterNetEvent('novalife_civjobs:busPay', function()
    local src = source
    if not exports.novalife_core:HasJob(src, 'bus') then return end
    exports.novalife_core:AddMoney(src, 'cash', 150, 'arrêt bus')
end)

-- Prise de service civile (serveur vérifie le job autorisé)
RegisterNetEvent('novalife_civjobs:takeJob', function(name)
    local src = source
    local allowed = { taxi = true, bus = true, garbage = true, delivery = true }
    if not allowed[name] then return end
    exports.novalife_core:SetJob(src, name, 0)
    NLNotify(src, 'success', 'Métier', 'Prise de service: ' .. name)
end)
