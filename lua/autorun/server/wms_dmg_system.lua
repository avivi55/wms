include("prettyPrint.lua")
local armes = util.JSONToTable(file.Read("armes.json", "GAME"))
--Print(armes) 
--local sons = util.JSONToTable(file.Read("sons.json", "GAME"))
-- print("\27[24m")
-- MsgC([[
-- ██╗    ██╗██╗███╗   ██╗███╗   ██╗██╗███████╗███████╗
-- ██║    ██║██║████╗  ██║████╗  ██║██║██╔════╝██╔════╝
-- ██║ █╗ ██║██║██╔██╗ ██║██╔██╗ ██║██║█████╗  ███████╗
-- ██║███╗██║██║██║╚██╗██║██║╚██╗██║██║██╔══╝  ╚════██║
-- ╚███╔███╔╝██║██║ ╚████║██║ ╚████║██║███████╗███████║
--  ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝╚═╝  ╚═══╝╚═╝╚══════╝╚══════╝]], "\n", Color(255, 0, 0))
-- MsgC([[
--         ███╗   ███╗███████╗██████╗ ██╗ ██████╗ █████╗ ██╗     
--         ████╗ ████║██╔════╝██╔══██╗██║██╔════╝██╔══██╗██║     
--         ██╔████╔██║█████╗  ██║  ██║██║██║     ███████║██║     
--         ██║╚██╔╝██║██╔══╝  ██║  ██║██║██║     ██╔══██║██║     
--         ██║ ╚═╝ ██║███████╗██████╔╝██║╚██████╗██║  ██║███████╗
--         ╚═╝     ╚═╝╚══════╝╚═════╝ ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝]], "\n", Color(255, 255, 255))
-- MsgC([[
--                 ███████╗██╗   ██╗███████╗████████╗███████╗███╗   ███╗
--                 ██╔════╝╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔════╝████╗ ████║
--                 ███████╗ ╚████╔╝ ███████╗   ██║   █████╗  ██╔████╔██║
--                 ╚════██║  ╚██╔╝  ╚════██║   ██║   ██╔══╝  ██║╚██╔╝██║
--                 ███████║   ██║   ███████║   ██║   ███████╗██║ ╚═╝ ██║
--                 ╚══════╝   ╚═╝   ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝
-- ]], Color(255, 0, 0))
-- MsgC([[
-- ███████╗███╗   ██╗ █████╗ ██████╗ ██╗     ███████╗██████╗   ██╗
-- ██╔════╝████╗  ██║██╔══██╗██╔══██╗██║     ██╔════╝██╔══██╗  ██║
-- █████╗  ██╔██╗ ██║███████║██████╔╝██║     █████╗  ██║  ██║  ██║
-- ██╔══╝  ██║╚██╗██║██╔══██║██╔══██╗██║     ██╔══╝  ██║  ██║  ╚═╝
-- ███████╗██║ ╚████║██║  ██║██████╔╝███████╗███████╗██████╔╝  ██╗
-- ╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚══════╝╚═════╝   ╚═╝
-- ]], Color(0, 255, 0))

print("updated")
WMS = WMS or {}

WMS.tblContains = function(tbl, val)
    for k, v in pairs(tbl) do
        if v == val or (type(v) == "table" and WMS.tblContains(v, val)) then return true end
    end
    return false
end

WMS.Init = function(ply, trans)
    PrintC("[WMS] Player Damage table initialized !", 8, "112")
    ply.pulse = math.random(70, 90)
    player.hemorrhage = false
    ply.wms_dmg_tbl = {}
end

WMS.ClearDmgDataTbl = function()
    for _, ply in pairs(player.GetAll()) do
        ply.wms_dmg_tbl = {}
    end
end

WMS.DeathHook = function(victim, inflictor, attacker)
    PrintC("[WMS] Player Damage table Deleted !", 8, "1")
    WMS.Init(victim, false)
end


WMS.DamageHook = function(target, dmginfo)
    if (not target:IsPlayer()) then return end
    WMS.RegisterDamage(target, dmginfo)
    dmginfo = WMS.HitgroupHandler(target, dmginfo)
    --return true
end

WMS.RegisterDamage = function(ply, dmgi)
    local dmg = {}
    dmg.pos = dmgi:GetDamagePosition()
    dmg.victim = ply
    dmg.attacker = dmgi:GetAttacker()
    dmg.inflictor = dmgi:GetInflictor()
    dmg.hit_grp = ply:LastHitGroup()
    dmg.damage = dmgi:GetDamage()
    dmg.type = dmgi:GetDamageType()
    dmg.wep = dmg.attacker:IsPlayer() and dmg.attacker:GetActiveWeapon() or
                dmg.inflictor:IsPlayer() and dmg.inflictor:GetActiveWeapon() or nil
    table.insert(dmg.victim.wms_dmg_tbl, dmg)
end

WMS.HeadDamage = function(dmg)
    -- son casque
    local total_death = math.random(100) <= 3 -- 3%
    print(total_death)
    -- Mort pertielle ou total
    -- fonction de mort 
end

WMS.TorsoDamage = function(dmg)
    local wep = dmg.wep:GetClass()
    local total_death = false
    local partial_death = false
    local hemorrhage = false

    print(wep, WMS.tblContains(armes.blanches, wep))

    if (WMS.tblContains(armes.fusils, wep)) then
        -- son torse
        total_death = math.random(100) <= 14 -- 14%
        partial_death = math.random(100) <= 25 -- 25%
    elseif (WMS.tblContains(armes.poings, wep)) then
        total_death = math.random(100) <= 10 -- 10%
        partial_death = math.random(100) <= 15 -- 15%
        hemorrhage = math.random(100) <= 35 -- 35%
    end

    print(total_death, partial_death, hemorrhage)
end

WMS.MeleeDamage = function(dmg)
    if (not WMS.tblContains(armes.blanches, wep)) then return end
    local total_death = math.random(100) <= 5 -- 10%
    local partial_death = math.random(100) <= 7 -- 15%
    local hemorrhage = math.random(100) <= 90 -- 90%

    print(total_death, partial_death, hemorrhage)
end

WMS.HitgroupHandler = function(ply, dmginfo)
    dmg = ply.wms_dmg_tbl[#ply.wms_dmg_tbl]
    PrintC(dmg, 8, "27")

    if (not dmg.inflictor:IsPlayer()) then -- Cas specifiques (feu, explostion, melée ...)
        local name = dmg.inflictor:GetClass()

        if (dmginfo:IsExplosionDamage()) then
            PrintC("BOOM !!", 8, 202)
            --TODO
            -- return
        end

        if (string.find(name, "mel")) then
            PrintC("SPLOUTCH !!", 8, 52)
            --TODO
            -- return
        end

        if (not WMS.tblContains(armes, name)) then
            table.remove(ply.wms_dmg_tbl)
            PrintC("[WMS] /!\\ ARME/SOURCE DE DÉGATS NON RECONNU /!\\\n\t->Nous annulons donc les dégats", 8, 196)
            return dmginfo:SetDamage(0)
        end
    end

    if (dmg.hit_grp == HITGROUP_HEAD) then
        WMS.HeadDamage(dmg)
    elseif (dmg.hit_grp == HITGROUP_CHEST) then
        WMS.TorsoDamage(dmg)
    elseif (dmg.hit_grp == HITGROUP_GENERIC) then
        PrintC("SPLOUTCH !!", 8, 52)
        WMS.MeleeDamage(dmg)
    end

    return dmginfo:SetDamage(0)
end

hook.Add("EntityTakeDamage", "wms_damage_hook", WMS.DamageHook)
hook.Add("PlayerInitialSpawn", "wms_init", WMS.Init)
hook.Add("PlayerDeath", "wms_death_hook", WMS.DeathHook)