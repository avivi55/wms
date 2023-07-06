AddCSLuaFile()
WMS = WMS or {}
WMS.utils = WMS.utils or {}

-- A naive function to find a value in a table
-- @tparam table table The haystack
-- @tparam any valueToFind The needle
-- @treturn boolean Whether the needle is in the haystack
WMS.utils.tableContains = function(table, valueToFind)

    for _, value in pairs(table) do

        if (value == valueToFind or (type(value) == "table" and WMS.utils.tableContains(value, valueToFind)))then 
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

    if (team ~= "ger" and team ~= "sov") then
        return
    end

    local variation = tostring(math.random(3))

    local folder = team.."_"..variation
    local randomFile = tostring(math.random(WMS.sounds.soundFolderLen[folder]))

    return "aie/"..folder.."/"..team.."_death_voice"..randomFile..".wav"
    
end

-- Loads the necessary files onto the client
-- @treturn nil
WMS.utils.addFileToClient = function()

    for number, length in pairs(WMS.sounds.soundFolderLen) do
        
        for i = 1, length do
            resource.AddFile("sound/aie/"..tostring(number).."/"..tostring(number)
                                .."_death_voice"..tostring(i)..".wav")
        end

    end

    for i = 1, 4 do
        resource.AddFile("sound/aie/ent_tool_melee_00"..tostring(i)..".wav")
    end

    resource.AddFile("sound/aie/Rising_storm_death.wav")

end


-- Syncs the damage table of a player to all clients
-- Ameliorations :
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