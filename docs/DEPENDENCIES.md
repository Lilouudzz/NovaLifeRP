# NovaLife RP — Dépendances & versions

Toutes les dépendances sont **open-source / libres**. Leur code n'est JAMAIS copié dans ce dépôt :
on les installe via `git clone` ou le `.zip` officiel dans `resources/[standalone]/`.

> ⚠️ Vérifiez toujours la licence et la doc officielle avant installation. Les versions
> ci-dessous sont indicatives (compatibles entre elles au moment de l'écriture).

## 1. FXServer (artefacts)
- Source officielle : https://runtime.fivem.net/ (FXServer builds)
- Licence : https://fivem.net (terms of service — nécessite une clé de licence)
- Install : télécharger l'artefact `server` pour votre OS, extraire dans le dossier serveur.

## 2. oxmysql
- GitHub : https://github.com/overextended/oxmysql
- Licence : MIT
- Rôle : pilote MySQL/MariaDB (connexion via `mysql_connection_string`).
- Install : `git clone https://github.com/overextended/oxmysql resources/[standalone]/oxmysql`
  puis `cd oxmysql && npm i --production` (build précompilé dispo aussi en release).

## 3. ox_lib
- GitHub : https://github.com/overextended/ox_lib
- Licence : MIT (certaines assets CC)
- Rôle : notifications (`lib.notify`), menus contextuels, utilitaires (`lib.math`, `lib.table`,
  `lib.callback`), et la base NUI (`ox_lib` fournit le loader pour nos interfaces).
- Install : `git clone https://github.com/overextended/ox_lib resources/[standalone]/ox_lib`

## 4. ox_target
- GitHub : https://github.com/overextended/ox_target
- Licence : MIT
- Rôle : interactions au monde (menus quand on vise un point/veh/player).
- Install : `git clone https://github.com/overextended/ox_target resources/[standalone]/ox_target`

## 5. ox_inventory
- GitHub : https://github.com/overextended/ox_inventory
- Licence : MIT (GPL pour certaines parties — consulter le repo)
- Rôle : inventaire + objets RP + stash/coffres.
- Dépend de : ox_lib, oxmysql, ox_target.
- Install : `git clone https://github.com/overextended/ox_inventory resources/[standalone]/ox_inventory`
  puis configurer `web/` et `data/items.lua` (on ajoute nos items via `ox_inventory/data/items.lua`
  ou via l'export `registerItem`).

## 6. illenium-appearance (personnalisation visage/vêtements)
- GitHub : https://github.com/iLLeniumStudios/illenium-appearance
- Licence : MIT (voir repo)
- Rôle : éditeur de personnage (visage, cheveux, vêtements, tatouages) basé sur
  fivem-appearance, UI via ox_lib.
- Install : `git clone https://github.com/iLLeniumStudios/illenium-appearance resources/[standalone]/illenium-appearance`
  puis `ensure illenium-appearance` (déjà dans server.cfg.example).
- Intégration NovaLife : déclaré en `dependency` de `novalife_identity`. Au moment
  de créer un personnage, l'éditeur s'ouvre ; l'apparence est sauvegardée en SQL
  (champ `identities.appearance`) et ré-appliquée au spawn/reconnexion.
  Si la ressource n'est pas installée, le serveur tourne sans personnalisation
  (pcall de sécurité côté client).
- ⚠️ Utiliser une **release** stable, pas la branche `main` (recommandation officielle).
- Fourni avec FXServer. Recommandé pour le panneau web / RCON / planification.
- Licence : inclus dans FXServer.

## Compatibilité vérifiée
- ox_inventory ≥ 2.x requiert ox_lib ≥ 3.x et ox_target ≥ 2.x.
- Toutes ces ressources utilisent `oxmysql` (plus `mysql-async` legacy).
- QBCore n'est PAS utilisé : NovaLife RP utilise un core maison léger
  (`novalife_core`) qui expose une API compatible (player, money, jobs) sans
  le poids d'un framework complet. Les exports clés sont documentés dans
  `resources/[core]/novalife_core/README.md`.

## À NE PAS ajouter (rappel licence)
- Aucun modèle de véhicule add-on protégé sans licence.
- Aucun mapping YMAP dont la licence interdit la redistribution.
- Les véhicules listés dans `config/vehicles.lua` sont du stock GTA ou des
  modèles que VOUS ajoutez légalement.
