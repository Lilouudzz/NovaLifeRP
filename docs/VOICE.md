# NovaLife RP — Système de voix (docs/VOICE.md)

Le serveur utilise la voix **mumble intégrée à FiveM** via **pma-voice**
(fourre-tout compatible mumble-voip, MIT — github.com/AvarianKnight/pma-voice).
`resvoice` (compatible mumble) fonctionne aussi : le bridge détecte l'une ou
l'autre au runtime (`GetResourceState`).

## Dépendances
- `pma-voice` (MIT) → `resources/[standalone]/pma-voice` (clone officiel).
- `novalife_voice` (bridge NovaLife) → `resources/[standalone]/novalife_voice`.

## Install
```
git clone https://github.com/AvarianKnight/pma-voice resources/[standalone]/pma-voice
```
`ensure pma-voice` + `ensure novalife_voice` sont déjà dans `server.cfg.example`.

## Canaux radio par métier (novalife_voice/server.lua)
| Métier      | Canal |
|-------------|-------|
| police      | 1     |
| ambulance   | 2     |
| fire        | 3     |
| mechanic    | 4     |
| taxi        | 5     |
| cardealer   | 6     |
| dispatch    | 911   |

Au **premier spawn** ou à la **prise de service** d'un métier (police/ems/fire),
le joueur est automatiquement mis sur le canal de son métier. Hors service →
radio coupée (canal 0).

## Commandes / touches (joueur)
- `K` : ouvrir l'UI radio (canal + power).
- `/radio <canal>` : rejoindre un canal manuellement.
- Touche par défaut pma-voice : `LMENU` (Alt gauche) = parler à la radio,
  `Z` ou `MAJ` = cycler la proximité (chuchoter/normal/crier).

## API réelle utilisée (pma-voice, côté client)
- `exports['pma-voice']:setRadioChannel(int)`  — 0 = quitter
- `exports['pma-voice']:setCallChannel(int)`    — 0 = quitter (appels téléphone)
- `exports['pma-voice']:addPlayerToRadio(int)`
Toutes les communications passent exclusivement par ces exports (le serveur
ne fait que décider des canaux métier, jamais router l'audio).

## Mégaphone
Touche `B` (Police) : bascule le submix mégaphone si pma-voice le supporte
(`setVoiceProperty('megaphone', ...)`). Sécurisé par vérif job police côté client.

## Téléphone (appels)
`novalife_phone` déclenche `novalife_voice:client:startCall(targetSrc)` /
`:endCall` qui utilise `setCallChannel` (canal = ID serveur de l'interlocuteur).

## Sécurité
- Le serveur n'autorise jamais un client à forcer un canal : c'est pma-voice qui
  applique, et les canaux d'urgence (911) peuvent être restreints via
  `addChannelCheck` de pma-voice si besoin.
- Si pma-voice/resvoice n'est pas installé, `novalife_voice` ne fait rien
  (pcall + GetResourceState) — aucun crash.
