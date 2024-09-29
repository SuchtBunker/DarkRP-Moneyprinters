-- [[ THIS CODE IS WRITTEN BY BENN20002 (76561198114067146) DONT COPY OR STEAL! ]] --

include("shared.lua")

local mPos, mAng = Vector(-3,-10.25,22.5), Angle(0,90,0)
local dPos, dAng = Vector(4.35,15,39.2), Angle(0,180,45)
local col = Color(0,0,0,50)
local maxDist = 150^2
local w = 256
local sndActive = Sound("sb/moneyprinter/print.wav")

function ENT:Initialize()
	self.iterations = 0
end

function ENT:Think()
	self.iterations = self:GetIterations()

	if self:IsActive() then
		local snd = self["Sound"]
		if !snd then
			snd = CreateSound(self,sndActive)
			snd:SetSoundLevel(65)
			self["Sound"] = snd
		end
		if !snd:IsPlaying() then
			snd:Play()
			snd:SetSoundLevel(65)
		end
	else
		local snd = self["Sound"]
		if snd then
			snd:Stop()
		end
	end

	self:SetNextClientThink(CurTime() + .25)
	return true
end

function ENT:OnRemove()
	local snd = self["Sound"]
	if snd and snd:IsPlaying() then snd:Stop() end
end

function ENT:DrawTranslucent()
	if self:GetPos():DistToSqr(LocalPlayer():GetPos()) > maxDist then return end
	
	cam.Start3D2D(self:LocalToWorld(dPos),self:LocalToWorldAngles(dAng),.05)
		draw.SimpleText(self["PrintName"],"Font_45",w/2,0,COLOR_WHITE,TEXT_ALIGN_CENTER)
		draw.RoundedBox(0,10,45,w-20,2,Ben_Derma["COLOR_ACCENT"])

		// math.Round(self:GetCurInk()/self["IterationInk"]) // time left ink
		// math.Round(self:GetCurPaper()/self["IterationPaper"]) // time left paper
		Ben_Derma.ProgressBar(self:GetCurInk(self.iterations)/100,w/2,75,w-20,40,"Tinte","Font_25")
		draw.RoundedBox(0,10,100,w-20,35,Ben_Derma["COLOR_BAR"])
		surface.SetDrawColor(Ben_Derma["COLOR_OUTLINE"])
		surface.DrawOutlinedRect(10,100,w-20,35)
		draw.SimpleText(self:IsActive() and "Ausschalten" or "Einschalten","Font_40",w/2,116,COLOR_WHITE,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	cam.End3D2D()
end

function ENT:Draw()
	local stack = (self:GetCurMoney(iterations)/self:GetMaxMoney())*100
	if stack > 0 and stack < 6 then
		self:SetPoseParameter("stack",6)
	else
		self:SetPoseParameter("stack",stack)
	end

	local paper = self:GetCurPaper(iterations)
	if paper > self["IterationPaper"] then
		if paper > 6.5 then
			self:SetPoseParameter("paper",paper)
		else
			self:SetPoseParameter("paper",6.5)
		end
	else
		self:SetPoseParameter("paper",0)
	end

	if self:IsActive() then
		self:SetPoseParameter("print",((CurTime() - self:GetStart())%self["IterationTime"]) * 100)
	else
		self:SetPoseParameter("print",0)
	end

	self:InvalidateBoneCache()

	self:DrawModel()
end 

ENT["3D2DButtons"] = {
	{
		["pos"] = dPos,
		["ang"] = dAng,
		["x"] = .5,
		["y"] = 5,
		["w"] = 11.8,
		["h"] = 1.8,
		["dist"] = 100^2,
		["func"] = function(ent)
			if !ent:IsActive() then
				local can, why = ent:CanRun()
				if !can then
					if why == 1 then
						Notify("Kein Papier!",NOTIFY_ORANGE,5)
					elseif why == 2 then
						Notify("Keine Tinte!",NOTIFY_ORANGE,5)
					elseif why == 3 then
						Notify("Geldspeicher voll!",NOTIFY_ORANGE,5)
					end
					return
				end
			end
			
			net.Start("Moneyprinter:Toggle")
			net.WriteEntity(ent)
			net.SendToServer()

			return true // supress default Use hook
		end,
	},

	{
		["pos"] = mPos,
		["ang"] = mAng,
		["w"] = 21,
		["h"] = 22.5,
		["dist"] = 75^2,
		["func"] = function(ent)
			net.Start("Moneyprinter:Pickup")
			net.WriteEntity(ent)
			net.SendToServer()
		end,
	},
}