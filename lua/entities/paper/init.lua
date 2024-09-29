-- [[ THIS CODE IS WRITTEN BY BENN20002 (76561198114067146) DONT COPY OR STEAL! ]] --

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel(self["Model"])
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	self:GetPhysicsObject():Wake()
end

function ENT:SpawnFunction( ply, tr, ClassName )
	if ( !tr.Hit ) then return end

	local pos = tr.HitPos
	pos["z"] = pos["z"] + 2
	local ent = ents.Create( ClassName )
	ent:SetPos( pos )
	ent:Spawn()
	ent:Activate()

	return ent
end