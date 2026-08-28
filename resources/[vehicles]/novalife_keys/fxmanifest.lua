-- NovaLife RP — novalife_keys
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'NovaLife RP'
version '1.0.0'
description 'Clés véhicules: verrouillage, don/retrait, démarrage (sécu serveur)'

dependency 'ox_lib'
dependency 'oxmysql'
dependency 'novalife_core'

server_scripts { 'server.lua' }
client_scripts { 'client.lua' }
