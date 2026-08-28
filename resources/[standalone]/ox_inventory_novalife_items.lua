-- ============================================================
--  NovaLife RP — objets RP pour ox_inventory
--  Ce fichier va dans : resources/[standalone]/ox_inventory/data/items.lua
--  (ou importez-le depuis votre fichier items existant via la table Items).
--  ox_inventory est MIT/GPL — on n'en copie PAS le code, on DÉCLARE nos items.
--
--  Documentation officielle ox_inventory (items) :
--  https://overextended.dev/ox_inventory/Items
-- ============================================================

Items = {
    ['water'] = {
        label = 'Eau', weight = 200, stack = true, close = true,
        description = 'Une bouteille d’eau.',
        consume = 20,
    },
    ['food'] = {
        label = 'Nourriture', weight = 300, stack = true, close = true,
        description = 'Un repas.',
        consume = 30,
    },
    ['phone'] = {
        label = 'Téléphone', weight = 150, stack = false, close = false,
        description = 'Smartphone NovaLife.',
    },
    ['id_card'] = {
        label = 'Carte d’identité', weight = 50, stack = false, close = false,
        description = 'Pièce d’identité du personnage.',
    },
    ['driver_license'] = {
        label = 'Permis de conduire', weight = 50, stack = false, close = false,
        description = 'Autorise la conduite de véhicules.',
    },
    ['bandage'] = {
        label = 'Bandage', weight = 100, stack = true, close = true,
        description = 'Soigne légèrement.',
        consume = 10,
    },
    ['repairkit'] = {
        label = 'Kit de réparation', weight = 500, stack = true, close = false,
        description = 'Répare un véhicule (mécano).',
    },
    ['tools'] = {
        label = 'Outils', weight = 400, stack = false, close = false,
        description = 'Boîte à outils.',
    },
    ['carkeys'] = {
        label = 'Clés', weight = 20, stack = false, close = false,
        description = 'Clés de véhicule (gérées par novalife_keys).',
    },
}
