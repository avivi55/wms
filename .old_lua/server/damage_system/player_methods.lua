-- This file deals with the methods added to the Player meta

WMS = WMS or {}

local PLAYER = FindMetaTable("Player")

-- Starts the bleeding process and send a damage signal
-- @tparam number speed The rate which the player should bleed
-- @tparam number importance The amount of hp taken per bleed
-- @treturn nil
function PLAYER:StartHemorrhage(speed, importance)
	if not self:GetNWBool("isBleeding") then
		return
	end

	timer.Create("Hemo_" .. self:EntIndex(), speed, 0, function()
		if not IsValid(self) or not self:Alive() then
			return
		end

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
		for _ = 1, 12 do
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

	if isBleeding then
		self:StartHemorrhage(speed, importance)
		return
	end

	timer.Remove("Hemo_" .. self:EntIndex())
end

-- Partial Death
-- Makes the player partially dead (in a coma)
-- @treturn nil
function PLAYER:PartialDeath()
	if self:GetNWBool("isPartiallyDead") then
		return
	end

	self:SetNWBool("isPartiallyDead", true)
	self:SetNWBool("isDragged", false)

	self:CreateRagdoll()

	self:StripWeapons()

	self:SetNWInt("pulse", math.random(3, 20))
	self:SetNWInt("partialDeathTimer", CurTime())

	timer.Simple(WMS.config.partialDeathTime, function()
		if not self:GetCreator():GetNWBool("isPartiallyDead") then
			return
		end
		self:Kill()
	end)
end

-- Wakes the player up after being partially dead
-- @treturn nil
function PLAYER:Revive()
	if not self:GetNWBool("isPartiallyDead") then
		return
	end

	self:SetNWBool("isPartiallyDead", false)

	self:UnSpectate()
	self:Spawn()

	local rag = self:GetRagdollEntity()
	self:SetPos(rag:GetPos())

	prone.Enter(self)
	self:SetHealth(math.random(7, 16))
	self:RemoveRagdoll()

	for _, weapon in pairs(rag.Weapons) do
		self:Give(weapon)
	end

	for k, v in pairs(rag.ammo) do
		self:GiveAmmo(k, v)
	end

	self:SelectWeapon(rag.ActiveWeapon)

	self.damagesTable = table.Copy(rag.damagesTable)
end

-- 🥰 verbose 🥰
-- Prevents prop spawning when in coma
hook.Add("PlayerSpawnObject", "WMS::PreventPropSpawnOnDeath", function(player)
	if player:GetNWBool("isPartiallyDead") then
		return false
	end
end)

-- Prevents suicide when in coma
hook.Add("CanPlayerSuicide", "WMS::PreventSuicide", function(player)
	if player:GetNWBool("isPartiallyDead") then
		return false
	end
end)

-- Limb Damage (handicaps)

-- Applies a leg fracture (limp)
-- @treturn nil
function PLAYER:LegFracture()
	if self:GetNWBool("isLimp") then
		return
	end
	self:SetNWBool("isLimp", true)

	self:SetRunSpeed(WMS.config.fractureRunSpeed)
	self:SetWalkSpeed(WMS.config.fractureWalkSpeed)

	prone.Enter(self)
end

-- Heals a leg fracture (limp)
-- @treturn nil
function PLAYER:HealLegFracture()
	if not self:GetNWBool("isLimp") then
		return
	end
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
	if self:GetNWBool("rightArmFracture") then
		return
	end

	self:SetNWBool("rightArmFracture", true)

	local weapon = self:GetActiveWeapon()

	if not IsValid(weapon) then
		return
	end

	if
		WMS.weapons.rifle[weapon:GetClass()]
		or WMS.weapons.pistol[weapon:GetClass()]
		or WMS.weapons.cut[weapon:GetClass()]
	then
		self:DropWeapon(weapon)
	end
end

-- Deals a left arm fracture.
-- Drops the weapon if it it a two handheld weapon (we assume everybody is right handed)
-- @treturn nil
function PLAYER:LeftArmFracture()
	if self:GetNWBool("leftArmFracture") then
		return
	end

	self:SetNWBool("leftArmFracture", true)

	local weapon = self:GetActiveWeapon()

	if not IsValid(weapon) then
		return
	end

	if
		WMS.weapons.rifle[weapon:GetClass()]
		or WMS.weapons.pistol[weapon:GetClass()]
		or WMS.weapons.cut[weapon:GetClass()] and not WMS.weapons.oneArm[weapon:GetClass()]
	then
		self:DropWeapon(weapon)
	end
end

-- Heals a right arm fracture.
-- @treturn nil
function PLAYER:HealRightArmFracture()
	if not self:GetNWBool("rightArmFracture") then
		return
	end

	self:SetNWBool("rightArmFracture", false)
end

-- Heals a left arm fracture.
-- @treturn nil
function PLAYER:HealLeftArmFracture()
	if not self:GetNWBool("leftArmFracture") then
		return
	end

	self:SetNWBool("leftArmFracture", false)
end
