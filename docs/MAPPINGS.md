# NovaLife RP — Mappings (docs/MAPPINGS.md)

Deux mappings livrés : `novalife_map_lspd` (Mission Row PD) et `novalife_map_pillbox`
(Pillbox Hill). Ils fournissent les points de service (prise de service, armurerie,
cellules, entrées/sorties intérieures) et les **spawn points** des métiers Police/EMS.

## ⚠️ Légalité
- **Aucun fichier YMAP binaire n'est redistribué** dans ce dépôt. Les YMAP sont des
  fichiers propriétaires Rockstar (GTA V) : leur redistribution viole les Terms of
  Service FiveM. Nous ne les incluons donc pas.
- L'approche retenue est **100% vanilla et légale** : on déverrouille l'accès aux
  intérieurs **stock** du jeu (IPL déjà chargés par GTA V — lobby MRPD `police1`,
  hôpital `RC12b_hospital`) en retirant la collision des portes d'intérieur. C'est
  une technique documentée et autorisée (on n'extrait ni ne redistribue d'asset).
- Si vous voulez un **vrai YMAP custom** (bâtiment modélisé par vous ou acheté avec
  licence de redistribution), ajoutez-le dans `resources/[mappings]/votre_map/` avec
  son `fxmanifest.lua` + `stream/votre_map.ymap` (licence à vérifier). Ne mettez que
  des mappings dont vous possédez les droits.

## Structure
```
resources/[mappings]/
├── novalife_map_lspd/
│   ├── fxmanifest.lua
│   ├── coords.lua          (coordonnées Mission Row)
│   └── client.lua          (déverrouillage portes + points service)
└── novalife_map_pillbox/
    ├── fxmanifest.lua
    ├── coords.lua          (coordonnées Pillbox)
    └── client.lua          (déverrouillage portes + points service)
```

## Coordonnées (utilisées)
### LSPD (Mission Row)
- Extérieur / prise de service : `441.0, -981.0, 30.7`
- Entrée : `434.0, -983.0, 30.7`
- Lobby intérieur : `-111.0, -621.0, 36.1` (heading 250)
- Armurerie : `-111.0, -607.0, 36.1`
- Cellules : `-105.0, -603.0, 36.1`
- Spawn Police : `425.0, -998.0, 29.4` (heading 90)

### Pillbox Hill (EMS)
- Extérieur / prise de service : `338.0, -1396.0, 32.5`
- Entrée : `322.0, -1064.0, -99.0`
- Lobby intérieur : `325.0, -1064.0, -99.0` (heading 180)
- Salle service EMS : `330.0, -1052.0, -99.0`
- Spawn EMS : `345.0, -1402.0, 32.5` (heading 320)

## Spawn automatique
`novalife_spawn` (server.lua) : au **premier spawn**, un joueur avec le job `police`
atterrit au spawn LSPD, `ambulance` au spawn Pillbox. Reconnexion = dernière position.
Nécessite que `novalife_map_lspd` / `novalife_map_pillbox` soient `ensure` avant le spawn.

## Téléportation (Owner Panel)
Le grade owner peut utiliser `/owner` → Téléportation pour se rendre sur ces points,
ou utilisez les exports `novalife_map_lspd:GetPoliceSpawn()` / `novalife_map_pillbox:GetEMSSpawn()`.
