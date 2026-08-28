-- NovaLife RP — novalife_phone (architecture compatible)
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'NovaLife RP'
version '1.0.0'
description 'Téléphone: appels, SMS, contacts, banque, GPS, annonces, urgences (architecture)'

dependency 'ox_lib'
dependency 'oxmysql'
dependency 'novalife_core'

server_scripts { 'server.lua' }
client_scripts { 'client.lua' }
ui_page 'html/phone.html'
files { 'html/phone.html', 'html/phone.css', 'html/phone.js' }
