# NovaLife RP — Checklist de tests

Format : TEST / ÉTAPES / RÉSULTAT ATTENDU / RÉSULTAT (à remplir en jeu).

## Connexion & personnage
- [ ] TEST: Création personnage
      ÉTAPES: Se connecter → remplir le formulaire → Valider
      RÉSULTAT ATTENDU: Personnage créé, sauvegardé en SQL (table `characters`), spawn effectué
      RÉSULTAT: ____
- [ ] TEST: Multi-personnages
      ÉTAPES: Reconnecter, choisir un 2e perso
      RÉSULTAT ATTENDU: Sélection fonctionnelle, pas de mélange d'identité
      RÉSULTAT: ____
- [ ] TEST: Connexion / Déconnexion
      ÉTAPES: /quit puis reconnecter
      RÉSULTAT ATTENDU: Log connect + déconnect (Discord + server_logs)
      RÉSULTAT: ____

## Économie & banque
- [ ] TEST: Argent
      ÉTAPES: Vérifier cash/banque au démarrage
      RÉSULTAT ATTENDU: 500$ cash / 5000$ banque (config)
      RÉSULTAT: ____
- [ ] TEST: Banque
      ÉTAPES: Aller à une banque → dépôt/retrait/transfert
      RÉSULTAT ATTENDU: Solde mis à jour, historique enregistré
      RÉSULTAT: ____
- [ ] TEST: Facture
      ÉTAPES: Mécano émet /facture → client paie via banque
      RÉSULTAT ATTENDU: Banque débitée, émetteur crédité (si compte)
      RÉSULTAT: ____

## Véhicules
- [ ] TEST: Achat véhicule
      ÉTAPES: Concessionnaire → achat comptant
      RÉSULTAT ATTENDU: -prix banque, véhicule en `player_vehicles`, plaque unique, clé donnée
      RÉSULTAT: ____
- [ ] TEST: Garage (sortie/rangement)
      ÉTAPES: /garage → sortir → re-garer
      RÉSULTAT ATTENDU: Véhicule spawn au point, état = 0 puis 1 en SQL
      RÉSULTAT: ____
- [ ] TEST: Clés
      ÉTAPES: /lock, /givekey à un autre joueur
      RÉSULTAT ATTENDU: Verrouillage OK, 2e joueur peut démarrer après /givekey
      RÉSULTAT: ____
- [ ] TEST: Carburant
      ÉTAPES: Garer à une station → faire le plein
      RÉSULTAT ATTENDU: -coût cash, niveau sauvegardé en SQL
      RÉSULTAT: ____

## Police
- [ ] TEST: Menottes
      ÉTAPES: Police proche → Menotter
      RÉSULTAT ATTENDU: Cible immobilisée, animation, log
      RÉSULTAT: ____
- [ ] TEST: Fouille
      ÉTAPES: Police → Fouiller
      RÉSULTAT ATTENDU: Inventaire de la cible affiché (si dans la range)
      RÉSULTAT: ____
- [ ] TEST: Arrestation
      ÉTAPES: Police → Arrestation (durée)
      RÉSULTAT ATTENDU: Casier créé, cible en cellule, log arrest
      RÉSULTAT: ____
- [ ] TEST: Plaque / Casier (MDT)
      ÉTAPES: MDT → recherche plaque / citizenid
      RÉSULTAT ATTENDU: Infos propriétaire / casier retournées
      RÉSULTAT: ____

## EMS / Pompiers
- [ ] TEST: EMS soin / réanimation
      ÉTAPES: EMS proche d'un joueur mort → Réanimer
      RÉSULTAT ATTENDU: Joueur revit, pleine vie
      RÉSULTAT: ____
- [ ] TEST: Pompiers sauvetage
      ÉTAPES: Pompier → Sauvetage
      RÉSULTAT ATTENDU: Cible réanimée
      RÉSULTAT: ____

## Mécano / Facture
- [ ] TEST: Mécano réparation
      ÉTAPES: Mécano dans véhicule → Réparer
      RÉSULTAT ATTENDU: Santé moteur/carrosserie = 1000 en SQL
      RÉSULTAT: ____

## Admin
- [ ] TEST: Admin
      ÉTAPES: /admin → kick/ban/givemoney/setjob
      RÉSULTAT ATTENDU: Action appliquée + log admin Discord
      RÉSULTAT: ____

## Logs
- [ ] TEST: Logs Discord
      ÉTAPES: Faire un achat + une arrestation
      RÉSULTAT ATTENDU: Webhooks reçus (vérifiez le salon Discord configuré)
      RÉSULTAT: ____

## Owner Panel (novalife_owner)
- [ ] TEST: /owner accès Owner
      ÉTAPES: Lancer /owner avec un identifiant owner (Config.OwnerIdentifiers)
      RÉSULTAT ATTENDU: Panneau s'ouvre
      RÉSULTAT: ____
- [ ] TEST: /owner refus joueur normal
      ÉTAPES: Lancer /owner sans être owner
      RÉSULTAT ATTENDU: Accès refusé (vérif serveur, pas de NUI)
      RÉSULTAT: ____
- [ ] TEST: Gestion joueurs
      ÉTAPES: TP vers/ramener/spectate/freeze/revive/heal/kick/ban depuis le panneau
      RÉSULTAT ATTENDU: Action appliquée + log owner
      RÉSULTAT: ____
- [ ] TEST: Argent
      ÉTAPES: Donner/retirer/définir cash & banque (grosse somme => confirmation)
      RÉSULTAT ATTENDU: Solde modifié, log OWNER_MONEY
      RÉSULTAT: ____
- [ ] TEST: Inventaire
      ÉTAPES: Donner/retirer/définir item (ex: water)
      RÉSULTAT ATTENDU: Item vérifié serveur, ajouté/retiré, log OWNER_ITEM
      RÉSULTAT: ____
- [ ] TEST: Jobs
      ÉTAPES: Définir/promouvoir/rétrograder/retirer métier
      RÉSULTAT ATTENDU: Job mis à jour, log OWNER_JOB
      RÉSULTAT: ____
- [ ] TEST: Véhicules
      ÉTAPES: Spawn/réparer/laver/carburant/verrouiller/changer plaque/donner
      RÉSULTAT ATTENDU: Action véhicule OK, log OWNER_VEHICLE
      RÉSULTAT: ____
- [ ] TEST: Propriétés
      ÉTAPES: Créer propriété en jeu (/owner → Propriétés → Créer, /ownerpos)
      RÉSULTAT ATTENDU: Propriété en SQL (table properties), clés gérées
      RÉSULTAT: ____
- [ ] TEST: Garages en jeu
      ÉTAPES: Mode création → créer garage
      RÉSULTAT ATTENDU: Garage en SQL (custom_garages)
      RÉSULTAT: ____
- [ ] TEST: Clés
      ÉTAPES: Donner/retirer accès propriété
      RÉSULTAT ATTENDU: property_keys mis à jour
      RÉSULTAT: ____
- [ ] TEST: Entreprises
      ÉTAPES: Créer/définir patron/compte
      RÉSULTAT ATTENDU: businesses mise à jour, log OWNER_BUSINESS
      RÉSULTAT: ____
- [ ] TEST: Téléportation
      ÉTAPES: Vers joueur / ramener / coords
      RÉSULTAT ATTENDU: TP effectif
      RÉSULTAT: ____
- [ ] TEST: Sanctions
      ÉTAPES: Kick/Ban/Unban
      RÉSULTAT ATTENDU: Appliqué + log OWNER_KICK/OWNER_BAN
      RÉSULTAT: ____
- [ ] TEST: Logs
      ÉTAPES: Ouvrir l'onglet Logs
      RÉSULTAT ATTENDU: Logs owner_*, OWNER_LOGIN, OWNER_ACTION visibles
      RÉSULTAT: ____
- [ ] TEST: Sécurité
      ÉTAPES: Tenter /owner en tant que admin non-owner
      RÉSULTAT ATTENDU: Refusé (IsOwner côté serveur uniquement)
      RÉSULTAT: ____
