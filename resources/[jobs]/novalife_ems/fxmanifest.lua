-- NovaLife RP — novalife_ems
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'NovaLife RP'
version '1.0.0'
description 'EMS: service, soins, réanimation, transport, facture, hôpital, respawn'

dependency 'ox_lib'
dependency 'oxmysql'
dependency 'ox_target'
dependency 'novalife_core'

server_scripts { 'server.lua' }
client_scripts { 'client.lua' }
