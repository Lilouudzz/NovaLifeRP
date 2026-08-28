-- ============================================================
--  novalife_admin — client.lua
--  Réception des actions serveur (TP, freeze, spawn, DV) + ouverture menu.
-- ============================================================

RegisterNetEvent('novalife_admin:client:open', function()
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'openAdmin' })
end)

RegisterNetEvent('novalife_admin:client:freeze', function()
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, not IsEntityFrozen(ped))
end)

RegisterNetEvent('novalife_admin:client:goto', function(coords)
    local ped = PlayerPedId()
    SetEntityCoords(ped, coords.x, coords.y, coords.z + 1.0, false, false, false, false)
end)

RegisterNetEvent('novalife_admin:client:bring', function(coords)
    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z + 1.0, false, false, false, false)
end)

RegisterNetEvent('novalife_admin:client:tpm', function()
    -- TP sur le waypoint
    local _, x, y = GetBlipInfoIdCoord(GetFirstBlipInfoId(8))
    if x and y and x ~= 0 then
        local z = GetGroundZFor3DCoord(x, y, 1000.0, 0, false)
        SetEntityCoords(PlayerPedId(), x, y, z, false, false, false, false)
    end
end)

RegisterNetEvent('novalife_admin:client:spawnCar', function(model)
    local m = GetHashKey(model)
    RequestModel(m); while not HasModelLoaded(m) do Wait(50) end
    local veh = CreateVehicle(m, GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId()), true, false)
    TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
end)

RegisterNetEvent('novalife_admin:client:dv', function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh == 0 then
        local _, _, _, _, ent = GetShapeTestResult(StartShapeTestRay(table.unpack(GetEntityCoords(PlayerPedId())), 0,0,0,0,0,0))
        veh = ent
    end
    if veh and DoesEntityExist(veh) then DeleteVehicle(veh) end
end)

RegisterNUICallback('closeAdmin', function(_, cb)
    SetNuiFocus(false, false); cb('ok')
end)

-- Le menu admin déclenche les commandes serveur
RegisterNUICallback('action', function(data, cb)
    ExecuteCommand(('%s %s'):format(data.cmd, data.args or ''))
    cb('ok')
end)
