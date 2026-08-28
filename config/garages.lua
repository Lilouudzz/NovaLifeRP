-- ============================================================
--  NovaLife RP — Garages
--  Types: public | police | ems | fire | mechanic | business | gang | private
--  Coordonnées Los Santos / Blaine County (GTA stock).
--  x,y,z = position du point d'interaction (ox_target)
--  veh = point de spawn des véhicules sortis
-- ============================================================

Garages = {
    {
        id = "public_ls_center",
        label = "Garage Public — Centre LS",
        type = "public",
        job = nil,
        coords = vector3(215.0, -791.0, 30.7),
        spawn = vector3(225.0, -800.0, 30.6),
        radius = 5.0,
    },
    {
        id = "public_paleto",
        label = "Garage Public — Paleto Bay",
        type = "public",
        job = nil,
        coords = vector3(-208.0, 6210.0, 31.5),
        spawn = vector3(-195.0, 6195.0, 31.0),
        radius = 5.0,
    },
    {
        id = "public_sandy",
        label = "Garage Public — Sandy Shores",
        type = "public",
        job = nil,
        coords = vector3(1830.0, 3670.0, 34.0),
        spawn = vector3(1845.0, 3660.0, 33.5),
        radius = 5.0,
    },

    -- ===== Métiers =====
    {
        id = "police_mrpd",
        label = "Garage Police — MRPD",
        type = "police",
        job = "police",
        coords = vector3(459.0, -1000.0, 25.0),
        spawn = vector3(470.0, -1015.0, 24.5),
        radius = 5.0,
    },
    {
        id = "ems_pillbox",
        label = "Garage EMS — Pillbox",
        type = "ems",
        job = "ambulance",
        coords = vector3(338.0, -1396.0, 32.5),
        spawn = vector3(350.0, -1408.0, 32.0),
        radius = 5.0,
    },
    {
        id = "fire_station",
        label = "Garage Pompiers — Davis",
        type = "fire",
        job = "fire",
        coords = vector3(-609.0, -124.0, 38.0),
        spawn = vector3(-595.0, -110.0, 37.5),
        radius = 5.0,
    },
    {
        id = "mechanic_lsc",
        label = "Garage Mécano — LS Custom",
        type = "mechanic",
        job = "mechanic",
        coords = vector3(-356.0, -133.0, 39.0),
        spawn = vector3(-345.0, -145.0, 38.5),
        radius = 5.0,
    },
    {
        id = "taxi_depot",
        label = "Garage Taxi — Depot",
        type = "business",
        job = "taxi",
        coords = vector3(903.0, -178.0, 74.0),
        spawn = vector3(915.0, -190.0, 73.5),
        radius = 5.0,
    },
}
