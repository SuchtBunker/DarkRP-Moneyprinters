-- [[ THIS CODE IS WRITTEN BY BENN20002 (76561198114067146) DONT COPY OR STEAL! ]] --

resource.AddWorkshop("3340237626")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel(self["Model"])
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
	self:GetPhysicsObject():Wake()

	self:SetBodygroup(1,1)
	self:SetBodygroup(3,1)
	self:SetTrigger(true)
	self:SetHealth(100)
end

function ENT:SpawnFunction( ply, tr, ClassName )
	if ( !tr.Hit ) then return end

	local pos = tr.HitPos
	pos["z"] = pos["z"] + 15
	local ent = ents.Create( ClassName )
	ent:SetPos( pos )
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:SetInkType(val)
	self:SetBodygroup(3,val)
end

function ENT:ResetStartNow(iterations)
	iterations = iterations or self:GetIterations()

	local paper, ink, money = self:GetCurPaper(iterations), self:GetCurInk(iterations), self:GetCurMoney(iterations)
	self:SetPaper(paper)
	self:SetInk(ink)
	self:SetMoney(money)

	local ct = CurTime()
	self:SetStart(ct - (ct - self:GetStart())%1)
end

local ink = {["moneyprinter_ink_20"] = true,["moneyprinter_ink_50"] = true,["moneyprinter_ink_100"] = true}
function ENT:StartTouch(ent)
	if ent["Used"] then return end
	
	local class = ent:GetClass()
	if ink[class] then
		if ent["InkType"] != self:GetInkType() then
			if self:GetCurMoney() != 0 then
				local ply = ent["LastGravGunner"]
				if IsValid(ply) then
					NotifyLang(ply,"MONEYPRINTER_INK_DOESNT_FIT")
				end
				return
			else
				self:SetBodygroup(2,ent["InkType"]-2)
			end
		end
		
		if self:GetActive() then
			self:ResetStartNow()
		end

		self:SetInk(100)
		self:SetInkType(ent["InkType"])

		SafeRemoveEntity(ent)
		self:EmitSound("moneyprinter_addink")
	elseif class == "paper" then
		if self:GetActive() then
			self:ResetStartNow()
		end

		self:SetPaper(math.min(100,self:GetPaper() + 50))

		SafeRemoveEntity(ent)
		self:EmitSound("moneyprinter_addpaper")
	end
end

function ENT:OnTakeDamage(dmg)
	if self.Exp then return end
	self:SetHealth(self:Health()-dmg:GetDamage())
	hook.Call("PostEntityTakeDamage",GAMEMODE,self,dmg,true)
	if self:Health() < 1 then
		self.Exp = true
		QueueExplosion(self,self.ExplosionSize,true)
	end
end

util.AddNetworkString("Moneyprinter:Toggle")
net.Receive("Moneyprinter:Toggle",function(_,ply)
	local ent = net.ReadEntity()
	if !ent["IsMoneyprinter"] then return end
	if ply:GetUseEntity() != ent then return end
	
	if ent:GetActive() then
		ent:ResetStartNow()
		ent:SetActive(false)
	elseif ent:CanRun() then
		ent:SetActive(true)
		ent:SetStart(CurTime())
	end
end)

util.AddNetworkString("Moneyprinter:Pickup")
net.Receive("Moneyprinter:Pickup",function(_,ply)
	local ent = net.ReadEntity()
	if !ent["IsMoneyprinter"] then return end
	if ply:GetUseEntity() != ent then return end

	local iterations = ent:GetIterations()
	
	local money = ent:GetCurMoney(iterations)
	if money == 0 then return end
	//money = FarmingBoosters.CalcNewFarmingBoosterMoney(ply,money)

	ent:ResetStartNow(iterations)
	ent:SetMoney(0)

	//ply:AddUnwashedMoney(money)
	ply:addMoney(money)
	//Notify(ply,"Du hast ungewaschenes Geld im Wert von "..DarkRP.formatMoney(money).." genommen!",NOTIFY_GREEN,5)
	Notify(ply,"Du hast "..DarkRP.formatMoney(money).." genommen!",NOTIFY_GREEN,5)

	if SBLogsInstalled then
		local owner = ent["Owner"]
		Logs.Log("moneyfarming",{
			["player"] = ply,
			["owner"] = IsValid(owner) and owner or ent["OwnerID64"] or false,
			["class"] = "Gelddrucker",
			["amount"] = money,
		})
	end
end)