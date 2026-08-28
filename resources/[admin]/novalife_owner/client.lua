-- ============================================================
--  novalife_owner — client.lua
--  Ouvre le panneau + reçoit les actions + mode création positions.
-- ============================================================

-- Ouvrir
RegisterNetEvent('novalife_owner:client:open', function()
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'openOwner' })
end)

-- Confirmation argent
RegisterNetEvent('novalife_owner:client:confirmMoney', function(action, target, amount)
    local ok = lib.alertDialog({
        header = 'Confirmation',
        content = ('Transaction importante: %s %d$ au joueur %s. Confirmer ?'):format(action, amount, target),
        centered = true, cancel = true
    })
    if ok == 'confirm' then
        TriggerServerEvent('novalife_owner:money', action, target, amount, true)
    end
end)

-- Actions véhicules côté client
RegisterNetEvent('novalife_owner:client:vehAction', function(action, data)
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh == 0 then
        -- véhicule visé
        local _, _, _, _, ent = GetShapeTestResult(StartShapeTestRay(table.unpack(GetEntityCoords(PlayerPedId()))))
        veh = ent
    end
    if not veh or veh == 0 then return end
    if action == 'repair' then SetVehicleEngineHealth(veh, 1000); SetVehicleBodyHealth(veh, 1000) end
    if action == 'clean' then WashDecalsFromVehicle(veh, 1.0); SetVehicleDirtLevel(veh, 0.0) end
    if action == 'fuel' then
        SetVehicleFuelLevel(veh, 100)
        local plate = GetVehicleNumberPlateText(veh):gsub('%s+','')
        TriggerServerEvent('novalife_fuel:save', plate, 100)
    end
    if action == 'lock' then SetVehicleDoorsLocked(veh, 2) end
    if action == 'unlock' then SetVehicleDoorsLocked(veh, 1) end
end)

RegisterNetEvent('novalife_owner:client:dv', function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh == 0 then
        local _, _, _, _, ent = GetShapeTestResult(StartShapeTestRay(table.unpack(GetEntityCoords(PlayerPedId()))))
        veh = ent
    end
    if veh and DoesEntityExist(veh) then DeleteVehicle(veh) end
end)

-- Spectate (basique: suivi caméra)
RegisterNetEvent('novalife_owner:client:spectate', function(targetSrc)
    local ped = GetPlayerPed(GetPlayerFromServerId(targetSrc))
    if ped and DoesEntityExist(ped) then
        local c = GetEntityCoords(ped)
        SetEntityCoords(PlayerPedId(), c.x, c.y, c.z + 5.0, false, false, false, false)
        NLNotify(0, 'inform', 'Owner', 'Spectate activé.')
    end
end)

-- =================== MODE CRÉATION DE POSITIONS ===================
local creating = nil

RegisterNUICallback('startCreate', function(kind, cb)
    creating = kind
    SetNuiFocus(false, false)
    NLNotify(0, 'inform', 'Owner', 'Allez à la position voulue, puis /ownerpos pour valider.')
    cb('ok')
end)

RegisterCommand('ownerpos', function()
    if not creating then NLNotify(0, 'error', 'Owner', 'Aucune création en cours.'); return end
    local c = GetEntityCoords(PlayerPedId())
    SendNUIMessage({ action = 'createResult', data = { kind = creating, x = c.x, y = c.y, z = c.z, h = GetEntityHeading(PlayerPedId()) } })
    SetNuiFocus(true, true)
    creating = nil
end, false)

RegisterNUICallback('closeOwner', function(_, cb)
    SetNuiFocus(false, false); cb('ok')
end)

-- Le panneau déclenche les events serveur
RegisterNUICallback('srv', function(data, cb)
    if data.e == 'money' then TriggerServerEvent('novalife_owner:money', data.action, data.target, data.amount, data.confirm)
    elseif data.e == 'item' then TriggerServerEvent('novalife_owner:item', data.action, data.target, data.item, data.count)
    elseif data.e == 'job' then TriggerServerEvent('novalife_owner:job', data.action, data.target, data.job, data.grade)
    elseif data.e == 'vehicle' then TriggerServerEvent('novalife_owner:vehicle', data.action, data.target, data.model, data.plate, data.data)
    elseif data.e == 'tp' then TriggerServerEvent('novalife_owner:tp', data.action, data.target)
    elseif data.e == 'tpcoords' then TriggerServerEvent('novalife_owner:tp:coords', data.x, data.y, data.z)
    elseif data.e == 'sanction' then TriggerServerEvent('novalife_owner:sanction', data.action, data.target, data.reason)
    elseif data.e == 'spectate' then TriggerServerEvent('novalife_owner:spectate', data.target)
    elseif data.e == 'property' then TriggerServerEvent('novalife_owner:property', data.action, data.data)
    elseif data.e == 'createGarage' then TriggerServerEvent('novalife_owner:createGarage', data.data)
    elseif data.e == 'business' then TriggerServerEvent('novalife_owner:business', data.action, data.data)
    elseif data.e == 'config' then TriggerServerEvent('novalife_owner:config', data.key, data.value) end
    cb('ok')
end)
