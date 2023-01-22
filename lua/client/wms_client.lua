net.Receive( "send_damage_table_to_client", function( len, ply )
	net.ReadEntity().wms_dmg_tbl = net.ReadTable()
    return
end )


hook.Add( "CalcView", "tetet_zz_simfphys_gunner_view", function( ply, pos, ang )
	HintPlayerAboutHisFuckingIncompetence = false

	if not IsValid( ply ) or not ply:Alive() or not ply:InVehicle() or ply:GetViewEntity() ~= ply then return end
	
	local Vehicle = ply:GetVehicle()
	
	if not IsValid( Vehicle ) then return end
	
	local Base = ply.GetSimfphys and ply:GetSimfphys() or Vehicle.vehiclebase
	
	if not IsValid( Base ) then return end
	
	if not Vehicle:GetNWBool( "simfphys_SpecialCam" ) then return end
	
	local view = {
		origin = pos,
		drawviewer = false,
	}
	
	if Vehicle:GetNWBool( "SpecialCam_LocalAngles" ) then
		view.angles = ply:EyeAngles()
	else
		view.angles = Vehicle:LocalToWorldAngles( ply:EyeAngles() )
	end
	
	if Vehicle.GetThirdPersonMode == nil or ply:GetViewEntity() ~= ply then
		return
	end
	
	ply.simfphys_smooth_out = 0
	
	local offset = Vehicle:GetNWVector( "SpecialCam_Thirdperson" )
	
	if not Vehicle:GetThirdPersonMode() then
		local offset = Vehicle:GetNWVector( "SpecialCam_Firstperson" )
		local ID = Base:LookupAttachment( Vehicle:GetNWString( "SpecialCam_Attachment" ) )
		
		if ID == 0 then
			view.origin = view.origin + Vehicle:GetForward() * offset.x + Vehicle:GetRight() * offset.y + Vehicle:GetUp() * offset.z
		else
			local attachment = Base:GetAttachment( ID )
			
			view.origin = attachment.Pos + attachment.Ang:Forward() * offset.x  + attachment.Ang:Right() * offset.y  + attachment.Ang:Up() *  offset.z
		end
		
		return view
	end
	
	view.origin = view.origin + Vehicle:GetForward() * offset.x + Vehicle:GetRight() * offset.y + Vehicle:GetUp() * offset.z
	
	local mn, mx = Vehicle:GetRenderBounds()
	local radius = ( mn - mx ):Length()
	local radius = radius + radius * Vehicle:GetCameraDistance()

	local TargetOrigin = view.origin + ( view.angles:Forward() * -radius )
	local WallOffset = 4

	local tr = util.TraceHull( {
		start = view.origin,
		endpos = TargetOrigin,
		filter = function( e )
			local c = e:GetClass()
			local collide = not c:StartWith( "prop_physics" ) and not c:StartWith( "prop_dynamic" ) and not c:StartWith( "prop_ragdoll" ) and not e:IsVehicle() and not c:StartWith( "gmod_" ) and not c:StartWith( "player" )
			return collide
		end,
		mins = Vector( -WallOffset, -WallOffset, -WallOffset ),
		maxs = Vector( WallOffset, WallOffset, WallOffset ),
	} )

	view.origin = tr.HitPos
	view.drawviewer = true

	if tr.Hit and not tr.StartSolid then
		view.origin = view.origin + tr.HitNormal * WallOffset
	end
	
	return view
end )


surface.CreateFont( "DEATH_SCREEN", {
	font = "DefaultBold",
	size = 130,
} )

surface.CreateFont( "DEATH_SCREEN_LITTLE", {
	font = "DefaultBold",
	size = 50,
} )