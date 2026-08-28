# NovaLife RP — Maps [maps]

Ce dossier reçoit les **mappings** (YMAP / YTYP / cabinet de ressources).

## Règle stricte
- N'ajoutez QUE des mappings dont la licence autorise la redistribution.
- Aucun mapping protégé (payant, « leak », ou interdisant la redistribution) ne doit être commité ici.

## Architecture
Chaque mapping = une ressource indépendante :
```
resources/[maps]/novalife_map_mrpd/
├── fxmanifest.lua
├── stream/        (fichiers .ymap/.ytyp)
└── data/         (optional)
```
Puis `ensure novalife_map_mrpd` dans `server.cfg`.

## Suggestions (à installer vous-même, conformément aux licences)
- Commissariat MRPD (remplacement intérieur)
- Hôpital Pillbox
- Caserne de pompiers Davis
- Concessionnaire
- Entreprises / magasins / appartements

Ajoutez-les un par un et testez le démarrage après chacun.
