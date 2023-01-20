AddCSLuaFile()
AddCSLuaFile("client/wms_client.lua")
WMS = WMS or {}
--PrintTable(WMS.sounds)

include("autorun/properties/wms_properties.lua")
include("config/sounds.lua")
include("config/weapons.lua")
include("config/config.lua")

include("sh_wms_utils.lua")

if (SERVER) then
    include("prettyPrint.lua")
    include("server/wms_init.lua")
end

if (CLIENT) then
    include("client/wms_client.lua")
end

WMS.Utils.loadPrint()