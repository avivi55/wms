AddCSLuaFile()
WMS = WMS or {}
WMS.utils = WMS.utils or {}

WMS.utils.tblContains = function(tbl, val)

    for k, v in pairs(tbl) do
        if v == val or (type(v) == "table" and WMS.utils.tblContains(v, val)) then 
            return true 
        end
    end

    return false

end

WMS.utils.loadPrint = function()

    MsgC([[
 ██╗    ██╗██╗███╗   ██╗███╗   ██╗██╗███████╗███████╗
 ██║    ██║██║████╗  ██║████╗  ██║██║██╔════╝██╔════╝
 ██║ █╗ ██║██║██╔██╗ ██║██╔██╗ ██║██║█████╗  ███████╗
 ██║███╗██║██║██║╚██╗██║██║╚██╗██║██║██╔══╝  ╚════██║
 ╚███╔███╔╝██║██║ ╚████║██║ ╚████║██║███████╗███████║
  ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝╚═╝  ╚═══╝╚═╝╚══════╝╚══════╝]], "\n", Color(255, 0, 0))
    MsgC([[
         ███╗   ███╗███████╗██████╗ ██╗ ██████╗ █████╗ ██╗     
         ████╗ ████║██╔════╝██╔══██╗██║██╔════╝██╔══██╗██║     
         ██╔████╔██║█████╗  ██║  ██║██║██║     ███████║██║     
         ██║╚██╔╝██║██╔══╝  ██║  ██║██║██║     ██╔══██║██║     
         ██║ ╚═╝ ██║███████╗██████╔╝██║╚██████╗██║  ██║███████╗
         ╚═╝     ╚═╝╚══════╝╚═════╝ ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝]], "\n", Color(255, 255, 255))
    MsgC([[
                 ███████╗██╗   ██╗███████╗████████╗███████╗███╗   ███╗
                 ██╔════╝╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔════╝████╗ ████║
                 ███████╗ ╚████╔╝ ███████╗   ██║   █████╗  ██╔████╔██║
                 ╚════██║  ╚██╔╝  ╚════██║   ██║   ██╔══╝  ██║╚██╔╝██║
                 ███████║   ██║   ███████║   ██║   ███████╗██║ ╚═╝ ██║
                 ╚══════╝   ╚═╝   ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝]], "\n", Color(255, 0, 0))
    MsgC([[
 ███████╗███╗   ██╗ █████╗ ██████╗ ██╗     ███████╗██████╗   ██╗
 ██╔════╝████╗  ██║██╔══██╗██╔══██╗██║     ██╔════╝██╔══██╗  ██║
 █████╗  ██╔██╗ ██║███████║██████╔╝██║     █████╗  ██║  ██║  ██║
 ██╔══╝  ██║╚██╗██║██╔══██║██╔══██╗██║     ██╔══╝  ██║  ██║  ╚═╝
 ███████╗██║ ╚████║██║  ██║██████╔╝███████╗███████╗██████╔╝  ██╗
 ╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚══════╝╚═════╝   ╚═╝]], Color(0, 255, 0))
    print()

end

WMS.utils.getRandomDeathSound = function(team)

    local man = tostring(math.random(3))

    if (team == "ger" or team == "sov") then

        local folder = team.."_"..man
        local file_rand = tostring(math.random(WMS.sounds.soundFolderLen[folder]))

        return "aie/"..folder.."/"..team.."_death_voice"..file_rand..".wav"
    end

    print("la team n'est pas bonne")

end

WMS.utils.addFileToClient = function()

    for k, len in pairs(WMS.sounds.soundFolderLen) do
        
        for i = 1, len do
            resource.AddFile("sound/aie/"..tostring(k).."/"..tostring(k)
                                .."_death_voice"..tostring(i)..".wav")
        end

    end

    for i = 1, 4 do
        resource.AddFile("sound/aie/ent_tool_melee_00"..tostring(i)..".wav")
    end

    resource.AddFile("sound/aie/Rising_storm_death.wav")

end

WMS.utils.syncDmgTbl = function(ply, dmg)

    net.Start("send_damage_table_to_client")
        net.WriteEntity(ply)
        net.WriteTable(dmg)
    net.Broadcast()

end