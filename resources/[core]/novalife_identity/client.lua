-- ============================================================
--  novalife_identity — client.lua
--  Ouvre la NUI de création/sélection au spawn, gère l'affichage,
--  et branche illenium-appearance (personnalisation visage/vêtements).
--  L'API illenium-appearance (fork fivem-appearance, MIT) :
--    exports['illenium-appearance']:StartAppearance(playerPed, config, targetPed?)
--    exports['illenium-appearance']:GetAppearance(playerPed) -> table
--    exports['illenium-appearance']:SetAppearance(playerPed, appearance)
--  Source: github.com/iLLeniumStudios/illenium-appearance (MIT).
--  Si la ressource n'est pas installée, on continue sans apparence.
-- ============================================================

local function openUI(mode, data)
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'openIdentity', mode = mode, data = data or {} })
end

local function hasAppearance()
    return GetResourceState('illenium-appearance') == 'started'
end

local function getAppearance()
    if not hasAppearance() then return nil end
    local ok, res = pcall(function()
        return exports['illenium-appearance']:GetAppearance(PlayerPedId())
    end)
    return ok and res or nil
end

local function setAppearance(appearance)
    if not appearance or not hasAppearance() then return end
    pcall(function()
        exports['illenium-appearance']:SetAppearance(PlayerPedId(), appearance)
    end)
end

local function startEditor(cb)
    if not hasAppearance() then cb(nil) return end
    local ok, res = pcall(function()
        -- config minimal: tout editable
        return exports['illenium-appearance']:StartAppearance(PlayerPedId(), {
            ped = true, headBlend = true, faceFeatures = true,
            headOverlays = true, components = true, props = true, tattoos = true
        })
    end)
    if ok and res then cb(getAppearance()) else cb(nil) end
end

RegisterNetEvent('novalife_identity:showId', function(id)
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'showId', data = id })
end)

RegisterNetEvent('novalife_identity:showLicenses', function(lic)
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'showLicenses', data = lic })
end)

RegisterNetEvent('novalife_identity:openCreation', function()
    local chars = lib.callback.await('novalife_identity:getCharacters', false)
    if chars and #chars > 0 then
        openUI('select', chars)
    else
        openUI('create', {})
    end
end)

-- Le spawn demande à appliquer l'apparence sauvegardée
RegisterNetEvent('novalife_identity:applyAppearance', function(appearance)
    setAppearance(appearance)
end)

RegisterNetEvent('novalife_identity:openEditor', function(cbEvent)
    startEditor(function(app)
        TriggerEvent(cbEvent, app)
    end)
end)

RegisterNUICallback('closeIdentity', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('createCharacter', function(data, cb)
    -- Ouvrir l'éditeur d'apparence AVANT de valider
    startEditor(function(appearance)
        data.appearance = appearance
        local res = lib.callback.await('novalife_identity:createCharacter', false, data)
        if res and res.success then
            SetNuiFocus(false, false)
            TriggerServerEvent('novalife_core:server:playerLoaded', res.citizenid)
            TriggerEvent('novalife_spawn:start')
            cb({ success = true })
        else
            cb({ success = false, error = res and res.error or 'erreur' })
        end
    end)
end)

RegisterNUICallback('selectCharacter', function(charId, cb)
    local res = lib.callback.await('novalife_identity:selectCharacter', false, charId)
    if res and res.success then
        SetNuiFocus(false, false)
        -- appliquer l'apparence sauvegardée (si illenium-appearance présent)
        setAppearance(res.appearance)
        TriggerServerEvent('novalife_core:server:playerLoaded', res.citizenid)
        TriggerEvent('novalife_spawn:start')
        cb({ success = true })
    else
        cb({ success = false })
    end
end)
