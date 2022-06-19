AddCSLuaFile()
AddCSLuaFile("client/wms_death_screen.lua")
WMS = WMS or {}
--PrintTable(WMS.sounds)

include("config/sounds.lua")
include("config/weapons.lua")

include("sh_wms_utils.lua")

if (SERVER) then
    include("prettyPrint.lua")
    include("server/wms_init.lua")
end

WMS.Utils.loadPrint()

