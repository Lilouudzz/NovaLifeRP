-- ============================================================
--  novalife_voice — server.lua
--  Logique serveur: attributions de canaux radio par métier,
--  mégaphone, appels. Le vrai routage audio est géré par pma-voice
--  (côté client via exports). Ici on applique les règles métier.
-- ============================================================

-- Canaux radio par métier (partagé avec le client)
VoiceChannels = {
    police    = 1,
    ambulance = 2,
    fire      = 3,
    mechanic  = 4,
    taxi      = 5,
    cardealer = 6,
    -- canal d'urgence global (dispatch)
    dispatch  = 911,
}

exports('GetJobChannel', function(job) return VoiceChannels[job] end)
exports('GetDispatchChannel', function() return VoiceChannels.dispatch end)

-- Met le joueur sur le canal radio de son métier (appelé par le core au changement de job)
RegisterNetEvent('novalife_voice:setJobChannel', function(job)
    local src = source
    local ch = VoiceChannels[job]
    if ch then
        TriggerClientEvent('novalife_voice:client:setRadio', src, ch)
    else
        TriggerClientEvent('novalife_voice:client:setRadio', src, 0) -- hors service: radio off
    end
end)
