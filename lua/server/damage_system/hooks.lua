-- HOOKS

WMS = WMS or {}
WMS.DamageSystem = WMS.DamageSystem or {}
WMS.DamageSystem.Hooks = {}

include("./damage_table_functions.lua")


-- Prevents switching weapons when the player has a broken arm
hook.Add("PlayerSwitchWeapon", "WMS::PreventSwitchingWeaponArmBroke", function(player, oldWeapon, newWeapon)
    -- return true to block switching

    if (player:Health() <= 30) then
        player:SetActiveWeapon(player:Give("re_hands"))
        return true
    end

    if (player:GetNWBool("rightArmFracture")) then return true end

    if (not player:GetNWBool("leftArmFracture")) then return false end

    if (WMS.weapons.oneArm[newWeapon:GetClass()]) then return false end

end)

-- This function is basically used to initialize most of the networking variables
-- and the player's damage table.
-- Hook utilization : Used when the player spawns the first time they connect.
-- @tparam Player player The player that should get initialized
-- @treturn nil
WMS.DamageSystem.Hooks.Init = function(player, transition)

    --hook.Call("CalcView") -- I am desperate
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


    print("[WMS] Player Damage table Deleted !")
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

    if (not target:IsPlayer()) then return true end
    if (target:HasGodMode()) then return true end

    local damage = WMS.DamageSystem.registerDamage(target, damageInfo)
    damageInfo:SetDamage(WMS.DamageSystem.damageCalculator(target, damage) or 0)

    if (WMS.config.NO_DMG) then
        damageInfo:SetDamage(0)
    end

    return false

end

-- Erases the player's damage table on disconnect
WMS.DamageSystem.Hooks.Disconnect = function(player)
    player.damagesTable = nil
end