-- ============================================================
--  novalife_map_pillbox — coords.lua (partagé)
--  Coordonnées officielles Pillbox Hill Medical Center.
--  Source: emplacements vanilla GTA V (publics, non redistribués).
-- ============================================================

PILLBOX = {
    -- Extérieur (devant l'hôpital)
    outside     = vector3(338.0, -1396.0, 32.5),
    outsideHead = 0.0,

    -- Entrée du service (marker devant la porte latérale)
    entrance    = vector3(322.0, -1064.0, -99.0),

    -- Intérieur: réception (IPL "RC12b_hospital" déjà chargé par le jeu)
    lobby       = vector3(325.0, -1064.0, -99.0),
    lobbyHead   = 180.0,

    -- Salle de service EMS (intérieur)
    service     = vector3(330.0, -1052.0, -99.0),

    -- Spawn point EMS (parking ambulances)
    spawn       = vector3(345.0, -1402.0, 32.5),
    spawnHead   = 320.0,

    -- Point de prise de service EMS
    dutyPoint   = vector3(338.0, -1396.0, 32.5),
}
