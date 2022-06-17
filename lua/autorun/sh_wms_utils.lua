WMS = WMS or {}
WMS.Utils = WMS.Utils or {}

WMS.Utils.tblContains = function(tbl, val)
    for k, v in pairs(tbl) do
        if v == val or (type(v) == "table" and WMS.Utils.tblContains(v, val)) then return true end
    end
    return false
end