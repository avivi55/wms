print()

WMS = WMS or {}
WMS.DamageSystem = WMS.DamageSystem or {}




WMS.DamageSystem.IsBleedingDmg = function(dmg)
    return dmg.type == DMG_BLEEDING / 2
end

WMS.DamageSystem.IsExplosionDamage = function(dmg, dmgI)
    return dmgI:IsExplosionDamage() or dmg.inflictor:GetClass() == "base_shell"
end

WMS.DamageSystem.IsVehicleDamage = function(dmg)
    return dmg.inflictor:IsVehicle() or dmg.inflictor:GetClass() == "worldspawn"
end


WMS.DamageSystem.RegisterDamage = function(ply, dmgi)
    local dmg = {}

    dmg.victim = ply

    dmg.attacker = dmgi:GetAttacker()

    dmg.inflictor = dmgi:GetInflictor()
    if (not IsValid(dmg.inflictor)) then dmg.inflictor = dmg.attacker end

    dmg.hit_grp = ply:LastHitGroup()
    dmg.h_hit_grp = WMS.HIT[dmg.hit_grp]

    dmg.damage = dmgi:GetDamage()

    dmg.type = dmgi:GetDamageType()

    dmg.total_death = false
    dmg.partial_death = false
    dmg.hemorrhage = false

    dmg.wep = nil
    if(dmg.attacker:IsPlayer())then
        dmg.wep = dmg.attacker:GetActiveWeapon()
        if (IsValid(dmg.wep)) then dmg.wep_class = dmg.wep:GetClass() end
    elseif(dmg.inflictor:IsPlayer())then
        dmg.wep = dmg.inflictor:GetActiveWeapon()
        if (IsValid(dmg.wep)) then dmg.wep_class = dmg.wep:GetClass() end
    end 

    -- dmg type
    dmg.wms_type = WMS.DmgTypes.DT_NORMAL

    if (WMS.DamageSystem.IsBleedingDmg(dmg)) then
        dmg.wms_type = WMS.DmgTypes.DT_BLEED

    elseif(WMS.Utils.tblContains(WMS.weapons.no_damage, dmg.inflictor:GetClass()))then
        dmg.wms_type = WMS.DmgTypes.DT_NO_DAMAGE
        
    elseif(dmgi:IsFallDamage())then
        dmg.wms_type = WMS.DmgTypes.DT_FALL
    
    elseif(WMS.DamageSystem.IsExplosionDamage(dmg, dmgi))then
        dmg.wms_type = WMS.DmgTypes.DT_EXPLOSION

    elseif(WMS.DamageSystem.IsVehicleDamage(dmg))then
        dmg.wms_type = WMS.DmgTypes.DT_VEHICLE

    elseif(dmg.attacker:IsPlayer())then
        dmg.wms_type = WMS.DmgTypes.DT_NORMAL

    elseif(IsValid(dmg.wep))then
        if(not WMS.Utils.tblContains(WMS.weapons, dmg.wep_class))then
            dmg.wms_type = WMS.DmgTypes.DT_NO_DAMAGE
        end
    end    

    dmg.h_wep = ""
    dmg.wep_type = WMS.WepTypes.WT_RIFLE

    if (WMS.Utils.tblContains(WMS.weapons.cut, dmg.wep_class) or WMS.Utils.tblContains(WMS.weapons.cut, dmg.inflictor:GetClass())) then
        dmg.wep_type = WMS.WepTypes.WT_CUT
        dmg.h_wep = "Lame"

    elseif (WMS.Utils.tblContains(WMS.weapons.pistol, dmg.wep_class)) then
        dmg.wep_type = WMS.WepTypes.WT_PISTOL
        dmg.h_wep = "Pistolet"

    elseif (WMS.Utils.tblContains(WMS.weapons.rifle, dmg.wep_class) or not IsValid(dmg.wep)) then
        dmg.wep_type = WMS.WepTypes.WT_RIFLE
        dmg.h_wep = "Fusil"
    
    elseif (not WMS.Utils.tblContains(WMS.weapons.rifle, dmg.wep_class) and IsValid(dmg.wep) and dmg.inflictor:IsPlayer() and not dmg.inflictor:InVehicle()) then
        dmg.wep_type = -1
        dmg.h_wep = "NON RECONNU"
    end


    dmg.area = -1

    local chance = math.random(100)

    if ((dmg.hit_grp == HITGROUP_CHEST or dmg.wms_type == WMS.DmgTypes.DT_VEHICLE or not IsValid(dmg.wep)) and 
        (not WMS.Utils.tblContains(WMS.weapons.cut, dmg.inflictor:GetClass()))) then

        if (chance <= WMS.Chances[WMS.DmgArea.DA_TORSO].chance) then
            dmg.area = WMS.DmgArea.DA_TORSO
        elseif(chance <= WMS.Chances[WMS.DmgArea.DA_TORSO].chance + WMS.Chances[WMS.DmgArea.DA_HEART].chance)then
            dmg.area = WMS.DmgArea.DA_HEART
        else
            dmg.area = WMS.DmgArea.DA_LUNGS
        end

    elseif(dmg.hit_grp == HITGROUP_GENERIC or 
        WMS.Utils.tblContains(WMS.weapons.cut, dmg.inflictor:GetClass()) or
        WMS.Utils.tblContains(WMS.weapons.cut, wep)
        )then

        local sum = 0

        for area, pourcentage in ipairs(WMS.Chances.cut) do 
            sum = sum + pourcentage
            if (chance <= sum) then
                dmg.area = area
                break
            end
        end

    elseif (dmg.hit_grp == HITGROUP_HEAD) then
        if (chance <= WMS.Chances[WMS.DmgArea.DA_SKULL].chance) then
            dmg.area = WMS.DmgArea.DA_SKULL
        elseif(chance <= WMS.Chances[WMS.DmgArea.DA_SKULL].chance + WMS.Chances[WMS.DmgArea.DA_FACE].chance)then
            dmg.area = WMS.DmgArea.DA_FACE
        else
            dmg.area = WMS.DmgArea.DA_NECK
        end

    elseif (dmg.hit_grp == HITGROUP_STOMACH) then
        if(chance <= WMS.Chances[WMS.DmgArea.DA_STOMACH].chance)then
            dmg.area = WMS.DmgArea.DA_STOMACH
        else
            dmg.area = WMS.DmgArea.DA_LIVER
        end

    elseif (dmg.hit_grp == HITGROUP_LEFTLEG or dmg.hit_grp == HITGROUP_RIGHTLEG) then
        if(chance <= WMS.Chances[WMS.DmgArea.DA_LEG].chance)then
            dmg.area = WMS.DmgArea.DA_LEG
        else
            dmg.area = WMS.DmgArea.DA_FOOT
        end

    elseif (dmg.hit_grp == HITGROUP_LEFTARM or dmg.hit_grp == HITGROUP_RIGHTARM) then
        if(chance <= WMS.Chances[WMS.DmgArea.DA_ARM].chance)then
            dmg.area = WMS.DmgArea.DA_ARM
        else
            dmg.area = WMS.DmgArea.DA_HAND
        end
    end

    local death_explosion = dmg.wms_type == WMS.DmgTypes.DT_EXPLOSION and dmg.damage >= 70

    local final_dmg = {}

    final_dmg.total_death = false 
    final_dmg.partial_death = false 
    final_dmg.hemorrhage = false 
    final_dmg.damage = 0

    if(dmg.area > 0 and dmg.wep_type > 0)then
        final_dmg.total_death = math.random(100) <= WMS.Chances[dmg.area][dmg.wep_type].total
        final_dmg.partial_death = math.random(100) <= WMS.Chances[dmg.area][dmg.wep_type].partial
        final_dmg.hemorrhage = math.random(100) <= WMS.Chances[dmg.area][dmg.wep_type].hemo

        local range = WMS.Chances[dmg.area][dmg.wep_type].dmgRange
        final_dmg.damage = math.random(range[1], range[2])
    end

    if (ply:Health() - final_dmg.damage <= 0) then
        final_dmg.total_death = true 
    end

    if (dmg.wms_type == WMS.DmgTypes.DT_VEHICLE) then final_dmg.hemorrhage = false end
    if (death_explosion) then final_dmg.total_death = true end
    

    final_dmg.wms_type = dmg.wms_type

    final_dmg.limp = false

    if (dmg.area == WMS.DmgArea.DA_LEG or
        dmg.wms_type == WMS.DmgTypes.DT_VEHICLE or
        final_dmg.damage >= 30) then
        
        final_dmg.limp = true 
    end

    final_dmg.broken_r_arm = false 
    final_dmg.broken_l_arm = false 
    if (dmg.area == WMS.DmgArea.DA_ARM) then
        if (dmg.hit_grp == HITGROUP_RIGHTARM)then
            final_dmg.broken_r_arm = true 
        else
            final_dmg.broken_l_arm = true  
        end
    end


    if (WMS.DEBUG) then
        PrintC(final_dmg, 8, 27)
        PrintC(dmg, 8, 33)
    end

    table.Empty(dmg)
    return final_dmg
end

WMS.DamageSystem.DamageApplier = function(ply, dmg)
    if (dmg.total_death) then
        if (WMS.DEBUG) then PrintC("FINITO PIPO", 8, 1) end
        
        ply:Kill()
        return 0
        
    elseif (dmg.partial_death) then
        if (WMS.DEBUG) then PrintC("FINITO", 8, 202) end

        --ply:PartialDeath()
        return 0

    elseif (dmg.hemorrhage and not ply:GetNWBool("hemo")) then
        if (WMS.DEBUG) then PrintC("\tOOF Sègne", 8, 9) end
        --ply:SetBleeding(true, 5, 1)

    elseif(dmg.limp)then
        --ply:LegFracture()

    elseif(dmg.broken_r_arm)then
        --ply:RightArmFracture()
    
    elseif(dmg.broken_l_arm)then
        --ply:LeftArmFracture()
    
    end


    ply.wms_dmg_tbl[#ply.wms_dmg_tbl] = dmg
    WMS.Utils.syncDmgTbl(ply)

    return dmg.damage
end
--util.ScreenShake( Vector(0, 0, 0), 300, 0.1, 30, 50000 )


do -- PLAYER FUNCTIONS
    --BLEEDING
    local PLAYER = FindMetaTable("Player")

    function PLAYER:StartHemorrhage(speed, importance)
        if (not self:GetNWBool("hemo")) then return end
        timer.Create("Hemo_" .. self:EntIndex(), speed, 0, function()
            if not IsValid( self ) or not self:Alive() then return end
    
            local d = DamageInfo()
            d:SetDamage( importance )
            d:SetDamageType( 4294967296 )
    
            -- bleeding effect
            local bone = self:GetBonePosition(math.random(1, self:GetBoneCount() - 1))
            if bone then
                local ef = EffectData()
                ef:SetOrigin(bone)
                util.Effect("BloodImpact", ef, true, true)
            end
    
            -- bleeding decals
    
            local src = self:LocalToWorld(self:OBBCenter())
            for i = 1, 12 do
                local dir = VectorRand() * self:GetModelRadius() * 1.4
                util.Decal("Blood", src - dir, src + dir)
            end
    
            self:TakeDamageInfo( d )
    
            if self:Health() <= 0 and self:Alive() then
                self:Kill()
            end
        end)
    end

    function PLAYER:SetBleeding(isBleeding, ...)
        self:SetNWBool("hemo", isBleeding)

        if (isBleeding) then
            local args = {...}
            self:StartHemorrhage(args[1], args[2]) 
            --                   speed    importrance
        else
            timer.Remove("Hemo_" .. self:EntIndex())
        end
    end

    do -- Partial Death
        function PLAYER:PartialDeath()
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

        function PLAYER:Revive()
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
        function PLAYER:LegFracture()
            if (self:GetNWBool("isLimp")) then return end
            self:SetNWBool("isLimp", true)

            self:SetRunSpeed(WMS.FractureRunSpeed)
            self:SetWalkSpeed(WMS.FractureWalkSpeed)

            prone.Enter(self)
        end

        function PLAYER:HealLegFracture()
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
        function PLAYER:RightArmFracture()
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

        function PLAYER:LeftArmFracture()
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

        function PLAYER:HealRightArmFracture()       
            if (!self:GetNWBool("RightArmFracture")) then return end
            
            self:SetNWBool("RightArmFracture", false)
        end

        function PLAYER:HealLeftArmFracture()       
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
end

WMS.DamageSystem.Init = function(ply, trans)
    ply:UnSpectate()
    ply:Spectate(OBS_MODE_NONE)
    PrintC(ply:SteamID() .. "[WMS] Player Damage table initialized !", 8, "112")
    ply.wms_dmg_tbl = {}
    
    WMS.Utils.syncDmgTbl(ply)
    
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
        if(IsValid(rag))then rag:Remove() end
    end)

    PrintC("[WMS] Player Damage table Deleted !", 8, "1")
    WMS.DamageSystem.Init(victim, false)
end

WMS.DamageSystem.DamageHook = function(target, dmginfo)
    if (not target:IsPlayer()) then return end
    local dmg = WMS.DamageSystem.RegisterDamage(target, dmginfo)
    dmginfo:SetDamage(WMS.DamageSystem.DamageApplier(target, dmg))
end


hook.Add("EntityTakeDamage", "wms_damage_hook", WMS.DamageSystem.DamageHook)
hook.Add("PlayerInitialSpawn", "wms_init", WMS.DamageSystem.Init)
hook.Add("PlayerDeath", "wms_death_hook", WMS.DamageSystem.DeathHook)
hook.Add("PlayerDeathSound", "wms_death_sound_hook", function(ply) return true end)