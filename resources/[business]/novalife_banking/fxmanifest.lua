-- NovaLife RP — novalife_banking (NUI banque)
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'NovaLife RP'
version '1.0.0'
description 'Banque NUI: solde, dépôt, retrait, transfert, historique, factures'

dependency 'ox_lib'
dependency 'oxmysql'
dependency 'novalife_core'

shared_scripts { 'shared.lua' }
server_scripts { 'server.lua' }
client_scripts { 'client.lua' }
ui_page 'html/index.html'
files { 'html/index.html', 'html/style.css', 'html/app.js' }
