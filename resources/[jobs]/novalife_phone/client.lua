-- ============================================================
--  novalife_phone — client.lua
--  Ouverture du téléphone (touche M) + réception des events.
-- ============================================================

RegisterKeyMapping('phone', 'Ouvrir le téléphone', 'keyboard', 'M')

RegisterCommand('phone', function()
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'openPhone' })
end, false)

RegisterNUICallback('closePhone', function(_, cb)
    SetNuiFocus(false, false); cb('ok')
end)
