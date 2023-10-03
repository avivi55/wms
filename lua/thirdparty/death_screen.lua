AddCSLuaFile()

if (CLIENT) then
	local STATE_ALIVE, STATE_DYING, STATE_GONE = 1, 0, -1
	local MyState = STATE_ALIVE
	local LeaveTime = 0
	local GoneFraction = 0
	local LastLivingEyeAngle = Angle(0, 0, 0)

	hook.Add("Think", "DP_Think", function()
		local ply = LocalPlayer()

		if not(IsValid(ply)) then return end

		if (ply:Alive() and not ply:GetNWBool("isPartiallyDead")) then
			LastLivingEyeAngle = ply:GetAimVector():Angle()
			LastLivingEyeAngle:Normalize()
			if (MyState ~= STATE_ALIVE) then
				MyState = STATE_ALIVE
				LeaveTime = 0
				GoneFraction = 0
				ply:ConCommand("soundfade 0 1")
			end
			
		else
			local Time, Delay = CurTime(), 0.25

			if (MyState == STATE_ALIVE) then
				for _ = 0, 10 do
					ply:EmitSound("aie/Rising_storm_death.wav")
				end
				MyState = STATE_DYING
				LeaveTime = Time + Delay
				GoneFraction = 0

			elseif (MyState == STATE_DYING) then
				local TimeLeft = LeaveTime - Time

				GoneFraction = 1 - (TimeLeft / Delay)
				if (GoneFraction >= 1) then
					GoneFraction = 1

					timer.Simple(0.7, function()
						ply:ConCommand("soundfade 100 99999")
					end)  

					MyState = STATE_GONE
				end
			end
		end
	end)

	hook.Add("PostDrawHUD", "DP_PostdrawHUD", function()
		local ply = LocalPlayer()

		if (ply:Alive() and not ply:GetNWBool("isPartiallyDead")) then return end
		if (ply:GetViewEntity() ~= ply) then return end
		if (GoneFraction <= 0) then return end

		local W, H = ScrW(), ScrH()

		surface.SetDrawColor(0, 0, 0, 255 * GoneFraction ^ 2)
		surface.DrawRect(-W, -H, ScrW() * 3, ScrH() * 3)

		surface.SetTextColor(255, 43, 43)
		surface.SetFont("DEATH_SCREEN")
		local s1 = surface.GetTextSize("VOUS ÊTES MORT")

		surface.SetTextPos((ScrW() / 2) - (s1 / 2), ScrH() / 3)
		surface.DrawText("VOUS ÊTES MORT")

		if (ply:GetNWBool("isPartiallyDead")) then
			surface.SetFont("DEATH_SCREEN_LITTLE")
			s1, s2 = surface.GetTextSize("Mais un medecin peut encore venir vous sauvez")
	
			surface.SetTextPos((ScrW() / 2) - (s1 / 2), ScrH() / 1.5)
			surface.DrawText("Mais un medecin peut encore venir vous sauvez")
	
			surface.SetTextPos(ScrW() / 2, ScrH() / 1.20)
			surface.DrawText(tostring(math.floor((ply:GetNWInt("partialDeathTimer") + WMS.config.partialDeathTime + 1) - CurTime())).."s")
		end
	end)
end
