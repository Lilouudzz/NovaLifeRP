-- NovaLife RP — novalife_fuel
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'NovaLife RP'
version '1.0.0'
description 'Carburant: consommation, stations, remplissage (prix config), sauvegarde SQL'

dependency 'ox_lib'
dependency 'oxmysql'
dependency 'ox_target'
dependency 'novalife_core'

server_scripts { 'server.lua' }
client_scripts { 'client.lua' }
