for k,v in pairs(player.GetAll())do
    print(v)
    --v:UnSpectate()
    --Spectate(OBS_MODE_NONE)
    --v:Spawn()
    --v:SpectateEntity(v)

    v:SetFOV(v:GetFOV())
    Print(v:EyePos())
    Print(v:GetPos())

    --v:SetPos(Vector(0,0,0))
end