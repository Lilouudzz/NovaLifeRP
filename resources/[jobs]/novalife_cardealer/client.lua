-- ============================================================
--  novalife_cardealer — client.lua
--  Ouverture du catalogue + achat/essai/financement.
-- ============================================================

CreateThread(function()
    while not Locations do Wait(500) end
    for _, c in ipairs(Locations.cardealer or {}) do
        exports.ox_target:addSphereZone({
            coords = c.coords, radius = 3.0, options = { {
                label = 'Concessionnaire — ' .. c.label, icon = 'fas fa-car',
                onSelect = function() openCatalog() end
            } }
        })
    end
end)

function openCatalog()
    local cat = lib.callback.await('novalife_cardealer:catalog', false)
    if not cat then NLNotify(0, 'error', 'Concession', 'Catalogue indisponible.'); return end
    local options = {}
    for id, data in pairs(cat) do
        for _, it in ipairs(data.items) do
            options[#options + 1] = { label = ('%s %s — %s$%s'):format(it.brand, it.name, it.price, it.stock == -1 and '' or (' (stock ' .. it.stock .. ')')), model = it.model }
        end
    end
    if #options == 0 then NLNotify(0, 'inform', 'Concession', 'Aucun véhicule en stock.'); return end
    local c = lib.inputDialog('Concessionnaire', {
        { type = 'select', label = 'Véhicule', options = options },
        { type = 'select', label = 'Mode', options = { { label = 'Achat comptant', value = 'buy' }, { label = 'Financement', value = 'finance' }, { label = 'Essai', value = 'test' } } }
    })
    if not c then return end
    local model = options[c[1]].model
    local mode = c[2]
    local r
    if mode == 'buy' then r = lib.callback.await('novalife_cardealer:buy', false, model)
    elseif mode == 'finance' then r = lib.callback.await('novalife_cardealer:finance', false, model)
    else r = lib.callback.await('novalife_cardealer:test', false, model) end
    if r and r.success then
        if mode == 'test' then spawnTest(r) else NLNotify(0, 'success', 'Concession', ('Achat validé: %s'):format(r.plate))
    else
        NLNotify(0, 'error', 'Concession', 'Erreur: ' .. (r and r.error or 'inconnu'))
    end
end

function spawnTest(r)
    local m = GetHashKey(r.vehicle)
    RequestModel(m); while not HasModelLoaded(m) do Wait(50) end
    local veh = CreateVehicle(m, r.coords.x, r.coords.y, r.coords.z, 0.0, true, false)
    TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
    NLNotify(0, 'inform', 'Essai', ('Essai de %d s'):format(Config.Cardealer.testDriveTime))
    SetTimeout(Config.Cardealer.testDriveTime * 1000, function()
        if DoesEntityExist(veh) then DeleteVehicle(veh) end
        NLNotify(0, 'inform', 'Essai', 'Fin de l’essai.')
    end)
end
