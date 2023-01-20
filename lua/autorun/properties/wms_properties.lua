AddCSLuaFile()

properties.Add("pulse", {
    MenuLabel = "#Pulse",
    Order = 1,
    MenuIcon = "icon16/heart.png",

    PrependSpacer = true,

    Filter = function(self, ent, ply)
        if (not IsValid(ent)) then return false end
        if (not (ent:IsPlayer() or ent:IsPlayerRagdoll())) then return false end
        if (not ply:IsAdmin()) then return false end

        return true
    end,

    Action = function(self, ent)
        self:MsgStart()
            net.WriteEntity(ent)
        self:MsgEnd()
    end,

    Receive = function(self, length, ply)
        if (not IsValid(ply)) then return end
        local ent = net.ReadEntity()
        if (ent:IsPlayerRagdoll()) then ent = ent:GetCreator() end
        if (not IsValid(ent)) then return end
        if (not self:Filter(ent, ply)) then return end

        local pulse = tostring(ent:GetNWInt("Pulse"))
        ply:ChatPrint("Le patient à : " .. pulse .. " de pouls")
    end
})


properties.Add("medic_sheet", {
    MenuLabel = "#Fiche diagnostics",
    Order = 2,
    MenuIcon = "icon16/folder_heart.png",

    Filter = function(self, ent, ply)
        if (not IsValid(ent)) then return false end
        if (not (ent:IsPlayer() or ent:IsPlayerRagdoll())) then return false end
        if (not ply:IsAdmin()) then return false end
        --local panel = vgui.Create("DFrame")
        
        return true
    end,

    Action = function(self, ent)
        local dmgs = ent.wms_dmg_tbl or {}

        print("test", #dmgs)
        local str = ""
        if (ent:IsPlayerRagdoll()) then str = str .. "MORT" end
        for k, dmg in pairs(dmgs) do
            str = str .. "Diagnostic n°" .. tostring(k) .. "\n"
            if (isstring(dmg.h_hit_grp)) then str = str .. "- Localisation : " .. dmg.h_hit_grp .. "\n" end
            if (isstring(dmg.h_wep)) then str = str .. "- Type de dégats : " .. dmg.h_wep .. "\n" end
            if (isnumber(dmg.damage)) then str = str .. "- Dégats : " .. tostring(math.Round(dmg.damage)) .. "\n" end
            if (ent:GetNWBool("hemo")) then str = str .. "HÉMORAGIE!!\n" end
            str = str .. "\n"
        end

        print(str)

        self:MsgStart()
            net.WriteEntity(ent)
        self:MsgEnd()
    end,

    Receive = function(self, length, ply)
        if (not IsValid(ply)) then return end
        local ent = net.ReadEntity()
        if (ent:IsPlayerRagdoll()) then ent = ent:GetCreator() end
        if (not IsValid(ent)) then return end
        if (not self:Filter(ent, ply)) then return end

        local dmgs = ent.wms_dmg_tbl or {}

        print("test", #dmgs)
        print(ply:Nick() .. " a ouvert le diagnostique sur " .. ent:Nick())
    end
})

properties.Add("revive", {
    MenuLabel = "#Revive",
    Order = 3,
    MenuIcon = "icon16/heart_add.png",

    PrependSpacer = true,

    Filter = function(self, ent, ply)
        if (not IsValid(ent)) then return false end
        if (not (ent:IsPlayer() or ent:IsPlayerRagdoll())) then return false end
        if (not ply:IsAdmin()) then return false end

        return true
    end,

    Action = function(self, ent)
        self:MsgStart()
            net.WriteEntity(ent)
        self:MsgEnd()
    end,

    Receive = function(self, length, ply)
        local ent = net.ReadEntity()
        if (ent:IsPlayerRagdoll()) then ent = ent:GetCreator() end
        if (not IsValid(ent)) then return end
        if (not self:Filter(ent, ply)) then return end

        ent:Revive()
    end
})

properties.Add("spacer", {
    MenuLabel = "#",
    Order = 4,

    Filter = function(self, ent, ply)
        if (not IsValid(ent)) then return false end
        if (not (ent:IsPlayer() or ent:IsPlayerRagdoll())) then return false end
        if (not ply:IsAdmin()) then return false end

        return true 
    end,

    Action = function(self, ent)
        return
    end
})