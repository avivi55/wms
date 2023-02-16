net.Receive( "send_damage_table_to_client", function( len, ply )
    net.ReadEntity().wms_dmg_tbl = net.ReadTable()
    return
end )


-- hook.Add("PlayerSpawn", "wms_spawn", function(ply)
--     hook.Call( "CalcView" )
--     hook.Run( "CalcView" )
--     -- print(66666)
-- end)

-- hook.Add( "CalcView", "tetet_zz_simfphys_gunner_view", function( ply, pos, ang )
--     ---print(ply)
--     return{origin = pos}
-- end )


surface.CreateFont( "DEATH_SCREEN", {
    font = "DefaultBold",
    size = 130,
} )

surface.CreateFont( "DEATH_SCREEN_LITTLE", {
    font = "DefaultBold",
    size = 50,
} )