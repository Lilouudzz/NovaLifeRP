-- ============================================================
--  novalife_mechanic — client.lua
-- ============================================================

local onDuty = false

CreateThread(function()
    while not Locations do Wait(500) end
    for _, g in ipairs(Garages) do
        if g.type == 'mechanic' then
            exports.ox_target:addSphereZone({
                coords = g.coords, radius = g.radius or 4.0, options = { {
                    label = 'Mécano — Atelier', icon = 'fas fa-wrench',
                    onSelect = function() openMechanic() end
                } }
            })
        end
    end
end)

function openMechanic()
    local opts = {
        { label = onDuty and 'Fin de service' or 'Prise de service', value = 'duty' },
        { label = 'Réparer (moteur+carrosserie)', value = 'repair' },
        { label = 'Laver', value = 'wash' },
        { label = 'Peindre', value = 'paint' },
        { label = 'Moteur', value = 'engine' },
        { label = 'Freins', value = 'brakes' },
        { label = 'Transmission', value = 'transmission' },
        { label = 'Suspension', value = 'suspension' },
        { label = 'Carrosserie', value = 'body' },
        { label = 'Facturer client', value = 'bill' },
    }
    local c = lib.inputDialog('Atelier Mécano', { { type='select', label='Service', options=opts } })
    if not c then return end
    local v = opts[c[1]].value
    if v == 'duty' then TriggerServerEvent('novalife_mechanic:toggleDuty')
    elseif v == 'bill' then
        local t = getNearbyVehOwner()
        if not t then NLNotify(0, 'error', 'Mécano', 'Client à proximité.'); return end
        local i = lib.inputDialog('Facture', { { type='number', label='Montant' }, { type='input', label='Raison' } })
        if i then TriggerServerEvent('novalife_mechanic:bill', t, i[1], i[2]) end
    else
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh == 0 then NLNotify(0, 'error', 'Mécano', 'Dans un véhicule.'); return end
        local plate = GetVehicleNumberPlateText(veh):gsub('%s+', '')
        TriggerServerEvent('novalife_mechanic:repair', plate, v)
    end
end

function getNearbyVehOwner()
    local ped = PlayerPedId(); local c = GetEntityCoords(ped)
    for _, pl in pairs(GetActivePlayers()) do
        local tp = GetPlayerPed(pl)
        if #(c - GetEntityCoords(tp)) < 6.0 then return GetPlayerServerId(pl) end
    end
    return nil
end

RegisterNetEvent('novalife_mechanic:client:apply', function(kind)
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh == 0 then veh = GetVehicleInFront() end
    if veh == 0 then return end
    if kind == 'repair' or kind == 'engine' then SetVehicleEngineHealth(veh, 1000) end
    if kind == 'repair' or kind == 'body' then SetVehicleBodyHealth(veh, 1000) end
    if kind == 'wash' then
        WashDecalsFromVehicle(veh, 1.0)
        SetVehicleDirtLevel(veh, 0.0)
    end
    if kind == 'paint' then
        local col = lib.inputDialog('Peinture', { { type='color', label='Couleur' } })
        if col then SetVehicleCustomPrimaryColour(veh, col[1].r*255, col[1].g*255, col[1].b*255) end
    end
    NLNotify(0, 'success', 'Mécano', 'Service effectué.')
end)

function GetVehicleInFront()
    local ped = PlayerPedId(); local c = GetEntityCoords(ped); local f = GetEntityForwardVector(ped)
    local _, hit, _, _, ent = GetShapeTestResult(StartShapeTestRay(c.x, c.y, c.z, c.x+f.x*5, c.y+f.y*5, c.z+f.z*5, 10, ped, 0))
    if hit and ent and IsEntityAVehicle(ent) then return ent end
    return 0
end
