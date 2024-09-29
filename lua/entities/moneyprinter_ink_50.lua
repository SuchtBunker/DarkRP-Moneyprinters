-- [[ THIS CODE IS WRITTEN BY BENN20002 (76561198114067146) DONT COPY OR STEAL! ]] --

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "moneyprinter_ink"

ENT.Category = "Geld Drucker"
ENT.PrintName = "Geld Drucker Tinte (50€)"
ENT.Spawnable = true
ENT.Material = Material "models/moneyprinter/printer_cartrige_b" :GetName()
ENT.Model = Model "models/moneyprinter/ink.mdl"
ENT.InkType = INK_50