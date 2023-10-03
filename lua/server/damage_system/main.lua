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

include("./hooks.lua")
include("./player_methods.lua")

hook.Add("EntityTakeDamage", "WMS::DamageHook", WMS.DamageSystem.Hooks.damageAmount)
hook.Add("PlayerDisconnected", "WMS::ResetOnDisconnect", WMS.DamageSystem.Hooks.Disconnect)
hook.Add("PlayerInitialSpawn", "WMS::Init", WMS.DamageSystem.Hooks.Init)
hook.Add("PlayerDeath", "WMS::DeathHook", WMS.DamageSystem.Hooks.Death)
hook.Add("PlayerDeathSound", "WMS::DeathSound", function(player) return true end)