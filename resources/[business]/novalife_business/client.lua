-- ============================================================
--  novalife_business — client.lua
--  Menu patron (ox_lib) à déclencher depuis un point entreprise (configurable).
--  Exemple minimal: commande /biz pour le patron.
-- ============================================================

RegisterCommand('biz', function(_, args)
    local name = args[1]
    if not name then NLNotify(0, 'error', 'Entreprise', 'Usage: /biz [nom]'); return end
    local info = lib.callback.await('novalife_business:info', false, name)
    if not info or info.error then NLNotify(0, 'error', 'Entreprise', 'Accès refusé.'); return end
    local act = lib.inputDialog('Entreprise — ' .. info.label, {
        { type = 'select', label = 'Action', options = {
            { label = 'Déposer (montant)', value = 'deposit' },
            { label = 'Retirer (montant)', value = 'withdraw' },
            { label = 'Infos', value = 'info' },
        } },
        { type = 'number', label = 'Montant', default = 0 }
    })
    if not act then return end
    local action, amount = act[1], tonumber(act[2]) or 0
    local r
    if action == 'deposit' then r = lib.callback.await('novalife_business:deposit', false, name, amount)
    elseif action == 'withdraw' then r = lib.callback.await('novalife_business:withdraw', false, name, amount) end
    if r and r.success then NLNotify(0, 'success', 'Entreprise', 'OK') else NLNotify(0, 'error', 'Entreprise', 'Action refusée') end
end, false)
