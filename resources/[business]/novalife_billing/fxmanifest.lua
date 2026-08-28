-- NovaLife RP — novalife_billing (système de factures)
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'NovaLife RP'
version '1.0.0'
description 'Factures: émission (métiers/entreprises), sauvegarde SQL, paiement via banque'

dependency 'ox_lib'
dependency 'oxmysql'
dependency 'novalife_core'

server_scripts { 'server.lua' }
