AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

ENT.Volume = 1.0
ENT.Pitch = 100
ENT.SoundLevel = 100

function ENT:Initialize()
	self:SetModel( "models/props_underground/old_speaker_big.mdl" )

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self:SetUseType( SIMPLE_USE )

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
end

function ENT:Use( activator )
end

function ENT:PlaySound( soundPath )
	self:EmitSound( soundPath, self.SoundLevel, self.Pitch, self.Volume )
end

function ENT:PlayBackground( duration )
	self:EmitSound( "cassie/background/" .. duration .. ".wav", self.SoundLevel, 100, self.Volume * 0.5 )
end

function ENT:StopSound( soundPath )
	-- Todo
end