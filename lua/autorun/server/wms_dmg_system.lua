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

function WMS.Init()
    print("INIT")
    for _, ply in pairs(player.GetAll()) do ply.wms_dmg_tbl = {} end
end

function WMS.RegisterDamage(ply, hitgroup, dmgi)
    local dmg = {}
    dmg.pos = dmgi:GetDamagePosition()
    dmg.attacker = dmgi:GetAttacker()
    dmg.inflictor = dmgi:GetInflictor()
    dmg.damage = dmgi:GetDamage()
    dmg.type = dmgi:GetDamageType()
    dmg.ammo_id = dmgi:GetAmmoType()
    dmg.ammo = {data = game.GetAmmoData(dmg.ammo_id), name = game.GetAmmoName(dmg.ammo_id)}
    dmg.ht_grp = hitgroup
    dmg.victim = ply


    PrintTable(dmg)
    -- local PelvisIndx = ply:LookupBone("ValveBiped.Bip01_Pelvis")
    -- if (PelvisIndx == nil) then return dmgi end --Maybe Hitgroup still works, need testing
    -- local PelvisPos = ply:GetBonePosition( PelvisIndx )
    -- local NutsDistance = dmgpos:Distance(PelvisPos)

    -- local LHandIndex = ply:LookupBone("ValveBiped.Bip01_L_Hand")
    -- local LHandPos = ply:GetBonePosition( LHandIndex )
    -- local LHandDistance = dmgpos:Distance(LHandPos)

    -- local RHandIndex = ply:LookupBone("ValveBiped.Bip01_R_Hand")
    -- local RHandPos = ply:GetBonePosition(RHandIndex)
    -- local RHandDistance = dmgpos:Distance(RHandPos)

    -- if (NutsDistance <= 7 && NutsDistance >= 5) then
    --     hitgroup = HITGROUP_NUTS
    -- elseif (LHandDistance < 6 || RHandDistance < 6 ) then
    --     hitgroup = HITGROUP_HAND
    -- end

    -- if (hitgroup == HITGROUP_HEAD) then
    --     dmgi:ScaleDamage(GetConVar("enhanceddamage_headdamagescale"):GetFloat())
    --     EnhancedDamage.HurtSound(ply, "head")

    -- elseif (hitgroup == HITGROUP_LEFTARM || hitgroup == HITGROUP_RIGHTARM) then
    --     EnhancedDamage.HurtSound(ply, "arm")
    --     dmgi:ScaleDamage(GetConVar("enhanceddamage_armdamagescale"):GetFloat())
    --     EnhancedDamage.DropWeapon(ply,100 - GetConVar("enhanceddamage_armdropchance"):GetInt(),dmgi:GetAttacker())

    -- elseif (hitgroup == HITGROUP_LEFTLEG || hitgroup == HITGROUP_RIGHTLEG) then
    --     dmgi:ScaleDamage(GetConVar("enhanceddamage_legdamagescale"):GetFloat())
    --     if ply:IsPlayer() and GetConVar("enhanceddamage_legbreak"):GetBool() then
    --         EnhancedDamage.BreakLeg(ply,5)
    -- else
    --     EnhancedDamage.HurtSound(ply, "leg")
    -- end

    -- elseif (hitgroup == HITGROUP_CHEST) then
    --     EnhancedDamage.HurtSound(ply, "generic")
    --     dmgi:ScaleDamage(GetConVar("enhanceddamage_chestdamagescale"):GetFloat())

    -- elseif (hitgroup == HITGROUP_STOMACH) then
    --     EnhancedDamage.HurtSound(ply, "stomach")
    --     dmgi:ScaleDamage(GetConVar("enhanceddamage_stomachdamagescale"):GetFloat())

    -- elseif (hitgroup == HITGROUP_NUTS) then
    --     local SoundsEnabled = GetConVar("enhanceddamage_enablesounds"):GetBool()
    --     if ((EnhancedDamage.GetVoiceType(ply) != "female") and SoundsEnabled) then
    --         dmgi:ScaleDamage(GetConVar("enhanceddamage_nutsdamagescale"):GetFloat())
    --         local sound = Sound("vo/npc/male01/ow01.wav")
    --         ply:EmitSound(sound,500,25)
    --     end
    -- elseif (hitgroup == HITGROUP_HAND) then
    --     EnhancedDamage.HurtSound(ply, "arm")
    --     dmgi:ScaleDamage(GetConVar("enhanceddamage_handdamagescale"):GetFloat())
    --     EnhancedDamage.DropWeapon(ply,100 - GetConVar("enhanceddamage_armdropchance"):GetInt(),dmgi:GetAttacker())
    -- else
    --     EnhancedDamage.HurtSound(ply, "generic")
    -- end
end