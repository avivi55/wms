AddCSLuaFile()
AddCSLuaFile("client/test.lua")
WMS = WMS or {}
--PrintTable(WMS.sounds)

include("config/sounds.lua")
include("config/weapons.lua")

include("sh_wms_utils.lua")

if (SERVER) then
    include("server/wms_init.lua")
end

-- if (CLIENT) then
--     include("client/test.lua")
-- end

WMS.Utils.loadPrint()

