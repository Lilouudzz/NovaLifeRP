-- NovaLife RP — novalife_police
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'NovaLife RP'
version '1.0.0'
description 'Police: service, menottes, fouille, arrestation, casier, plaque, radar, fourrière, MDT'

dependency 'ox_lib'
dependency 'oxmysql'
dependency 'ox_target'
dependency 'novalife_core'

server_scripts { 'server.lua' }
client_scripts { 'client.lua', 'handcuff.lua' }
ui_page 'html/mdt.html'
files { 'html/mdt.html', 'html/mdt.css', 'html/mdt.js' }
