-- ============================================================
--  novalife_ems — client.lua
-- ============================================================

local onDuty = false

CreateThread(function()
    while not Locations do Wait(500) end
    for _, h in ipairs(Locations.hospitals or {}) do
        exports.ox_target:addSphereZone({
            coords = h.coords, radius = 2.5, options = { {
                label = 'EMS — ' .. h.label, icon = 'fas fa-truck-medical',
                onSelect = function() openEMS(h) end
            } }
        })
    end
end)

function openEMS(h)
    local opts = {
        { label = onDuty and 'Fin de service' or 'Prise de service', value = 'duty' },
        { label = 'Soigner (proche)', value = 'heal' },
        { label = 'Réanimer', value = 'revive' },
        { label = 'Facturer', value = 'bill' },
    }
    local c = lib.inputDialog('EMS — ' .. h.label, { { type='select', label='Action', options=opts } })
    if not c then return end
    local v = opts[c[1]].value
    if v == 'duty' then TriggerServerEvent('novalife_ems:toggleDuty')
    elseif v == 'heal' then emsTargetAction('heal')
    elseif v == 'revive' then emsTargetAction('revive')
    elseif v == 'bill' then
        local t = getNearbyCitizen()
        if not t then NLNotify(0, 'error', 'EMS', 'Personne à proximité.'); return end
        local i = lib.inputDialog('Facture EMS', { { type='number', label='Montant' }, { type='input', label='Raison' } })
        if i then TriggerServerEvent('novalife_ems:bill', t, i[1], i[2]) end
    end
end

function emsTargetAction(kind)
    local t = getNearbyCitizen()
    if not t then NLNotify(0, 'error', 'EMS', 'Personne à proximité.'); return end
    TriggerServerEvent('novalife_ems:' .. (kind == 'heal' and 'heal' or 'revive'), t, kind)
end

function getNearbyCitizen()
    local ped = PlayerPedId()
    local c = GetEntityCoords(ped)
    for _, pl in pairs(GetActivePlayers()) do
        local tp = GetPlayerPed(pl)
        if #(c - GetEntityCoords(tp)) < 4.0 then return GetPlayerServerId(pl) end
    end
    return nil
end

RegisterNetEvent('novalife_ems:client:heal', function(kind)
    local ped = PlayerPedId()
    if kind == 'revive' then
        NetworkResurrectLocalPlayer(GetEntityCoords(ped), GetEntityHeading(ped), true, true, true)
        SetEntityHealth(ped, 200)
    else
        SetEntityHealth(ped, 200)
    end
    NLNotify(0, 'success', 'EMS', 'Soins prodigués.')
end)

RegisterNetEvent('novalife_ems:client:revive', function()
    local ped = PlayerPedId()
    NetworkResurrectLocalPlayer(GetEntityCoords(ped), GetEntityHeading(ped), true, true, true)
    SetEntityHealth(ped, 200)
    NLNotify(0, 'success', 'EMS', 'Réanimé.')
end)
