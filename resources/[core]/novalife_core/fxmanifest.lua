-- NovaLife RP — novalife_core (framework maison léger)
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'NovaLife RP'
version '1.0.0'
description 'Core: joueurs, économie, callbacks, logs, sécurité'

-- Dépendances réelles (open-source, MIT) — installées dans [standalone]
dependency 'ox_lib'
dependency 'oxmysql'

shared_scripts {
    'shared.lua',
}

server_scripts {
    'server.lua',
}

client_scripts {
    'client.lua',
}
