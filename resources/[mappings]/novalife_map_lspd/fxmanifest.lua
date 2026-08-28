-- NovaLife RP — novalife_map_lspd (Mission Row Police Department)
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'NovaLife RP'
version '1.0.0'
description 'Mapping LSPD Mission Row: déverrouillage des intérieurs stock (lobby, cellules, armurerie) + points service Police'

-- Aucun YMAP binaire redistribué: on déverrouille les intérieurs natifs GTA V
-- (technique légale, documentée dans docs/MAPPINGS.md). Les portes sont
-- rendues franchissables côté client (SetEntityCollision désactivé sur les
-- portes des intérieurs police). Approche 100% vanilla, sans asset tiers.
dependency 'ox_target'
dependency 'novalife_core'

shared_scripts { 'coords.lua' }
client_scripts { 'client.lua' }
