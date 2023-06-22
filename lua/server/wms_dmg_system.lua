-- This file contains the functions and hook functions related to parsing the damage info taken by each player
-- how it works :
-- The point is to parse the information given by the EntityTakeDamage hook


WMS = WMS or {}
WMS.DamageSystem = WMS.DamageSystem or {}
WMS.DamageSystem.Hooks = {}

WMS.DamageSystem.isBleedingDmg = function(damages)
    return damages.type == WMS.config.DMG_BLEEDING / 2
end

WMS.DamageSystem.isExplosionDamage = function(damages, damageInfo)
    return damageInfo:isExplosionDamage() or damages.inflictor:GetClass() == "base_shell"
end

WMS.DamageSystem.isVehicleDamage = function(damages)
    return damages.inflictor:IsVehicle() or damages.inflictor:GetClass() == "worldspawn"
end

WMS.DamageSystem.getWeaponType = function(damages)
    
    if (WMS.weapons.cut[damages.weaponClass] or WMS.weapons.cut[damages.inflictor:GetClass()]) then

        return WMS.config.enums.weaponTypes.CUT, "cut"

    elseif (WMS.weapons.pistol[damages.weaponClass]) then

        return WMS.config.enums.weaponTypes.PISTOL, "pistol"

    elseif (WMS.weapons.rifle[damages.weaponClass] or !IsValid(damages.weapon)) then

        return WMS.config.enums.weaponTypes.RIFLE, "rifle"

    elseif (damages.customDamageType == WMS.config.enums.damageTypes.VEHICLE) then

        return 0, "vehicle"

    elseif (!WMS.weapons.rifle[damages.weaponClass]
            and IsValid(damages.weapon) 
            and damages.inflictor:IsPlayer() 
            and !damages.inflictor:InVehicle()) then

        return -1, "UNRECOGNIZED"
    end

    return WMS.config.enums.weaponTypes.RIFLE, "rifle"

end

WMS.DamageSystem.getCustomDamageType = function(damages)

    if (WMS.DamageSystem.isBleedingDmg(damages)) then
        return WMS.config.enums.damageTypes.BLEED
    end
    
    if (WMS.weapons.noDamage[damages.inflictor:GetClass()]) then
        return WMS.config.enums.damageTypes.NO_DAMAGE
    end

    if (damageInfo:IsFallDamage()) then
        return WMS.config.enums.damageTypes.FALL
    end

    if (WMS.DamageSystem.isExplosionDamage(damages, damageInfo)) then
        return WMS.config.enums.damageTypes.EXPLOSION
    end
    
    if (WMS.DamageSystem.isVehicleDamage(damages)) then
        return WMS.config.enums.damageTypes.VEHICLE
    end

    if (damages.attacker:IsPlayer()) then
        return WMS.config.enums.damageTypes.NORMAL
    end

    if (IsValid(damages.weapon)) then

        if (!WMS.weapons[damages.weaponClass]) then
            return WMS.config.enums.damageTypes.NO_DAMAGE
        end

    end

    return WMS.config.enums.damageTypes.NORMAL

end

WMS.DamageSystem.getDamageArea = function(damages)

    local chance = math.random(100)

    if ((damages.hitGroup == HITGROUP_CHEST 
        or damages.customDamageType == WMS.config.enums.damageTypes.VEHICLE 
        or !IsValid(damages.weapon))
        and (!WMS.weapons.cut[damages.inflictor:GetClass()])) then

        if (chance <= WMS.config.chances[WMS.config.enums.damageArea.TORSO].chance) then
            return WMS.config.enums.damageArea.TORSO
        end

        if (chance <= WMS.config.chances[WMS.config.enums.damageArea.TORSO].chance + WMS.config.chances[WMS.config.enums.damageArea.HEART].chance) then
            return WMS.config.enums.damageArea.HEART
        end

        return WMS.config.enums.damageArea.LUNGS

    end

    if (damages.hitGroup == HITGROUP_GENERIC
        or WMS.weapons.cut[damages.inflictor:GetClass()]
        or WMS.weapons.cut[damages.weapon]) then

        local sum --int

        for area, pourcentage in ipairs(WMS.config.chances.cut) do

            sum = sum + pourcentage
            if (chance <= sum) then
                return area
            end

        end

    end
    
    if (damages.hitGroup == HITGROUP_HEAD) then

        if (chance <= WMS.config.chances[WMS.config.enums.damageArea.SKULL].chance) then
            return WMS.config.enums.damageArea.SKULL
        end
        
        if (chance <= WMS.config.chances[WMS.config.enums.damageArea.SKULL].chance 
            + WMS.config.chances[WMS.config.enums.damageArea.FACE].chance) then

            return WMS.config.enums.damageArea.FACE

        end

        return WMS.config.enums.damageArea.NECK
        --print("sound")
        -- local sound_ = WMS.sounds.headshotSounds[math.random(#WMS.sounds.headshotSounds)]
        -- for i = 0,10 do player:EmitSound(sound_, 90) end
    end

    if (damages.hitGroup == HITGROUP_STOMACH) then

        if (chance <= WMS.config.chances[WMS.config.enums.damageArea.STOMACH].chance) then
            return WMS.config.enums.damageArea.STOMACH
        end
        
        return WMS.config.enums.damageArea.LIVER

    end

    if (damages.hitGroup == HITGROUP_LEFTLEG or damages.hitGroup == HITGROUP_RIGHTLEG) then

        if (chance <= WMS.config.chances[WMS.config.enums.damageArea.LEG].chance) then
            return WMS.config.enums.damageArea.LEG
        end
        
        return WMS.config.enums.damageArea.FOOT

    end

    if (damages.hitGroup == HITGROUP_LEFTARM or damages.hitGroup == HITGROUP_RIGHTARM) then

        if (chance <= WMS.config.chances[WMS.config.enums.damageArea.ARM].chance) then
            return WMS.config.enums.damageArea.ARM
        end
        
        return WMS.config.enums.damageArea.HAND

    end

    return -1

end

WMS.DamageSystem.getDamageTable = function(damages)

    local finalDamages = {}

    finalDamages.totalDeath = false
    finalDamages.partialDeath = false
    finalDamages.hemorrhage = false

    finalDamages.damageAmount = 0

    if (damages.area > 0 and damages.weaponType > 0) then
        finalDamages.totalDeath   = math.random(100) <= WMS.config.chances[damages.area][damages.weaponType].total
        finalDamages.partialDeath = math.random(100) <= WMS.config.chances[damages.area][damages.weaponType].partial
        finalDamages.hemorrhage    = math.random(100) <= WMS.config.chances[damages.area][damages.weaponType].hemorrhage

        local range = WMS.config.chances[damages.area][damages.weaponType].dmgRange
        finalDamages.damageAmount = math.random(range[1], range[2])
    end

    if (damages.customDamageType == WMS.config.enums.damageTypes.FALL) then
        finalDamages.totalDeath = false
    end

    if (player:Health() - finalDamages.damageAmount <= 0) then
        finalDamages.totalDeath = true
        finalDamages.partialDeath = true
    end

    if (player:Health() - finalDamages.damageAmount <= 30) then
        finalDamages.limp = true
    end

    if (damages.customDamageType == WMS.config.enums.damageTypes.VEHICLE 
        or damages.customDamageType == WMS.config.enums.damageTypes.FALL) then

        finalDamages.hemorrhage = false 

    end

    local explosionByDeathCondition = damages.customDamageType == WMS.config.enums.damageTypes.EXPLOSION and damages.damageAmount >= 70

    if (explosionByDeathCondition) then 
        finalDamages.totalDeath = true 
    end

    finalDamages.customDamageType = damages.customDamageType
    finalDamages.verboseWeapon = damages.verboseWeapon
    finalDamages.hitGroup = damages.hitGroup


    if (damages.area == WMS.config.enums.damageArea.LEG or
        damages.customDamageType == WMS.config.enums.damageTypes.VEHICLE or
        damages.customDamageType == WMS.config.enums.damageTypes.FALL or
        finalDamages.damageAmount >= 70) then

        finalDamages.limp = true

    end

    finalDamages.brokenRightArm = false
    finalDamages.brokenLeftArm = false
    if (damages.area == WMS.config.enums.damageArea.ARM) then

        if (damages.hitGroup == HITGROUP_RIGHTARM) then
            finalDamages.brokenRightArm = true
        else
            finalDamages.brokenLeftArm = true
        end

    end

    if (damages.customDamageType == WMS.config.enums.damageTypes.FALL) then
        finalDamages.verboseWeapon = nil
    end

    if (damages.victim == damages.inflictor) then
        finalDamages.customDamageType = WMS.config.enums.damageTypes.NO_DAMAGE
    end

    finalDamages.area = damages.area

    if (WMS.DEBUG) then
        PrintC(finalDamages, 8, 27)
        PrintC(damages, 8, 33)

        PrintTable(damages)
        table.Empty(damages)
    end
    
    return finalDamages
end

WMS.DamageSystem.registerDamage = function(player, damageInfo)

    local damages = {}

    damages.victim = player

    damages.attacker = damageInfo:GetAttacker()
    damages.inflictor = damageInfo:GetInflictor()

    if (!IsValid(damages.inflictor)) then 
        damages.inflictor = damages.attacker 
    end

    damages.hitGroup = player:LastHitGroup()
    --damages.verboseHitGroup = WMS.HIT[damages.hitGroup]

    damages.damageAmount = damageInfo:GetDamage()

    damages.type = damageInfo:GetDamageType()

    damages.totalDeath = false
    damages.partialDeath = false
    damages.hemorrhage = false

    damages.weapon = nil

    local damageOriginEntity

    if (damages.attacker:IsPlayer()) then
        damageOriginEntity = damages.attacker

    elseif (damages.inflictor:IsPlayer()) then
        damageOriginEntity = damages.inflictor
    end

    if (IsValid(damageOriginEntity)) then
        
        damages.weapon = damageOriginEntity:GetActiveWeapon()

        if (IsValid(damages.weapon)) then 
            damages.weaponClass = damages.weapon:GetClass() 
        end

    end

    damages.customDamageType = WMS.DamageSystem.getCustomDamageType(damages)

    if (WMS.DamageSystem.isBleedingDmg(damages)) then
        damages.hemorrhage = true
        return damages
    end
    
    damages.verboseWeapon, damages.weaponType = WMS.DamageSystem.getWeaponType(damages)

    damages.area = WMS.DamageSystem.getDamageArea(damages)
    damages.verboseHitGroup = WMS.config.human.damageArea[damages.area]

    return WMS.DamageSystem.getDamageTable(damages)
end

WMS.DamageSystem.damageApplier = function(player, damages)
    if (!player:Alive()) then return end

    if (damages.customDamageType == WMS.config.enums.damageTypes.NO_DAMAGE) then
        player.damagesTable[#player.damagesTable + 1] = table.Copy(damages)
        WMS.utils.syncDmgTbl(player, table.Copy(player.damagesTable))
        return 0
    end
    if (damages.totalDeath) then
        if (WMS.DEBUG) then PrintC("FINITO PIPO", 8, 1) end

        if (!WMS.config.NO_DMG) then
            player:Kill()
        end

        return 0

    elseif (damages.partialDeath) then
        if (WMS.DEBUG) then PrintC("FINITO", 8, 202) end

        if (!WMS.config.NO_DMG) then
            player:PartialDeath()
        end

        player.damagesTable[#player.damagesTable + 1] = table.Copy(damages)
        WMS.utils.syncDmgTbl(player, table.Copy(player.damagesTable))
        return 0

    elseif (damages.hemorrhage and !player:GetNWBool("isBleeding")) then
        if (WMS.DEBUG) then PrintC("\tOOF Sègne", 8, 9) end

        if (!WMS.config.NO_DMG) then
            player:SetBleeding(true, WMS.config.hemoSpeed, WMS.config.hemoImportance)
        end

    elseif (damages.limp) then
        player:LegFracture()

    elseif (damages.brokenRightArm) then
        player:RightArmFracture()

    elseif (damages.brokenLeftArm) then
        player:LeftArmFracture()
    end


    player.damagesTable[#player.damagesTable + 1] = table.Copy(damages)
    WMS.utils.syncDmgTbl(player, table.Copy(player.damagesTable))

    return damages.damageAmount
end
--util.ScreenShake(Vector(0, 0, 0), 300, 0.1, 30, 50000)


do -- PLAYER FUNCTIONS
    --BLEEDING
    local PLAYER = FindMetaTable("Player")

    function PLAYER:StartHemorrhage(speed, importance)

        if (!self:GetNWBool("isBleeding")) then return end

        timer.Create("Hemo_"..self:EntIndex(), speed, 0, function()

            if (!IsValid(self) or !self:Alive()) then return end

            local d = DamageInfo()
            d:SetDamage(importance)
            d:SetDamageType(WMS.config.DMG_BLEEDING)

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

            self:TakeDamageInfo(d)

            if self:Health() <= 0 and self:Alive() then
                self:Kill()
            end

        end)

    end

    function PLAYER:SetBleeding(isBleeding, ...)

        self:SetNWBool("isBleeding", isBleeding)

        if (isBleeding) then
            local args = {...}
            self:StartHemorrhage(args[1], args[2])
            --                   speed    importrance
        else
            timer.Remove("Hemo_"..self:EntIndex())
        end

    end

    do -- Partial Death
        function PLAYER:PartialDeath()

            if (self:GetNWBool("isPartiallyDead")) then return end

            self:SetNWBool("isPartiallyDead", true)
            self:SetNWBool("isDragged", false)

            self:CreateRagdoll()

            self:StripWeapons()

            self:SetNWInt("pulse", math.random(3, 20))
            self:SetNWInt("partialDeathTimer", CurTime())

            timer.Simple(WMS.config.partialDeathTime, function()
                if (!self:GetCreator():GetNWBool("isPartiallyDead")) then return end
                self:Kill()
            end)

        end

        function PLAYER:Revive()

            if (!self:GetNWBool("isPartiallyDead")) then return end
            self:SetNWBool("isPartiallyDead", false)

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

            self.damagesTable = table.Copy(rag.damagesTable)

        end

        hook.Add("PlayerSpawnObject", "WMS::PreventPropSpawnOnDeath", function(player)
            if (player:GetNWBool("isPartiallyDead")) then return false end
        end)

        hook.Add("CanPlayerSuicide", "WMS::PreventSuicide", function(player)
            if (player:GetNWBool("isPartiallyDead")) then return false end
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

        WMS.DamageSystem.Hooks.LegHit = function(player)
            return !player:GetNWBool("isLimp")
        end

        hook.Add("prone.CanExit", "WMS::PreventGettingUpOnLimp", WMS.DamageSystem.Hooks.LegHit)


        -- ARMS
        function PLAYER:RightArmFracture()

            if (self:GetNWBool("rightArmFracture")) then return end
            
            self:SetNWBool("rightArmFracture", true)

            local weapon = self:GetActiveWeapon()

            if (!IsValid(weapon)) then return end

            if (WMS.weapons.rifle[weapon:GetClass()] or

                WMS.weapons.pistol[weapon:GetClass()] or
                WMS.weapons.cut[weapon:GetClass()]) then
                self:DropWeapon(weapon)

            end

        end

        function PLAYER:LeftArmFracture()
            
            if (self:GetNWBool("leftArmFracture")) then return end
            self:SetNWBool("leftArmFracture", true)

            local weapon = self:GetActiveWeapon()
            if (WMS.weapons.rifle[weapon:GetClass()] 
                or WMS.weapons.pistol[weapon:GetClass()] 
                or WMS.weapons.cut[weapon:GetClass()]
                and !WMS.weapons.oneArm[weapon:GetClass()]) then

                self:DropWeapon(weapon)

            end

        end

        function PLAYER:HealRightArmFracture()
            if (!self:GetNWBool("rightArmFracture")) then return end

            self:SetNWBool("rightArmFracture", false)
        end

        function PLAYER:HealLeftArmFracture()
            if (!self:GetNWBool("leftArmFracture")) then return end

            self:SetNWBool("leftArmFracture", false)
        end

        WMS.DamageSystem.Hooks.ArmDamage = function(player, oldWep, newWep)

            if (player:Alive() and player:Health() <= 30) then
                player:SetActiveWeapon(player:Give("re_hands"))
                return true
            end

            if (player:GetNWBool("rightArmFracture")) then return true end
            if (!player:GetNWBool("leftArmFracture")) then return false end

            if (WMS.weapons.oneArm[weapon:GetClass()]) then
                return false
            end

        end

        hook.Add("PlayerSwitchWeapon", "WMS::LeftArmBroke", WMS.DamageSystem.Hooks.ArmDamage)
    end
end


-- HOOKS
WMS.DamageSystem.Hooks.Init = function(player, trans)

    hook.Call("CalcView")
    player:UnSpectate()

    PrintC(player:SteamID().."[WMS] Player Damage table initialized !", 8, "112")
    
    player.damagesTable = {}

    WMS.utils.syncDmgTbl(player, player.damagesTable)

    player:SetNWInt("pulse", math.random(70, 90))

    player:SetNWInt("partialDeathTimer", -1)
    player:SetNWBool("isPartiallyDead", false)
    player:SetNWBool("isDragged", false)

    player:SetNWBool("isLimp", false)
    player:SetNWBool("rightArmFracture", false)
    player:SetNWBool("leftArmFracture", false)

end

WMS.DamageSystem.Hooks.Death = function(victim, inflictor, attacker)

    if (victim:Alive()) then return end

    if (victim:GetNWBool("isPartiallyDead")) then 
        victim:RemoveRagdoll() 
    end

    if (victim:GetNWBool("isBleeding")) then
        timer.Remove("Hemo_"..victim:EntIndex())
        victim:SetBleeding(false)
    end

    local rag = victim:Create_Untied_Ragdoll()

    timer.Simple(WMS.config.corpsDeleteTime, function()
        if (IsValid(rag)) then 
            rag:Remove() 
        end
    end)


    PrintC("[WMS] Player Damage table Deleted !", 8, "1")
    WMS.DamageSystem.Hooks.Init(victim, false)
    -- hook.Call("CalcView") -- not sure about that
end

WMS.DamageSystem.Hooks.damageAmount = function(target, damageInfo)
    
    if (target:IsPlayerRagdoll() and target:GetCreator():GetNWBool("isPartiallyDead")) then
        
        if (damageInfo:GetDamage() > 10) then
            target:GetCreator():Kill()
        end

        return true

    end

    if (!target:IsPlayer()) then return end
    if (target:HasGodMode()) then return true end

    local damages = WMS.DamageSystem.registerDamage(target, damageInfo)
    damageInfo:SetDamage(WMS.DamageSystem.damageApplier(target, damages) or 0)

    if (WMS.config.NO_DMG) then
        damageInfo:SetDamage(0)
    end

end

WMS.DamageSystem.Hooks.Disconnect = function(player)
    player.damagesTable = nil
end



hook.Add("EntityTakeDamage", "WMS::DamageHook", WMS.DamageSystem.Hooks.damageAmount)
hook.Add("PlayerDisconnected", "WMS::ResetOnDisconnect", WMS.DamageSystem.Hooks.Disconnect)
hook.Add("PlayerInitialSpawn", "WMS::Init", WMS.DamageSystem.Hooks.Init)
hook.Add("PlayerDeath", "WMS::DeathHook", WMS.DamageSystem.Hooks.Death)
hook.Add("PlayerDeathSound", "WMS::DeathSOund", function(player) return true end)