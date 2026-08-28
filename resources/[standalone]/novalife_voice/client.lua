-- ============================================================
--  novalife_voice — client.lua
--  S'interface avec pma-voice (ou resvoice compatible mumble).
--  API réelle pma-voice (github.com/AvarianKnight/pma-voice, MIT):
--    exports['pma-voice']:setRadioChannel(int)  -- 0 = quitter
--    exports['pma-voice']:setCallChannel(int)    -- 0 = quitter
--    exports['pma-voice']:addPlayerToRadio(int)
--  Si la ressource n'est pas présente, on ne fait rien (pcall).
-- ============================================================

local currentRadio = 0
local usingMegaphone = false

local function hasVoice()
    return GetResourceState('pma-voice') == 'started' or GetResourceState('resvoice') == 'started'
end

local function voiceRes()
    if GetResourceState('pma-voice') == 'started' then return 'pma-voice' end
    if GetResourceState('resvoice') == 'started' then return 'resvoice' end
    return nil
end

local function setRadio(ch)
    local r = voiceRes()
    if not r then return end
    local ok = pcall(function()
        exports[r]:setRadioChannel(ch)
    end)
    if ok then currentRadio = ch end
end

local function setCall(ch)
    local r = voiceRes()
    if not r then return end
    pcall(function() exports[r]:setCallChannel(ch) end)
end

-- Réception de la demande serveur (changement de métier)
RegisterNetEvent('novalife_voice:client:setRadio', function(ch)
    if ch and ch > 0 then
        setRadio(ch)
        NLNotify(0, 'inform', 'Radio', ('Canal ' .. ch .. ' (métier)'))
    else
        setRadio(0)
        NLNotify(0, 'inform', 'Radio', 'Radio coupée')
    end
    SendNUIMessage({ action = 'setFreq', freq = ch or 0 })
end)

-- Ouvrir/fermer l'UI radio (touche K)
RegisterKeyMapping('+novaRadioUI', 'Ouvrir la radio', 'keyboard', 'K')
RegisterCommand('+novaRadioUI', function()
    SendNUIMessage({ action = 'openRadio' })
    SetNuiFocus(false, false)
end)
RegisterCommand('-novaRadioUI', function()
    SendNUIMessage({ action = 'closeRadio' })
end)

RegisterNUICallback('radioPower', function(_, cb)
    setRadio(currentRadio > 0 and 0 or (exports.novalife_voice:GetJobChannel('police') or 1))
    SendNUIMessage({ action = 'setFreq', freq = currentRadio })
    cb('ok')
end)
RegisterNUICallback('setChannel', function(data, cb)
    local ch = tonumber(data.value)
    if ch then setRadio(ch); SendNUIMessage({ action = 'setFreq', freq = ch }) end
    cb('ok')
end)

-- Hooks: quand un métier prend/finit son service, on (ré)attribue le canal
RegisterNetEvent('novalife_police:client:dutyChanged', function(onDuty)
    if onDuty then setRadio(exports.novalife_voice:GetJobChannel('police') or 1)
    else setRadio(0) end
end)
RegisterNetEvent('novalife_ems:client:dutyChanged', function(onDuty)
    if onDuty then setRadio(exports.novalife_voice:GetJobChannel('ambulance') or 2)
    else setRadio(0) end
end)
RegisterNetEvent('novalife_fire:client:dutyChanged', function(onDuty)
    if onDuty then setRadio(exports.novalife_voice:GetJobChannel('fire') or 3)
    else setRadio(0) end
end)

-- Mégaphone (Police, touche BOUCLIER par défaut via keybinding)
RegisterKeyMapping('+novaMegaphone', 'Mégaphone (Police)', 'keyboard', 'B')
RegisterCommand('+novaMegaphone', function()
    local p = exports.novalife_core:GetPlayer and nil
    if not exports.novalife_core:HasJob(PlayerId and cache.serverId or source, 'police', 0) then return end
    -- pma-voice gère le mégaphone via l'export dédié si présent
    local r = voiceRes()
    if r and GetResourceMetadata(r, 'megaphone') then
        pcall(function() exports[r]:setVoiceProperty('megaphone', true) end)
    end
end)
RegisterCommand('-novaMegaphone', function()
    local r = voiceRes()
    if r then pcall(function() exports[r]:setVoiceProperty('megaphone', false) end) end
end)

-- Commande /radio <canal>
RegisterCommand('radio', function(src, args)
    local ch = tonumber(args[1])
    if not ch then NLNotify(0,'error','Radio','Usage: /radio <canal>'); return end
    setRadio(ch)
    NLNotify(0, 'inform', 'Radio', 'Canal ' .. ch)
end, false)

-- Appel téléphone (bridge avec novalife_phone si présent)
RegisterNetEvent('novalife_voice:client:startCall', function(targetSrc)
    setCall(targetSrc)  -- pma-voice utilise l'ID serveur comme canal d'appel
end)
RegisterNetEvent('novalife_voice:client:endCall', function()
    setCall(0)
end)

-- Export local
exports('SetRadio', setRadio)
exports('SetCall', setCall)
exports('GetRadio', function() return currentRadio end)
