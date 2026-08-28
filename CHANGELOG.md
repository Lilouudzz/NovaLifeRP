# CHANGELOG — NovaLife RP

## ✅ Phase 1 — Architecture + configuration
- Arborescence `NovaLifeRP/`, `config/*.lua` (6 fichiers), `server.cfg.example`, `permissions.cfg`, `README.md`, `CHANGELOG.md`, `docs/DEPENDENCIES.md`.

## ✅ Phase 2 — Core + base de données
- `novalife_core` (framework maison: joueurs, économie serveur, callbacks, logs, sécu, exports).
- `database/install.sql` (toutes les tables: players, characters, identities, player_vehicles, vehicle_keys, bills, bank_*, businesses, criminal_records, warrants, police_reports, impound, server_logs, whitelist, bans).

## ✅ Phase 3 — Personnage + spawn + utils
- `novalife_identity` (NUI création + multi-personnages + /id + /permis + permis serveur).
- **Personnalisation visage** : intégration `illenium-appearance` (MIT) — éditeur au moment de la création, apparence sauvegardée en SQL (`identities.appearance`) et ré-appliquée au spawn. Câblage sécurisé (`pcall`, pas de crash si ressource absente).
- `novalife_spawn` (premier spawn / reconnexion, anti double spawn).
- `novalife_utils` (helpers: FindPlayer, FormatMoney, Dist).

## ✅ Phase 4 — Économie + banque
- Économie validée serveur (Add/Remove/Deposit/Withdraw/Transfer + plafonds + cooldowns).
- `novalife_banking` (NUI banque: solde, dépôt, retrait, transfert, historique, factures).

## ✅ Phase 5 — Inventaire
- `ox_inventory_novalife_items.lua` (objets RP: eau, nourriture, téléphone, carte id, permis, bandage, kit réparation, outils, clés).
- `novalife_inventory` (bridge: GiveItem/RemoveItem validés serveur).

## ✅ Phase 6 — Véhicules + clés + garages + carburant
- `novalife_garages` (sortie/rangement par type, service métier).
- `novalife_keys` (verrouillage, don/retrait, anti-démarrage sans clé — sécu serveur).
- `novalife_fuel` (consommation, stations, prix config, sauvegarde SQL).
- **Véhicules add-on** : `config/vehicles.lua` restructure pour `addon = true` (templates d'exemple commentés), `docs/VEHICLES.md` + dossier `resources/[vehicles]/` (README template fxmanifest). Aucun modèle protégé redistribué — vous fournissez les fichiers légaux.

## ✅ Phase 7 — Police
- `novalife_police`: prise/fin service, menottes, escorte, fouille, saisie, amende, arrestation, cellule, casier, plaque, radar, fourrière, dispatch + MDT NUI (9 pages).

## ✅ Phase 8 — EMS + Pompiers
- `novalife_ems` (soins, réanimation, transport, facture, hôpital, respawn).
- `novalife_fire` (service, camion, sauvetage, extincteur).

## ✅ Phase 9 — Mécano + Concessionnaire
- `novalife_mechanic` (atelier, réparations, lavage, peinture, moteur/freins/transmission/suspension/carrosserie, facturation).
- `novalife_cardealer` (catalogue par catégorie, achat comptant, financement, essai, stocks).

## ✅ Phase 10 — Entreprises + métiers civils
- `novalife_business` (patron, employés, recrutement, coffre, compte bancaire).
- `novalife_billing` (factures: mécano/police/EMS/entreprise).
- `novalife_civjobs` (taxi compteur, bus, éboueur, livreur — récompenses plafonnées serveur).

## ✅ Phase 11 — Téléphone + chat + voice
- `novalife_chat` (/me /do /try /ooc /911 /112 avec distance).
- `novalife_phone` (NUI: contacts, SMS, banque, GPS, annonces, urgences — architecture VoIP via ressource vocale).
- Voice: compatibilité via ressource vocale tiers (pjs) — voir docs.

## ✅ Phase 12 — Administration
- `novalife_admin` (commandes kick/ban/unban/freeze/goto/bring/revive/heal/tpm/giveitem/givemoney/setjob/setgrade/car/dv + menu NUI + logs).
- `novalife_owner` (👑 Owner Panel complet: joueurs, argent, inventaire, jobs, véhicules, propriétés, garages en jeu, entreprises, TP, sanctions, positions, config, logs — sécurité stricte `IsOwner` côté serveur + `Config.OwnerIdentifiers`).

## ✅ Phase 13 — NUI identité visuelle
- `novalife_core/html/theme.css` (thème sombre/moderne partagé, --primary configurable).
- Toutes les NUI (identité, banque, MDT, phone, admin) respectent ce style.

## ✅ Phase 14 — Logs + sécurité
- `docs/SECURITY.md` (toutes les opérations sensibles validées serveur: distance, cooldown, anti-spam, vérif job/grade, logs).
- Webhooks Discord (configurés UNIQUEMENT `server.cfg`, lus par `GetConvar` côté serveur, jamais exposés au client).

## ✅ Phase 15 — Documentation finale
- `docs/TEST_CHECKLIST.md` (tests complets TEST/ÉTAPES/RÉSULTAT ATTENDU).
- `RESULTAT.md` (résultat final A→K).
- `start.bat` (lanceur Windows FXServer).

---
### Vérifications automatiques effectuées
- ✅ 68 fichiers Lua compilés sans erreur de syntaxe (LuaJIT `load`).
- ✅ 5 fichiers JS NUI validés (`node --check`).
- ✅ Cohérence des chemins fxmanifest ↔ fichiers existants.
- ✅ ordre de démarrage dans `server.cfg.example`.
