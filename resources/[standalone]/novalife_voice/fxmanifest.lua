-- NovaLife RP — novalife_voice (bridge pma-voice / resvoice)
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'NovaLife RP'
version '1.0.0'
description 'Voix: radio auto par métier, mégaphone, appels, proximité (bridge pma-voice)'

-- pma-voice (ou resvoice compatible mumble-voip) doit être installé.
-- Source: github.com/AvarianKnight/pma-voice (MIT)
dependency 'ox_lib'
dependency 'novalife_core'

server_scripts { 'server.lua' }
client_scripts { 'client.lua' }
ui_page 'html/radio.html'
files { 'html/radio.html', 'html/radio.css', 'html/radio.js' }
