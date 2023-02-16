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
        local t = vgui.Create("MedicExam")
        t:SetPlayer(ent)

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

        print(ply:Nick() .. " a ouvert le diagnostique sur " .. ent:Nick())
    end
})

properties.Add("Grab", {
    MenuLabel = "#Grab",
    Order = 3,
    Type = "toggle",
    --MenuIcon = "icon16/arrow_up.png",

    PrependSpacer = true,

    Filter = function(self, ent, ply)
        if (not IsValid(ent)) then return false end
        if (not (ent:IsPlayer())) then return false end
        if (not ply:IsAdmin()) then return false end
        if (ent:GetNWBool("isDragged")) then return true end
        if (ent:Health() > 30) then return false end

        return true
    end,

    Checked = function( self, ent, ply )
        return ent:GetNWBool("isDragged")
    end,

    Action = function(self, ent)
        self:MsgStart()
            net.WriteEntity(ent)
        self:MsgEnd()
    end,

    Receive = function(self, length, ply)
        local ent = net.ReadEntity()
        if (not IsValid(ent)) then return end
        if (not self:Filter(ent, ply)) then return end


        if (not ent:GetNWBool("isDragged")) then
            ent:SetNWBool("isDragged", true)
            ent:SetNWEntity("Kidnapper", ply)
        else
            ent:SetNWBool("isDragged", false)
            ent:SetNWEntity("Kidnapper", nil)
        end
    end
})

local debugOrder = {
    "Revive",
    "Partial Death",
    "Repare",
    "Leg Fracture",
    "Right Arm Fracture",
    "Left Arm Fracture",
    "Full Health",
    "Half Health",
    "Low Health",
    "Add diagnostic"
}
local debugFun = {
    ["Revive"] = function(ply)
        ply:Revive()
    end,

    ["Partial Death"] =  function(ply)
        ply:PartialDeath()
    end,

    ["Repare"] = function(ply)
        ply:HealRightArmFracture()
        ply:HealLeftArmFracture()
        ply:HealLegFracture()
    end,

    ["Leg Fracture"] = function(ply)
        ply:LegFracture()
    end,

    ["Right Arm Fracture"] = function(ply)
        ply:RightArmFracture()
    end,

    ["Left Arm Fracture"] = function(ply)
        ply:LeftArmFracture()
    end,

    ["Full Health"] = function(ply)
        ply:SetHealth(100)
    end,

    ["Half Health"] = function(ply)
        ply:SetHealth(50)
    end,

    ["Low Health"] = function(ply)
        ply:SetHealth(20)
    end,
    ["Add diagnostic"] = function(ply)
        ply.wms_dmg_tbl[#ply.wms_dmg_tbl + 1] = {
            damage = 20,
            wms_type = 7,
            h_wep = "OUI"
        }

        WMS.utils.syncDmgTbl(ply, table.Copy(ply.wms_dmg_tbl))
    end,
}
local debugIcon = {
    ["Repare"] = "wrench",
    ["Revive"] = "add",
    ["Partial Death"] = "exclamation",
    ["Leg Fracture"] = "arrow_down",
    ["Right Arm Fracture"] = "resultset_next",
    ["Left Arm Fracture"] = "resultset_previous",
    ["Full Health"] = "heart_add",
    ["Half Health"] = "heart",
    ["Low Health"] = "heart_delete",
    ["Add diagnostic"] = "plus",
}

properties.Add( "debug", {
    MenuLabel = "#Admin Option",
    Order = 5,
    MenuIcon = "icon16/wand.png",

    Filter = function( self, ent, ply )
        if (not WMS.DEBUG) then return false end
        if (not IsValid(ent)) then return false end
        if (not (ent:IsPlayer() or ent:IsPlayerRagdoll())) then return false end
        if (not ply:IsAdmin()) then return false end

        return true
    end,

    MenuOpen = function( self, option, ent, tr )
        local submenu = option:AddSubMenu()

        for k, name in ipairs(debugOrder) do
            --print(name)
            submenu:AddOption( name, function() self:NewAction(ent, name) end)
                            :SetIcon("icon16/" .. debugIcon[name] .. ".png")
        end
    end,



    NewAction = function( self, ent, name )
        self:MsgStart()
            net.WriteEntity(ent)
            net.WriteString(name)
        self:MsgEnd()
    end,

    Action = function( self, ent )
    end,


    Receive = function( self, length, ply )
        local ent = net.ReadEntity()
        if (ent:IsPlayerRagdoll()) then ent = ent:GetCreator() end
        if (not IsValid(ent)) then return end
        if (not self:Filter(ent, ply)) then return end

        local nFun = net.ReadString()

        if (not isstring(nFun)) then return end

        print(nFun)
        debugFun[nFun](ent)


        local ed = EffectData()
        ed:SetEntity( ent )
        util.Effect( "LaserTracer", ed, true, true )
        util.Effect( "entity_remove", ed, true, true )
    end
} )




properties.Add("spacer", {
    MenuLabel = "#",
    Order = 10,

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