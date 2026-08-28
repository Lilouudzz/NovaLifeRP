-- ============================================================
--  novalife_spawn — client.lua
--  Applique le spawn sans double spawn (flag local).
-- ============================================================

local spawned = false

RegisterNetEvent('novalife_spawn:start', function()
    if spawned then return end  -- anti double spawn
    TriggerServerEvent('novalife_spawn:request')
end)

RegisterNetEvent('novalife_spawn:doSpawn', function(sp)
    DoScreenFadeOut(800)
    Wait(900)
    local ped = PlayerPedId()
    SetEntityCoordsNoOffset(ped, sp.x, sp.y, sp.z, false, false, false)
    if sp.heading then SetEntityHeading(ped, sp.heading) end
    FreezeEntityPosition(ped, true)
    Wait(400)
    FreezeEntityPosition(ped, false)
    DoScreenFadeIn(800)
    spawned = true
    TriggerEvent('novalife_core:client:spawned', sp)
    -- boucle de sauvegarde de position (thread espacé, pas Wait(0))
    CreateThread(function()
        while spawned do
            Wait(15000)
            local c = GetEntityCoords(PlayerPedId())
            TriggerServerEvent('novalife_core:server:savePosition', { x = c.x, y = c.y, z = c.z, heading = GetEntityHeading(PlayerPedId()) })
        end
    end)
end)

AddEventHandler('onResourceStop', function(r)
    if r == GetCurrentResourceName() then spawned = false end
end)
