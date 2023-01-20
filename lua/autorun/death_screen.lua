-- Death Perception (formerly Instant True Death), by Jackarunda, January 2023
-- inspired by blnk's Instant Death Screen addon
AddCSLuaFile()
CreateConVar("DP_NoEarRing", "1", FCVAR_NONE, "suppresses blast tinnitus during death", 0, 1)
if (CLIENT) then	
	CreateClientConVar("DP_Enabled", "1", true, false, "controls whether or not DeathPerception is enabled", 0, 1)
	CreateClientConVar("DP_Delay", "0.25", true, false, "controls how much time passes before post-death sensory cutoff, or how long vision fade lasts", 0, 1)
	CreateClientConVar("DP_PoV", "1", true, false, "forces death perspective to be first-person", 0, 1)
	CreateClientConVar("DP_ColorMode", "0", true, false, "0: no color change, 1: black and white, 2: high contrast, 3: red", 0, 3)
	CreateClientConVar("DP_Blur", "0", true, false, "controls whether vision is blurred during dying", 0, 1)
	CreateClientConVar("DP_OverlayMode", "0", true, false, "0: no dying overlay, 1: tunnel vision, 2: blood", 0, 2)
	CreateClientConVar("DP_VisionCutOffMode", "1", true, false, "0: no cutoff, 1: instant, 2: fade", 0, 2)
	CreateClientConVar("DP_HearingCutOff", "1", true, false, "controls whether hearing cuts out or not", 0, 1)
end

local blurMat = Material("pp/blurscreen")
local tunnelVisionMat = Material("deathperception_vignette_overlay.png")
local bloodVisionMat = Material("deathperception_blood_overlay.png")

if (SERVER) then
	hook.Add("OnDamagedByExplosion", "DP_OnDamagedByExplosion", function(ply, dmg)
		if not(GetConVar("DP_Enabled"):GetBool()) then return end
		if not(GetConVar("DP_NoEarRing"):GetBool()) then return end
		if (ply:GetViewEntity() ~= ply) then return end
		if ((IsValid(ply)) and (ply:Health() <= 0)) then
			return true
		end
	end)
elseif (CLIENT) then
	local STATE_ALIVE, STATE_DYING, STATE_GONE = 1, 0, -1
	local MyState = STATE_ALIVE
	local LeaveTime = 0 -- the time our consciousness will leave the mortal plane
	local GoneFraction = 0 -- runtime fraction to keep track of how strong effects should be
	local LastLivingEyeAngle = Angle(0, 0, 0)
	local InterpolatedViewAngle = Angle(0, 0, 0)

	hook.Add("Think", "DP_Think", function()
		if not(GetConVar("DP_Enabled"):GetBool()) then return end
		local ply = LocalPlayer()
		if not(IsValid(ply)) then return end
		//print(ply:GetNWBool("isPartialDead"))
		if (ply:Alive() and not ply:GetNWBool("isPartialDead")) then
			LastLivingEyeAngle = ply:GetAimVector():Angle()
			LastLivingEyeAngle:Normalize()
			if (MyState ~= STATE_ALIVE) then
				MyState = STATE_ALIVE
				LeaveTime = 0
				GoneFraction = 0
				ply:ConCommand("soundfade 0 1")
			end
		else
			local Time, Delay, HearingMode = CurTime(), GetConVar("DP_Delay"):GetFloat(), GetConVar("DP_HearingCutOff"):GetBool()
			if (MyState == STATE_ALIVE) then -- we just got shot
				MyState = STATE_DYING
				LeaveTime = Time + Delay
				GoneFraction = 0
				-- ply:SetDSP(39)
			elseif (MyState == STATE_DYING) then
				local TimeLeft = LeaveTime - Time
				GoneFraction = 1 - (TimeLeft / Delay)
				if (GoneFraction >= 1) then
					GoneFraction = 1
					if (HearingMode) then ply:ConCommand("soundfade 100 99999") end
					MyState = STATE_GONE
				end
			elseif (MyState == STATE_GONE) then
				-- meet God
			end
		end
	end)

	hook.Add("PostDrawHUD", "DP_PostdrawHUD", function()
		if not(GetConVar("DP_Enabled"):GetBool()) then return end
		local ply = LocalPlayer()
		if (ply:GetViewEntity() ~= ply) then return end
		if (GoneFraction <= 0) then return end
		local ColorMode, ShouldBlur, OverlayMode, VisionCutOff = GetConVar("DP_ColorMode"):GetInt(), GetConVar("DP_Blur"):GetBool(), GetConVar("DP_OverlayMode"):GetInt(), GetConVar("DP_VisionCutOffMode"):GetInt()

		local W, H = ScrW(), ScrH()

		if (ColorMode == 1) then
			DrawColorModify({
				[ "$pp_colour_addr" ] = 0,
				[ "$pp_colour_addg" ] = 0,
				[ "$pp_colour_addb" ] = 0,
				[ "$pp_colour_brightness" ] = 0,
				[ "$pp_colour_contrast" ] = 1,
				[ "$pp_colour_colour" ] = 1 - GoneFraction,
				[ "$pp_colour_mulr" ] = 0,
				[ "$pp_colour_mulg" ] = 0,
				[ "$pp_colour_mulb" ] = 0
			})
		elseif (ColorMode == 2) then
			DrawColorModify({
				[ "$pp_colour_addr" ] = 0,
				[ "$pp_colour_addg" ] = 0,
				[ "$pp_colour_addb" ] = 0,
				[ "$pp_colour_brightness" ] = -GoneFraction,
				[ "$pp_colour_contrast" ] = 1 + GoneFraction * 5,
				[ "$pp_colour_colour" ] = 1 - GoneFraction,
				[ "$pp_colour_mulr" ] = 0,
				[ "$pp_colour_mulg" ] = 0,
				[ "$pp_colour_mulb" ] = 0
			})
		elseif (ColorMode == 3) then
			DrawColorModify({
				[ "$pp_colour_addr" ] = GoneFraction * 2,
				[ "$pp_colour_addg" ] = 0,
				[ "$pp_colour_addb" ] = 0,
				[ "$pp_colour_brightness" ] = 0,
				[ "$pp_colour_contrast" ] = 1,
				[ "$pp_colour_colour" ] = 1,
				[ "$pp_colour_mulr" ] = GoneFraction * 2,
				[ "$pp_colour_mulg" ] = 0,
				[ "$pp_colour_mulb" ] = 0
			})
		end

		if (ShouldBlur) then
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(blurMat)
			for i = 1, 5 * GoneFraction do
				blurMat:SetFloat("$blur", 5 * GoneFraction)
				blurMat:Recompute()
				render.UpdateScreenEffectTexture()
				surface.DrawTexturedRect(-1, -1, W + 2, H + 2)
			end
		end

		if (OverlayMode == 1) then
			surface.SetDrawColor(255, 255, 255, 255 * GoneFraction ^ .25)
			surface.SetMaterial(tunnelVisionMat)
			surface.DrawTexturedRect(-1, -1, W + 2, H + 2)
		elseif (OverlayMode == 2) then
			surface.SetDrawColor(255, 255, 255, 255 * GoneFraction ^ .25)
			surface.SetMaterial(bloodVisionMat)
			surface.DrawTexturedRect(-1, -1, W + 2, H + 2)
		end

		if (VisionCutOff == 1) then
			if (GoneFraction >= 1) then
				surface.SetDrawColor(0, 0, 0, 255)
				surface.DrawRect(-W, -H, ScrW() * 3, ScrH() * 3)
			end
		elseif (VisionCutOff == 2) then
			surface.SetDrawColor(0, 0, 0, 255 * GoneFraction ^ 2)
			surface.DrawRect(-W, -H, ScrW() * 3, ScrH() * 3)
		end

		surface.SetTextColor( 255, 43, 43)
		surface.SetFont( "DEATH_SCREEN" )
		local s1, s2 = surface.GetTextSize("VOUS ÊTES MORT")

		surface.SetTextPos((ScrW()/2)-(s1/2), ScrH()/3)
		surface.DrawText("VOUS ÊTES MORT")

		if(ply:GetNWBool("isPartialDead"))then
			surface.SetFont( "DEATH_SCREEN_LITTLE" )
			s1, s2 = surface.GetTextSize("Mais un medecin peut encore venir vous sauvez")
	
			surface.SetTextPos((ScrW()/2)-(s1/2), ScrH()/1.5)
			surface.DrawText("Mais un medecin peut encore venir vous sauvez")
	
			surface.SetTextPos(ScrW()/2, ScrH()/1.20)
			surface.DrawText(tostring(math.floor((ply:GetNWInt("Partial_death_timer") + WMS.PartialDeathTime + 1) - CurTime())) .. "s")
		end
	end)

	hook.Add("CalcView", "DP_CalcView", function(ply, pos, angles, fov)
		if not(GetConVar("DP_Enabled"):GetBool()) then return end
		if not(GetConVar("DP_PoV"):GetBool()) then return end
		if not(IsValid(ply)) then return end
		if (ply:GetViewEntity() ~= ply) then return end
		local Ragdoll = ply:GetRagdollEntity()
		if not(IsValid(Ragdoll)) then return end
		local view = Ragdoll:GetAttachment(Ragdoll:LookupAttachment("eyes"))
		if not view then return end

		local HeadID = Ragdoll:LookupBone("ValveBiped.Bip01_Head1")
		if (HeadID) then
			Ragdoll:ManipulateBoneScale(HeadID, Vector(.01, .01, .01))
		end

		view.Ang:Normalize()
		local CustomAngle = LerpAngle(GoneFraction ^ .5, LastLivingEyeAngle, view.Ang)

		local playerview = {
			origin = view.Pos,
			angles = CustomAngle,
			znear = 1
		}
	
		return playerview
	end)
end
