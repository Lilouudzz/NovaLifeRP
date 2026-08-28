# NovaLife RP

Serveur **GTA RP francophone** — RP semi-sérieux, orienté automobile, architecture moderne FiveM.

> Projet construit module par module (voir `CHANGELOG.md` et `docs/DEPENDENCIES.md`).
> Toute l'interface est en **français**, le style est sombre / moderne / minimaliste.

---

## 📌 Stack technique

| Composant | Rôle | Licence / source |
|-----------|------|------------------|
| FXServer + OneSync | Serveur FiveM | https://fivem.net |
| Lua 5.4 | Langage des ressources | — |
| oxmysql | Connexion MySQL/MariaDB | https://github.com/overextended/oxmysql (MIT) |
| ox_lib | Notifications, menus, utilitaires, NUI | https://github.com/overextended/ox_lib (MIT/CC) |
| ox_target | Interactions au monde (menus contextuels) | https://github.com/overextended/ox_target (MIT) |
| ox_inventory | Inventaire + objets RP | https://github.com/overextended/ox_inventory (MIT) |
| novalife_core | Framework maison (notifications, callbacks, économie, sécu) | Ce dépôt |

Toutes ces dépendances sont **open-source / libres**. Leur code n'est jamais copié ici :
on les installe via `git clone` ou le `.zip` officiel (voir `docs/DEPENDENCIES.md`).

> ⚠️ **Véhicules & mappings** : NovaLife RP n'inclut AUCUN modèle protégé.
> Le système de concession et de garages accepte uniquement les véhicules dont **vous**
> possédez les droits. Ajoutez vos propres modèles dans `config/vehicles.lua` et dans
> `resources/[vehicles]/`. Voir la section « Ajout de véhicules ».

---

## 🚀 Installation rapide

1. Installer FXServer (artefacts) — voir `docs/DEPENDENCIES.md`.
2. Installer MariaDB 10.x et créer la base `novalife`.
3. Importer `database/install.sql`.
4. Cloner les dépendances (`oxmysql`, `ox_lib`, `ox_target`, `ox_inventory`) dans `resources/[standalone]/`.
5. Copier `server.cfg.example` → `server.cfg` et renseigner les valeurs `CHANGE_ME`.
6. `exec permissions.cfg` est chargé automatiquement depuis `server.cfg`.
7. Lancer FXServer.

Guide complet : section **Documentation** plus bas et `docs/DEPENDENCIES.md`.

---

## 🗂 Arborescence

```
NovaLifeRP/
├── server.cfg.example
├── permissions.cfg
├── README.md
├── CHANGELOG.md
├── docs/DEPENDENCIES.md
├── database/install.sql
├── config/                # Toute la configuration modifiable
│   ├── jobs.lua
│   ├── vehicles.lua
│   ├── garages.lua
│   ├── locations.lua
│   ├── economy.lua
│   └── permissions.lua
└── resources/
    ├── [core]/        novalife_core, novalife_spawn, novalife_identity, novalife_utils
    ├── [jobs]/        police, ems, fire, mechanic, taxi, cardealer
    ├── [vehicles]/    garages, keys, fuel
    ├── [business]/    business, banking, billing
    ├── [admin]/       novalife_admin
    ├── [maps]/        (mappings tiers, à ajouter soi-même)
    └── [standalone]/  (oxmysql, ox_lib, ox_target, ox_inventory)
```

---

## 🎮 Commandes joueur (principales)

- `/id` — voir sa carte d'identité
- `/permis` — voir ses permis
- `/me`, `/do`, `/try`, `/ooc` — chat RP
- `/911`, `/112` — urgences (police / EMS)
- `/facture [id] [montant] [raison]` — émettre une facture (métiers)
- `/garage` — ouvrir le garage (à proximité)
- `/lock` — verrouiller/déverrouiller son véhicule
- `/fuel` — pompe à proximité

## 🛡 Commandes admin

`/kick`, `/ban`, `/unban`, `/freeze`, `/goto`, `/bring`, `/revive`, `/heal`,
`/tpm`, `/giveitem`, `/givemoney`, `/setjob`, `/setgrade`, `/car`, `/dv`
+ menu NUI `/admin`.

---

## 🧩 Documentation

- `docs/DEPENDENCIES.md` — versions, sources officielles, licence.
- `CHANGELOG.md` — avancement par phase.
- `database/install.sql` — schéma SQL complet.
- Chaque ressource contient son propre `README.md` (ou en-tête) expliquant son usage.

---

## ⚖️ Sécurité

Priorité absolue : **jamais confiance au client**. Toute opération sensible
(argent, items, véhicules, jobs, grades, arrestations, factures) est validée
côté serveur (distance checks, cooldowns, anti-spam, vérification job/grade, logs).
Voir `resources/[core]/novalife_core` et `docs/SECURITY.md` (phase 14).

---

## 📜 License du projet

Le code **NovaLife RP** (dossiers `novalife_*`, `config/`, `database/`) est fourni
sous licence **MIT** — réutilisation libre en conservant cet en-tête.
Les dépendances tiers conservent leur propre licence (MIT pour la suite ox_).
Aucun asset protégé (modèles de véhicules, mappings YMAP protégés) n'est redistribué.
