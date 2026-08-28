-- NovaLife RP — novalife_admin
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'NovaLife RP'
version '1.0.0'
description 'Administration: commandes + menu NUI + logs (toutes actions tracées)'

dependency 'ox_lib'
dependency 'oxmysql'
dependency 'novalife_core'

server_scripts { 'server.lua' }
client_scripts { 'client.lua' }
ui_page 'html/admin.html'
files { 'html/admin.html', 'html/admin.css', 'html/admin.js' }
