-- ============================================================
--  novalife_fuel — client.lua
--  Consommation realiste + stations (ox_target) + remplissage.
-- ============================================================

local lastSave = 0

CreateThread(function()
    while true do
        Wait(1500) -- pas Wait(0): consommation lissée
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            local veh = GetVehiclePedIsIn(ped, false)
            local level = GetVehicleFuelLevel(veh)
            if level > 0 then
                local mult = Economy.Fuel.consumptionRate or 1.0
                local new = level - (0.08 * mult)
                if new < 0 then new = 0 end
                SetVehicleFuelLevel(veh, new)
                if new <= 0 then
                    -- moteur coupé
                    SetVehicleEngineOn(veh, false, true, true)
                end
            end
            -- sauvegarde SQL espacée
            local now = GetGameTimer()
            if now - lastSave > (Economy.Fuel.saveInterval or 30) * 1000 then
                local plate = GetVehicleNumberPlateText(veh):gsub('%s+', '')
                TriggerServerEvent('novalife_fuel:save', plate, GetVehicleFuelLevel(veh))
                lastSave = now
            end
        end
    end
end)

-- Stations-service
CreateThread(function()
    while not Locations do Wait(500) end
    for _, s in ipairs(Locations.fuelStations or {}) do
        exports.ox_target:addSphereZone({
            coords = s.coords, radius = 3.0, options = { {
                label = 'Station-service — ' .. s.label,
                icon = 'fas fa-gas-pump',
                canInteract = function() return IsPedInAnyVehicle(PlayerPedId(), false) end,
                onSelect = function() openFuel() end
            } }
        })
    end
end)

function openFuel()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh == 0 then return end
    local plate = GetVehicleNumberPlateText(veh):gsub('%s+', '')
    local level = GetVehicleFuelLevel(veh)
    local need = math.ceil(100 - level)
    if need <= 0 then NLNotify(0, 'inform', 'Carburant', 'Réservoir plein.'); return end
    local input = lib.inputDialog('Carburant', {
        { type = 'number', label = 'Litres à ajouter (max ' .. need .. ')', default = need, min = 1, max = need }
    })
    if not input then return end
    local litres = math.min(tonumber(input[1]) or 0, need)
    local res = lib.callback.await('novalife_fuel:buy', false, plate, litres)
    if res and res.success then
        NLNotify(0, 'success', 'Carburant', ('Plein fait: -%d$'):format(res.cost))
    else
        NLNotify(0, 'error', 'Carburant', 'Fonds insuffisants ou erreur.')
    end
end
