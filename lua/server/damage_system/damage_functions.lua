WMS = WMS or {}
WMS.DamageSystem = WMS.DamageSystem or {}
WMS.DamageSystem.Hooks = {}

-- Checks if a parsed damage table is bleeding damage
-- @tparam table damage The parsed damage table
-- @treturn boolean Whether the damage is bleeding damage
WMS.DamageSystem.isBleedingDamage = function(damage)
    return damage.type == WMS.config.DMG_BLEEDING / 2
end

-- Checks if a parsed damage table is explosion damage
-- @tparam table damage The parsed damage table
-- @tparam CTakeDamageInfo damageInfo The original damage info
-- @treturn boolean Whether the damage is explosion damage
WMS.DamageSystem.isExplosionDamage = function(damage, damageInfo)
    return damageInfo:IsExplosionDamage() or damage.inflictor:GetClass() == "base_shell"
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

    if (WMS.DamageSystem.isBleedingDamage(damage)) then
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