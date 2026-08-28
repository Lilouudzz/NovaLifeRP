# NovaLife RP — Sécurité (Phase 14)

Principe absolu : **le serveur ne fait jamais confiance au client.**

## 1. Source de vérité
- Toutes les données critiques vivent en SQL (`database/install.sql`) et dans `Core.Players` côté serveur.
- Le client ne fait QUE : afficher l'UI, envoyer des *intentions* via `lib.callback`/`TriggerServerEvent`,
  et recevoir l'état validé (`novalife_core:client:updateMoney`, `:updateJob`, `:playerReady`).

## 2. Opérations validées côté serveur
| Opération | Où | Vérifications |
|-----------|----|---------------|
| Argent (add/remove/deposit/withdraw/transfer) | `novalife_core` | montant >0, plafonds `Economy.Max*`, cooldown, solde suffisant |
| Items (give/remove) | `novalife_inventory` | joueur existe, `CanCarryItem`, log |
| Véhicules (sortie/achat) | `novalife_garages`, `novalife_cardealer` | propriété (citizenid), garage autorisé, plaque unique |
| Clés | `novalife_keys` | seul le propriétaire donne/retire, pas de création côté client |
| Jobs/grades | `novalife_core:SetJob` + commandes admin | `HasPermission` (niveau ACE), whitelist métier |
| Arrestation/menottes/fouille | `novalife_police` | `HasJob('police')`, `CheckDistance`, cooldown `arrest` |
| Factures | `novalife_billing` | émetteur a un métier autorisé, montant plafonné |
| Récompenses civiles | `novalife_civjobs` | job requis, montant plafonné (anti-abus) |
| Admin | `novalife_admin` | `IsPlayerAceAllowed` + `HasPermission` niveau, tout logué |

## 3. Défenses techniques appliquées
- **Distance checks** : `Core.CheckDistance(src, coords, maxDist)` sur chaque action physique (menottes, fouille, soin, arrestation, amende).
- **Cooldowns** : `Core.CanDo(src, action)` (configuré dans `Config.Cooldowns`).
- **Anti-spam** : cooldowns + plafonds par transaction.
- **Validation des paramètres** : `tonumber`, formats de date, longueurs de champ (`novalife_identity:validateIdentity`).
- **Vérification job/grade** : `HasJob(src, job, minGrade)` avant chaque action de métier.
- **Logs** : `Core.Log(kind, ...)` vers webhooks Discord (jamais envoyés au client) + table `server_logs`.

## 4. Webhooks Discord
- Déclarés **uniquement** dans `server.cfg` via `set NovaLife_Webhook_*`.
- Lues côté serveur par `GetConvar` dans `novalife_core` (`loadWebhooks`).
- **Jamais** présentes dans aucun fichier NUI ni fichier client.

## 5. Points laissés à intervention manuelle (voir résultat final, section K)
- Configuration réelle de `server.cfg` (license, SQL, webhooks, rcon) → `CHANGE_ME`.
- Ajout des mappings (YMAP) et véhicules add-on que VOUS possédez légalement.
- Réglage de `set onesync_population` selon la licence.
- Installation des dépendances `[standalone]` (oxmysql/ox_lib/ox_target/ox_inventory) via git clone.
