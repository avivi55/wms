if (SERVER) then return end

for k,v in pairs(player.GetAll())do
    local function getW(w)
        return (w/1024) * ScrW()        
    end

    local function getH(h)
        return (h/768) * ScrH()        
    end

    do -- mEDIC WEAPON
        local PANEL = {}
        function PANEL:Init()
            local panel = self
            local panelPadding = 20

            local choiseSize = 80
            local Choises = {
                {
                    name = "BANDAGE",
                    img = "ui/quickclot_ca.png",
                    fun = function() panel:Remove() end
                },
                {
                    name = "PAUMADE",
                    img = "ui/paumade.png",
                    fun = function() panel:Remove() end
                },
                {
                    name = "SUTURE",
                    img = "ui/stitch.png",
                    fun = function() panel:Remove() end
                },
                {
                    name = "TOURNIQUET",
                    img = "ui/tourniquet.png",
                    fun = function() panel:Remove() end
                },
                {
                    name = "MORPHINE",
                    img = "ui/morphine.png",
                    fun = function() panel:Remove() end
                },
                {
                    name = "antibiotic",
                    img = "ui/antibiotics2.png",
                    fun = function() panel:Remove() end
                },
                {
                    name = "Iodine",
                    img = "ui/iodine.png",
                    fun = function() panel:Remove() end
                },
            }


            local W, H = #Choises*(panelPadding + choiseSize) +  panelPadding, getH(200)
            self:SetSize(W, H)
            self:CenterHorizontal()
            self:CenterVertical(0.9)

            --print(H)

            self.topShelf = vgui.Create( "DPanel", self )
            self.topShelf:SetSize(W, getH(15))
            self.topShelf:SetPos(0, 0)
            self.topShelf.Paint = function(self, w, h)
                surface.SetDrawColor(255,255,255,0)
                surface.DrawRect(0, 0, w, h)
            end
            
            local _, topH = self.topShelf:GetSize()
            self.mainShelf = vgui.Create( "DPanel", self )
            self.mainShelf:SetSize(W, H-topH)
            self.mainShelf:SetPos(0, topH)
            local main = self.mainShelf
            W, H = main:GetSize()


            do -- CLOSE BUTTON
                local cb = vgui.Create( "DLabel", self.topShelf )
                local parent = cb:GetParent()
                cb:SetMouseInputEnabled(true)
                cb:SetText("")
                cb:SetPos( 0, 0 )
                local sw, sh = parent:GetSize()
                cb:SetSize( sw, sh )
                --print(sw, sh)
                cb.DoClick = function() panel:Remove() end
                cb.Paint = function(self,w,h)
                    draw.RoundedBoxEx(8, 0, 0, w, h, Color(255, 0, 0), true, true)
                    surface.SetDrawColor(255, 255, 255)
                end
            end




            --print(H,H/2)
            local x = panelPadding
            for _, choise in pairs(Choises) do
                local t = vgui.Create("MedicChoise", main)
                --t:SetKeepAspect(true)
                t:SetImage(choise.img)
                t:SetName(choise.name)
                t:SetSize(choiseSize, choiseSize)
                t:SetPos(x, (H/2) - (choiseSize/2))
                t.DoClick = choise.fun
                x = x + panelPadding + choiseSize
            end

        end

        function PANEL:Paint(W, H) end
        vgui.Register("MedicPanel", PANEL, "DPanel")
    end
    
    do -- MedicChoise
        local PANEL = {}
        AccessorFunc(PANEL, "name", "Name", FORCE_STRING)
        function PANEL:Init()
            if (not self:GetParent()) then return  end
            timer.Simple(0.1, function() self:SetTooltip(self:GetName()) end)
        end

        vgui.Register("MedicChoise", PANEL, "DImageButton")
    end

    do -- MedicCloseButton
        local PANEL = {}

        function PANEL:Init()
            local parent = self:GetParent()
            self:SetMouseInputEnabled(true)
            self:SetText("")
            self:SetPos( 0, 0 )
            local sw, sh = parent:GetSize()
            self:SetSize( sw, sh )
            --print(sw, sh)
            self.DoClick = function() parent:Remove() end
        end
        function PANEL:Paint(w,h)
            draw.RoundedBoxEx(8, 0, 0, w, h, Color(255, 0, 0), true, true)
            surface.SetDrawColor(255, 255, 255)
        end
        vgui.Register("MedicCloseButton", PANEL, "DLabel")
    end

    do -- MedicPlayerPrint TODO
        local PANEL = {}
        AccessorFunc(PANEL, "t", "TorsoDamage", FORCE_BOOL)
        AccessorFunc(PANEL, "h", "HeadDamage", FORCE_BOOL)
        AccessorFunc(PANEL, "a_r", "ArmRightDamage", FORCE_BOOL)
        AccessorFunc(PANEL, "a_l", "ArmLeftDamage", FORCE_BOOL)
        AccessorFunc(PANEL, "l_r", "LegRightDamage", FORCE_BOOL)
        AccessorFunc(PANEL, "l_l", "LegLeftDamage", FORCE_BOOL)

        function PANEL:Init()
            self.name = vgui.Create("DLabel", self)
            self.background = vgui.Create("DImage", self)
            self.head = vgui.Create("DImage", self)
            self.torso = vgui.Create("DImage", self)
            self.arm_right = vgui.Create("DImage", self)
            self.arm_left = vgui.Create("DImage", self)
            self.leg_right = vgui.Create("DImage", self)
            self.leg_left = vgui.Create("DImage", self)
            self.arm_right_b = vgui.Create("DImage", self)
            self.arm_left_b = vgui.Create("DImage", self)
            self.leg_right_b = vgui.Create("DImage", self)
            self.leg_left_b = vgui.Create("DImage", self)


            self.background:SetImage("vgui/body/background.png")
            self.head:SetImage("vgui/body/head.png")
            self.torso:SetImage("vgui/body/torso.png")
            self.arm_right:SetImage("vgui/body/arm_right.png")
            self.arm_left:SetImage("vgui/body/arm_left.png")
            self.leg_right:SetImage("vgui/body/leg_right.png")
            self.leg_left:SetImage("vgui/body/leg_left.png")
            self.arm_right_b:SetImage("vgui/body/arm_right_b.png")
            self.arm_left_b:SetImage("vgui/body/arm_left_b.png")
            self.leg_right_b:SetImage("vgui/body/leg_right_b.png")
            self.leg_left_b:SetImage("vgui/body/leg_left_b.png")

            self.background:SetKeepAspect(true)
            self.head:SetKeepAspect(true)
            self.torso:SetKeepAspect(true)
            self.arm_right:SetKeepAspect(true)
            self.arm_left:SetKeepAspect(true)
            self.leg_right:SetKeepAspect(true)
            self.leg_left:SetKeepAspect(true)
            self.arm_right_b:SetKeepAspect(true)
            self.arm_left_b:SetKeepAspect(true)
            self.leg_right_b:SetKeepAspect(true)
            self.leg_left_b:SetKeepAspect(true)
            
            self.background:SetPos(0, 0)
            self.head:SetPos(0, 0)
            self.torso:SetPos(0, 0)
            self.arm_right:SetPos(0, 0)
            self.arm_left:SetPos(0, 0)
            self.leg_right:SetPos(0, 0)
            self.leg_left:SetPos(0, 0)
            self.arm_right_b:SetPos(0, 0)
            self.arm_left_b:SetPos(0, 0)
            self.leg_right_b:SetPos(0, 0)
            self.leg_left_b:SetPos(0, 0)
        end

        function PANEL:Paint(w, h)
            --print(self.name:GetText() )
            if(self.name:GetText() == "Label")then
                local n = self:GetParent():GetParent():GetPlayer():Nick()
                self.name:SetText(n)
                self.name:SetPos(w/2 - surface.GetTextSize(n)/2 +1, 0)
                self.name:SetColor(Color(255, 255, 255))
            end

            if(self.background:GetSize() != w)then
                self.background:SetSize(w, h)
                self.head:SetSize(w, h)
                self.torso:SetSize(w, h)
                self.arm_right:SetSize(w, h)
                self.arm_left:SetSize(w, h)
                self.leg_right:SetSize(w, h)
                self.leg_left:SetSize(w, h)
                self.arm_right_b:SetSize(w, h)
                self.arm_left_b:SetSize(w, h)
                self.leg_right_b:SetSize(w, h)
                self.leg_left_b:SetSize(w, h)
            end

            self.head:SetImageColor(Color(255, 0, 0))
            self.torso:SetImageColor(Color(98, 0, 255))
            self.arm_right_b:SetImageColor(Color(255, 0, 0))

            draw.RoundedBox(0, 0, 0, 3, h, Color(0, 0, 0, 200))
        end
        vgui.Register("MedicPlayerPrint", PANEL, "DPanel")
    end

    do -- MedicDiagnostic
        local PANEL = {}
        AccessorFunc(PANEL, "source", "Source", FORCE_STRING)
        AccessorFunc(PANEL, "area", "Area", FORCE_STRING)
        AccessorFunc(PANEL, "n", "Number", FORCE_NUMBER)
        AccessorFunc(PANEL, "dmg", "Damage", FORCE_NUMBER)
        function PANEL:Init()
            self.image = vgui.Create("DImage", self)
            self.body_img = vgui.Create("DImage", self)
        end

        function PANEL:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(78, 78, 78, 50))

            draw.RoundedBox(0, 0 ,0, h/4, h/4, Color(46, 46, 46))
            draw.Text({text = "n°"..self:GetNumber(), pos = {0, h/16}})
            
            --draw.RoundedBox(0, h/4, 0, w-h/4, h/4, Color(0, 0, 0, 175))
            draw.RoundedBox(0, h/4, 0, ((w-h/4)*self:GetDamage())/100, h/4, Color(81, 78, 230, 232))
            draw.Text({text = " "..self:GetDamage(), pos = {w/2 - h/8, h/16}})
            
            draw.RoundedBox(0, w/2, h/4, 3, h-h/4, Color(0, 0, 0, 232))
            
            if(self.image:GetImage() == "")then
                local x = ((w/2) - (3/4*h))/2
                local source = self:GetSource()
                self.image:SetImage("vgui/wep/"..source..".png")
                self.image:SetPos(x, h/4)
                self.image:SetSize(3/4 * h, 3/4 * h)
                
                local area = self:GetArea()
                self.body_img:SetImage("vgui/body/"..area..".png")
                self.body_img:SetPos(w/2 + x, h/4)
                self.body_img:SetSize(3/4*h, 3/4*h)
                self.body_img:SetImageColor(Color(255, 0, 0))
            end
        end

        vgui.Register("MedicDiagnostic", PANEL, "DPanel")
    end

    do -- MedicDiagnostics
        local PANEL = {}

        function PANEL:Init() self.t = false end

        function PANEL:Paint(w, h)
            local grandParent = self:GetParent():GetParent()

            if(self.t)then return end
            self.t = true 
            local dmgs = grandParent:GetPlayer().wms_dmg_tbl or {}

            for k, dmg in pairs(dmgs) do
                --print(dmg.h_wep, dmg.damage, WMS.DmgAreaT[dmg.hit_grp])
                local t = self:Add("MedicDiagnostic")
                t:SetArea(WMS.DmgAreaT[dmg.hit_grp])
                t:SetDamage(dmg.damage)
                t:SetNumber(k)
                if(dmg.h_wep == "")then
                    t:SetSource("rifle")
                else
                    t:SetSource(dmg.h_wep or "rifle")
                end
                t:SetSize(w, h/4)
                t:Dock(TOP)

                local l = self:Add("DPanel")
                l:SetHeight(10)
                l.Paint = function(self, w, h) return end
                l:Dock(TOP)
            end            
        end

        vgui.Register("MedicDiagnostics", PANEL, "DScrollPanel")
    end

    do
        local PANEL = {}
        AccessorFunc(PANEL, "player", "Player")
        function PANEL:Init()
            local panel = self
            local W, H = getW(600), getH(400)
            self:MakePopup()
            self:SetSize(W, H)
            self:CenterHorizontal()
            self:CenterVertical()

            local ply = self:GetPlayer()
            self.topShelf = vgui.Create( "DPanel", self )
            self.topShelf:SetSize(W, getH(15))
            self.topShelf:SetPos(0, 0)
            self.topShelf.Paint = function(self, w, h)
            end
            self.topShelf.OnRemove = function()
                panel:Remove()
            end
            -- CLOSE BUTTON
            vgui.Create("MedicCloseButton", self.topShelf)
            
            local _, topH = self.topShelf:GetSize()
            self.mainShelf = vgui.Create( "DPanel", self )
            self.mainShelf:SetSize(W, H-topH)
            self.mainShelf:SetPos(0, topH)
            local main = self.mainShelf
            main.Paint = function(s, w, h) 
                surface.SetDrawColor(Color(0, 0, 0, 240))
                surface.DrawRect(0, 0, w, h)
                if(ply)then
                    draw.RoundedBox(0, 0, h-h/8, w/2, h/8, Color(0, 0, 0, 157))
                    draw.RoundedBox(0, 0, h-h/8, (ply:Health() * w)/200, h/8, Color(255, 96, 96, 232))
                    local w_, h_ = surface.GetTextSize(ply:Health())
                    draw.Text({text = ply:Health(), pos = {w/4, (h-h/16)-h_/2}})
                    return 
                end
                ply = self:GetPlayer()
            end
            W, H = main:GetSize()


            local playerModel = vgui.Create("MedicPlayerPrint", main)
            playerModel:SetPos(W - W/4, 0)
            playerModel:SetSize(W/4, H)

            local dmg_list = vgui.Create("MedicDiagnostics", main)
            dmg_list:SetPos(W - 2*W/4, 0)
            dmg_list:SetSize(W/4, H)

        end

        function PANEL:Paint(W, H) end
        --function PANEL:Think() end
        vgui.Register("MedicExam", PANEL, "DPanel")
    end
end