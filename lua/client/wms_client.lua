net.Receive( "send_damage_table_to_client", function( len, ply )
	net.ReadEntity().wms_dmg_tbl = net.ReadTable()
    return
end )

print("tststststststst")
do
local PANEL = {}

function PANEL:Init()
	self:SetText( "Time for something different!" )
end

function PANEL:Paint( aWide, aTall )

	local TextX, TextY = 0, 0
	local TextColor = Color( 255, 0, 0, 255 )

	surface.SetFont( self:GetFont() or "default" )
	surface.SetTextColor( TextColor )
	surface.SetTextPos( TextX, TextY )
	surface.DrawText( self:GetText() )

end

vgui.Register( "NewPanel", PANEL, "DLabel" )
end