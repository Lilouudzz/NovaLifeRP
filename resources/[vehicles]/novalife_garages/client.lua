-- ============================================================
--  novalife_garages — client.lua
--  Zones ox_target + spawn/store véhicules.
-- ============================================================

local inGarage = nil

CreateThread(function()
    while not Garages do Wait(500) end
    for _, g in ipairs(Garages) do
        exports.ox_target:addSphereZone({
            coords = g.coords, radius = g.radius or 3.0, options = { {
                label = 'Garage — ' .. g.label,
                icon = 'fas fa-warehouse',
                onSelect = function() openGarage(g) end
            }, {
                label = 'Ranger le véhicule',
                icon = 'fas fa-parking',
                canInteract = function() return IsPedInAnyVehicle(PlayerPedId(), false) end,
                onSelect = function() storeVehicle(g) end
            } }
        })
    end
end)

function openGarage(g)
    local data = lib.callback.await('novalife_garages:list', false, g.id)
    if data.error then NLNotify(0, 'error', 'Garage', 'Accès refusé.'); return end
    -- Menu ox_lib listant les véhicules
    local opts = {}
    for _, v in ipairs(data.vehicles) do
        opts[#opts + 1] = { label = (Vehicles.list[v.vehicle] and Vehicles.list[v.vehicle].name or v.vehicle) .. ' [' .. v.plate .. ']', plate = v.plate, vehicle = v.vehicle, fuel = v.fuel, engine = v.engine, body = v.body }
    end
    if g.job then
        for _, v in ipairs(Vehicles.serviceVehicles[g.job] or {}) do
            opts[#opts + 1] = { label = '[SERVICE] ' .. (Vehicles.list[v] and Vehicles.list[v].name or v), plate = 'SERVICE', vehicle = v, service = true }
        end
    end
    if #opts == 0 then NLNotify(0, 'inform', 'Garage', 'Aucun véhicule.'); return end
    local choice = lib.inputDialog('Garage — ' .. g.label, {
        { type = 'select', label = 'Véhicule', options = opts }
    })
    if not choice then return end
    local sel = opts[choice[1]]
    if sel.service then
        local r = lib.callback.await('novalife_garages:spawnService', false, g.id, sel.vehicle)
        if r and r.success then spawnVeh(r) end
    else
        local r = lib.callback.await('novalife_garages:spawn', false, g.id, sel.plate)
        if r and r.success then spawnVeh(r) else NLNotify(0, 'error', 'Garage', 'Sortie impossible.') end
    end
end

function spawnVeh(r)
    local m = GetHashKey(r.vehicle)
    RequestModel(m)
    while not HasModelLoaded(m) do Wait(50) end
    local veh = CreateVehicle(m, r.coords.x, r.coords.y, r.coords.z, 0.0, true, false)
    SetVehicleNumberPlateText(veh, r.plate)
    SetVehicleFuelLevel(veh, r.fuel or 100)
    SetVehicleEngineHealth(veh, r.engine or 1000)
    SetVehicleBodyHealth(veh, r.body or 1000)
    TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
end

function storeVehicle(g)
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh == 0 then return end
    local plate = GetVehicleNumberPlateText(veh)
    plate = plate:gsub('%s+', '')
    local fuel = GetVehicleFuelLevel(veh)
    local engine = GetVehicleEngineHealth(veh)
    local body = GetVehicleBodyHealth(veh)
    TriggerServerEvent('novalife_garages:store', plate, g.id, { fuel = fuel, engine = engine, body = body })
    DeleteVehicle(veh)
end
