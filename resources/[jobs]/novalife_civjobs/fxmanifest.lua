-- NovaLife RP — novalife_civjobs (Taxi, Bus, Éboueur, Livreur)
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'NovaLife RP'
version '1.0.0'
description 'Métiers civils: taxi, bus, éboueur, livreur (missions, compteur, salaire)'

dependency 'ox_lib'
dependency 'oxmysql'
dependency 'ox_target'
dependency 'novalife_core'

server_scripts { 'server.lua' }
client_scripts { 'client.lua' }
