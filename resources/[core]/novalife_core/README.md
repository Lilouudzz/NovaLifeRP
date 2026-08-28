# novalife_core — API

Framework maison léger. Toute opération sensible est côté serveur. Le client
utilise uniquement des `lib.callback` (lecture/action sécurisée) et des events.

## Exports serveur (utilisables par les autres ressources)
```lua
exports('GetPlayer', src)                 -> player object | nil
exports('GetPlayerByCitizenId', cid)
exports('AddMoney', src, mtype, amount, reason)   -> bool
exports('RemoveMoney', src, mtype, amount, reason)-> bool
exports('GetMoney', src, mtype)           -> number
exports('Deposit', src, amount)           -> bool
exports('Withdraw', src, amount)          -> bool
exports('Transfer', src, targetSrc, amount)-> bool
exports('SetJob', src, jobName, grade)    -> bool
exports('HasPermission', src, level)      -> bool
exports('HasJob', src, jobName, minGrade) -> bool
exports('CheckDistance', src, coords, maxDist) -> bool
exports('CanDo', src, action)             -> bool  (cooldown)
exports('Log', kind, title, msg, color)
exports('SavePlayer', src)
exports('GenCitizenId')
```

## Tables globales chargées (config/*.lua)
`Jobs`, `Vehicles`, `Garages`, `Locations`, `Economy`, `Permissions`
(servent de source de vérité, modifiables sans toucher au code).

## Callbacks client
- `novalife_core:getPlayer` -> player
- `novalife_core:deposit` (amount)
- `novalife_core:withdraw` (amount)
- `novalife_core:transfer` (targetSrc, amount)

## Events client
- `novalife_core:client:init` (serverName)
- `novalife_core:client:playerReady` (player)
- `novalife_core:client:updateMoney` (money)
- `novalife_core:client:updateJob` (job)
- `novalife_core:client:notify` ({type,title,description})
