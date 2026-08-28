-- ============================================================
--  novalife_police — client.lua
--  Menus d'action (ox_target/ox_lib), points de service.
-- ============================================================

local onDuty = false

-- Points de service (prise/fin)
CreateThread(function()
    while not Locations do Wait(500) end
    for _, st in ipairs(Locations.policeStations or {}) do
        exports.ox_target:addSphereZone({
            coords = st.coords, radius = 2.5, options = { {
                label = 'Police — ' .. st.label,
                icon = 'fas fa-shield-halved',
                onSelect = function() openPoliceMenu(st) end
            } }
        })
    end
end)

function openPoliceMenu(st)
    local p = exports.novalife_core:GetPlayer and nil
    local opts = {
        { label = onDuty and 'Fin de service' or 'Prise de service', value = 'duty' },
        { label = 'Tablette Police (MDT)', value = 'mdt' },
        { label = 'Armurerie', value = 'armory' },
        { label = 'Garage Police', value = 'garage' },
        { label = 'Radar', value = 'radar' },
        { label = 'Dispatch', value = 'dispatch' },
    }
    local choice = lib.inputDialog('Police — ' .. st.label, {
        { type = 'select', label = 'Action', options = opts }
    })
    if not choice then return end
    local v = opts[choice[1]].value
    if v == 'duty' then TriggerServerEvent('novalife_police:toggleDuty')
    elseif v == 'mdt' then openMDT()
    elseif v == 'armory' then openArmory()
    elseif v == 'garage' then openGarage()
    elseif v == 'radar' then openRadar()
    elseif v == 'dispatch' then sendDispatch() end
end

function openArmory()
    -- donne arme de service (sécu serveur côté item)
    local res = lib.callback.await('novalife_core:getPlayer', false)
    if not res or res.job.name ~= 'police' then return end
    TriggerServerEvent('novalife_police:giveWeapon')
end

RegisterNetEvent('novalife_police:client:setDuty', function(d) onDuty = d end)

-- Interactions sur un joueur via ox_target (quand proche)
CreateThread(function()
    exports.ox_target:addSphereZone({
        coords = vector3(0,0,0), radius = 0, -- dummy; on utilise target sur peds ci-dessous
    })
    exports.ox_target:addGlobalPlayer({
        label = 'Actions Police',
        icon = 'fas fa-user-shield',
        canInteract = function(entity)
            return IsPedAPlayer(entity) and onDuty
        end,
        onSelect = function(data)
            local tgt = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
            openPlayerActions(tgt)
        end
    })
end)

function openPlayerActions(tgt)
    local opts = {
        { label = 'Menotter', value = 'cuff' },
        { label = 'Escorter', value = 'escort' },
        { label = 'Fouiller', value = 'search' },
        { label = 'Amende', value = 'fine' },
        { label = 'Arrestation', value = 'arrest' },
        { label = 'Plaque du véhicule', value = 'plate' },
    }
    local c = lib.inputDialog('Action sur le citoyen', { { type='select', label='Action', options=opts } })
    if not c then return end
    local v = opts[c[1]].value
    if v == 'cuff' then TriggerServerEvent('novalife_police:cuff', tgt)
    elseif v == 'escort' then TriggerServerEvent('novalife_police:escort', tgt)
    elseif v == 'search' then policeSearch(tgt)
    elseif v == 'fine' then
        local i = lib.inputDialog('Amende', { { type='number', label='Montant' }, { type='input', label='Raison' } })
        if i then TriggerServerEvent('novalife_police:fine', tgt, i[1], i[2]) end
    elseif v == 'arrest' then
        local i = lib.inputDialog('Arrestation', { { type='number', label='Durée (min)', default=60 } })
        if i then TriggerServerEvent('novalife_police:arrest', tgt, i[1]) end
    elseif v == 'plate' then
        local veh = GetVehiclePedIsIn(GetPlayerPed(tgt), false)
        if veh == 0 then NLNotify(0, 'error', 'Police', 'Pas dans un véhicule.'); return end
        local plate = GetVehicleNumberPlateText(veh):gsub('%s+', '')
        local r = lib.callback.await('novalife_police:plate', false, plate)
        if r and r.found then NLNotify(0, 'inform', 'Plaque', ('%s — %s | Volé: %s'):format(r.vehicle, r.owner, r.stolen)) end
    end
end

function policeSearch(tgt)
    local r = lib.callback.await('novalife_police:search', false, tgt)
    if not r or r.error then NLNotify(0, 'error', 'Fouille', 'Refusée.'); return end
    local txt = 'Fouille de ' .. (r.name or '?') .. ':\n'
    for _, it in ipairs(r.items or {}) do
        if it and it.name then txt = txt .. '- ' .. it.name .. ' x' .. (it.count or 1) .. '\n' end
    end
    lib.alertDialog({ header = 'Fouille', content = txt, centered = true })
end

function openRadar()
    NLNotify(0, 'inform', 'Radar', 'Visez un véhicule.')
    CreateThread(function()
        local hit, _, _, _, ent = RayCast()
        if hit and IsEntityAVehicle(ent) then
            local plate = GetVehicleNumberPlateText(ent):gsub('%s+', '')
            local speed = math.floor(GetEntitySpeed(ent) * 3.6)
            TriggerServerEvent('novalife_police:radar', plate, speed)
        end
    end)
end

function sendDispatch()
    local i = lib.inputDialog('Dispatch', { { type='input', label='Code (ex: 10-20)' }, { type='input', label='Info' } })
    if i then
        local c = GetEntityCoords(PlayerPedId())
        TriggerServerEvent('novalife_police:dispatch', i[1], c, i[2])
    end
end

function RayCast()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local fwd = GetEntityForwardVector(ped)
    local ray = StartShapeTestRay(coords.x, coords.y, coords.z, coords.x+fwd.x*30, coords.y+fwd.y*30, coords.z+fwd.z*30, 10, ped, 0)
    return GetShapeTestResult(ray)
end
