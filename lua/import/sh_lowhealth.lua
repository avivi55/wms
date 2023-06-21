if SERVER then
	resource.AddFile("materials/vgui/vignette_w.vmt")
	resource.AddFile("sound/lowhp/hbeat.wav")
end

AddCSLuaFile()

-- LITTERALLY STOLEN (https://steamcommunity.com/sharedfiles/filedetails/?id=652896605)

if CLIENT then
	local intensity = 0
	local hpwait, hpalpha = 0, 0
	local vig = surface.GetTextureID("vgui/vignette_w")
	
	local clr = {
		[ "$pp_colour_addr" ] = 0,
		[ "$pp_colour_addg" ] = 0,
		[ "$pp_colour_addb" ] = 0,
		[ "$pp_colour_brightness" ] = 0,
		[ "$pp_colour_contrast" ] = 1,
		[ "$pp_colour_colour" ] = 1,
		[ "$pp_colour_mulr" ] = 0,
		[ "$pp_colour_mulg" ] = 0,
		[ "$pp_colour_mulb" ] = 0
	}

	local function LowHP_HUDPaint()
		local ply = LocalPlayer()
		local hp = ply:Health()
		local x, y = ScrW(), ScrH()
		local FT = FrameTime()
		
		if false then
			if ply:Health() <= 40 then
				if !ply.lastDSP then
					ply:SetDSP(14)
					ply.lastDSP = 14
				end
			else
				if ply.lastDSP then
					ply:SetDSP(0)
					ply.lastDSP = nil
				end
			end
		end
		
		intensity = math.Approach(intensity, math.Clamp(1 - math.Clamp(hp / 40, 0, 1), 0, 1), FT * 3)
		
		if intensity > 0 then
			
			surface.SetDrawColor(0, 0, 0, 200 * intensity)
			surface.SetTexture(vig)
			surface.DrawTexturedRect(0, 0, x, y)
			
			clr[ "$pp_colour_colour" ] = 1 - intensity
			DrawColorModify(clr)
			
			if (!ply:Alive()) then return end

			local CT = CurTime()
			
			if CT > hpwait then 
				ply:EmitSound("lowhp/hbeat.wav", 45 * intensity, 100 + 20 * intensity)
				hpwait = CT + 0.5 
			end

			surface.SetDrawColor(255, 0, 0, (50 * intensity) * hpalpha)
			surface.DrawTexturedRect(0, 0, x, y)
			
			if CT < hpwait - 0.4 then
				hpalpha = math.Approach(hpalpha, 1, FrameTime() * 10)
			else
				hpalpha = math.Approach(hpalpha, 0.33, FrameTime() * 10)
			end
		end	
	end
	
	hook.Add("HUDPaint", "LowHP_HUDPaint", LowHP_HUDPaint)
end