# NovaLife RP — [vehicles] (véhicules add-on)

Dossier pour vos **packs de véhicules add-on** (modèles hors GTA stock).

## Règle stricte (licence)
- N'ajoutez QUE des modèles dont vous possédez les droits de redistribution
  (créateur, achat, ou licence explicite). Aucun modèle "leak" / protégé.
- Aucun fichier `.yft`/`.ytd` n'est fourni ici (pas de redistribution d'assets).

## Structure d'un pack
```
resources/[vehicles]/mon_pack/
├── fxmanifest.lua      (template ci-dessous)
├── stream/             (fichiers du modèle fournis par le créateur)
└── data/               (vehicle.meta, handling.meta fournis par le créateur)
```

## fxmanifest.lua template
```lua
fx_version 'cerulean'
game 'gta5'
this_is_a_map 'no'

files {
    'data/vehicle.meta',
    'data/handling.meta',
}

data_file 'VEHICLE_METADATA_FILE' 'data/vehicle.meta'
data_file 'HANDLING_FILE' 'data/handling.meta'
```

## Déclarer le véhicule
1. Ajoutez l'entrée dans `config/vehicles.lua` → `Vehicles.list` (voir `docs/VEHICLES.md`).
2. `ensure mon_pack` dans `server.cfg`.
3. Le véhicule apparaît au garage / concessionnaire automatiquement.

## Stock GTA
Les véhicules stock ne nécessitent aucun pack : ils sont déjà dans le jeu.
