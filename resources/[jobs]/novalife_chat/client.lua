-- ============================================================
--  novalife_chat — client.lua
--  Affichage des messages RP (non-intrusif).
-- ============================================================

RegisterNetEvent('novalife_chat:client:msg', function(prefix, text, color)
    -- Affichage via ox_lib (toast discret) + print console
    print(('^3%s %s^7'):format(prefix, text))
    if lib and lib.notify then
        lib.notify({ type = 'inform', title = prefix, description = text, duration = 6000 })
    end
end)
