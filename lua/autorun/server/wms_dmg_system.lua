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

WMS.Init = function(ply, trans)
    print("INIT")
    ply.wms_dmg_tbl = {}
end

WMS.DamageHook = function(target, dmginfo)
    if (not target:IsPlayer()) then return end
    WMS.RegisterDamage(target, dmginfo)
    dmginfo = WMS.DamageHandler(dmginfo)
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

    PrintTable(dmg.victim.wms_dmg_tbl)
end

WMS.DamageHandler = function(ply, dmginfo)
    dmg = ply.wms_dmg_tbl[#ply.wms_dmg_tbl]



    return dmginfo:SetDamage(0)
end

hook.Add("EntityTakeDamage", "wms_damage_hook", WMS.DamageHook)
hook.Add( "PlayerInitialSpawn", "wms_init", WMS.Init)