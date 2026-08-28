-- ============================================================
--  nova_life_core — shared.lua
--  Config + helpers partagés (serveur & client).
-- ============================================================

Config = {
    ServerName = "NovaLife RP",
    Locale = "fr",
    Debug = false,

    StartCash = 500,
    StartBank = 5000,

    EnableWhitelist = false,

    -- Webhooks (lues depuis les Convars côté serveur; le client ne les voit JAMAIS)
    Webhooks = {
        connect  = "",
        money    = "",
        admin    = "",
        arrest   = "",
        errors   = "",
        vehicle  = "",
    },

    -- Cooldowns globaux (secondes) — anti-spam / anti-abus
    Cooldowns = {
        giveMoney  = 3,
        giveItem   = 3,
        setJob     = 2,
        arrest     = 5,
        fine       = 3,
        fuel       = 1,
        garageOut  = 2,
    },

    -- Vérification de distance par défaut (mètres)
    DefaultInteractDistance = 5.0,
}

-- Locale minimale (FR). On garde simple et extensible.
Locale = {
    ["no_permission"]  = "Vous n'avez pas la permission.",
    ["invalid_args"]   = "Arguments invalides.",
    ["player_not_found"] = "Joueur introuvable.",
    ["not_enough_money"] = "Fonds insuffisants.",
    ["success"]        = "Action effectuée.",
    ["error"]          = "Une erreur est survenue.",
}

-- Helper: notif côté client (ox_lib)
function NLNotify(src, type, title, description, duration)
    if type == nil then type = "inform" end
    if duration == nil then duration = 5000 end
    if src == 0 or src == nil then
        -- appel local (client)
        if lib and lib.notify then
            lib.notify({ type = type, title = title, description = description, duration = duration })
        end
    else
        TriggerClientEvent('ox_lib:notify', src, {
            type = type, title = title, description = description, duration = duration
        })
    end
end
