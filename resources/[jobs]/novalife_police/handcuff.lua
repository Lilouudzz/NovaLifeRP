-- ============================================================
--  novalife_police — handcuff.lua
--  Gère l'état menotté + escort côté client.
-- ============================================================

local cuffed = false
local escorting = nil

RegisterNetEvent('novalife_police:client:cuff', function(state)
    cuffed = state
    local ped = PlayerPedId()
    if cuffed then
        -- animation menottes
        RequestAnimDict('mp_arresting')
        while not HasAnimDictLoaded('mp_arresting') do Wait(10) end
        TaskPlayAnim(ped, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0, false, false, false)
        NLNotify(0, 'inform', 'Police', 'Vous êtes menotté.')
    else
        ClearPedTasks(ped)
        NLNotify(0, 'inform', 'Police', 'Vous êtes libéré.')
    end
end)

RegisterNetEvent('novalife_police:client:escort', function(copSrc, state)
    if state then
        escorting = copSrc
        CreateThread(function()
            while escorting do
                Wait(0)
                local cop = GetPlayerPed(GetPlayerFromServerId(escorting))
                if cop and DoesEntityExist(cop) then
                    local c = GetEntityCoords(cop)
                    SetEntityCoords(PlayerPedId(), c.x - 0.6, c.y, c.z, false, false, false, false)
                end
            end
        end)
    else
        escorting = nil
        ClearPedTasks(PlayerPedId())
    end
end)

RegisterNetEvent('novalife_police:client:jail', function(time)
    NLNotify(0, 'error', 'Prison', ('Vous êtes incarcéré %d min.'):format(time))
    -- TP cellule
    SetEntityCoords(PlayerPedId(), 1691.0, 2604.0, 45.5, false, false, false, false)
    cuffed = true
end)

-- Bloquer actions quand menotté
CreateThread(function()
    while true do
        Wait(0)
        if cuffed then
            DisableControlAction(0, 24, true)  -- attack
            DisableControlAction(0, 22, true)  -- jump
            DisableControlAction(0, 25, true)  -- aim
            DisableControlAction(0, 75, true)  -- exit veh
        end
    end
end)
