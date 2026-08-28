-- ============================================================
--  novalife_banking — client.lua
--  Points d'interaction (ox_target) aux banques + ouverture NUI.
-- ============================================================

local opened = false

CreateThread(function()
    while not Locations do Wait(500) end
    for _, bank in ipairs(Locations.banks or {}) do
        exports.ox_target:addSphereZone({
            coords = bank.coords, radius = 1.5, options = { {
                label = 'Ouvrir la banque — ' .. bank.label,
                icon = 'fas fa-university',
                onSelect = function() openBank() end
            } }
        })
    end
end)

function openBank()
    if opened then return end
    opened = true
    SetNuiFocus(true, true)
    local data = lib.callback.await('novalife_banking:open', false)
    if data then
        SendNUIMessage({ action = 'openBank', data = data })
    else
        opened = false
        SetNuiFocus(false, false)
    end
end

RegisterNUICallback('closeBank', function(_, cb)
    SetNuiFocus(false, false); opened = false; cb('ok')
end)

RegisterNUICallback('deposit', function(amount, cb)
    local r = lib.callback.await('novalife_banking:deposit', false, amount)
    cb({ success = r })
end)
RegisterNUICallback('withdraw', function(amount, cb)
    local r = lib.callback.await('novalife_banking:withdraw', false, amount)
    cb({ success = r })
end)
RegisterNUICallback('transfer', function(d, cb)
    local r = lib.callback.await('novalife_banking:transfer', false, d.target, d.amount)
    cb(r)
end)
RegisterNUICallback('payBill', function(billId, cb)
    local r = lib.callback.await('novalife_banking:payBill', false, billId)
    cb(r)
end)
RegisterNUICallback('refresh', function(_, cb)
    local data = lib.callback.await('novalife_banking:refresh', false)
    cb(data)
end)
