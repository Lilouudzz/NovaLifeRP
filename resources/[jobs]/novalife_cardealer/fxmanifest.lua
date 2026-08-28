-- NovaLife RP — novalife_cardealer
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'NovaLife RP'
version '1.0.0'
description 'Concessionnaire: catalogue, catégories, achat, essai, financement, stocks'

dependency 'ox_lib'
dependency 'oxmysql'
dependency 'ox_target'
dependency 'novalife_core'

server_scripts { 'server.lua' }
client_scripts { 'client.lua' }

Config = Config or {}
Config.Cardealer = {
    testDriveTime = 60,        -- secondes
    financeRate = 0.15,        -- intérêt mensuel
    financeMonths = 12,
}
