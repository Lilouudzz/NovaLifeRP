-- NovaLife RP — novalife_identity (création + multi-personnages + apparence)
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'NovaLife RP'
version '1.0.0'
description 'Création de personnage, identité, permis, apparence (illenium-appearance), sélection multi-persos'

dependency 'ox_lib'
dependency 'oxmysql'
dependency 'novalife_core'
dependency 'illenium-appearance'

shared_scripts { 'shared.lua' }
server_scripts { 'server.lua' }
client_scripts { 'client.lua' }
ui_page 'html/index.html'
files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
}
