print("updated")
WMS = WMS or {}
WMS.DamageSystem = WMS.DamageSystem or {}


WMS.DamageSystem.Init = function(ply, trans)
    PrintC("[WMS] Player Damage table initialized !", 8, "112")
    ply:SetNWInt("Pulse", math.random(70, 90))
    ply:SetBleeding(false)
    ply.wms_dmg_tbl = {}
end

WMS.DamageSystem.ClearAllDmgDataTbl = function()
    for _, ply in pairs(player.GetAll()) do
        ply.wms_dmg_tbl = {}
    end
end

WMS.DamageSystem.DeathHook = function(victim, inflictor, attacker)
    if (victim:GetNWBool("hemo")) then
        timer.Remove("Hemo_" .. victim:EntIndex())
        --victim:SetNWBool("hemo", false )
    end
    PrintC("[WMS] Player Damage table Deleted !", 8, "1")
    WMS.DamageSystem.Init(victim, false)
end

WMS.DamageSystem.DamageHook = function(target, dmginfo)
    if (not target:IsPlayer()) then return end
    print(dmginfo:GetDamage())
    WMS.DamageSystem.RegisterDamage(target, dmginfo)
    dmginfo:SetDamage(WMS.DamageSystem.DamageApplier(target, dmginfo))
    print(dmginfo:GetDamage())
    --return true
end

local HIT = {[0] = "melee", "head", "chest", "stomack", "left_arm", "right_arm", "left_leg", "right_leg"}

WMS.DamageSystem.RegisterDamage = function(ply, dmgi)
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


    if (not IsValid(dmg.inflictor) and dmg.attacker:IsPlayer() and dmg.attacker:InVehicle()) then
        dmg.inflictor = dmg.attacker
        dmg.wep = "vehicle"-- dmg.attacker:GetVehicle()
    end

    table.insert(dmg.victim.wms_dmg_tbl, dmg)
end

WMS.DamageSystem.GenericDamage = function(dmg, rifle, pistol, cut)
    cut = cut or {total = 5, partial = 7, hemo = 90}
    local wep = IsValid(dmg.wep) and dmg.wep:GetClass() or ""
    local total_death = false
    local partial_death = false
    local hemorrhage = false

    if (IsValid(dmg.inflictor) and cut and (WMS.Utils.tblContains(WMS.weapons.cut, wep) or WMS.Utils.tblContains(WMS.weapons.cut, dmg.inflictor:GetClass()))) then
        print("coutal")
        total_death = math.random(100) <= cut.total
        partial_death = math.random(100) <= cut.partial
        hemorrhage = math.random(100) <= cut.hemo
    elseif (WMS.Utils.tblContains(WMS.weapons.pistol, wep)) then
        print("pistolè")
        total_death = math.random(100) <= pistol.total
        partial_death = math.random(100) <= pistol.partial
        hemorrhage = math.random(100) <= pistol.hemo
    elseif (WMS.Utils.tblContains(WMS.weapons.rifle, wep) or not IsValid(dmg.wep)) then
        print("fuzy")
        total_death = math.random(100) <= rifle.total
        partial_death = math.random(100) <= rifle.partial
        hemorrhage = math.random(100) <= rifle.hemo
    end

    --"weapons/crossbow/hitbod1.wav"
    local snd = "physics/metal/metal_box_impact_bullet3.wav"
    --print(snd)
    dmg.attacker:EmitSound(snd)
    timer.Simple(SoundDuration(snd), function() dmg.attacker:EmitSound("weapons/crossbow/hitbod1.wav") end)
    if (total_death) then
        PrintC("FINITO PIPO", 8, 1)
        --dmg.victim:Kill()
    elseif (partial_death) then
        PrintC("FINITO", 8, 202)
        --dmg.victim:Kill()
    else
        PrintC("Abatar t viven", 8, 14)
        if (hemorrhage) then
            PrintC("\tOOF Sègne", 8, 9)
        end
        if (not dmg.victim:IsProne()) then
            prone.Enter(dmg.victim)
        end
    end

    return total_death, partial_death, hemorrhage
end

WMS.DamageSystem.DamageHandler = function(ply, dmginfo)
    local dmg = ply.wms_dmg_tbl[#ply.wms_dmg_tbl]

    no_dmg = dmg
    no_dmg.damage = 0
    PrintC(dmg, 8, "27")

    if (dmg.type == DMG_BLEEDING / 2) then
        table.remove(ply.wms_dmg_tbl)
        PrintC("SEN", 8, 9)
        return dmg

    elseif (IsValid(dmg.inflictor) and WMS.Utils.tblContains(WMS.weapons.no_damage, dmg.inflictor:GetClass())) then
        dmg.victim:SetBleeding(false)
        PrintC("[WMS] DÉGATS ANNULÉS : PROP", 8, 6)
        return no_dmg

    elseif (IsEntity(dmg.inflictor) and (dmginfo:IsFallDamage() or dmg.inflictor:EntIndex() == 0)) then
        PrintC("AÏE !!", 8, 81)
        --TODO
        return no_dmg

    elseif (IsValid(dmg.wep) and not WMS.Utils.tblContains(WMS.weapons, dmg.wep:GetClass())) then
        PrintC("ARME NON RECONNU -> DÉGATS ANNULÉS\nSi vous voulez qu'elle fonctionne, pensez à la rajouter dans 'WMS.weapons.json'", 8, 184)
        return no_dmg

    elseif (not dmg.inflictor:IsPlayer() and IsValid(dmg.inflictor)) then -- Cas specifiques (feu, explostion, melée ...)
        local name = dmg.inflictor:GetClass()

        if (dmginfo:IsExplosionDamage() or name == "base_shell") then
            PrintC("BOOM !!", 8, 202)
            --TODO
            return no_dmg
        end

        if (dmg.inflictor:IsVehicle()) then
            if (dmg.inflictor == dmg.victim:GetVehicle() or dmg.damage <= 10) then return no_dmg end
            PrintC("TUT TUT !!", 8, 211)
            --TODO
            return no_dmg
        end

        if (not WMS.Utils.tblContains(WMS.weapons, name)) then
            table.remove(ply.wms_dmg_tbl)
            Msg("\27[6;1m")
            PrintC("[WMS] /!\\ SOURCE DE DÉGATS NON RECONNU /!\\\n\t->Nous annulons donc les dégats", 8, 196)
            Msg("\27[0mVoici des detailles:")
            PrintC(dmg, 8, "27")
            return no_dmg
        end
    end

    local total_death, partial_death, hemorrhage

    if ((dmg.hit_grp == HITGROUP_CHEST or dmg.wep == "vehicle" or not IsValid(dmg.wep)) and (not IsValid(dmg.inflictor) or not WMS.Utils.tblContains(WMS.weapons.cut, dmg.inflictor:GetClass()))) then
        --TORSO
        total_death, partial_death, hemorrhage = WMS.DamageSystem.GenericDamage(dmg,
            {total = 25, partial = 40, hemo = 37},
            {total = 15, partial = 20, hemo = 35})

    elseif (dmg.hit_grp == HITGROUP_GENERIC or WMS.Utils.tblContains(WMS.weapons.cut, dmg.inflictor:GetClass())) then
        PrintC("SPLOUTCH !!", 8, 52)
        local wep = dmg.inflictor:GetClass()

        if (not WMS.Utils.tblContains(WMS.weapons.cut, wep)) then return end

        total_death, partial_death, hemorrhage = WMS.DamageSystem.GenericDamage(dmg,
            {total = 0, partial = 0, hemo = 0},
            {total = 0, partial = 0, hemo = 0},
            {total = 5, partial = 7, hemo = 90})

    elseif (dmg.hit_grp == HITGROUP_HEAD) then

        total_death, partial_death, hemorrhage = WMS.DamageSystem.GenericDamage(dmg,
            {total = 97, partial = 99, hemo = 0},
            {total = 96, partial = 98, hemo = 0})

    elseif (dmg.hit_grp == HITGROUP_STOMACH) then

        total_death, partial_death, hemorrhage = WMS.DamageSystem.GenericDamage(dmg,
            {total = 10, partial = 20, hemo = 42},
            {total = 7, partial = 10, hemo = 40})

    elseif (dmg.hit_grp == HITGROUP_LEFTLEG or dmg.hit_grp == HITGROUP_RIGHTLEG) then
        total_death, partial_death, hemorrhage = WMS.DamageSystem.GenericDamage(dmg,
            {total = 5, partial = 7, hemo = 34},
            {total = 3, partial = 5, hemo = 30})

    elseif (dmg.hit_grp == HITGROUP_LEFTARM or dmg.hit_grp == HITGROUP_RIGHTARM) then
        total_death, partial_death, hemorrhage = WMS.DamageSystem.GenericDamage(dmg,
            {total = 5, partial = 7, hemo = 15},
            {total = 3, partial = 5, hemo = 10})
    end

    dmg.total_death = total_death
    dmg.partial_death = partial_death
    dmg.hemorrhage = hemorrhage

    return dmg
end


WMS.DamageSystem.DamageApplier = function(ply, dmginfo)
    local dmg_ = WMS.DamageSystem.DamageHandler(ply, dmginfo)

    if (dmg_.total_death) then
        ply:Kill()

    elseif (dmg_.partial_death) then
        ply:Kill()

    elseif (dmg_.hemorrhage and not ply:GetNWBool("hemo")) then
        ply:SetBleeding(true, 5, 1)
    end

    print(dmg_.damage, dmg_.type, dmg_.victim:GetNWBool("hemo"))
    return dmg_.damage
end


--BLEEDING


local meta = FindMetaTable("Player")


function meta:SetBleeding(bool, ...)
    self:SetNWBool("hemo", bool)

    if (bool) then
        local args = {...}
        WMS.DamageSystem.StartHemorrhage(self, args[1], args[2])
    else
        timer.Remove("Hemo_" .. self:EntIndex())
    end
end


WMS.DamageSystem.StartHemorrhage = function(ply, speed, importance)
    if (not ply:GetNWBool("hemo")) then return end
    timer.Create("Hemo_" .. ply:EntIndex(), speed, 0, function()
        if not IsValid( ply ) or not ply:Alive() then return end

        local d = DamageInfo()
        d:SetDamage( importance )
        d:SetDamageType( 4294967296 )

        -- bleeding effect
        local bone = ply:GetBonePosition(math.random(1, ply:GetBoneCount() - 1))
        if bone then
            local ef = EffectData()
            ef:SetOrigin(bone)
            util.Effect("BloodImpact", ef, true, true)
        end

        -- bleeding decals

        local src = ply:LocalToWorld(ply:OBBCenter())
        for i = 1, 12 do
            local dir = VectorRand() * ply:GetModelRadius() * 1.4
            util.Decal("Blood", src - dir, src + dir)
        end

        ply:TakeDamageInfo( d )

        if ply:Health() <= 0 and ply:Alive() then
            ply:Kill()
        end
    end)
end

hook.Add("EntityTakeDamage", "wms_damage_hook", WMS.DamageSystem.DamageHook)
hook.Add("PlayerInitialSpawn", "wms_init", WMS.DamageSystem.Init)
hook.Add("PlayerDeath", "wms_death_hook", WMS.DamageSystem.DeathHook)
hook.Add("PlayerDeathSound", "wms_death_hook", function(ply) return true end)