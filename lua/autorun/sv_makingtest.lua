if (SERVER)then
	print(GetConVar("developer"):GetInt())
for k,v in pairs(player.GetAll())do
    print(v, v:Alive())
--[[     v:Give("re_hands")
	prone.Exit(v)
	v:EmitSound(WMS.sounds.headshotsounds[math.random(#WMS.sounds.headshotsounds)])
	
	local test = ents.Create("prop_physics")
	test:SetModel("models/hunter/plates/plate.mdl")
	test:FollowBone(v, v:LookupBone("ValveBiped.Bip01_Spine4"))
	local t = v:GetBonePosition(v:LookupBone("ValveBiped.Bip01_Spine4"))
	test:SetPos(t + 10*t:Angle():Forward())

	local a = v:GetAngles()
	--a:Normalize()
	test:SetAngles(a)
	timer.Simple(3, function() test:Remove() end) ]]
end

hook.Add( "SetupMove", "DragWMS", function(ply, mv, cmd)
	local cuffed = ply:GetNWBool("isDragged")
    local kidnapper = ply:GetNWEntity("Kidnapper")
	if (not cuffed) then return end
	--print(ply)
	mv:SetMaxClientSpeed( mv:GetMaxClientSpeed()*0.6 )
	
	if not IsValid(kidnapper) then return end // Nowhere to move to
	
	if kidnapper==ply then return end
	
	local TargetPoint = (kidnapper:IsPlayer() and kidnapper:GetShootPos()) or kidnapper:GetPos()
	local MoveDir = (TargetPoint - ply:GetPos()):GetNormal()
	local ShootPos = ply:GetShootPos() + (Vector(0,0, (ply:Crouching() and 0)))
	local Distance = 30
	
	local distFromTarget = ShootPos:Distance( TargetPoint )
	if distFromTarget<=(Distance+5) then return end
	if ply:InVehicle() then
		if SERVER and (distFromTarget>(Distance*3)) then
			ply:ExitVehicle()
		end
		
		return
	end
	
	local TargetPos = TargetPoint - (MoveDir*Distance)
	
	local xDif = math.abs(ShootPos[1] - TargetPos[1])
	local yDif = math.abs(ShootPos[2] - TargetPos[2])
	local zDif = math.abs(ShootPos[3] - TargetPos[3])
	
	local speedMult = 3+ ( (xDif + yDif)*0.5)^1.01
	local vertMult = math.max((math.Max(300-(xDif + yDif), -10)*0.08)^1.01  + (zDif/2),0)
	
	if kidnapper:GetGroundEntity()==ply then vertMult = -vertMult end
	
	local TargetVel = (TargetPos - ShootPos):GetNormal() * 10
	TargetVel[1] = TargetVel[1]*speedMult
	TargetVel[2] = TargetVel[2]*speedMult
	TargetVel[3] = TargetVel[3]*vertMult
	local dir = mv:GetVelocity()
	
	local clamp = 50
	local vclamp = 20
	local accel = 200
	local vaccel = 30*(vertMult/50)
	
	dir[1] = (dir[1]>TargetVel[1]-clamp or dir[1]<TargetVel[1]+clamp) and math.Approach(dir[1], TargetVel[1], accel) or dir[1]
	dir[2] = (dir[2]>TargetVel[2]-clamp or dir[2]<TargetVel[2]+clamp) and math.Approach(dir[2], TargetVel[2], accel) or dir[2]
	
	if ShootPos[3]<TargetPos[3] then
		dir[3] = (dir[3]>TargetVel[3]-vclamp or dir[3]<TargetVel[3]+vclamp) and math.Approach(dir[3], TargetVel[3], vaccel) or dir[3]
		
		if vertMult>0 then ply.Cuff_ForceJump=ply end
	end
	
	mv:SetVelocity( dir )
end)

end