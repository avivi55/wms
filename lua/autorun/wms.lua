AddCSLuaFile()
WMS = WMS or {}

include("sh_wms_utils.lua")

if (SERVER) then
        include("server/wms_init.lua")
end

WMS.Utils.loadPrint()

