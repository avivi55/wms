include("prettyPrint.lua")
local armes = util.JSONToTable(file.Read("armes.json", "GAME"))
--Print(armes) 
local sons = util.JSONToTable(file.Read("sons.json", "GAME"))
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

WMS = WMS or {}

WMS.tblContains = function(tbl, val)
    for k, v in pairs(tbl) do
        if v == val or (type(v) == "table" and WMS.tblContains(v, val)) then return true end
    end
    return false
end

WMS.Init = function(ply, trans)
    PrintC("Player Damage table initialized !", 8, "112")
    ply.wms_dmg_tbl = {}
end

WMS.ClearDmgDataTbl = function()
    for _, ply in pairs(player.GetAll()) do
        ply.wms_dmg_tbl = {}
    end
end

WMS.DeathHook = function(victim, inflictor, attacker)
    PrintC("Player Damage table Deleted !", 8, "1")
    WMS.Init(victim, false)
end


WMS.DamageHook = function(target, dmginfo)
    if (not target:IsPlayer()) then return end
    WMS.RegisterDamage(target, dmginfo)
    dmginfo = WMS.DamageHandler(target, dmginfo)
    --return true
end

WMS.RegisterDamage = function(ply, dmgi)
    local dmg = {}
    dmg.pos = dmgi:GetDamagePosition()
    dmg.victim = ply
    dmg.attacker = dmgi:GetAttacker()
    dmg.inflictor = dmgi:GetInflictor()
    dmg.ht_grp = ply:LastHitGroup()
    dmg.damage = dmgi:GetDamage()
    dmg.type = dmgi:GetDamageType()
    dmg.wep = dmg.attacker:IsPlayer() and dmg.attacker:GetActiveWeapon() or
                dmg.inflictor:IsPlayer() and dmg.inflictor:GetActiveWeapon() or nil
    table.insert(dmg.victim.wms_dmg_tbl, dmg)
end

WMS.DamageHandler = function(ply, dmginfo)
    dmg = ply.wms_dmg_tbl[#ply.wms_dmg_tbl]
    PrintC(dmg, 8, "27")
    if (not dmg.inflictor:IsPlayer()) then -- Cas specifiques (feu, explostion, melée ...)
        local name = dmg.inflictor:GetClass()

        if (dmginfo:IsExplosionDamage()) then
            PrintC("BOOM !!", 8, 202)
            --TODO
            return
        end

        if (string.find(name, "mel")) then
            PrintC("SPLOUTCH !!", 8, 52)
            --TODO
            return
        end

        if (not WMS.tblContains(armes, name)) then
            table.remove(ply.wms_dmg_tbl)
            PrintC("/!\\ ARME/SOURCE DE DÉGATS NON RECONNU /!\\\n\t->Nous annulons donc les dégats", 8, 196)
            return dmginfo:SetDamage(0)
        end
    end


    return dmginfo
end

hook.Add("EntityTakeDamage", "wms_damage_hook", WMS.DamageHook)
hook.Add("PlayerInitialSpawn", "wms_init", WMS.Init)
hook.Add("PlayerDeath", "wms_death_hook", WMS.DeathHook)