-- ============================================================
--  novalife_keys — client.lua
--  /lock, /givekey, /takekey. Verrouillage visuel + démarrage bloqué sans clé.
-- ============================================================

RegisterCommand('lock', function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh == 0 then
        -- viser un véhicule proche
        local cveh = GetVehicleInFront()
        if cveh == 0 then NLNotify(0, 'error', 'Clés', 'Aucun véhicule.'); return end
        veh = cveh
    end
    local plate = GetVehicleNumberPlateText(veh):gsub('%s+', '')
    local ok = lib.callback.await('novalife_keys:canLock', false, plate)
    if not ok then NLNotify(0, 'error', 'Clés', 'Vous n’avez pas la clé.'); return end
    local locked = GetVehicleDoorLockStatus(veh) ~= 1
    if locked then
        SetVehicleDoorsLocked(veh, 1)
        NLNotify(0, 'inform', 'Clés', 'Véhicule déverrouillé.')
    else
        SetVehicleDoorsLocked(veh, 2)
        NLNotify(0, 'inform', 'Clés', 'Véhicule verrouillé.')
    end
end)

RegisterCommand('givekey', function(_, args)
    local target = tonumber(args[1])
    if not target then NLNotify(0, 'error', 'Clés', 'Usage: /givekey [id]'); return end
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh == 0 then NLNotify(0, 'error', 'Clés', 'Dans un véhicule.'); return end
    local plate = GetVehicleNumberPlateText(veh):gsub('%s+', '')
    TriggerServerEvent('novalife_keys:give', plate, target)
end)

function GetVehicleInFront()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local fwd = GetEntityForwardVector(ped)
    local ray = StartShapeTestRay(coords.x, coords.y, coords.z, coords.x + fwd.x * 5, coords.y + fwd.y * 5, coords.z + fwd.z * 5, 10, ped, 0)
    local _, hit, _, _, ent = GetShapeTestResult(ray)
    if hit and ent and DoesEntityExist(ent) and IsEntityAVehicle(ent) then
        return ent
    end
    return 0
end

-- Anti-démarrage sans clé (hook clé)
CreateThread(function()
    while true do
        Wait(500)
        local ped = PlayerPedId()
        if IsPedTryingToEnterALockedVehicle(ped) then
            local veh = GetVehiclePedIsTryingToEnter(ped)
            if veh and veh > 0 then
                local plate = GetVehicleNumberPlateText(veh):gsub('%s+', '')
                local ok = lib.callback.await('novalife_keys:canStart', false, plate)
                if not ok then
                    ClearPedTasks(ped)
                    NLNotify(0, 'error', 'Clés', 'Portes verrouillées.')
                end
            end
        end
    end
end)
