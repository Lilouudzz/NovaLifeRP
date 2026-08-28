-- ============================================================
--  novalife_utils — server.lua
--  Helpers réutilisables par toutes les ressources.
-- ============================================================

-- Trouver un joueur par ID serveur, citizenid, ou nom partiel
function FindPlayer(query)
    if not query then return nil end
    -- par src
    local n = tonumber(query)
    if n and Core and Core.Players[n] then return n end
    -- par citizenid / nom
    for src, p in pairs(Core.Players) do
        if p.citizenid == query or (p.name and p.name:lower():find(tostring(query):lower(), 1, true)) then
            return src
        end
    end
    return nil
end

-- Formatage argent FR
function FormatMoney(n)
    local s = tostring(math.floor(n or 0))
    local out = s:reverse():gsub("(%d%d%d)", "%1 "):reverse()
    out = out:gsub("^ ", "")
    return out .. '$'
end

-- Distance 3D
function Dist(a, b) return #(a - b) end

-- Notification raccourci
function Notify(src, type, title, desc, dur)
    NLNotify(src, type, title, desc, dur)
end

exports('FindPlayer', FindPlayer)
exports('FormatMoney', FormatMoney)
exports('Dist', Dist)
exports('Notify', Notify)
