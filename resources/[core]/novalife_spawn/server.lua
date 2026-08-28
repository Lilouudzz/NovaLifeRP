-- ============================================================
--  novalife_spawn — server.lua
--  Détermine le spawn (premier vs reconnexion) côté serveur.
-- ============================================================

local function getSpawn(src)
    local p = exports.novalife_core:GetPlayer(src)
    if not p then return { x = 0, y = 0, z = 0, heading = 0, first = true } end
    -- Premier spawn: pas de position sauvegardée
    if not p.position or (p.position.x == 0 and p.position.y == 0 and p.position.z == 0) then
        -- Métier Police -> spawn LSPD ; EMS -> spawn Pillbox (exports des mappings)
        local job = p.job and p.job.name
        if job == 'police' and GetResourceState('novalife_map_lspd') == 'started' then
            local c, h = exports.novalife_map_lspd:GetPoliceSpawn()
            if c then return { x = c.x, y = c.y, z = c.z, heading = h or 0, first = true } end
        elseif job == 'ambulance' and GetResourceState('novalife_map_pillbox') == 'started' then
            local c, h = exports.novalife_map_pillbox:GetEMSSpawn()
            if c then return { x = c.x, y = c.y, z = c.z, heading = h or 0, first = true } end
        end
        local apt = Locations and Locations.starterApartment and Locations.starterApartment.coords
        return { x = apt and apt.x or 255.0, y = apt and apt.y or -1000.0, z = apt and apt.z or -99.0,
                 heading = 0, first = true }
    end
    -- Reconnexion: dernière position valide
    return { x = p.position.x, y = p.position.y, z = p.position.z, heading = p.position.heading or 0, first = false }
end

RegisterNetEvent('novalife_spawn:request', function()
    local src = source
    local sp = getSpawn(src)
    TriggerClientEvent('novalife_spawn:doSpawn', src, sp)
end)
