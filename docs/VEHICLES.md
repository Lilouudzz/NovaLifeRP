# NovaLife RP — Véhicules add-on (docs/VEHICLES.md)

Le serveur supporte nativement les **véhicules add-on** (modèles hors GTA stock).
Aucun modèle protégé n'est redistribué dans ce dépôt. Cette doc explique comment
ajouter LÉGALEMENT vos propres véhicules.

## 1. Licence (OBLIGATOIRE)
- Les modèles **stock GTA** (`addon = false`) sont utilisables sur un serveur
  FiveM disposant d'une licence valide (usage prévu par les Terms of Service FiveM).
- Les modèles **add-on** (`addon = true`) : vous devez être le créateur, OU avoir
  acheté/obtenu une licence explicite de redistribution du créateur. Ne jamais
  utiliser un modèle "leak" ou dont la licence interdit la redistribution.

## 2. Ajouter un véhicule (en 2 étapes)

### Étape A — déclarer dans `config/vehicles.lua`
Ajoutez UNE entrée dans `Vehicles.list` :
```lua
monmodele = { name = "Ma Voiture", category = "sport", price = 95000, stock = -1,
              brand = "MaMarque", fuel = "essence", addon = true }
```
`category` doit être une clé existante dans `Vehicles.categories`.
`stock = -1` => illimité (recommandé). Sinon mettez un nombre.

### Étape B — streamer le modèle (légal)
Créez une ressource dans `resources/[vehicles]/` :
```
resources/[vehicles]/mon_pack/
├── fxmanifest.lua
├── stream/
│   ├── monmodele.yft
│   ├── monmodele.ytd
│   └── (autres fichiers fournis par le créateur)
└── data/
    └── vehicle.meta / handling.meta (fournis par le créateur)
```
`fxmanifest.lua` minimal :
```lua
fx_version 'cerulean'
game 'gta5'
this_is_a_map 'no'
files { 'data/vehicle.meta', 'data/handling.meta' }
data_file 'VEHICLE_METADATA_FILE' 'data/vehicle.meta'
data_file 'HANDLING_FILE' 'data/handling.meta'
```
Puis `ensure mon_pack` dans `server.cfg`.

## 3. Exemples template (déjà présents)
`config/vehicles.lua` contient 3 templates `addon = true` (commentés) :
`nova_sport_example`, `nova_suv_example`, `nova_bike_example`.
Décommentez-les et remplacez le nom de modèle par le vôtre une fois le
fichier streamé. Ils n'embarquent AUCUN asset.

## 4. Garages & clés
- Les véhicules (stock OU add-on) fonctionnent de façon identique dans
  `novalife_garages` (sortie/rangement) et `novalife_keys` (verrouillage).
- La colonne `player_vehicles.vehicle` stocke le nom du modèle (ex: `nova_sport_example`).
- `novalife_fuel` lit le type de carburant depuis `Vehicles.list[model].fuel`.

## 5. Concessionnaire
- `novalife_cardealer` filtre automatiquement les véhicules `service = true`
  (non vendables) et ceux avec `stock = 0`.
- Tout véhicule `addon = true` déclaré et streamé apparaît au catalogue dès
  qu'il n'est pas marqué `service`.

⚠️ Rappel : la responsabilité des licences des véhicules add-on incombe au
propriétaire du serveur (Config.OwnerIdentifiers).
