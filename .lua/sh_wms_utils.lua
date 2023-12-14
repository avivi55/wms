AddCSLuaFile()
WMS = WMS or {}
WMS.utils = WMS.utils or {}

-- A naive function to find a value in a table
-- @tparam table table The haystack
-- @tparam any valueToFind The needle
-- @treturn boolean Whether the needle is in the haystack
WMS.utils.tableContains = function(table, valueToFind)
	for _, value in pairs(table) do
		if value == valueToFind or (type(value) == "table" and WMS.utils.tableContains(value, valueToFind)) then
			return true
		end
	end

	return false
end

-- Prints a message in the console on server start
-- @treturn nil
WMS.utils.loadPrint = function()
	print()
	MsgC("WMS Enabled", "\n", Color(255, 0, 0))
	print()
end

-- Gives a random audio file for a specified team
-- @tparam string team The team of the player
-- @treturn ?string A path to a random death track for the specified team.
WMS.utils.getRandomDeathSound = function(team)
	if team ~= "ger" and team ~= "sov" then
		return
	end

	local variation = tostring(math.random(3))

	local folder = team .. "_" .. variation
	local randomFile = tostring(math.random(WMS.sounds.soundFolderLen[folder]))

	return "aie/" .. folder .. "/" .. team .. "_death_voice" .. randomFile .. ".wav"
end

-- Loads the necessary files onto the client
-- @treturn nil
WMS.utils.addFileToClient = function()
	for number, length in pairs(WMS.sounds.soundFolderLen) do
		for i = 1, length do
			resource.AddFile(
				"sound/aie/" .. tostring(number) .. "/" .. tostring(number) .. "_death_voice" .. tostring(i) .. ".wav"
			)
		end
	end

	for i = 1, 4 do
		resource.AddFile("sound/aie/ent_tool_melee_00" .. tostring(i) .. ".wav")
	end

	resource.AddFile("sound/aie/Rising_storm_death.wav")
end

-- Syncs the damage table of a player to all clients
-- Possible upgrades :
-- The Broadcast is probably inefficient. The point here is to give the information to medics, who
-- should be the only ones to access the damage table of a given player.
-- @tparam Player player The player
-- @tparam table damageTable The player's damage table
-- @treturn nil
WMS.utils.syncDamageTable = function(player, damageTable)
	net.Start("send_damage_table_to_client")
	net.WriteEntity(player)
	net.WriteTable(damageTable)
	net.Broadcast()
end

-- Nice printing for the damage table while debugging
-- @tparam table damageTable The player's damage table
-- @treturn nil
WMS.utils.__debugPrintDamageTable = function(damagesTable)
	for i, damageTable in pairs(damagesTable) do
		print("╭──────────────────╮")
		Msg("│" .. "\27[1;4;37m")
		Msg("Damage n°" .. i)
		Msg("\27[0m        │\n")

		local s = "  "
		local ss = "    "

		Msg("│" .. s .. "\27[4;90m")
		Msg("État")
		Msg("\27[0m")
		if damageTable.totalDeath then
			Msg("\27[91m")
			print(s .. "MORT\27[0m      │")
		elseif damageTable.partialDeath then
			Msg("\27[38;5;166m")
			print(s .. "COMA\27[0m      │")
		else
			Msg("\27[32m")
			print(s .. "EN VIE\27[0m    │")
		end
		Msg("\27[0m")

		Msg("│" .. "\27[90m")
		Msg("┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄")
		Msg("\27[0m" .. "│\n")

		if damageTable.verboseDamageArea then
			Msg("│" .. s .. "\27[4;90m")
			Msg("Area")
			Msg("\27[0m")

			Msg("\27[38;5;111m")
			print(
				s
					.. damageTable.verboseDamageArea
					.. "\27[0m"
					.. (string.rep(" ", 19 - (string.len(damageTable.verboseDamageArea) + 9)))
					.. "│"
			)
			Msg("\27[0m")
		end

		if damageTable.damageAmount and isnumber(damageTable.damageAmount) then
			Msg("│" .. s .. "\27[4;90m")
			Msg("Damage")
			Msg("\27[0m")

			Msg("\27[38;5;64m")
			print(
				s
					.. damageTable.damageAmount
					.. "\27[0m"
					.. (string.rep(" ", 19 - (string.len(tostring(damageTable.damageAmount)) + 11)))
					.. "│"
			)
			Msg("\27[0m")
		end

		if damageTable.customDamageType then
			Msg("│" .. s .. "\27[4;90m")
			Msg("Type")
			Msg("\27[0m")

			Msg("\27[38;5;6m")
			Msg(s .. damageTable.verboseType .. (string.rep(" ", 19 - (string.len(damageTable.verboseType) + 8))))
			Msg("\27[0m│\n")
		end

		Msg("│" .. "\27[90m")
		Msg("┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄")
		Msg("\27[0m" .. "│\n")

		Msg("│" .. s .. "\27[4;90m")
		Msg("Misc")
		Msg("\27[0m            │")

		if damageTable.brokenRightArm then
			Msg("\n│" .. "\27[38;5;124m")
			Msg(ss .. "Bras Droit")
			Msg("\27[0m    │")
		end
		if damageTable.brokenLeftArm then
			Msg("\n│" .. "\27[38;5;124m")
			Msg(ss .. "Bras Gauche")
			Msg("\27[0m   │")
		end
		if damageTable.hemorrhage then
			Msg("\n│" .. "\27[38;5;124m")
			Msg(ss .. "Hemorrhage")
			Msg("\27[0m    │")
		end

		print("\n╰──────────────────╯")
	end
end
