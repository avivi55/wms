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

local HIT = {[0] = "melee", "head", "chest", "stomack", "left_arm", "right_arm", "left_leg", "right_leg"}

WMS.RegisterDamage = function(ply, dmgi)
    local dmg = {}
    dmg.pos = dmgi:GetDamagePosition()
    dmg.victim = ply
    dmg.attacker = dmgi:GetAttacker()
    dmg.inflictor = dmgi:GetInflictor()
    dmg.hit_grp = ply:LastHitGroup()
    dmg.h_hit_grp = HIT[dmg.hit_grp]
    dmg.damage = dmgi:GetDamage()
    dmg.type = dmgi:GetDamageType()
    dmg.wep = dmg.attacker:IsPlayer() and dmg.attacker:GetActiveWeapon() or
                dmg.inflictor:IsPlayer() and dmg.inflictor:GetActiveWeapon() or nil
    table.insert(dmg.victim.wms_dmg_tbl, dmg)
end

WMS.GenericDamage = function(dmg, rifle, pistol, cut)
    cut = cut or {}
    local wep = dmg.wep:GetClass()
    local total_death = false
    local partial_death = false
    local hemorrhage = false

    if (WMS.tblContains(armes.fusils, wep)) then
        -- son torse
        total_death = math.random(100) <= rifle.total
        partial_death = math.random(100) <= rifle.partial
        hemorrhage = math.random(100) <= rifle.hemo
    elseif (WMS.tblContains(armes.poings, wep)) then
        total_death = math.random(100) <= pistol.total
        partial_death = math.random(100) <= pistol.partial
        hemorrhage = math.random(100) <= pistol.hemo
    elseif (cut and (WMS.tblContains(armes.blanches, wep) or WMS.tblContains(armes.blanches, dmg.inflictor:GetClass()))) then
        total_death = math.random(100) <= cut.total
        partial_death = math.random(100) <= cut.partial
        hemorrhage = math.random(100) <= cut.hemo
    end

    PrintC(dmg.h_hit_grp .. ":", 8, 15)
    if (total_death) then
        PrintC("FINITO PIPO", 8, 1)
        dmg.victim:Kill()
    elseif (partial_death) then
        PrintC("FINITO", 8, 202)
        dmg.victim:Kill()
    else
        PrintC("Abatar t viven", 8, 14)
        if (hemorrhage) then
            PrintC("\tOOF Sègne", 8, 9)
        end
        prone.Handle(dmg.victim)
    end

    return total_death, partial_death, hemorrhage
end

WMS.HeadDamage = function(dmg)
    local total_death, partial_death, hemorrhage = WMS.GenericDamage(dmg,
    {total = 97, partial = 99, hemo = 0},
    {total = 96, partial = 98, hemo = 0})
    -- son casque
    -- Mort pertielle ou total
    -- fonction de mort 
end

WMS.TorsoDamage = function(dmg)
    local total_death, partial_death, hemorrhage = WMS.GenericDamage(dmg,
    {total = 14, partial = 25, hemo = 37},
    {total = 12, partial = 19, hemo = 35})
end

WMS.StomachDamage = function(dmg)
    local total_death, partial_death, hemorrhage = WMS.GenericDamage(dmg, 
    {total = 10, partial = 20, hemo = 42},
    {total = 7, partial = 10, hemo = 40})
end

WMS.ArmDamage = function(dmg)
    local total_death, partial_death, hemorrhage = WMS.GenericDamage(dmg, 
    {total = 5, partial = 7, hemo = 15},
    {total = 3, partial = 5, hemo = 10})
end

WMS.LegDamage = function(dmg)
    local total_death, partial_death, hemorrhage = WMS.GenericDamage(dmg,
    {total = 5, partial = 7, hemo = 34},
    {total = 3, partial = 5, hemo = 30})
end

WMS.MeleeDamage = function(dmg)
    local wep = dmg.inflictor:GetClass()
    if (not WMS.tblContains(armes.blanches, wep)) then return end
    local total_death, partial_death, hemorrhage = WMS.GenericDamage(dmg,
    {total = 0, partial = 0, hemo = 0},
    {total = 0, partial = 0, hemo = 0},
    {total = 5, partial = 7, hemo = 90})
end

WMS.HitgroupHandler = function(ply, dmginfo)
    dmg = ply.wms_dmg_tbl[#ply.wms_dmg_tbl]
    PrintC(dmg, 8, "27")

    if (not dmg.inflictor:IsPlayer()) then -- Cas specifiques (feu, explostion, melée ...)
        local name = dmg.inflictor:GetClass()

        if (dmginfo:IsExplosionDamage()) then
            PrintC("BOOM !!", 8, 202)
            --TODO
            return dmginfo:SetDamage(0)
        end

        if (not WMS.tblContains(armes, name)) then
            table.remove(ply.wms_dmg_tbl)
            PrintC("[WMS] /!\\ ARME/SOURCE DE DÉGATS NON RECONNU /!\\\n\t->Nous annulons donc les dégats", 8, 196)
            return dmginfo:SetDamage(0)
        end
    end

    if (dmg.hit_grp == HITGROUP_GENERIC or WMS.tblContains(armes.blanches, dmg.inflictor:GetClass())) then
        PrintC("SPLOUTCH !!", 8, 52)
        WMS.MeleeDamage(dmg)
    elseif (dmg.hit_grp == HITGROUP_HEAD) then
        WMS.HeadDamage(dmg)
    elseif (dmg.hit_grp == HITGROUP_CHEST) then
        WMS.TorsoDamage(dmg)
    elseif (dmg.hit_grp == HITGROUP_STOMACH) then
        WMS.StomachDamage(dmg)
    elseif (dmg.hit_grp == HITGROUP_LEFTLEG or dmg.hit_grp == HITGROUP_RIGHTLEG) then
        WMS.LegDamage(dmg)
    elseif (dmg.hit_grp == HITGROUP_LEFTARM or dmg.hit_grp == HITGROUP_RIGHTARM) then
        WMS.ArmDamage(dmg)
    end

    return dmginfo:SetDamage(0)
end

hook.Add("EntityTakeDamage", "wms_damage_hook", WMS.DamageHook)
hook.Add("PlayerInitialSpawn", "wms_init", WMS.Init)
hook.Add("PlayerDeath", "wms_death_hook", WMS.DeathHook)