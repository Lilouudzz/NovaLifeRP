-- ============================================================
--  NovaLife RP — Configuration des métiers (jobs)
--  Modifiable SANS toucher au cœur du système.
--  Charge via: #include "config/jobs.lua" dans server.cfg
--  ou require depuis novalife_core.
-- ============================================================

Jobs = {
    -- Format:
    -- name = {
    --   label     = "Nom affiché",
    --   default   = grade par défaut (clé du grade),
    --   grades    = { [grade] = { name = "Nom du grade", payment = salaire/heure } },
    --   type      = "civ" | "leo" | "ems" | "fire" | "biz",
    --   whitelisted = true/false (si true -> recrutement uniquement par admin/patron),
    -- }

    unemployed = {
        label = "Sans emploi",
        default = 0,
        grades = { [0] = { name = "Citoyen", payment = 0 } },
        type = "civ",
        whitelisted = false,
    },

    police = {
        label = "Police",
        default = 0,
        whitelisted = true,
        type = "leo",
        grades = {
            [0] = { name = "Cadet",        payment = 1200 },
            [1] = { name = "Officier",     payment = 1600 },
            [2] = { name = "Sergent",      payment = 2000 },
            [3] = { name = "Lieutenant",   payment = 2400 },
            [4] = { name = "Capitaine",    payment = 2800 },
            [5] = { name = "Commandant",   payment = 3200 },
            [6] = { name = "Chef",         payment = 4000 },
        },
    },

    ambulance = {
        label = "EMS",
        default = 0,
        whitelisted = true,
        type = "ems",
        grades = {
            [0] = { name = "Stagiaire",   payment = 1100 },
            [1] = { name = "Ambulancier", payment = 1500 },
            [2] = { name = "Infirmier",   payment = 1900 },
            [3] = { name = "Medecin",     payment = 2300 },
            [4] = { name = "Chirurgien",  payment = 2700 },
            [5] = { name = "Chef",        payment = 3300 },
        },
    },

    fire = {
        label = "Pompiers",
        default = 0,
        whitelisted = true,
        type = "fire",
        grades = {
            [0] = { name = "Recrue",      payment = 1100 },
            [1] = { name = "Pompier",     payment = 1500 },
            [2] = { name = "Caporal",     payment = 1900 },
            [3] = { name = "Lieutenant",  payment = 2300 },
            [4] = { name = "Capitaine",   payment = 2800 },
            [5] = { name = "Chef",        payment = 3300 },
        },
    },

    mechanic = {
        label = "Mécanicien",
        default = 0,
        whitelisted = true,
        type = "biz",
        grades = {
            [0] = { name = "Apprenti",    payment = 900 },
            [1] = { name = "Mécanicien",  payment = 1400 },
            [2] = { name = "Expert",      payment = 1900 },
            [3] = { name = "Chef atelier",payment = 2400 },
        },
    },

    taxi = {
        label = "Taxi",
        default = 0,
        whitelisted = false,
        type = "civ",
        grades = {
            [0] = { name = "Chauffeur",   payment = 250 },  -- base + courses
            [1] = { name = "Chauffeur confirmé", payment = 350 },
        },
    },

    cardealer = {
        label = "Concessionnaire",
        default = 0,
        whitelisted = true,
        type = "biz",
        grades = {
            [0] = { name = "Vendeur",     payment = 1000 },
            [1] = { name = "Responsable", payment = 1500 },
            [2] = { name = "Directeur",   payment = 2200 },
        },
    },

    bus = {
        label = "Bus",
        default = 0,
        whitelisted = false,
        type = "civ",
        grades = { [0] = { name = "Chauffeur", payment = 300 } },
    },

    garbage = {
        label = "Éboueur",
        default = 0,
        whitelisted = false,
        type = "civ",
        grades = { [0] = { name = "Éboueur", payment = 280 } },
    },

    delivery = {
        label = "Livreur",
        default = 0,
        whitelisted = false,
        type = "civ",
        grades = { [0] = { name = "Livreur", payment = 260 } },
    },
}
