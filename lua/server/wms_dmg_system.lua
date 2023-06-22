-- This file contains the functions and hook functions related to parsing the damage info taken by each player
-- how it works :
-- The point is to parse the information given by the EntityTakeDamage hook and only get the generated
-- amount of damage depending on the weapon and the area and luck.


WMS = WMS or {}
WMS.DamageSystem = WMS.DamageSystem or {}
WMS.DamageSystem.Hooks = {}

-- Checks if a parsed damage table is bleeding damage
-- @param damage: table The parsed damage table
-- @returns boolean Whether the damage is bleeding damage
WMS.DamageSystem.isBleedingDmg = function(damage)
    return damage.type == WMS.config.DMG_BLEEDING / 2
end

-- Checks if a parsed damage table is explosion damage
-- @param damage: table The parsed damage table
-- @param damageInfo: CTakeDamageInfo The original damage info
-- @returns boolean Whether the damage is explosion damage
WMS.DamageSystem.isExplosionDamage = function(damage, damageInfo)
    return damageInfo:isExplosionDamage() or damage.inflictor:GetClass() == "base_shell"
end

-- Checks if a parsed damage table is vehicle damage
-- @param damage: table The parsed damage table
-- @returns boolean Whether the damage is vehicle damage
WMS.DamageSystem.isVehicleDamage = function(damage)
    return damage.inflictor:IsVehicle() or damage.inflictor:GetClass() == "worldspawn"
end

-- Gets the predefined weapon type with the parsed damage table
-- @param damage: table The parsed damage table 
-- @returns number The custom weapon type
WMS.DamageSystem.getWeaponType = function(damage)
    
    if (WMS.weapons.cut[damage.weaponClass] or WMS.weapons.cut[damage.inflictor:GetClass()]) then

        return WMS.config.enums.weaponTypes.CUT

    elseif (WMS.weapons.pistol[damage.weaponClass]) then

        return WMS.config.enums.weaponTypes.PISTOL

    elseif (WMS.weapons.rifle[damage.weaponClass] or !IsValid(damage.weapon)) then

        return WMS.config.enums.weaponTypes.RIFLE

    elseif (damage.customDamageType == WMS.config.enums.damageTypes.VEHICLE) then

        return WMS.config.enums.weaponTypes.VEHICLE

    elseif (!WMS.weapons.rifle[damage.weaponClass]
            and IsValid(damage.weapon) 
            and damage.inflictor:IsPlayer() 
            and !damage.inflictor:InVehicle()) then

        return WMS.config.enums.weaponTypes.UNRECOGNIZED

    end

    return WMS.config.enums.weaponTypes.RIFLE

end

-- Gets the predefined damage type of a parsed damage table
-- @param damage: table The parsed damage table
-- @param damageInfo: CTakeDamageInfo The original damage info
-- @returns number The custom damage type detected
WMS.DamageSystem.getCustomDamageType = function(damage, damageInfo)

    if (WMS.DamageSystem.isBleedingDmg(damage)) then
        return WMS.config.enums.damageTypes.BLEED
    end
    
    if (WMS.weapons.noDamage[damage.inflictor:GetClass()]) then
        return WMS.config.enums.damageTypes.NO_DAMAGE
    end

    if (damageInfo:IsFallDamage()) then
        return WMS.config.enums.damageTypes.FALL
    end

    if (WMS.DamageSystem.isExplosionDamage(damage, damageInfo)) then
        return WMS.config.enums.damageTypes.EXPLOSION
    end
    
    if (WMS.DamageSystem.isVehicleDamage(damage)) then
        return WMS.config.enums.damageTypes.VEHICLE
    end

    if (damage.attacker:IsPlayer()) then
        return WMS.config.enums.damageTypes.NORMAL
    end

    if (IsValid(damage.weapon)) then

        if (!WMS.weapons[damage.weaponClass]) then
            return WMS.config.enums.damageTypes.NO_DAMAGE
        end

    end

    return WMS.config.enums.damageTypes.NORMAL

end

-- Gets the predefined damage area with the parsed damage table
-- @param damage: table The parsed damage table 
-- @returns number The custom damage area
WMS.DamageSystem.getDamageArea = function(damage)

    local chance = math.random(100)

    if ((damage.hitGroup == HITGROUP_CHEST 
        or damage.customDamageType == WMS.config.enums.damageTypes.VEHICLE 
        or !IsValid(damage.weapon))
        and (!WMS.weapons.cut[damage.inflictor:GetClass()])) then

        if (chance <= WMS.config.chances[WMS.config.enums.damageArea.TORSO].chance) then
            return WMS.config.enums.damageArea.TORSO
        end

        if (chance <= WMS.config.chances[WMS.config.enums.damageArea.TORSO].chance + WMS.config.chances[WMS.config.enums.damageArea.HEART].chance) then
            return WMS.config.enums.damageArea.HEART
        end

        return WMS.config.enums.damageArea.LUNGS

    end

    if (damage.hitGroup == HITGROUP_GENERIC
        or WMS.weapons.cut[damage.inflictor:GetClass()]
        or WMS.weapons.cut[damage.weapon]) then

        local sum = 0

        for area, percentage in ipairs(WMS.config.chances.cut) do

            sum = sum + percentage
            if (chance <= sum) then
                return area
            end

        end

    end
    
    if (damage.hitGroup == HITGROUP_HEAD) then

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

    if (damage.hitGroup == HITGROUP_STOMACH) then

        if (chance <= WMS.config.chances[WMS.config.enums.damageArea.STOMACH].chance) then
            return WMS.config.enums.damageArea.STOMACH
        end
        
        return WMS.config.enums.damageArea.LIVER

    end

    if (damage.hitGroup == HITGROUP_LEFTLEG or damage.hitGroup == HITGROUP_RIGHTLEG) then

        if (chance <= WMS.config.chances[WMS.config.enums.damageArea.LEG].chance) then
            return WMS.config.enums.damageArea.LEG
        end
        
        return WMS.config.enums.damageArea.FOOT

    end

    if (damage.hitGroup == HITGROUP_LEFTARM or damage.hitGroup == HITGROUP_RIGHTARM) then

        if (chance <= WMS.config.chances[WMS.config.enums.damageArea.ARM].chance) then
            return WMS.config.enums.damageArea.ARM
        end
        
        return WMS.config.enums.damageArea.HAND

    end

    return WMS.config.enums.damageArea.UNRECOGNIZED

end

-- Calculates the chances of different types of deaths and gives a table containing 
-- the necessary information
-- @param damage: table The parsed damage table
-- @returns table The final damage table
WMS.DamageSystem.getDamageTable = function(damage)

    local finalDamages = {}

    finalDamages.totalDeath = false
    finalDamages.partialDeath = false
    finalDamages.hemorrhage = false

    finalDamages.damageAmount = 0

    if (damage.area > 0 and damage.weaponType > 0) then
        finalDamages.totalDeath = math.random(100) <= WMS.config.chances[damage.area][damage.weaponType].total
        finalDamages.partialDeath = math.random(100) <= WMS.config.chances[damage.area][damage.weaponType].partial
        finalDamages.hemorrhage = math.random(100) <= WMS.config.chances[damage.area][damage.weaponType].hemorrhage

        local range = WMS.config.chances[damage.area][damage.weaponType].dmgRange
        finalDamages.damageAmount = math.random(range[1], range[2])
    end

    if (damage.customDamageType == WMS.config.enums.damageTypes.FALL) then
        finalDamages.totalDeath = false
    end

    if (damage.victim:Health() - finalDamages.damageAmount <= 0) then
        finalDamages.totalDeath = true
        finalDamages.partialDeath = true
    end

    if (damage.victim:Health() - finalDamages.damageAmount <= 30) then
        finalDamages.limp = true
    end

    if (damage.customDamageType == WMS.config.enums.damageTypes.VEHICLE 
        or damage.customDamageType == WMS.config.enums.damageTypes.FALL) then

        finalDamages.hemorrhage = false 

    end

    local explosionByDeathCondition = damage.customDamageType == WMS.config.enums.damageTypes.EXPLOSION and damage.damageAmount >= 70

    if (explosionByDeathCondition) then 
        finalDamages.totalDeath = true 
    end

    finalDamages.customDamageType = damage.customDamageType
    finalDamages.verboseWeapon = damage.verboseWeapon
    finalDamages.hitGroup = damage.hitGroup


    if (damage.area == WMS.config.enums.damageArea.LEG 
        or damage.customDamageType == WMS.config.enums.damageTypes.VEHICLE
        or damage.customDamageType == WMS.config.enums.damageTypes.FALL
        or finalDamages.damageAmount >= 70) then

        finalDamages.limp = true

    end

    finalDamages.brokenRightArm = false
    finalDamages.brokenLeftArm = false

    if (damage.area == WMS.config.enums.damageArea.ARM) then

        if (damage.hitGroup == HITGROUP_RIGHTARM) then
            finalDamages.brokenRightArm = true
        else
            finalDamages.brokenLeftArm = true
        end

    end

    if (damage.customDamageType == WMS.config.enums.damageTypes.FALL) then
        finalDamages.verboseWeapon = nil
    end

    if (damage.victim == damage.inflictor) then
        finalDamages.customDamageType = WMS.config.enums.damageTypes.NO_DAMAGE
    end

    finalDamages.area = damage.area

    if (WMS.DEBUG) then

        PrintC(finalDamages, 8, 27)
        PrintC(damage, 8, 33)

        PrintTable(damage)
        table.Empty(damage)

    end
    
    return finalDamages
end

-- The main parsing function
-- @param player: Player The victim
-- @param damageInfo: CTakeDamageInfo The original damage info
-- @returns table The final damage table
WMS.DamageSystem.parseDamage = function(player, damageInfo)

    local damage = {}

    damage.victim = player

    damage.attacker = damageInfo:GetAttacker()
    damage.inflictor = damageInfo:GetInflictor()

    if (!IsValid(damage.inflictor)) then 
        damage.inflictor = damage.attacker 
    end

    damage.hitGroup = player:LastHitGroup()
    --damage.verboseHitGroup = WMS.HIT[damage.hitGroup]

    damage.damageAmount = damageInfo:GetDamage()

    damage.type = damageInfo:GetDamageType()

    damage.totalDeath = false
    damage.partialDeath = false
    damage.hemorrhage = false

    damage.weapon = nil

    local damageOriginEntity

    if (damage.attacker:IsPlayer()) then
        damageOriginEntity = damage.attacker

    elseif (damage.inflictor:IsPlayer()) then
        damageOriginEntity = damage.inflictor
    end

    if (IsValid(damageOriginEntity)) then
        
        damage.weapon = damageOriginEntity:GetActiveWeapon()

        if (IsValid(damage.weapon)) then 
            damage.weaponClass = damage.weapon:GetClass() 
        end

    end

    damage.customDamageType = WMS.DamageSystem.getCustomDamageType(damage, damageInfo)

    if (WMS.DamageSystem.isBleedingDmg(damage)) then
        damage.hemorrhage = true
        return damage
    end
    
    damage.weaponType = WMS.DamageSystem.getWeaponType(damage)
    damage.verboseWeapon = WMS.config.human.weaponTypes[damage.weaponType]

    damage.area = WMS.DamageSystem.getDamageArea(damage)
    damage.verboseHitGroup = WMS.config.human.damageArea[damage.area]

    return damage
end

-- The main registering function
-- @param player: Player The victim
-- @param damageInfo: CTakeDamageInfo The original damage info
-- @returns table The final damage table
WMS.DamageSystem.registerDamage = function(player, damageInfo)

    local damage = WMS.DamageSystem.parseDamage(player, damageInfo)

    local finalDamages = WMS.DamageSystem.getDamageTable(damage)

    return finalDamages

end

WMS.DamageSystem.damageApplier = function(player, damage)

    if (!player:Alive()) then return end

    if (damage.customDamageType == WMS.config.enums.damageTypes.NO_DAMAGE) then

        player.damagesTable[#player.damagesTable + 1] = table.Copy(damage)
        WMS.utils.syncDmgTbl(player, table.Copy(player.damagesTable))

        return 0

    end

    if (damage.totalDeath) then

        if (WMS.DEBUG) then 
            PrintC("FINITO PIPO", 8, 1) 
        end

        if (!WMS.config.NO_DMG) then
            player:Kill()
        end

        return 0

    end

    if (damage.partialDeath) then

        if (WMS.DEBUG) then 
            PrintC("FINITO", 8, 202) 
        end

        if (!WMS.config.NO_DMG) then
            player:PartialDeath()
        end

        player.damagesTable[#player.damagesTable + 1] = table.Copy(damage)
        WMS.utils.syncDmgTbl(player, table.Copy(player.damagesTable))

        return 0

    end

    if (damage.hemorrhage and !player:GetNWBool("isBleeding")) then

        if (WMS.DEBUG) then PrintC("\tOOF Bleeds", 8, 9) end

        if (!WMS.config.NO_DMG) then
            player:SetBleeding(true, WMS.config.bleedingSpeed, WMS.config.bleedingImportance)
        end

    elseif (damage.limp) then
        player:LegFracture()

    elseif (damage.brokenRightArm) then
        player:RightArmFracture()

    elseif (damage.brokenLeftArm) then
        player:LeftArmFracture()

    end

    player.damagesTable[#player.damagesTable + 1] = table.Copy(damage)

    WMS.utils.syncDmgTbl(player, table.Copy(player.damagesTable))

    return damage.damageAmount

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

    local damage = WMS.DamageSystem.registerDamage(target, damageInfo)
    damageInfo:SetDamage(WMS.DamageSystem.damageApplier(target, damage) or 0)

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
hook.Add("PlayerDeathSound", "WMS::DeathSound", function(player) return true end)