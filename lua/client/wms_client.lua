net.Receive( "send_damage_table_to_client", function( len, ply )
	net.ReadEntity().wms_dmg_tbl = net.ReadTable()
    return
end )

surface.CreateFont( "DEATH_SCREEN", {
	font = "DefaultBold",
	size = 130,
} )

surface.CreateFont( "DEATH_SCREEN_LITTLE", {
	font = "DefaultBold",
	size = 50,
} )