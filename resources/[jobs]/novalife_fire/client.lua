-- ============================================================
--  novalife_fire — client.lua
--  Points de caserne + menu intervention + extinction d'incendie.
-- ============================================================

local onDuty = false

CreateThread(function()
    while not Locations do Wait(500) end
    for _, st in ipairs(Locations.fireStations or {}) do
        exports.ox_target:addSphereZone({
            coords = st.coords, radius = 2.5, options = { {
                label = 'Pompiers — ' .. st.label, icon = 'fas fa-fire',
                onSelect = function() openFire(st) end
            } }
        })
    end
end)

function openFire(st)
    local opts = {
        { label = onDuty and 'Fin de service' or 'Prise de service', value = 'duty' },
        { label = 'Sauvetage (proche)', value = 'rescue' },
        { label = 'Donner extincteur', value = 'extinguisher' },
    }
    local c = lib.inputDialog('Pompiers — ' .. st.label, { { type='select', label='Action', options=opts } })
    if not c then return end
    local v = opts[c[1]].value
    if v == 'duty' then TriggerServerEvent('novalife_fire:toggleDuty')
    elseif v == 'rescue' then
        local t = getNearby()
        if t then TriggerServerEvent('novalife_fire:rescue', t) else NLNotify(0, 'error', 'Pompiers', 'Personne à proximité.') end
    elseif v == 'extinguisher' then
        GiveWeaponToPed(PlayerPedId(), 'weapon_fireextinguisher', 1, false, true)
    end
end

function getNearby()
    local ped = PlayerPedId(); local c = GetEntityCoords(ped)
    for _, pl in pairs(GetActivePlayers()) do
        local tp = GetPlayerPed(pl)
        if #(c - GetEntityCoords(tp)) < 5.0 then return GetPlayerServerId(pl) end
    end
    return nil
end

-- Boucle d'extinction: si le joueur tient l'extincteur et vise un feu (particule)
-- On utilise simplement l'extincteur vanilla GTA (le "feu" est géré par le jeu / mappings).
CreateThread(function()
    while true do
        Wait(0)
        if onDuty and HasPedGotWeapon(PlayerPedId(), 'weapon_fireextinguisher', false) then
            DisableControlAction(0, 22, false) -- autoriser utilisation
        end
    end
end)
