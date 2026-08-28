# NovaLife RP — RÉSULTAT FINAL

Serveur GTA RP francophone, architecture moderne (FXServer + OneSync + Lua), construit
module par module selon le cahier des charges. Priorité sécurité: **jamais confiance au client**.

> Tous les fichiers Lua (68) compilent sans erreur (LuaJIT). Tous les fichiers JS NUI (5) passent `node --check`.

---

## A. Arborescence complète
```
NovaLifeRP/
├── server.cfg.example
├── permissions.cfg
├── start.bat
├── README.md
├── CHANGELOG.md
├── config/
│   ├── jobs.lua          (métiers + grades + salaires)
│   ├── vehicles.lua       (catalogue concession + service)
│   ├── garages.lua        (positions par type)
│   ├── locations.lua      (POI: hopitaux, banks, stations, etc.)
│   ├── economy.lua        (cash/banque, plafonds, carburant)
│   └── permissions.lua    (groupes ACE + niveaux)
├── database/install.sql   (schéma SQL complet)
├── docs/
│   ├── DEPENDENCIES.md    (sources officielles, licences)
│   ├── SECURITY.md        (sécurité serveur)
│   └── TEST_CHECKLIST.md  (tests)
└── resources/
    ├── [core]/   novalife_core, novalife_identity, novalife_spawn, novalife_utils
    ├── [jobs]/   novalife_police, novalife_ems, novalife_fire, novalife_mechanic,
    │             novalife_cardealer, novalife_civjobs (taxi/bus/éboueur/livreur),
    │             novalife_chat, novalife_phone
    ├── [vehicles]/ novalife_garages, novalife_keys, novalife_fuel
    ├── [business]/ novalife_banking, novalife_billing, novalife_business, novalife_inventory
    ├── [admin]/   novalife_admin
    ├── [maps]/    README.md (à remplir avec vos mappings licites)
    └── [standalone]/ ox_inventory_novalife_items.lua + README.md (install deps)
```

## B. Liste des dépendances
| Dépendance | Rôle | Source | Licence |
|-----------|------|--------|---------|
| FXServer + OneSync | Serveur | fivem.net | Terms |
| oxmysql | MySQL/MariaDB | github.com/overextended/oxmysql | MIT |
| ox_lib | Notifs/menus/NUI/callbacks | github.com/overextended/ox_lib | MIT |
| ox_target | Interactions monde | github.com/overextended/ox_target | MIT |
| ox_inventory | Inventaire + items | github.com/overextended/ox_inventory | MIT/GPL |
| (optionnel) ressource vocale | Proximité/radio/téléphone | voir docs | selon ressource |

Aucune dépendance n'est copiée: installez via `git clone` dans `resources/[standalone]/`.

## C. Instructions d'installation
1. Installer FXServer (artefacts) → dossier serveur.
2. `python -m pip install lupa` (outillage de vérif, optionnel).
3. `cd resources/[standalone]` puis cloner oxmysql/ox_lib/ox_target/ox_inventory.
4. Installer MariaDB 10.x, créer la base `novalife`.
5. Importer `database/install.sql`.
6. Copier `server.cfg.example` → `server.cfg`, remplacer tous les `CHANGE_ME` (license, SQL, webhooks, rcon).
7. Copier `ox_inventory_novalife_items.lua` dans `ox_inventory/data/items.lua`.
8. `exec permissions.cfg` est déjà appelé par `server.cfg`.
9. `start.bat` (Windows) ou `./run.sh +exec server.cfg` (Linux).

Détail complet: `README.md` + `docs/DEPENDENCIES.md`.

## D. Configuration
Tout est dans `config/*.lua` (sans toucher au code) :
- `jobs.lua` : ajouter un métier, ses grades, ses salaires.
- `vehicles.lua` : ajouter véhicules (modèles que vous possédez légalement), catégories, prix, stock, service.
- `garages.lua` : positions/rayons par type (public/police/ems/fire/mécanic/business).
- `locations.lua` : banques, stations, hôpitaux, commissariats, fourrière, points civils.
- `economy.lua` : cash/banque de départ, plafonds, prix carburant.
- `permissions.lua` : groupes + niveaux + webhooks (côté serveur).
Couleur principale NUI: `--primary` dans `novalife_core/html/theme.css`.

## E. Commandes joueur
- `/id`, `/permis` — identité & permis
- `/me`, `/do`, `/try`, `/ooc` — chat RP (distance)
- `/911` (police), `/112` (EMS/pompiers) — urgences
- `/facture [id] [montant] [raison]` — émettre une facture (métiers)
- `/garage` — ouvrir le garage (au point)
- `/lock` — verrouiller/déverrouiller ; `/givekey [id]` — donner une clé
- `/course` (taxi), `/livrer` (livreur) — métiers civils
- `M` — téléphone

## F. Commandes admin (toutes loguées)
`/kick`, `/ban`, `/unban`, `/freeze`, `/goto`, `/bring`, `/revive`,
`/heal`, `/tpm`, `/giveitem`, `/givemoney`, `/setjob`, `/setgrade`,
`/car`, `/dv`, `/admin` (menu NUI).
Niveaux: helper(1) < mod(2) < admin(3) < superadmin(4) < owner(5) — voir `permissions.cfg` + `config/permissions.lua`.

## G. Jobs
police (7 grades), ambulance (6), fire (6), mechanic (4), cardealer (3),
taxi (2), bus (1), garbage (1), delivery (1), unemployed. + entreprises (patron/employés).
Whitelist par métier configurable (`whitelisted = true/false` dans `config/jobs.lua`).

## H. Tables SQL
`players`, `characters`, `identities`, `player_vehicles`, `vehicle_keys`,
`bills`, `bank_accounts`, `bank_transactions`, `businesses`, `criminal_records`,
`warrants`, `police_reports`, `impound`, `server_logs`, `whitelist`, `bans`
(+ `phone_contacts`, `phone_messages`, `phone_announces` créées par `novalife_phone`).
Voir `database/install.sql`.

## I. Procédure de lancement
Voir `start.bat` + section C. Résumé: configurer `server.cfg` (CHANGE_ME),
lancer FXServer, vérifier la console (aucun ensure en erreur), se connecter,
créer un personnage, tester `/admin` pour se donner un métier.

## J. Checklist de test
Voir `docs/TEST_CHECKLIST.md` — couvre création perso, connexion, économie,
banque, inventaire, achat véhicule, garage, clés, carburant, police, EMS,
mécano, facture, admin, logs.

## K. Problèmes nécessitant intervention manuelle
1. **`server.cfg`** : renseigner `sv_license`, `mysql_connection_string`, webhooks Discord, `rcon_password` (tous en `CHANGE_ME`).
2. **Dépendances** : cloner oxmysql/ox_lib/ox_target/ox_inventory dans `resources/[standalone]/` (non fournies ici par licence).
3. **ox_inventory** : merger `ox_inventory_novalife_items.lua` dans `data/items.lua`.
4. **Véhicules add-on** : ajouter VOS modèles légaux dans `config/vehicles.lua` + streamer les fichiers (le serveur n'inclut que du stock GTA par défaut — aucun modèle protégé).
5. **Mappings (YMAP)** : ajouter vos mappings licites dans `resources/[maps]/`.
6. **OneSync Infinity** : activer `set onesync_population true` selon votre licence.
7. **Voix** : installer une ressource vocale compatible (proximité/radio/tél) — non incluse.
8. **Personnalisation personnage** : `novalife_identity` gère identité + champ `appearance` (JSON) prêt pour un système de visage (ex: illenium-appearance) — à brancher.
9. **Salaires** : le tick de versement automatique est ACTIF (toutes les `Economy.SalaryIntervalMinutes`, défaut 15 min) — voir `novalife_core/server.lua`. Le montant vient de `config/jobs.lua` (champ `payment` par grade).

---
© NovaLife RP — code MIT. Dépendances conservent leur licence. Aucun asset protégé redistribué.
