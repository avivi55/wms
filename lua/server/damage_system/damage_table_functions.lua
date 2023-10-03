WMS = WMS or {}
WMS.DamageSystem = WMS.DamageSystem or {}
WMS.DamageSystem.Hooks = {}


include("./damage_functions.lua")

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

    if (damage.area ~= WMS.config.enums.damageArea.UNRECOGNIZED and damage.weaponType ~= WMS.config.enums.weaponTypes.UNRECOGNIZED) then

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

    local deathByExplosionCondition = damage.customDamageType == WMS.config.enums.damageTypes.EXPLOSION and damage.damageAmount >= 70

    if (deathByExplosionCondition) then
        finalDamage.totalDeath = true
    end

    finalDamage.customDamageType = damage.customDamageType
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

    if (WMS.DamageSystem.isBleedingDamage(damage)) then
        finalDamage.damageAmount = damage.damageAmount
    end

    finalDamage.area = damage.area

    if (WMS.DEBUG) then

        finalDamage.verboseWeapon = WMS.config.verbose.weaponTypes[damage.weaponType]
        finalDamage.verboseDamageArea = WMS.config.verbose.damageArea[finalDamage.area]
        finalDamage.verboseHitGroup = WMS.config.damageAreaToImage[damage.hitGroup]
        finalDamage.verboseType = WMS.config.verbose.damageTypes[finalDamage.customDamageType]

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

    if (WMS.DamageSystem.isBleedingDamage(damage)) then
        damage.hemorrhage = true
        damage.weaponType = WMS.config.enums.weaponTypes.UNRECOGNIZED
        damage.area = WMS.config.enums.damageArea.UNRECOGNIZED
        return damage
    end

    damage.weaponType = WMS.DamageSystem.getWeaponType(damage)

    damage.area = WMS.DamageSystem.getDamageArea(damage)

    return damage
end

-- The main registering function
-- @tparam Player player The victim
-- @tparam CTakeDamageInfo damageInfo The original damage info
-- @treturn table The final damage table
WMS.DamageSystem.registerDamage = function(player, damageInfo)

    local damage = WMS.DamageSystem.parseDamage(player, damageInfo)

    -- PrintTable(damage)

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

        if (not WMS.config.NO_DMG) then
            player:Kill()
        end

        return 0

    end

    if (damage.partialDeath) then

        if (not WMS.config.NO_DMG) then
            player:PartialDeath()
        end

        player.damagesTable[#player.damagesTable + 1] = table.Copy(damage)
        WMS.utils.syncDamageTable(player, table.Copy(player.damagesTable))

        return 0

    end

    if (damage.hemorrhage and not player:GetNWBool("isBleeding")) then

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