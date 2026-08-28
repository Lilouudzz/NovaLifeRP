-- ============================================================
--  novalife_inventory — server.lua
--  Helpers d'items. Tout passe par ox_inventory côté serveur.
--  Le client ne peut JAMAIS ajouter d'items (sécu serveur).
-- ============================================================

-- Donner un item (admin / métier). Vérifie le joueur + item valide.
function GiveItem(src, targetSrc, item, count, meta)
    local t = exports.novalife_core:GetPlayer(targetSrc)
    if not t then return false end
    if not exports.ox_inventory:CanCarryItem(targetSrc, item, count or 1) then
        TriggerClientEvent('novalife_core:client:notify', src or targetSrc, { type='error', title='Inventaire', description='Capacité insuffisante.' })
        return false
    end
    exports.ox_inventory:AddItem(targetSrc, item, count or 1, meta or {})
    if src and src ~= targetSrc then
        exports.novalife_core:Log('admin', '📦 Item donné', ('%s → %s : %dx %s'):format(exports.novalife_core:GetPlayer(src).name, t.name, count, item), 16776960)
    end
    return true
end

exports('GiveItem', GiveItem)
exports('RemoveItem', function(src, item, count)
    return exports.ox_inventory:RemoveItem(src, item, count or 1)
end)
exports('GetItemCount', function(src, item)
    return exports.ox_inventory:Search(src, 'count', item) or 0
end)
