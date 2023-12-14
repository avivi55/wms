WMS.utils.addFileToClient()
util.AddNetworkString("send_damage_table_to_client")

include("./damage_system/main.lua")


hook.Add("SetupMove", "WMS::DragSystem", function(ply, mv, cmd)

	if (not ply:GetNWBool("isDragged")) then return end

	local kidnapper = ply:GetNWEntity("Kidnapper")

	if (not IsValid(kidnapper)) then return end -- Nowhere to move to

	if (kidnapper == ply) then return end
	
	mv:SetMaxClientSpeed(mv:GetMaxClientSpeed() * 0.6)

	local targetPoint = kidnapper:IsPlayer() and kidnapper:GetShootPos() or kidnapper:GetPos()
	local moveDirection = (targetPoint - ply:GetPos()):GetNormal()
	local shootPosition = ply:GetShootPos() + (Vector(0,0, ply:Crouching() and 0))
	local distance = 30

	local distanceFromTarget = shootPosition:distance(targetPoint)

	if (distanceFromTarget <= (distance + 5)) then return end

	if ply:InVehicle() then

		if (SERVER and (distanceFromTarget > (distance * 3))) then
			ply:ExitVehicle()
		end

		return

	end

	local targetPosition = targetPoint - (moveDirection * distance)

	local xDif = math.abs(shootPosition[1] - targetPosition[1])
	local yDif = math.abs(shootPosition[2] - targetPosition[2])
	local zDif = math.abs(shootPosition[3] - targetPosition[3])

	local speedMultiplier = 3 + ((xDif + yDif) * 0.5)
	local verticalMultiplier = math.max((math.max(300-(xDif + yDif), -10) * 0.08) + (zDif / 2),0)

	if (kidnapper:GetGroundEntity() == ply) then 
		verticalMultiplier = -verticalMultiplier 
	end

	local targetVelocity = (targetPosition - shootPosition):GetNormal() * 10

	targetVelocity[1] = targetVelocity[1] * speedMultiplier
	targetVelocity[2] = targetVelocity[2] * speedMultiplier
	targetVelocity[3] = targetVelocity[3] * verticalMultiplier

	local dir = mv:GetVelocity()

	local clamp = 50
	local vclamp = 20
	local accel = 200
	local vaccel = 30 * (verticalMultiplier / 50)

	dir[1] = (dir[1] > targetVelocity[1]-clamp or dir[1] < targetVelocity[1] + clamp) and math.Approach(dir[1], targetVelocity[1], accel) or dir[1]
	dir[2] = (dir[2] > targetVelocity[2]-clamp or dir[2] < targetVelocity[2] + clamp) and math.Approach(dir[2], targetVelocity[2], accel) or dir[2]

	if (shootPosition[3] < targetPosition[3]) then

		dir[3] = (dir[3] > targetVelocity[3]-vclamp or dir[3] < targetVelocity[3] + vclamp) 
			and math.Approach(dir[3], targetVelocity[3], vaccel) 
			or dir[3]

		if (verticalMultiplier > 0) then 
			ply.Cuff_ForceJump = ply 
		end

	end

	mv:SetVelocity(dir)

end)