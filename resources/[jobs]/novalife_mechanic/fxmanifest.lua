-- NovaLife RP — novalife_mechanic
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'NovaLife RP'
version '1.0.0'
description 'Mécano: garage, atelier, réparations, lavage, peinture, facturation'

dependency 'ox_lib'
dependency 'oxmysql'
dependency 'ox_target'
dependency 'novalife_core'

server_scripts { 'server.lua' }
client_scripts { 'client.lua' }
