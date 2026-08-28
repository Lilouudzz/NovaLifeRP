-- NovaLife RP — novalife_map_pillbox (Pillbox Hill Medical Center)
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'NovaLife RP'
version '1.0.0'
description 'Mapping Pillbox Hill: déverrouillage des intérieurs stock (réception, salles, service EMS) + points service EMS'

-- Aucun YMAP binaire redistribué: on déverrouille les intérieurs natifs GTA V
-- (technique légale documentée dans docs/MAPPINGS.md). Approche 100% vanilla.
dependency 'ox_target'
dependency 'novalife_core'

shared_scripts { 'coords.lua' }
client_scripts { 'client.lua' }
