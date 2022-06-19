WMS.Utils.addFileToClient()


local dmg_meta = FindMetaTable("CTakeDamageInfo")

function dmg_meta:SetFromTbl(dmg_tbl)
    if (IsValid(dmg_tbl.pos)) then
        self:SetDamagePosition(dmg_tbl.pos)
    end

    if (IsValid(dmg_tbl.attacker)) then
        self:SetAttacker(dmg_tbl.attacker)
    end

    if (IsValid(dmg_tbl.inflictor)) then
        self:SetInflictor(dmg_tbl.inflictor)
    end

    if (isnumber(dmg_tbl.damage)) then
        self:SetDamage(dmg_tbl.damage)
    end

    if (isnumber(dmg_tbl.type)) then
        self:SetDamageType(dmg_tbl.type)
    end
end

include("server/wms_dmg_system.lua")