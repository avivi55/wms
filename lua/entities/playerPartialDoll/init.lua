AddCSLuaFile( "shared.lua" )

include('shared.lua')
print("dqsdqs\nbdfsdfdqsdqs\nbdfsdfdqsdqs\nbdfsdfdqsdqs\nbdfsdf")
function ENT:Initialize()
    self:SetModel(self.Player:GetModel())
    self:SetPos(self.Player:GetPos())
    self:SetAngles(self.Player:GetAngles())

    self:PhysicsInit( SOLID_VPHYSICS );
    self:SetMoveType( MOVETYPE_VPHYSICS );
    self:SetUseType( SIMPLE_USE );
    self:SetSolid( SOLID_VPHYSICS );

    local phys = self:GetPhysicsObject();

    if (phys:IsValid()) then phys:Wake(); end;
end;


function ENT:OnTakeDamage(dmgi)
    print(555, dmgi:GetDamage())
    if (dmgi:GetDamage() >= 20) then
        self.Player:Kill()
    end
    return 
end