-- This file contains the functions and hook functions related to parsing the damage info taken by each player
-- how it works :
-- The point is to parse the information given by the EntityTakeDamage hook and only get the generated
-- amount of damage depending on the weapon and the area and luck.
--
-- Known issue : 
-- In particular situations the player keeps spectating the corps even if the player re-spawned
-- and the corps disappeared.
-- The cause is **probably** due to the coma system.
-- this problem is difficult to replicate and occurs at "random" times (it seems)



WMS = WMS or {}
WMS.DamageSystem = WMS.DamageSystem or {}
WMS.DamageSystem.Hooks = {}

-- Checks if a parsed damage table is bleeding damage
-- @tparam table damage The parsed damage table
-- @treturn boolean Whether the damage is bleeding damage
WMS.DamageSystem.isBleedingDmg = function(damage)
    return damage.type == WMS.config.DMG_BLEEDING / 2
end

-- Checks if a parsed damage table is explosion damage
-- @tparam table damage The parsed damage table
-- @tparam CTakeDamageInfo damageInfo The original damage info
-- @treturn boolean Whether the damage is explosion damage
WMS.DamageSystem.isExplosionDamage = function(damage, damageInfo)
    return damageInfo:isExplosionDamage() or damage.inflictor:GetClass() == "base_shell"
end

-- Checks if a parsed damage table is vehicle damage
-- @tparam table damage The parsed damage table
-- @treturn boolean Whether the damage is vehicle damage
WMS.DamageSystem.isVehicleDamage = function(damage)
    return damage.inflictor:IsVehicle() or damage.inflictor:GetClass() == "worldspawn"
end

-- Gets the predefined weapon type with the parsed damage table
-- @tparam table damage The parsed damage table 
-- @treturn number The custom weapon type
WMS.DamageSystem.getWeaponType = function(damage)
    
    if (WMS.weapons.cut[damage.weaponClass] or WMS.weapons.cut[damage.inflictor:GetClass()]) then

        return WMS.config.enums.weaponTypes.CUT

    elseif (WMS.weapons.pistol[damage.weaponClass]) then

        return WMS.config.enums.weaponTypes.PISTOL

    elseif (WMS.weapons.rifle[damage.weaponClass] or not IsValid(damage.weapon)) then

        return WMS.config.enums.weaponTypes.RIFLE

    elseif (damage.customDamageType == WMS.config.enums.damageTypes.VEHICLE) then

        return WMS.config.enums.weaponTypes.VEHICLE

    elseif (not WMS.weapons.rifle[damage.weaponClass]
            and IsValid(damage.weapon) 
            and damage.inflictor:IsPlayer() 
            and not damage.inflictor:InVehicle()) then

        return WMS.config.enums.weaponTypes.UNRECOGNIZED

    end

    return WMS.config.enums.weaponTypes.RIFLE

end

-- Gets the predefined damage type of a parsed damage table
-- @tparam table damage The parsed damage table
-- @tparam CTakeDamageInfo damageInfo The original damage info
-- @treturn number The custom damage type detected
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

        if (not WMS.weapons[damage.weaponClass]) then
            return WMS.config.enums.damageTypes.NO_DAMAGE
        end

    end

    return WMS.config.enums.damageTypes.NORMAL

end

-- Gets the predefined damage area with the parsed damage table
-- @tparam table damage The parsed damage table 
-- @treturn number The custom damage area
WMS.DamageSystem.getDamageArea = function(damage)

    local chance = math.random(100)

    if ((damage.hitGroup == HITGROUP_CHEST 
        or damage.customDamageType == WMS.config.enums.damageTypes.VEHICLE 
        or not IsValid(damage.weapon))
        and (not WMS.weapons.cut[damage.inflictor:GetClass()])) then

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
-- @tparam table damage The parsed damage table
-- @treturn table The final damage table
WMS.DamageSystem.getDamageTable = function(damage)

    local finalDamage = {}

    finalDamage.totalDeath = false
    finalDamage.partialDeath = false
    finalDamage.hemorrhage = false

    finalDamage.damageAmount = 0

    if (damage.area > 0 and damage.weaponType > 0) then
        finalDamage.totalDeath = math.random(100) <= WMS.config.chances[damage.area][damage.weaponType].total
        finalDamage.partialDeath = math.random(100) <= WMS.config.chances[damage.area][damage.weaponType].partial
        finalDamage.hemorrhage = math.random(100) <= WMS.config.chances[damage.area][damage.weaponType].hemorrhage

        local range = WMS.config.chances[damage.area][damage.weaponType].dmgRange
        finalDamage.damageAmount = math.random(range[1], range[2])
    end

    if (damage.customDamageType == WMS.config.enums.damageTypes.FALL) then
        finalDamage.totalDeath = false
    end

    if (damage.victim:Health() - finalDamage.damageAmount <= 0) then
        finalDamage.totalDeath = true
        finalDamage.partialDeath = true
    end

    if (damage.victim:Health() - finalDamage.damageAmount <= 30) then
        finalDamage.limp = true
    end

    if (damage.customDamageType == WMS.config.enums.damageTypes.VEHICLE 
        or damage.customDamageType == WMS.config.enums.damageTypes.FALL) then

        finalDamage.hemorrhage = false 

    end

    local explosionByDeathCondition = damage.customDamageType == WMS.config.enums.damageTypes.EXPLOSION and damage.damageAmount >= 70

    if (explosionByDeathCondition) then 
        finalDamage.totalDeath = true 
    end

    finalDamage.customDamageType = damage.customDamageType
    finalDamage.verboseWeapon = damage.verboseWeapon
    finalDamage.hitGroup = damage.hitGroup


    if (damage.area == WMS.config.enums.damageArea.LEG 
        or damage.customDamageType == WMS.config.enums.damageTypes.VEHICLE
        or damage.customDamageType == WMS.config.enums.damageTypes.FALL
        or finalDamage.damageAmount >= 70) then

        finalDamage.limp = true

    end

    finalDamage.brokenRightArm = false
    finalDamage.brokenLeftArm = false

    if (damage.area == WMS.config.enums.damageArea.ARM) then

        if (damage.hitGroup == HITGROUP_RIGHTARM) then
            finalDamage.brokenRightArm = true
        else
            finalDamage.brokenLeftArm = true
        end

    end

    if (damage.customDamageType == WMS.config.enums.damageTypes.FALL) then
        finalDamage.verboseWeapon = nil
    end

    if (damage.victim == damage.inflictor) then
        finalDamage.customDamageType = WMS.config.enums.damageTypes.NO_DAMAGE
    end

    finalDamage.area = damage.area

    if (WMS.DEBUG) then

        print(finalDamage)
        print(damage)

        PrintTable(damage)
        table.Empty(damage)

    end
    
    return finalDamage
end

-- The main parsing function
-- @tparam Player player The victim
-- @tparam CTakeDamageInfo damageInfo The original damage info
-- @treturn table The final damage table
WMS.DamageSystem.parseDamage = function(player, damageInfo)

    local damage = {}

    damage.victim = player

    damage.attacker = damageInfo:GetAttacker()
    damage.inflictor = damageInfo:GetInflictor()

    if (not IsValid(damage.inflictor)) then 
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
-- @tparam Player player The victim
-- @tparam CTakeDamageInfo damageInfo The original damage info
-- @treturn table The final damage table
WMS.DamageSystem.registerDamage = function(player, damageInfo)

    local damage = WMS.DamageSystem.parseDamage(player, damageInfo)

    local finalDamage = WMS.DamageSystem.getDamageTable(damage)

    return finalDamage

end

-- Takes the final damage table and applies the deaths or yields the amount
-- of hp to take from the player
-- @tparam Player player The victim
-- @tparam table damage The parsed damage table
-- @treturn number The amount of damage that should be applied
WMS.DamageSystem.damageCalculator = function(player, damage)

    if (not player:Alive()) then return end

    if (damage.customDamageType == WMS.config.enums.damageTypes.NO_DAMAGE) then

        player.damagesTable[#player.damagesTable + 1] = table.Copy(damage)
        WMS.utils.syncDamageTable(player, table.Copy(player.damagesTable))

        return 0

    end

    if (damage.totalDeath) then

        if (WMS.DEBUG) then 
            print("FINITO PIPO") 
        end

        if (not WMS.config.NO_DMG) then
            player:Kill()
        end

        return 0

    end

    if (damage.partialDeath) then

        if (WMS.DEBUG) then 
            print("FINITO", 8, 202) 
        end

        if (not WMS.config.NO_DMG) then
            player:PartialDeath()
        end

        player.damagesTable[#player.damagesTable + 1] = table.Copy(damage)
        WMS.utils.syncDamageTable(player, table.Copy(player.damagesTable))

        return 0

    end

    if (damage.hemorrhage and not player:GetNWBool("isBleeding")) then

        if (WMS.DEBUG) then print("\tOOF Bleeds") end

        if (not WMS.config.NO_DMG) then
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

    WMS.utils.syncDamageTable(player, table.Copy(player.damagesTable))

    return damage.damageAmount

end

-- This section deals with the methods added to the Player meta
do -- PLAYER FUNCTIONS
    --BLEEDING
    local PLAYER = FindMetaTable("Player")
    
    -- Starts the bleeding process and send a damage signal
    -- @tparam number speed The rate which the player should bleed
    -- @tparam number importance The amount of hp taken per bleed
    -- @treturn nil
    function PLAYER:StartHemorrhage(speed, importance)

        if (not self:GetNWBool("isBleeding")) then return end

        timer.Create("Hemo_"..self:EntIndex(), speed, 0, function()

            if (not IsValid(self) or not self:Alive()) then return end

            local d = DamageInfo()
            d:SetDamage(importance)
            d:SetDamageType(WMS.config.DMG_BLEEDING)

            -- bleeding effect
            local bone = self:GetBonePosition(math.random(1, self:GetBoneCount() - 1))
            if bone then

                local effect = EffectData()
                effect:SetOrigin(bone)
                util.Effect("BloodImpact", effect, true, true)

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

    -- Calls the latter method and acts as a switch
    -- @tparam boolean isBleeding Whether the player should bleed or not
    -- @tparam number speed The rate which the player should bleed
    -- @tparam number importance The amount of hp taken per bleed
    -- @treturn nil
    function PLAYER:SetBleeding(isBleeding, speed, importance)

        self:SetNWBool("isBleeding", isBleeding)

        if (isBleeding) then
            self:StartHemorrhage(speed, importance)
            return
        end
        
        timer.Remove("Hemo_"..self:EntIndex())

    end

    -- Partial Death
    -- Makes the player partially dead (in a coma)
    -- @treturn nil
    function PLAYER:PartialDeath()

        if (self:GetNWBool("isPartiallyDead")) then return end

        self:SetNWBool("isPartiallyDead", true)
        self:SetNWBool("isDragged", false)

        self:CreateRagdoll()

        self:StripWeapons()

        self:SetNWInt("pulse", math.random(3, 20))
        self:SetNWInt("partialDeathTimer", CurTime())

        timer.Simple(WMS.config.partialDeathTime, function()
            if (not self:GetCreator():GetNWBool("isPartiallyDead")) then return end
            self:Kill()
        end)

    end

    -- Wakes the player up after being partially dead
    -- @treturn nil
    function PLAYER:Revive()

        if (not self:GetNWBool("isPartiallyDead")) then return end

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

    -- 🥰 verbose 🥰
    -- Prevents prop spawning when in coma 
    hook.Add("PlayerSpawnObject", "WMS::PreventPropSpawnOnDeath", function(player)
        if (player:GetNWBool("isPartiallyDead")) then return false end
    end)

    -- Prevents suicide when in coma 
    hook.Add("CanPlayerSuicide", "WMS::PreventSuicide", function(player)
        if (player:GetNWBool("isPartiallyDead")) then return false end
    end)


    -- Limb Damage (handicaps)

    -- Applies a leg fracture (limp)
    -- @treturn nil
    function PLAYER:LegFracture()

        if (self:GetNWBool("isLimp")) then return end
        self:SetNWBool("isLimp", true)

        self:SetRunSpeed(WMS.config.fractureRunSpeed)
        self:SetWalkSpeed(WMS.config.fractureWalkSpeed)

        prone.Enter(self)

    end

    -- Heals a leg fracture (limp)
    -- @treturn nil 
    function PLAYER:HealLegFracture()

        if (not self:GetNWBool("isLimp")) then return end
        self:SetNWBool("isLimp", false)

        self:SetRunSpeed(WMS.config.defaultRunSpeed)
        self:SetWalkSpeed(WMS.config.defaultWalkSpeed)

    end

    -- Prevents getting up when limp 
    hook.Add("prone.CanExit", "WMS::PreventGettingUpOnLimp", function(player)
        return not player:GetNWBool("isLimp")
    end)


    -- ARMS
    -- code repeating because I'm a lazy fucker 🙃

    -- Deals a right arm fracture.
    -- Drops the weapon either way
    -- @treturn nil 
    function PLAYER:RightArmFracture()

        if (self:GetNWBool("rightArmFracture")) then return end
        
        self:SetNWBool("rightArmFracture", true)

        local weapon = self:GetActiveWeapon()

        if (not IsValid(weapon)) then return end

        if (WMS.weapons.rifle[weapon:GetClass()] or
            WMS.weapons.pistol[weapon:GetClass()] or
            WMS.weapons.cut[weapon:GetClass()]) then

            self:DropWeapon(weapon)

        end

    end

    -- Deals a left arm fracture.
    -- Drops the weapon if it it a two handheld weapon (we assume everybody is right handed)
    -- @treturn nil 
    function PLAYER:LeftArmFracture()
        
        if (self:GetNWBool("leftArmFracture")) then return end

        self:SetNWBool("leftArmFracture", true)

        local weapon = self:GetActiveWeapon()

        if (not IsValid(weapon)) then return end

        if (WMS.weapons.rifle[weapon:GetClass()] 
            or WMS.weapons.pistol[weapon:GetClass()] 
            or WMS.weapons.cut[weapon:GetClass()]
            and not WMS.weapons.oneArm[weapon:GetClass()]) then

            self:DropWeapon(weapon)

        end

    end

    -- Heals a right arm fracture.
    -- @treturn nil 
    function PLAYER:HealRightArmFracture()
        if (not self:GetNWBool("rightArmFracture")) then return end

        self:SetNWBool("rightArmFracture", false)
    end

    -- Heals a left arm fracture.
    -- @treturn nil 
    function PLAYER:HealLeftArmFracture()
        if (not self:GetNWBool("leftArmFracture")) then return end

        self:SetNWBool("leftArmFracture", false)
    end

    -- Prevents switching weapons when the player has a broken arm
    hook.Add("PlayerSwitchWeapon", "WMS::PreventSwitchingWeaponArmBroke", function(player, oldWeapon, newWeapon)
        -- return true to block switching

        if (player:Health() <= 30) then 
            player:SetActiveWeapon(player:Give("re_hands"))
            return true 
        end

        if (player:GetNWBool("rightArmFracture")) then return true end

        if (not player:GetNWBool("leftArmFracture")) then return false end

        if (WMS.weapons.oneArm[weapon:GetClass()]) then return false end

    end)
end


-- HOOKS

-- This function is basically used to initialize most of the networking variables 
-- and the player's damage table.
-- Hook utilization : Used when the player spawns the first time they connect.
-- @tparam Player player The player that should get initialized
-- @treturn nil
WMS.DamageSystem.Hooks.Init = function(player, transition)

    hook.Call("CalcView") -- I am desperate
    player:UnSpectate()

    print(player:SteamID().."[WMS] Player Damage table initialized !")
    
    player.damagesTable = {}

    WMS.utils.syncDamageTable(player, player.damagesTable)

    -- player:SetNWInt("pulse", math.random(70, 90))

    player:SetNWInt("partialDeathTimer", -1)
    player:SetNWBool("isPartiallyDead", false)
    player:SetNWBool("isDragged", false)

    player:SetNWBool("isLimp", false)
    player:SetNWBool("rightArmFracture", false)
    player:SetNWBool("leftArmFracture", false)

end

-- This function removes any remainders of the victim
-- Hook utilization : Used when the player dies.
-- @tparam Player victim The player who died
-- @tparam Entity inflictor Item used to kill the victim
-- @tparam Entity attacker Player or entity that killed the victim
-- @treturn nil
WMS.DamageSystem.Hooks.Death = function(victim, inflictor, attacker)

    if (victim:Alive()) then return end

    if (victim:GetNWBool("isPartiallyDead")) then 
        victim:RemoveRagdoll() 
    end

    if (victim:GetNWBool("isBleeding")) then
        timer.Remove("Hemo_"..victim:EntIndex())
        victim:SetBleeding(false)
    end

    local ragdoll = victim:Create_Untied_Ragdoll()

    timer.Simple(WMS.config.corpsDeleteTime, function()

        if (IsValid(ragdoll)) then 
            ragdoll:Remove() 
        end

    end)


    print("[WMS] Player Damage table Deleted not ")
    WMS.DamageSystem.Hooks.Init(victim, false)
    -- hook.Call("CalcView") -- not sure about that
end

-- This function uses the above functions to get the amount of damage the 
-- player should take.
-- Hook utilization : Used when the player takes damage.
-- @tparam Entity target The entity that took the damage 
-- @tparam CTakeDamageInfo damageInfo The original damage info
-- @treturn boolean Whether to block the damage
WMS.DamageSystem.Hooks.damageAmount = function(target, damageInfo)
    
    if (target:IsPlayerRagdoll() and target:GetCreator():GetNWBool("isPartiallyDead")) then
        
        if (damageInfo:GetDamage() > WMS.config.amountOfDamageToKillCorps) then
            target:GetCreator():Kill()
        end

        return true

    end

    if (not target:IsPlayer()) then return end
    if (target:HasGodMode()) then return true end

    local damage = WMS.DamageSystem.registerDamage(target, damageInfo)
    damageInfo:SetDamage(WMS.DamageSystem.damageCalculator(target, damage) or 0)

    if (WMS.config.NO_DMG) then
        damageInfo:SetDamage(0)
    end

end

-- Erases the player's damage table on disconnect
WMS.DamageSystem.Hooks.Disconnect = function(player)
    player.damagesTable = nil
end


hook.Add("EntityTakeDamage", "WMS::DamageHook", WMS.DamageSystem.Hooks.damageAmount)
hook.Add("PlayerDisconnected", "WMS::ResetOnDisconnect", WMS.DamageSystem.Hooks.Disconnect)
hook.Add("PlayerInitialSpawn", "WMS::Init", WMS.DamageSystem.Hooks.Init)
hook.Add("PlayerDeath", "WMS::DeathHook", WMS.DamageSystem.Hooks.Death)
hook.Add("PlayerDeathSound", "WMS::DeathSound", function(player) return true end)