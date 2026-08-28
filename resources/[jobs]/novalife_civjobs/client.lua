-- ============================================================
--  novalife_civjobs — client.lua
--  Points de métier + boucles simples de récompense (espacées).
-- ============================================================

local jobs = {
    taxi = { depot = Locations.civilJobs.taxiRanks[1], pay = 'taxiPay', label = 'Taxi' },
    bus = { depot = Locations.civilJobs.busDepot, pay = 'busPay', label = 'Bus' },
    garbage = { depot = Locations.civilJobs.garbageDepot, pay = 'garbagePay', label = 'Éboueur' },
    delivery = { depot = Locations.civilJobs.deliveryDepot, pay = 'deliveryPay', label = 'Livreur' },
}

CreateThread(function()
    while not Locations do Wait(500) end
    for name, j in pairs(jobs) do
        if j.depot and j.depot.coords then
            exports.ox_target:addSphereZone({
                coords = j.depot.coords, radius = 3.0, options = { {
                    label = 'Prise de service — ' .. j.label, icon = 'fas fa-briefcase',
                    onSelect = function() takeJob(name) end
                } }
            })
        end
    end
end)

-- Prise de service civile (appel serveur qui vérifie le job)
function takeJob(name)
    TriggerServerEvent('novalife_civjobs:takeJob', name)
end
RegisterCommand('course', function()
    local res = lib.callback.await('novalife_core:getPlayer', false)
    if not res or res.job.name ~= 'taxi' then NLNotify(0, 'error', 'Taxi', 'Vous n’êtes pas taxi.'); return end
    local start = GetEntityCoords(PlayerPedId())
    NLNotify(0, 'inform', 'Taxi', 'Course démarrée, allez à destination.')
    CreateThread(function()
        local done = false
        while not done do
            Wait(1000)
            if #(start - GetEntityCoords(PlayerPedId())) > 300 then
                local dist = #(start - GetEntityCoords(PlayerPedId()))
                TriggerServerEvent('novalife_civjobs:taxiPay', dist)
                done = true
                NLNotify(0, 'success', 'Taxi', ('Course payée: %dm'):format(math.floor(dist)))
            end
        end
    end)
end, false)

-- Livraison: point de livraison aléatoire
RegisterCommand('livrer', function()
    local res = lib.callback.await('novalife_core:getPlayer', false)
    if not res or res.job.name ~= 'delivery' then NLNotify(0, 'error', 'Livreur', 'Vous n’êtes pas livreur.'); return end
    local dest = vector3(120.0 + math.random(-200,200), -1000.0 + math.random(-200,200), 29.0)
    SetNewWaypoint(dest.x, dest.y)
    NLNotify(0, 'inform', 'Livreur', 'Direction la livraison.')
    CreateThread(function()
        local done = false
        while not done do
            Wait(1000)
            if #(dest - GetEntityCoords(PlayerPedId())) < 8 then
                TriggerServerEvent('novalife_civjobs:deliveryPay')
                done = true
                NLNotify(0, 'success', 'Livreur', 'Livraison payée.')
            end
        end
    end
end, false)

-- SetJob côté serveur (helper pour prise de service civile) géré dans server.lua via 'novalife_civjobs:takeJob'
