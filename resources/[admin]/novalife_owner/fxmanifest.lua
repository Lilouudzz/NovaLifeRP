-- NovaLife RP — novalife_owner (Owner Panel)
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'NovaLife RP'
version '1.0.0'
description 'Panneau propriétaire: joueurs, argent, inventaire, jobs, véhicules, propriétés, garages, entreprises, logs (sécurisé serveur)'

dependency 'ox_lib'
dependency 'oxmysql'
dependency 'ox_target'
dependency 'novalife_core'
dependency 'novalife_admin'

shared_scripts { 'shared.lua' }
server_scripts { 'server.lua' }
client_scripts { 'client.lua' }
ui_page 'html/owner.html'
files { 'html/owner.html', 'html/owner.css', 'html/owner.js' }
