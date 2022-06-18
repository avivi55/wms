AddCSLuaFile()
WMS = WMS or {}
WMS.Utils = WMS.Utils or {}

WMS.Utils.tblContains = function(tbl, val)
    for k, v in pairs(tbl) do
        if v == val or (type(v) == "table" and WMS.Utils.tblContains(v, val)) then return true end
    end
    return false
end

WMS.Utils.loadPrint = function()
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

WMS.Utils.getRandomDeathSound = function(team)
    local man = tostring(math.random(3))
    if (team == "ger" or team == "sov") then
        local folder = team .. "_" .. man
        local file_rand = tostring(math.random(WMS.sounds.sound_folder_len[folder]))

        return "aie/" .. folder .. "/" .. team .. "_death_voice" .. file_rand .. ".wav"
    else
        print("la team n'est pas bonne")
    end
end

WMS.Utils.addFileToClient = function()
    for k, len in pairs(WMS.sounds.sound_folder_len) do
        for i = 1, len do
            resource.AddFile("sound/aie/" .. tostring(k) .. "/" .. tostring(k) .. "_death_voice" .. tostring(i) .. ".wav")
        end
    end
end