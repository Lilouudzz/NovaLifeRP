-- ============================================================
--  NovaLife RP — Permissions (groupes / rangs serveur)
--  Ces groupes sont déclarés dans permissions.cfg via add_ace/add_principal.
--  Une action admin vérifie toujours: IsPlayerAceAllowed(src, "command.<x>")
--  ET le groupe NovaLife stocké en DB (helper/mod/admin/superadmin/owner).
-- ============================================================

Permissions = {
    -- Groupes (rang) ordre hiérarchique
    groups = {
        user       = 0,
        helper     = 1,
        mod        = 2,
        admin      = 3,
        superadmin = 4,
        owner      = 5,
    },

    -- Commandes admin par niveau minimum requis (group.level)
    commandLevel = {
        kick       = 2,  -- mod
        ban        = 3,  -- admin
        unban      = 3,
        freeze     = 2,
        goto       = 2,
        bring      = 2,
        revive     = 2,
        heal       = 2,
        tpm        = 3,
        giveitem   = 3,
        givemoney  = 4,  -- superadmin
        setjob     = 4,
        setgrade   = 4,
        car        = 3,
        dv         = 2,
    },

    -- ACE principals (déclarés dans permissions.cfg)
    acePrefix = "novalife",

    -- Webhooks Discord (CÔTÉ SERVEUR UNIQUEMENT — jamais exposés au client)
    -- Les valeurs réelles viennent de server.cfg via Convar, pas d'ici.
    webhooks = {
        -- rempli dynamiquement depuis les Convars dans novalife_core
    },
}

-- Helper: renvoie le niveau d'un groupe
function GetGroupLevel(group)
    return Permissions.groups[group] or 0
end
