print("updated")
WMS = WMS or {}
WMS.DamageSystem = WMS.DamageSystem or {}

WMS.HIT = {[0] = "Melée", "Tête", "Buste", "Estomac", "Bras gauche", "Bras droit", "Jambe gauche", "Jambe droite"}

WMS.DamageSystem.RegisterDamage = function(ply, dmgi)
    local dmg = {}
    dmg.pos = dmgi:GetDamagePosition()
    dmg.victim = ply
    dmg.attacker = dmgi:GetAttacker()
    dmg.inflictor = dmgi:GetInflictor()
    dmg.hit_grp = ply:LastHitGroup()
    dmg.h_hit_grp = WMS.HIT[dmg.hit_grp]
    dmg.damage = dmgi:GetDamage()
    dmg.type = dmgi:GetDamageType()
    dmg.wep = dmg.attacker:IsPlayer() and dmg.attacker:GetActiveWeapon() or
              dmg.inflictor:IsPlayer() and dmg.inflictor:GetActiveWeapon() or nil


    if (WMS.DamageSystem.IsVehicleDamage(dmg)) then--not IsValid(dmg.inflictor) and dmg.attacker:IsPlayer() and dmg.attacker:InVehicle()) then
        dmg.inflictor = dmg.attacker
        dmg.wep = "vehicle"
    end

    table.insert(dmg.victim.wms_dmg_tbl, dmg)
    net.Start("send_damage_table_to_client")
        net.WriteEntity(dmg.victim)
        net.WriteTable(dmg.victim.wms_dmg_tbl)
    net.Broadcast()
end

WMS.DamageSystem.GenericDamage = function(dmg, rifle, pistol, cut)
    cut = cut or {total = 5, partial = 7, hemo = 90}
    local wep = IsValid(dmg.wep) and dmg.wep:GetClass() or ""
    local total_death = false
    local partial_death = false
    local hemorrhage = false

    if (IsValid(dmg.inflictor) and cut and (WMS.Utils.tblContains(WMS.weapons.cut, wep) or WMS.Utils.tblContains(WMS.weapons.cut, dmg.inflictor:GetClass()))) then
        print("coutal")
        dmg.h_wep = "Lame"
        total_death = math.random(100) <= cut.total
        partial_death = math.random(100) <= cut.partial
        hemorrhage = math.random(100) <= cut.hemo
    elseif (WMS.Utils.tblContains(WMS.weapons.pistol, wep)) then
        print("pistolè")
        dmg.h_wep = "Pistolet"
        total_death = math.random(100) <= pistol.total
        partial_death = math.random(100) <= pistol.partial
        hemorrhage = math.random(100) <= pistol.hemo
    elseif (WMS.Utils.tblContains(WMS.weapons.rifle, wep) or not IsValid(dmg.wep)) then
        print("fuzy")
        dmg.h_wep = "Fusil"
        total_death = math.random(100) <= rifle.total
        partial_death = math.random(100) <= rifle.partial
        hemorrhage = math.random(100) <= rifle.hemo
    end

    return total_death, partial_death, hemorrhage
end

WMS.DamageSystem.IsBleedingDmg = function(dmg)
    return dmg.type == DMG_BLEEDING / 2
end

WMS.DamageSystem.IsExplosionDamage = function(dmg, dmgI)
    return dmgI:IsExplosionDamage() or (IsValid(dmg.inflictor) and dmg.inflictor:GetClass() == "base_shell")
end

WMS.DamageSystem.IsVehicleDamage = function(dmg)
    return IsValid(dmg.inflictor) and (dmg.inflictor:IsVehicle() or dmg.inflictor:GetClass() == "worldspawn")
end


WMS.DamageSystem.DamageHandler = function(ply, dmginfo)
    local dmg = ply.wms_dmg_tbl[#ply.wms_dmg_tbl]

    no_dmg = table.Copy(dmg)
    no_dmg.damage = 0

    PrintC(dmg, 8, "27")
    PrintC(dmginfo, 8, "28")

    if (WMS.DamageSystem.IsBleedingDmg(dmg)) then
        table.remove(ply.wms_dmg_tbl)
        PrintC("SEN", 8, 9)
        return dmg

    elseif (IsValid(dmg.inflictor) and WMS.Utils.tblContains(WMS.weapons.no_damage, dmg.inflictor:GetClass())) then
        dmg.victim:SetBleeding(false)
        PrintC("[WMS] DÉGATS ANNULÉS : PROP", 8, 6)
        return no_dmg

    elseif (dmginfo:IsFallDamage()) then
        PrintC("AÏE !!", 8, 81)
        ply:SetLastHitGroup(math.random(0,1) and 6 or 7)
        table.remove(ply.wms_dmg_tbl)
        WMS.DamageSystem.RegisterDamage(dmg.victim, dmginfo)
        return dmg

    elseif (WMS.DamageSystem.IsExplosionDamage(dmg, dmginfo)) then
        PrintC("BOOM !!", 8, 202)
        dmg.isExplosion = true
        --TODO
        return dmg

    elseif (WMS.DamageSystem.IsVehicleDamage(dmg)) then
        PrintC("TUT TUT !!", 8, 211)
        dmg.wep = "vehicle"
        if (dmg.inflictor == dmg.victim:GetVehicle() or dmg.damage <= 10) then return no_dmg end
        --TODO
        return no_dmg

    elseif (IsValid(dmg.wep) and not WMS.Utils.tblContains(WMS.weapons, dmg.wep:GetClass())) then
        table.remove(ply.wms_dmg_tbl)
        PrintC("ARME NON RECONNU -> DÉGATS ANNULÉS\nSi vous voulez qu'elle fonctionne, pensez à la rajouter dans 'config/weapons.lua'", 8, 184)
        return no_dmg

    elseif (IsValid(dmg.inflictor) and !dmg.inflictor:IsPlayer()) then
        local name = dmg.inflictor:GetClass()

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

    //return no_dmg
    return dmg
end

WMS.DamageSystem.DamageApplier = function(ply, dmginfo)
    local dmg = WMS.DamageSystem.DamageHandler(ply, dmginfo)
    --ply:PartialDeath()
    --return dmg.damage
    


    if (dmg.total_death) then
        PrintC("FINITO PIPO", 8, 1)
        ply:Kill()
    elseif (dmg.partial_death) then
        PrintC("FINITO", 8, 202)
        ply:PartialDeath()
    elseif (dmg.damage != 0) then
        PrintC("Abatar t viven", 8, 14)
        if (dmg.hemorrhage and not ply:GetNWBool("hemo")) then
            ply:SetBleeding(true, 5, 1)
            PrintC("\tOOF Sègne", 8, 9)
        end

        --print(dmg.type)
        if (not dmg.isExplosion and dmg.type != DMG_BLEEDING / 2) then dmg.damage = math.random(65, 85) end

        if (ply:Health() - dmg.damage <= 0) then
            ply:Kill()
        end
        

        --[[ if (not dmg.victim:IsProne()) then
            prone.Enter(dmg.victim)
        end ]]
    end

    --PrintTable(dmg)
    dmg.victim.wms_dmg_tbl[#dmg.victim.wms_dmg_tbl] = dmg
    net.Start("send_damage_table_to_client")
        net.WriteEntity(dmg.victim)
        net.WriteTable(dmg.victim.wms_dmg_tbl)
    net.Broadcast()

    return dmg.damage
end
--util.ScreenShake( Vector(0, 0, 0), 300, 0.1, 30, 50000 )

--BLEEDING
local meta = FindMetaTable("Player")

function meta:SetBleeding(isBleeding, ...)
    self:SetNWBool("hemo", isBleeding)

    if (isBleeding) then
        local args = {...}
        WMS.DamageSystem.StartHemorrhage(self, args[1], args[2]) 
        --                                     speed    importrance
    else
        timer.Remove("Hemo_" .. self:EntIndex())
    end
end

do -- Partial Death
    function meta:PartialDeath()
        if (self:GetNWBool("isPartialDead")) then return end

        self:SetNWBool("isPartialDead", true)

        self:CreateRagdoll()

        self:StripWeapons()
        
        self:SetNWInt("Pulse", math.random(3, 20))
        self:SetNWInt("Partial_death_timer", CurTime())
        timer.Simple(WMS.PartialDeathTime, function()
            if(not self:GetCreator():GetNWBool("isPartialDead")) then return end
            self:Kill()
        end)
    end

    function meta:Revive()
        if (!self:GetNWBool("isPartialDead")) then return end
        self:SetNWBool("isPartialDead", false)

        self:UnSpectate()
        self:Spawn()
        local rag = self:GetRagdollEntity()
        self:SetPos(rag:GetPos())
        prone.Enter(self)
        self:SetHealth(math.random(7, 16))
        self:RemoveRagdoll()

        for k,v in pairs(rag.Weapons) do
            self:Give(v)
        end

        self:SetActiveWeapon(rag.ActiveWeapon)
    end

    hook.Add("PlayerSpawnObject", "WMS_Partial_Death_spawn_obj", function(ply)
        if (ply:GetNWBool("isPartialDead")) then return false end
    end)
    
    hook.Add("CanPlayerSuicide", "WMS_Partial_Death_suicide", function(ply)
        if (ply:GetNWBool("isPartialDead")) then return false end
    end)
    
    hook.Add("PlayerDeath", "WMS_Partial_Death_remove_ragdoll_death", function(ply)
        if (ply:GetNWBool("isPartialDead")) then ply:RemoveRagdoll() end
    end)
end

do -- Limb Damage (handicaps)
    function meta:LegFracture()
        if (self:GetNWBool("isLimp")) then return end
        self:SetNWBool("isLimp", true)

        self:SetRunSpeed(WMS.FractureRunSpeed)
        self:SetWalkSpeed(WMS.FractureWalkSpeed)

        prone.Enter(self)
    end

    function meta:HealLegFracture()
        if (!self:GetNWBool("isLimp")) then return end
        self:SetNWBool("isLimp", false)

        self:SetRunSpeed(WMS.DefaultRunSpeed)
        self:SetWalkSpeed(WMS.DefaultWalkSpeed)
    end

    WMS.DamageSystem.LegHitHook = function(ply)
        return !ply:GetNWBool("isLimp")
    end

    hook.Add("prone.CanExit", "wms_stop_getting_up", WMS.DamageSystem.LegHitHook)


    -- ARMS
    function meta:RightArmFracture(side)
        if (self:GetNWBool("RightArmFracture")) then return end
        self:SetNWBool("RightArmFracture", true)

        local wep = self:GetActiveWeapon()
        if (WMS.Utils.tblContains(WMS.weapons.rifle, wep:GetClass()) or
            WMS.Utils.tblContains(WMS.weapons.pistol, wep:GetClass()) or
            WMS.Utils.tblContains(WMS.weapons.cut, wep:GetClass())
        ) then
            self:DropWeapon(wep)
        end
    end

    function meta:LeftArmFracture(side)
        if (self:GetNWBool("LeftArmFracture")) then return end
        self:SetNWBool("LeftArmFracture", true)

        local wep = self:GetActiveWeapon()
        if (WMS.Utils.tblContains(WMS.weapons.rifle, wep:GetClass()) or
            WMS.Utils.tblContains(WMS.weapons.pistol, wep:GetClass()) or
            WMS.Utils.tblContains(WMS.weapons.cut, wep:GetClass()) and
            !WMS.Utils.tblContains(WMS.weapons.one_arm, wep:GetClass())
        ) then
            self:DropWeapon(wep)
        end
    end

    function meta:HealRightArmFracture()       
        if (!self:GetNWBool("RightArmFracture")) then return end
        
        self:SetNWBool("RightArmFracture", false)
    end

    function meta:HealLeftArmFracture()       
        if (!self:GetNWBool("LefttArmFracture")) then return end
        
        self:SetNWBool("LefttArmFracture", false)
    end

    WMS.DamageSystem.ArmDamageHook = function(ply, oldWep, newWep)
        if (ply:GetNWBool("RightArmFracture")) then return true end

        if (ply:GetNWBool("LeftArmFracture") ) then
            if(WMS.Utils.tblContains(WMS.weapons.one_arm, wep:GetClass()))then 
                return false
            end
        end
    end

    hook.Add("PlayerSwitchWeapon", "wms_left_arm_broken", WMS.DamageSystem.ArmDamageHook)
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

WMS.DamageSystem.Init = function(ply, trans)
    ply:UnSpectate()
    PrintC(ply:SteamID() .. "[WMS] Player Damage table initialized !", 8, "112")
    ply.wms_dmg_tbl = {}
    
    net.Start("send_damage_table_to_client")
        net.WriteEntity(ply)
        net.WriteTable({})
    net.Broadcast()
    ply:UnSpectate()
    
    ply:SetNWInt("Pulse", math.random(70, 90))
    
    ply:SetNWInt("Partial_death_timer", -1)
    ply:SetNWBool("isPartialDead", false)
    
    ply:SetNWBool("isLimp", false)
    ply:SetNWBool("RightArmFracture", false)
    ply:SetNWBool("LeftArmFracture", false)
end

WMS.DamageSystem.DeathHook = function(victim, inflictor, attacker)
    if (victim:GetNWBool("hemo")) then
        timer.Remove("Hemo_" .. victim:EntIndex())
        victim:SetBleeding(false)
    end

    local rag = victim:Create_Untied_Ragdoll()
    timer.Simple(WMS.CorpsDeleteTime, function()
        rag:Remove()
    end)

    PrintC("[WMS] Player Damage table Deleted !", 8, "1")
    WMS.DamageSystem.Init(victim, false)
end

WMS.DamageSystem.DamageHook = function(target, dmginfo)
    if (not target:IsPlayer()) then return end
    WMS.DamageSystem.RegisterDamage(target, dmginfo)
    dmginfo:SetDamage(WMS.DamageSystem.DamageApplier(target, dmginfo))
    --print(dmginfo:GetDamage())
    --return true
end


hook.Add("EntityTakeDamage", "wms_damage_hook", WMS.DamageSystem.DamageHook)
hook.Add("PlayerInitialSpawn", "wms_init", WMS.DamageSystem.Init)
hook.Add("PlayerDeath", "wms_death_hook", WMS.DamageSystem.DeathHook)
hook.Add("PlayerDeathSound", "wms_death_sound_hook", function(ply) return true end)