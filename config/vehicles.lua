-- ============================================================
--  NovaLife RP — Catalogue de véhicules (concessionnaire + garages)
--  ⚠️ LICENCE : ne mettez QUE des véhicules dont vous possédez les droits.
--
--  - Les modèles "stock GTA" (addon = false) sont utilisables sur un
--    serveur FiveM licencié (usage prévu par la licence FiveM).
--  - Les modèles "addon = true" sont des VÉHICULES ADD-ON : vous devez
--    fournir le fichier .yft/.ytd légalement (créateur ayant vendu/cédé
--    les droits, ou licence explicite de redistribution). Ils ne sont
--    PAS fournis ici (pas de modèle protégé redistribué).
--
--  ➕ AJOUTER UN VÉHICULE PLUS TARD = une seule entrée dans Vehicles.list :
--     monmodele = { name="...", category="sport", price=..., stock=-1,
--                    brand="...", fuel="essence", addon=true }
--     + streamer le modèle dans resources/[vehicles]/votre_pack/
-- ============================================================

Vehicles = {
    categories = {
        compact   = "Compact",
        sedan     = "Berline",
        suv       = "SUV",
        coupe     = "Coupé",
        muscle    = "Muscle",
        sport     = "Sport",
        super     = "Super",
        motorcycle= "Motos",
        utility   = "Utilitaires",
    },

    -- ============================================================
    --  STOCK GTA (addon = false) — utilisables sur serveur licencié
    -- ============================================================
    list = {
        -- ===== Compact =====
        issi3      = { name = "Issi",       category = "compact",    price = 8500,    stock = -1, brand = "Weeny",      fuel = "essence", addon = false },
        blista     = { name = "Blista",     category = "compact",    price = 9500,    stock = -1, brand = "Dinka",      fuel = "essence", addon = false },

        -- ===== Berline =====
        asea       = { name = "Asea",       category = "sedan",      price = 12000,   stock = -1, brand = "Karin",      fuel = "essence", addon = false },
        ingot      = { name = "Ingot",      category = "sedan",      price = 11000,   stock = -1, brand = "Vulcar",     fuel = "essence", addon = false },

        -- ===== SUV =====
        baller     = { name = "Baller",     category = "suv",        price = 32000,   stock = -1, brand = "Gallivanter",fuel = "essence", addon = false },
        granger    = { name = "Granger",    category = "suv",        price = 38000,   stock = -1, brand = "Declasse",   fuel = "essence", addon = false },

        -- ===== Coupé =====
        sentinel   = { name = "Sentinel",   category = "coupe",      price = 24000,   stock = -1, brand = "Ubermacht",  fuel = "essence", addon = false },
        penumbra   = { name = "Penumbra",   category = "coupe",      price = 26000,   stock = -1, brand = "Maibatsu",   fuel = "essence", addon = false },

        -- ===== Muscle =====
        dominator  = { name = "Dominator",  category = "muscle",     price = 28000,   stock = -1, brand = "Vapid",      fuel = "essence", addon = false },
        gauntlet   = { name = "Gauntlet",   category = "muscle",     price = 30000,   stock = -1, brand = "Bravado",    fuel = "essence", addon = false },

        -- ===== Sport =====
        elegy2     = { name = "Elegy",      category = "sport",      price = 45000,   stock = -1, brand = "Annis",      fuel = "essence", addon = false },
        furoregt   = { name = "Furore GT",  category = "sport",      price = 52000,   stock = -1, brand = "Grotti",     fuel = "essence", addon = false },

        -- ===== Super =====
        zentorno   = { name = "Zentoro",  category = "super",      price = 740000,  stock = -1, brand = "Pegassi",   fuel = "essence", addon = false },
        entityxf   = { name = "Entity XF",  category = "super",      price = 880000,  stock = -1, brand = "Overflod",   fuel = "essence", addon = false },

        -- ===== Motos =====
        pcj        = { name = "PCJ-600",    category = "motorcycle", price = 9000,    stock = -1, brand = "Shitzu",     fuel = "essence", addon = false },
        daemon     = { name = "Daemon",     category = "motorcycle", price = 13000,   stock = -1, brand = "Western",    fuel = "essence", addon = false },

        -- ===== Utilitaires =====
        bobcatxl   = { name = "Bobcat XL",  category = "utility",    price = 33000,   stock = -1, brand = "Vapid",      fuel = "diesel",  addon = false },
        boxville   = { name = "Boxville",   category = "utility",    price = 28000,   stock = -1, brand = "Bravado",    fuel = "diesel",  addon = false },

        -- ===== Véhicules de service (réservés métiers, non vendus) =====
        police      = { name = "Police Cruiser",   category = "utility", price = 0, stock = 0, brand = "Vapid",      fuel = "essence", service = "police",  addon = false },
        police2     = { name = "Police 2",         category = "utility", price = 0, stock = 0, brand = "Bravado",    fuel = "essence", service = "police",  addon = false },
        ambulance   = { name = "Ambulance",        category = "utility", price = 0, stock = 0, brand = "Declasse",   fuel = "essence", service = "ambulance", addon = false },
        firetruk    = { name = "Camion-pompe",     category = "utility", price = 0, stock = 0, brand = "MTL",        fuel = "diesel",  service = "fire",     addon = false },

        -- ============================================================
        --  EXEMPLES ADD-ON (addon = true)
        --  ⚠️ TEMPLATES : remplacez le nom de modèle + fournissez le
        --  fichier .yft/.ytd LÉGAL dans resources/[vehicles]/votre_pack/.
        --  Aucun modèle protégé n'est redistribué ici.
        --  Procédure : voir docs/VEHICLES.md
        -- ============================================================
        -- [[ EXEMPLE 1 : coupé sport add-on (à remplacer par VOTRE modèle légal)
        nova_sport_example = { name = "Nova Sport (EXEMPLE)", category = "sport", price = 95000, stock = -1,
                               brand = "Nova", fuel = "essence", addon = true },
        -- ]]
        -- [[ EXEMPLE 2 : SUV add-on
        nova_suv_example   = { name = "Nova SUV (EXEMPLE)",   category = "suv",   price = 78000, stock = -1,
                               brand = "Nova", fuel = "diesel", addon = true },
        -- ]]
        -- [[ EXEMPLE 3 : moto add-on
        nova_bike_example  = { name = "Nova Bike (EXEMPLE)",  category = "motorcycle", price = 21000, stock = -1,
                               brand = "Nova", fuel = "essence", addon = true },
        -- ]]
    },

    -- Véhicules de service par métier (garage métier)
    serviceVehicles = {
        police    = { "police", "police2" },
        ambulance = { "ambulance" },
        fire      = { "firetruk" },
        mechanic  = { "flatbed", "towtruck" },
        taxi      = { "taxi" },
    },
}
