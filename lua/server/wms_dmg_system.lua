WMS = WMS or {}
WMS.DamageSystem = WMS.DamageSystem or {}
WMS.DamageSystem.Hooks = {}

WMS.DamageSystem.IsBleedingDmg = function(dmg)
    return dmg.type == WMS.config.DMG_BLEEDING / 2
end

WMS.DamageSystem.IsExplosionDamage = function(dmg, dmgi)
    return dmgi:IsExplosionDamage() or dmg.inflictor:GetClass() == "base_shell"
end

WMS.DamageSystem.IsVehicleDamage = function(dmg)
    return dmg.inflictor:IsVehicle() or dmg.inflictor:GetClass() == "worldspawn"
end


WMS.DamageSystem.RegisterDamage = function(ply, dmgi)
    local dmg = {}

    dmg.victim = ply

    dmg.attacker = dmgi:GetAttacker()

    dmg.inflictor = dmgi:GetInflictor()
    if (!IsValid(dmg.inflictor)) then dmg.inflictor = dmg.attacker end

    dmg.hit_grp = ply:LastHitGroup()
    --dmg.h_hit_grp = WMS.HIT[dmg.hit_grp]

    dmg.damage = dmgi:GetDamage()

    dmg.type = dmgi:GetDamageType()

    dmg.total_death = false
    dmg.partial_death = false
    dmg.hemorrhage = false

    dmg.wep = nil
    if (dmg.attacker:IsPlayer()) then
        dmg.wep = dmg.attacker:GetActiveWeapon()
        if (IsValid(dmg.wep)) then dmg.wep_class = dmg.wep:GetClass() end
    elseif (dmg.inflictor:IsPlayer()) then
        dmg.wep = dmg.inflictor:GetActiveWeapon()
        if (IsValid(dmg.wep)) then dmg.wep_class = dmg.wep:GetClass() end
    end

    -- dmg type
    dmg.wms_type = WMS.config.enums.dmgTypes.NORMAL

    if (WMS.DamageSystem.IsBleedingDmg(dmg)) then
        dmg.wms_type = WMS.config.enums.dmgTypes.BLEED
        dmg.hemorrhage = true
        return dmg

    elseif (WMS.weapons.noDamage[dmg.inflictor:GetClass()]) then
        dmg.wms_type = WMS.config.enums.dmgTypes.NO_DAMAGE

    elseif (dmgi:IsFallDamage()) then
        dmg.wms_type = WMS.config.enums.dmgTypes.FALL

    elseif (WMS.DamageSystem.IsExplosionDamage(dmg, dmgi)) then
        dmg.wms_type = WMS.config.enums.dmgTypes.EXPLOSION

    elseif (WMS.DamageSystem.IsVehicleDamage(dmg)) then
        dmg.wms_type = WMS.config.enums.dmgTypes.VEHICLE

    elseif (dmg.attacker:IsPlayer()) then
        dmg.wms_type = WMS.config.enums.dmgTypes.NORMAL

    elseif (IsValid(dmg.wep)) then
        if (!WMS.weapons[dmg.wep_class]) then
            dmg.wms_type = WMS.config.enums.dmgTypes.NO_DAMAGE
        end
    end

    dmg.h_wep = ""
    dmg.wep_type = WMS.config.enums.wepTypes.RIFLE

    if (WMS.weapons.cut[dmg.wep_class] or WMS.weapons.cut[dmg.inflictor:GetClass()]) then
        dmg.wep_type = WMS.config.enums.wepTypes.CUT
        dmg.h_wep = "cut"

    elseif (WMS.weapons.pistol[dmg.wep_class]) then
        dmg.wep_type = WMS.config.enums.wepTypes.PISTOL
        dmg.h_wep = "pistol"

    elseif (WMS.weapons.rifle[dmg.wep_class] or !IsValid(dmg.wep)) then
        dmg.wep_type = WMS.config.enums.wepTypes.RIFLE
        dmg.h_wep = "rifle"

    elseif (dmg.wms_type == WMS.config.enums.dmgTypes.VEHICLE) then
        dmg.h_wep = "vehicle"

    elseif (!WMS.weapons.rifle[dmg.wep_class]) and IsValid(dmg.wep) and dmg.inflictor:IsPlayer() and !dmg.inflictor:InVehicle() then
        dmg.wep_type = -1
        dmg.h_wep = "NON RECONNU"
    end


    dmg.area = -1

    local chance = math.random(100)

    if ((dmg.hit_grp == HITGROUP_CHEST or dmg.wms_type == WMS.config.enums.dmgTypes.VEHICLE or !IsValid(dmg.wep)) and
        (!WMS.weapons.cut[dmg.inflictor:GetClass()])) then

        if (chance <= WMS.config.chances[WMS.config.enums.dmgArea.TORSO].chance) then
            dmg.area = WMS.config.enums.dmgArea.TORSO

        elseif (chance <= WMS.config.chances[WMS.config.enums.dmgArea.TORSO].chance + WMS.config.chances[WMS.config.enums.dmgArea.HEART].chance) then
            dmg.area = WMS.config.enums.dmgArea.HEART

        else
            dmg.area = WMS.config.enums.dmgArea.LUNGS
        end
        dmg.h_hit_grp = WMS.config.human.dmgArea[dmg.area]

    elseif (dmg.hit_grp == HITGROUP_GENERIC or
        WMS.weapons.cut[dmg.inflictor:GetClass()]) or
        WMS.weapons.cut[dmg.wep] then

        local sum = 0

        for area, pourcentage in ipairs(WMS.config.chances.cut) do
            sum = sum + pourcentage
            if (chance <= sum) then
                dmg.area = area
                break
            end
        end
        dmg.h_hit_grp = WMS.config.human.dmgArea[dmg.area]

    elseif (dmg.hit_grp == HITGROUP_HEAD) then
        if (chance <= WMS.config.chances[WMS.config.enums.dmgArea.SKULL].chance) then
            dmg.area = WMS.config.enums.dmgArea.SKULL
        elseif (chance <= WMS.config.chances[WMS.config.enums.dmgArea.SKULL].chance + WMS.config.chances[WMS.config.enums.dmgArea.FACE].chance) then
            dmg.area = WMS.config.enums.dmgArea.FACE
        else
            dmg.area = WMS.config.enums.dmgArea.NECK
        end
        --print("sound")
        local sound_ = WMS.sounds.headshotSounds[math.random(#WMS.sounds.headshotSounds)]

        for i = 0,10 do ply:EmitSound(sound_, 90) end

        dmg.h_hit_grp = WMS.config.human.dmgArea[dmg.area]
    elseif (dmg.hit_grp == HITGROUP_STOMACH) then
        if (chance <= WMS.config.chances[WMS.config.enums.dmgArea.STOMACH].chance) then
            dmg.area = WMS.config.enums.dmgArea.STOMACH
        else
            dmg.area = WMS.config.enums.dmgArea.LIVER
        end
        dmg.h_hit_grp = WMS.config.human.dmgArea[dmg.area]

    elseif (dmg.hit_grp == HITGROUP_LEFTLEG or dmg.hit_grp == HITGROUP_RIGHTLEG) then
        if (chance <= WMS.config.chances[WMS.config.enums.dmgArea.LEG].chance) then
            dmg.area = WMS.config.enums.dmgArea.LEG
        else
            dmg.area = WMS.config.enums.dmgArea.FOOT
        end

    elseif (dmg.hit_grp == HITGROUP_LEFTARM or dmg.hit_grp == HITGROUP_RIGHTARM) then
        if (chance <= WMS.config.chances[WMS.config.enums.dmgArea.ARM].chance) then
            dmg.area = WMS.config.enums.dmgArea.ARM
        else
            dmg.area = WMS.config.enums.dmgArea.HAND
        end
    end

    local death_explosion = dmg.wms_type == WMS.config.enums.dmgTypes.EXPLOSION and dmg.damage >= 70

    local final_dmg = {}

    final_dmg.total_death = false
    final_dmg.partial_death = false
    final_dmg.hemorrhage = false

    final_dmg.damage = 0

    if (dmg.area > 0 and dmg.wep_type > 0) then
        final_dmg.total_death = math.random(100) <= WMS.config.chances[dmg.area][dmg.wep_type].total
        final_dmg.partial_death = math.random(100) <= WMS.config.chances[dmg.area][dmg.wep_type].partial
        final_dmg.hemorrhage = math.random(100) <= WMS.config.chances[dmg.area][dmg.wep_type].hemo

        local range = WMS.config.chances[dmg.area][dmg.wep_type].dmgRange
        final_dmg.damage = math.random(range[1], range[2])
    end

    if (dmg.wms_type == WMS.config.enums.dmgTypes.FALL) then
        final_dmg.total_death = false
    end

    if (ply:Health() - final_dmg.damage <= 0) then
        final_dmg.total_death = true
        final_dmg.partial_death = true
    end

    if (ply:Health() - final_dmg.damage <= 30) then
        final_dmg.limp = true
    end

    if (dmg.wms_type == WMS.config.enums.dmgTypes.VEHICLE or dmg.wms_type == WMS.config.enums.dmgTypes.FALL) then final_dmg.hemorrhage = false end
    if (death_explosion) then final_dmg.total_death = true end


    final_dmg.wms_type = dmg.wms_type
    final_dmg.h_wep = dmg.h_wep
    final_dmg.hit_grp = dmg.hit_grp


    if (dmg.area == WMS.config.enums.dmgArea.LEG or
        dmg.wms_type == WMS.config.enums.dmgTypes.VEHICLE or
        dmg.wms_type == WMS.config.enums.dmgTypes.FALL or
        final_dmg.damage >= 70) then

        final_dmg.limp = true
    end

    final_dmg.broken_r_arm = false
    final_dmg.broken_l_arm = false
    if (dmg.area == WMS.config.enums.dmgArea.ARM) then
        if (dmg.hit_grp == HITGROUP_RIGHTARM) then
            final_dmg.broken_r_arm = true
        else
            final_dmg.broken_l_arm = true
        end
    end

    if (dmg.wms_type == WMS.config.enums.dmgTypes.FALL) then
        final_dmg.h_wep = nil
    end

    if (dmg.victim == dmg.inflictor) then
        final_dmg.wms_type = WMS.config.enums.dmgTypes.NO_DAMAGE
    end

    final_dmg.area = dmg.area


    if (WMS.DEBUG) then
        PrintC(final_dmg, 8, 27)
        PrintC(dmg, 8, 33)
    end
    PrintTable(dmg)
    table.Empty(dmg)

    return final_dmg
end

WMS.DamageSystem.DamageApplier = function(ply, dmg)
    if (!ply:Alive()) then return end

    if (dmg.wms_type == WMS.config.enums.dmgTypes.NO_DAMAGE) then
        ply.wms_dmg_tbl[#ply.wms_dmg_tbl + 1] = table.Copy(dmg)
        WMS.utils.syncDmgTbl(ply, table.Copy(ply.wms_dmg_tbl))
        return 0
    end
    if (dmg.total_death) then
        if (WMS.DEBUG) then PrintC("FINITO PIPO", 8, 1) end

        if (!WMS.config.NO_DMG) then
            ply:Kill()
        end

        return 0

    elseif (dmg.partial_death) then
        if (WMS.DEBUG) then PrintC("FINITO", 8, 202) end

        if (!WMS.config.NO_DMG) then
            ply:PartialDeath()
        end

        ply.wms_dmg_tbl[#ply.wms_dmg_tbl + 1] = table.Copy(dmg)
        WMS.utils.syncDmgTbl(ply, table.Copy(ply.wms_dmg_tbl))
        return 0

    elseif (dmg.hemorrhage and !ply:GetNWBool("hemo")) then
        if (WMS.DEBUG) then PrintC("\tOOF Sègne", 8, 9) end

        if (!WMS.config.NO_DMG) then
            ply:SetBleeding(true, WMS.config.hemoSpeed, WMS.config.hemoImportance)
        end

    elseif (dmg.limp) then
        ply:LegFracture()

    elseif (dmg.broken_r_arm) then
        ply:RightArmFracture()

    elseif (dmg.broken_l_arm) then
        ply:LeftArmFracture()
    end


    ply.wms_dmg_tbl[#ply.wms_dmg_tbl + 1] = table.Copy(dmg)
    WMS.utils.syncDmgTbl(ply, table.Copy(ply.wms_dmg_tbl))

    return dmg.damage
end
--util.ScreenShake( Vector(0, 0, 0), 300, 0.1, 30, 50000 )


do -- PLAYER FUNCTIONS
    --BLEEDING
    local PLAYER = FindMetaTable("Player")

    function PLAYER:StartHemorrhage(speed, importance)
        if (!self:GetNWBool("hemo")) then return end
        timer.Create("Hemo_" .. self:EntIndex(), speed, 0, function()
            if !IsValid( self ) or !self:Alive() then return end

            local d = DamageInfo()
            d:SetDamage( importance )
            d:SetDamageType( WMS.config.DMG_BLEEDING )

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
            self:SetNWBool("isDragged", false)

            self:CreateRagdoll()

            self:StripWeapons()

            self:SetNWInt("pulse", math.random(3, 20))
            self:SetNWInt("partialDeathTimer", CurTime())
            timer.Simple(WMS.config.partialDeathTime, function()
                if (!self:GetCreator():GetNWBool("isPartialDead")) then return end
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

            for k,v in pairs(rag.ammo) do
                self:GiveAmmo(k, v)
            end

            self:SelectWeapon(rag.ActiveWeapon)

            self.wms_dmg_tbl = table.Copy(rag.wms_dmg_tbl)
        end

        hook.Add("PlayerSpawnObject", "WMS::PreventPropSpawnOnDeath", function(ply)
            if (ply:GetNWBool("isPartialDead")) then return false end
        end)

        hook.Add("CanPlayerSuicide", "WMS::PreventSuicide", function(ply)
            if (ply:GetNWBool("isPartialDead")) then return false end
        end)
    end

    do -- Limb Damage (handicaps)
        function PLAYER:LegFracture()
            if (self:GetNWBool("isLimp")) then return end
            self:SetNWBool("isLimp", true)

            self:SetRunSpeed(WMS.config.fractureRunSpeed)
            self:SetWalkSpeed(WMS.config.fractureWalkSpeed)

            prone.Enter(self)
        end

        function PLAYER:HealLegFracture()
            if (!self:GetNWBool("isLimp")) then return end
            self:SetNWBool("isLimp", false)

            self:SetRunSpeed(WMS.config.defaultRunSpeed)
            self:SetWalkSpeed(WMS.config.defaultWalkSpeed)
        end

        WMS.DamageSystem.Hooks.LegHit = function(ply)
            return !ply:GetNWBool("isLimp")
        end

        hook.Add("prone.CanExit", "WMS::PreventGettingUpOnLimp", WMS.DamageSystem.Hooks.LegHit)


        -- ARMS
        function PLAYER:RightArmFracture()
            if (self:GetNWBool("rightArmFracture")) then return end
            self:SetNWBool("rightArmFracture", true)

            local wep = self:GetActiveWeapon()

            if (!IsValid(wep)) then return end
            if (WMS.weapons.rifle[wep:GetClass()] or
                WMS.weapons.pistol[wep:GetClass()] or
                WMS.weapons.cut[wep:GetClass()]) then
                self:DropWeapon(wep)
            end
        end

        function PLAYER:LeftArmFracture()
            if (self:GetNWBool("leftArmFracture")) then return end
            self:SetNWBool("leftArmFracture", true)

            local wep = self:GetActiveWeapon()
            if (WMS.weapons.rifle[wep:GetClass()] or
                WMS.weapons.pistol[wep:GetClass()] or
                WMS.weapons.cut[wep:GetClass()] and
                !WMS.weapons.oneArm[wep:GetClass()]) then
                self:DropWeapon(wep)
            end
        end

        function PLAYER:HealRightArmFracture()
            if (!self:GetNWBool("rightArmFracture")) then return end

            self:SetNWBool("rightArmFracture", false)
        end

        function PLAYER:HealLeftArmFracture()
            if (!self:GetNWBool("LefttArmFracture")) then return end

            self:SetNWBool("LefttArmFracture", false)
        end

        WMS.DamageSystem.Hooks.ArmDamage = function(ply, oldWep, newWep)
            if (ply:Alive() and ply:Health() <= 30) then
                ply:SetActiveWeapon(ply:Give("re_hands"))
                return true
            end
            if (ply:GetNWBool("rightArmFracture")) then return true end



            if (!ply:GetNWBool("leftArmFracture")) then return false end
            if (WMS.weapons.oneArm[wep:GetClass()]) then
                return false
            end
        end

        hook.Add("PlayerSwitchWeapon", "WMS::LeftArmBroke", WMS.DamageSystem.Hooks.ArmDamage)
    end
end



-- HOOKS
WMS.DamageSystem.Hooks.Init = function(ply, trans)
    hook.Call( "CalcView" )

    ply:UnSpectate()
    PrintC(ply:SteamID() .. "[WMS] Player Damage table initialized !", 8, "112")
    ply.wms_dmg_tbl = {}

    WMS.utils.syncDmgTbl(ply, ply.wms_dmg_tbl)

    ply:SetNWInt("pulse", math.random(70, 90))

    ply:SetNWInt("partialDeathTimer", -1)
    ply:SetNWBool("isPartialDead", false)
    ply:SetNWBool("isDragged", false)

    ply:SetNWBool("isLimp", false)
    ply:SetNWBool("rightArmFracture", false)
    ply:SetNWBool("leftArmFracture", false)

end

WMS.DamageSystem.Hooks.Death = function(victim, inflictor, attacker)
    if (victim:Alive()) then return end

    if (victim:GetNWBool("isPartialDead")) then victim:RemoveRagdoll() end

    if (victim:GetNWBool("hemo")) then
        timer.Remove("Hemo_" .. victim:EntIndex())
        victim:SetBleeding(false)
    end

    local rag = victim:Create_Untied_Ragdoll()
    timer.Simple(WMS.config.corpsDeleteTime, function()
        if (IsValid(rag)) then rag:Remove() end
    end)


    PrintC("[WMS] Player Damage table Deleted !", 8, "1")
    WMS.DamageSystem.Hooks.Init(victim, false)
    -- hook.Call( "CalcView" ) -- not sure about that
end

WMS.DamageSystem.Hooks.Damage = function(target, dmginfo)
    if (target:IsPlayerRagdoll() and target:GetCreator():GetNWBool("isPartialDead")) then
        if (dmginfo:GetDamage() > 10) then
            target:GetCreator():Kill()
        end
        return true
    end

    if (!target:IsPlayer()) then return end
    if (target:HasGodMode()) then return true end

    local dmg = WMS.DamageSystem.RegisterDamage(target, dmginfo)
    dmginfo:SetDamage(WMS.DamageSystem.DamageApplier(target, dmg) or 0)

    if (WMS.config.NO_DMG) then
        dmginfo:SetDamage(0)
    end
end

WMS.DamageSystem.Hooks.Disconnect = function(ply)
    ply.wms_dmg_tbl = nil
end



hook.Add("EntityTakeDamage", "WMS::DamageHook", WMS.DamageSystem.Hooks.Damage)
hook.Add("PlayerDisconnected", "WMS::ResetOnDisconnect", WMS.DamageSystem.Hooks.Disconnect)
hook.Add("PlayerInitialSpawn", "WMS::Init", WMS.DamageSystem.Hooks.Init)
hook.Add("PlayerDeath", "WMS::DeathHook", WMS.DamageSystem.Hooks.Death)
hook.Add("PlayerDeathSound", "WMS::DeathSOund", function(ply) return true end)