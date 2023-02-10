AddCSLuaFile()
AddCSLuaFile("client/wms_client.lua")
WMS = WMS or {}

include("autorun/properties/wms_properties.lua")
include("config/sounds.lua")
include("config/weapons.lua")
include("config/config.lua")

include("sh_wms_utils.lua")

include("prettyPrint.lua")

if (SERVER) then
    include("server/wms_init.lua")
end

if (CLIENT) then
    include("client/wms_client.lua")
end

WMS.utils.loadPrint()