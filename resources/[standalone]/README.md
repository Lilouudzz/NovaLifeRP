# NovaLife RP — Standalone [standalone]

Dépendances open-source (MIT) à installer ici via `git clone` ou `.zip` officiel.
**Leur code n'est pas copié dans ce dépôt** (voir `docs/DEPENDENCIES.md`).

## Installation rapide (PowerShell / bash)
```bash
cd resources/[standalone]
git clone https://github.com/overextended/oxmysql oxmysql
git clone https://github.com/overextended/ox_lib ox_lib
git clone https://github.com/overextended/ox_target ox_target
git clone https://github.com/overextended/ox_inventory ox_inventory
```

## Build oxmysql (si besoin)
```bash
cd oxmysql && npm i --production
```

## Objets RP NovaLife
Le fichier `ox_inventory_novalife_items.lua` (à la racine de `[standalone]`) déclare nos
items RP. Copiez/collez son contenu dans `ox_inventory/data/items.lua` (ou importez-le
depuis votre fichier d'items). ox_inventory est sous licence MIT/GPL — nous ne copions
pas son moteur, seulement nos déclarations d'items.

## Versions recommandées (compatibles)
- oxmysql ≥ 2.x
- ox_lib ≥ 3.x
- ox_target ≥ 2.x
- ox_inventory ≥ 2.x

Ces ressources utilisent `oxmysql`. QBCore n'est PAS utilisé.
