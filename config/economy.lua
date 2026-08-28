-- ============================================================
--  NovaLife RP — Économie
--  Tous les montants sont validés côté serveur (novalife_core).
--  Modifiable SANS toucher au cœur.
-- ============================================================

Economy = {
    StartCash = 500,
    StartBank = 5000,

    -- Paiement des salaires (tous les X minutes)
    SalaryIntervalMinutes = 15,

    -- Plafonds anti-abus (sécurité serveur)
    MaxCash = 500000,        -- cash max par joueur
    MaxBank = 50000000,      -- banque max
    MaxTransfer = 1000000,   -- virement max / transaction
    MaxWithdraw = 100000,    -- retrait max / transaction
    MaxDeposit = 100000,     -- dépôt max / transaction

    -- Carburant
    Fuel = {
        pricePerLitre = {
            essence   = 1.65,
            diesel    = 1.45,
            electrique= 0.90,   -- recharge
        },
        tankSize = 100,          -- litres (modèle GTA)
        consumptionRate = 1.0,   -- multiplicateur
        saveInterval = 30,       -- secondes entre sauvegardes SQL
    },

    -- Prix par défaut (référence, peut être surchargé)
    DefaultPrices = {
        identityCard = 0,        -- offert à la création
        repairKit = 1500,
        water = 50,
        food = 120,
        bandage = 80,
    },
}
