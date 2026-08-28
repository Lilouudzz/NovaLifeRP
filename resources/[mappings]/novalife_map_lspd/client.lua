-- ============================================================
--  novalife_map_lspd — client.lua
--  Déverrouille l'accès aux intérieurs police stock (technique
--  légale: on désactive la collision des portes d'intérieur via
--  leur hash, et on place les points de service ox_target).
--  Aucun asset tiers, aucun YMAP binaire redistribué.
-- ============================================================

-- Liste des portes d'intérieur police dont on retire la collision
-- (hashes connus des portes "v_ilev_*" du lobby MRPD). On les rend
-- franchissables pour que les joueurs entrent librement.
local policeDoors = {
    1785282319,  -- v_ilev_police_frontdoor
    1785282320,
    -1226170249, -- v_ilev_copdoor
    -1226170250,
}

CreateThread(function()
    -- Retire la collision des portes d'intérieur police (une fois chargées)
    while true do
        Wait(2000)
        for _, h in ipairs(policeDoors) do
            local ent = GetClosestObjectOfType(-110.0, -620.0, 36.0, 6.0, h, false, false, false)
            if ent and ent ~= 0 then
                SetEntityCollision(ent, false, false)
                FreezeEntityPosition(ent, true)
            end
        end
        Wait(15000)
    end
end)

-- Points de service Police (ox_target)
CreateThread(function()
    while not LSPD do Wait(500) end
    while not exports.ox_target do Wait(500) end

    -- Prise de service devant le commissariat
    exports.ox_target:addSphereZone({
        coords = LSPD.dutyPoint, radius = 2.5, options = { {
            label = 'Police — Prise de service', icon = 'fas fa-user-shield',
            groups = 'police',
            onSelect = function() TriggerServerEvent('novalife_police:toggleDuty') end
        } }
    })

    -- Armurerie (intérieur lobby)
    exports.ox_target:addSphereZone({
        coords = LSPD.armor, radius = 1.2, options = { {
            label = 'Police — Armurerie', icon = 'fas fa-shield-halved',
            groups = 'police',
            onSelect = function() exports.novalife_admin:OpenArmory and nil end
        } }
    })

    -- Cellules
    exports.ox_target:addSphereZone({
        coords = LSPD.cells, radius = 1.5, options = { {
            label = 'Police — Cellules', icon = 'fas fa-lock',
            groups = 'police',
            onSelect = function() NLNotify(0, 'inform', 'Police', 'Accès cellules.') end
        } }
    })

    -- Entrée extérieure: téléporte vers le lobby
    exports.ox_target:addSphereZone({
        coords = LSPD.entrance, radius = 1.5, options = { {
            label = 'Entrer (LSPD)', icon = 'fas fa-door-open',
            onSelect = function()
                DoScreenFadeOut(400)
                Wait(450)
                SetEntityCoords(PlayerPedId(), LSPD.lobby.x, LSPD.lobby.y, LSPD.lobby.z, false, false, false, true)
                SetEntityHeading(PlayerPedId(), LSPD.lobbyHead)
                DoScreenFadeIn(400)
            end
        } }
    })

    -- Sortie: lobby -> extérieur
    exports.ox_target:addSphereZone({
        coords = vector3(-108.0, -627.0, 36.1), radius = 1.5, options = { {
            label = 'Sortir (LSPD)', icon = 'fas fa-door-open',
            onSelect = function()
                DoScreenFadeOut(400)
                Wait(450)
                SetEntityCoords(PlayerPedId(), LSPD.outside.x, LSPD.outside.y, LSPD.outside.z, false, false, false, true)
                DoScreenFadeIn(400)
            end
        } }
    })
end)

-- Export: spawn Police
exports('GetPoliceSpawn', function() return LSPD.spawn, LSPD.spawnHead end)
exports('GetPoliceLobby', function() return LSPD.lobby, LSPD.lobbyHead end)
