-- ============================================================
--  novalife_map_pillbox — client.lua
--  Déverrouille l'accès aux intérieurs hôpital stock (technique
--  légale: collision des portes retirée) + points de service EMS.
--  Aucun asset tiers, aucun YMAP binaire redistribué.
-- ============================================================

local hospitalDoors = {
    150406194,  -- v_ilev_hospdoor
    150406195,
    1627538942, -- v_ilev_gates_01
}

CreateThread(function()
    while true do
        Wait(2000)
        for _, h in ipairs(hospitalDoors) do
            local ent = GetClosestObjectOfType(323.0, -1064.0, -99.0, 8.0, h, false, false, false)
            if ent and ent ~= 0 then
                SetEntityCollision(ent, false, false)
                FreezeEntityPosition(ent, true)
            end
        end
        Wait(15000)
    end
end)

CreateThread(function()
    while not PILLBOX do Wait(500) end
    while not exports.ox_target do Wait(500) end

    -- Prise de service EMS (devant l'hôpital)
    exports.ox_target:addSphereZone({
        coords = PILLBOX.dutyPoint, radius = 2.5, options = { {
            label = 'EMS — Prise de service', icon = 'fas fa-truck-medical',
            groups = 'ambulance',
            onSelect = function() TriggerServerEvent('novalife_ems:toggleDuty') end
        } }
    })

    -- Salle de service EMS (intérieur)
    exports.ox_target:addSphereZone({
        coords = PILLBOX.service, radius = 1.5, options = { {
            label = 'EMS — Salle de service', icon = 'fas fa-stethoscope',
            groups = 'ambulance',
            onSelect = function() NLNotify(0, 'inform', 'EMS', 'Salle de service.') end
        } }
    })

    -- Entrée extérieure -> intérieur
    exports.ox_target:addSphereZone({
        coords = vector3(315.0, -1070.0, -99.0), radius = 1.5, options = { {
            label = 'Entrer (Pillbox)', icon = 'fas fa-door-open',
            onSelect = function()
                DoScreenFadeOut(400); Wait(450)
                SetEntityCoords(PlayerPedId(), PILLBOX.lobby.x, PILLBOX.lobby.y, PILLBOX.lobby.z, false, false, false, true)
                SetEntityHeading(PlayerPedId(), PILLBOX.lobbyHead)
                DoScreenFadeIn(400)
            end
        } }
    })

    -- Sortie intérieur -> extérieur
    exports.ox_target:addSphereZone({
        coords = vector3(328.0, -1072.0, -99.0), radius = 1.5, options = { {
            label = 'Sortir (Pillbox)', icon = 'fas fa-door-open',
            onSelect = function()
                DoScreenFadeOut(400); Wait(450)
                SetEntityCoords(PlayerPedId(), PILLBOX.outside.x, PILLBOX.outside.y, PILLBOX.outside.z, false, false, false, true)
                DoScreenFadeIn(400)
            end
        } }
    })
end)

-- Export: spawn EMS
exports('GetEMSSpawn', function() return PILLBOX.spawn, PILLBOX.spawnHead end)
exports('GetEMSLobby', function() return PILLBOX.lobby, PILLBOX.lobbyHead end)
