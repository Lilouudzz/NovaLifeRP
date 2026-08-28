-- ============================================================
--  NovaLife RP — Lieux importants (POI)
--  Utilisés par: spawn, banque, concessionnaire, hôpital,
--  commissariat, fourrière, stations-service, points civils.
-- ============================================================

Locations = {
    -- Hôpital de respawn (EMS)
    hospitals = {
        { label = "Pillbox Hill",   coords = vector3(338.0, -1396.0, 32.5) },
        { label = "Mount Zonah",    coords = vector3(-452.0, -341.0, 34.0) },
        { label = "Sandy Shores",   coords = vector3(1839.0, 3673.0, 34.0) },
    },

    -- Commissariats (prise de service police)
    policeStations = {
        { label = "MRPD",      coords = vector3(441.0, -981.0, 30.7) },
        { label = "Vinewood",  coords = vector3(642.0, 13.0, 41.0) },
        { label = "Paleto",    coords = vector3(-441.0, 6016.0, 31.7) },
    },

    -- Casernes pompiers
    fireStations = {
        { label = "Davis",     coords = vector3(-609.0, -124.0, 38.0) },
        { label = "LSIA",      coords = vector3(-1146.0, -1443.0, 5.0) },
    },

    -- Concessionnaire
    cardealer = {
        { label = "Concessionnaire Central", coords = vector3(-34.0, -1108.0, 26.4) },
    },

    -- Banques (NUI)
    banks = {
        { label = "Fleeca — Centre",   coords = vector3(147.0, -1044.0, 29.4) },
        { label = "Fleeca — Burton",   coords = vector3(-295.0, -892.0, 31.0) },
        { label = "Pacific — Paleto",  coords = vector3(-109.0, 6462.0, 31.6) },
        { label = "Maze — Legit",      coords = vector3(-77.0, -832.0, 43.0) },
    },

    -- Stations-service (carburant)
    fuelStations = {
        { label = "Davis",   coords = vector3(-71.0, -1763.0, 28.5) },
        { label = "Rex",     coords = vector3(1704.0, 6415.0, 32.5) },
        { label = "LSC",     coords = vector3(-703.0, -932.0, 19.0) },
        { label = "Sandy",   coords = vector3(1920.0, 3743.0, 32.0) },
    },

    -- Fourrière
    impound = {
        { label = "Fourrière LS", coords = vector3(409.0, -1630.0, 29.3) },
    },

    -- Appartement de premier spawn
    starterApartment = {
        coords = vector3(266.0, -1007.0, -99.0), -- intérieur configurable
    },

    -- Points métiers civils
    civilJobs = {
        taxiRanks = {
            { label = "Rank LS", coords = vector3(903.0, -178.0, 74.0) },
        },
        busDepot = { label = "Bus Depot", coords = vector3(436.0, -656.0, 28.5) },
        garbageDepot = { label = "Éboueur", coords = vector3(-322.0, -1545.0, 31.0) },
        deliveryDepot = { label = "Livreur", coords = vector3(-427.0, -2757.0, 6.0) },
    },
}
