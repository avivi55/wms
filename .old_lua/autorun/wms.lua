AddCSLuaFile()
AddCSLuaFile("client/wms_client.lua")

WMS = WMS or {}
WMS._VERSION = 0.1

include("autorun/properties/wms_properties.lua")
include("config/sounds.lua")
include("config/config.lua")

include("sh_wms_utils.lua")

include("config/weapons.lua")

include("thirdparty/sh_improved_player_ragdolls.lua")
include("thirdparty/sh_lowhealth.lua")
include("thirdparty/death_screen.lua")

--include("sh_pretty_print.lua")


if (SERVER) then
    include("server/wms_init.lua")
end

if (CLIENT) then
    include("client/wms_client.lua")
end

WMS.utils.loadPrint()