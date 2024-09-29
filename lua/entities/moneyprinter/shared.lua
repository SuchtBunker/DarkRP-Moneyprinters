-- [[ THIS CODE IS WRITTEN BY BENN20002 (76561198114067146) DONT COPY OR STEAL! ]] --

ENT.Type = "anim"
ENT.Base = "_benlib_ent"

ENT.Category = "Geld Drucker"
ENT.PrintName = "Geld Drucker"
ENT.Spawnable = true
ENT.Model = Model "models/moneyprinter/printer.mdl"
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.IsMoneyprinter = true

INK_EMPTY = 1
INK_20 = 2
INK_50 = 3
INK_100 = 4

ENT.IterationTime = 1
ENT.IterationPaper = 100/1200
ENT.IterationInk = 100/1800
ENT.IterationMoney = {
	[INK_EMPTY] = 0,
	[INK_20] = 23,
	[INK_50] = 45,
	[INK_100] = 60,
}
ENT.MaxMoneyMultiplier = 1100

sound.Add({
	name = "moneyprinter_addink",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 55,
	sound = "ambient/machines/keyboard7_clicks_enter.wav",
})

sound.Add({
	name = "moneyprinter_addpaper",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 55,
	sound = "ambient/materials/shuffle1.wav",
})

function ENT:SetupDataTables()
	self:NetworkVar("Float",0,"Ink")
	self:NetworkVar("Float",1,"Paper")
	self:NetworkVar("Float",2,"Start")
	self:NetworkVar("Int",0,"Money")
	self:NetworkVar("Bool",0,"Active")
end

function ENT:GetInkType()
	return self:GetBodygroup(3)
end

function ENT:GetMaxMoney()
	return self["MaxMoneyMultiplier"] * self["IterationMoney"][self:GetInkType() or 0]
end

function ENT:CanRun()
	local iterations = self:GetIterations()
	if self:GetCurPaper(iterations) < self["IterationPaper"] then return false, 1 end
	if self:GetCurInk(iterations) < self["IterationInk"] then return false, 2 end
	if (self:GetCurMoney(iterations) + self["IterationMoney"][self:GetInkType()]) >= self:GetMaxMoney() then return false, 3 end

	return true
end

function ENT:IsActive()
	return self:GetActive() and self:CanRun()
end

function ENT:GetIterationMoney()
	return self["IterationMoney"][self:GetInkType()] or 0
end

function ENT:GetIterations()
	if !self:GetActive() then return 0 end

	local start = self:GetStart()
	if start == 0 then return 0 end

	return math.floor(math.min(self:GetPaper()/self["IterationPaper"],self:GetInk()/self["IterationInk"],(self:GetMaxMoney() - self:GetMoney())/self:GetIterationMoney(),(CurTime() - start)/self["IterationTime"]))
end

function ENT:GetCurPaper(iterations)
	return self:GetPaper() - (iterations or self:GetIterations()) * self["IterationPaper"]
end

function ENT:GetCurMoney(iterations)
	return self:GetMoney() + (iterations or self:GetIterations()) * self:GetIterationMoney()
end

function ENT:GetCurInk(iterations)
	return self:GetInk() - (iterations or self:GetIterations()) * self["IterationInk"]
end

hook.Add("CanProperty","Moneyprinter",function(ply,prop,ent)
	if prop != "bodygroups" then return end
	if ent["IsMoneyprinter"] then return false end
end)