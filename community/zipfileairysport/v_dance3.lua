-- update force 2

cloneref = cloneref or function(o) return o end

local Debris = cloneref(game:GetService("Debris"))
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local StarterGui = cloneref(game:GetService("StarterGui"))
local HttpService = cloneref(game:GetService("HttpService"))
local TextService = cloneref(game:GetService("TextService"))
local TweenService = cloneref(game:GetService("TweenService"))
local TextChatService = cloneref(game:GetService("TextChatService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local ContextActionService = cloneref(game:GetService("ContextActionService"))

local Player = Players.LocalPlayer

local modules = {}
local function AddModule(m)
	table.insert(modules, m)
end

AddModule(function()
	local m = {}
	m.ModuleType = "DANCE"
	m.Name = "i miss the quiet"
	m.Description = "i cant deny it\n\ni forgot the rest\nrbxm is from"
	m.Assets = {"imissthequiet.anim@MARKET/zipfileairysport/imissthequiet.anim", "imissthequiet.mp3@MARKET/zipfileairysport/imissthequiet.mp3","imissthequietfull.mp3@MARKET/zipfileairysport/imissthequietfull.mp3","imissthequietfull.anim@MARKET/zipfileairysport/imissthequietfull.anim"}

m.Alternative = false
m.Config = function(parent: GuiBase2d)
Util_CreateSwitch(parent, "Full. Version", m.Alternative).Changed:Connect(function(val)
m.Alternative = val
end)
end
m.LoadConfig = function(save: any)
m.Alternative = not not save.Alternative
end
m.SaveConfig = function()
return {
Alternative = m.Alternative
}
end

local animator = nil
local start = 0
m.Init = function(figure: Model)
SetOverrideDanceMusic(AssetGetContentId("imissthequiet.mp3"), "I Miss The Quiet - churgny gurgey or whatever his name is", 1, NumberRange.new(0, 14.56))
start = os.clock()
animator = AnimLib.Animator.new()
animator.rig = figure
animator.looped = true
animator.speed = 1.127157
if m.Alternative then
animator.track = AnimLib.Track.fromfile(AssetGetPathFromFilename("imissthequietfull.anim"))
SetOverrideDanceMusic(AssetGetContentId("imissthequietfull.mp3"), "I Miss The Quiet - churgny gurgey or whatever his name is", 1, NumberRange.new(0, 243))
else
animator.track = AnimLib.Track.fromfile(AssetGetPathFromFilename("imissthequiet.anim"))
end
end
m.Update = function(dt: number, figure: Model)
local t = os.clock()
animator:Step(t - start)
end
m.Destroy = function(figure: Model?)
animator = nil
end
return m
end)

AddModule(function()
	local m = {}
	m.ModuleType = "DANCE"
	m.Name = "SUBTERFUGE"
	m.Description = "ill make you play\nalongt\nin time with me"
	m.Assets = {"subterfuge.anim@MARKET/zipfileairysport/subterfuge.anim", "subterfuge.mp3@MARKET/zipfileairysport/subterfuge.mp3"}

	m.Config = function(parent: GuiBase2d)
	end

	local animator = nil
	m.Init = function(figure: Model)
		SetOverrideDanceMusic(AssetGetContentId("subterfuge.mp3"), "Subterfuge - churgny gurgey or whatever his name is", 1, NumberRange.new(0, 139))
		animator = AnimLib.Animator.new()
		animator.rig = figure
		animator.looped = true
		animator.map = {{0, 5.88}, {0, 5.69999}}
		animator.track = AnimLib.Track.fromfile(AssetGetPathFromFilename("subterfuge.anim"))
	end
	m.Update = function(dt: number, figure: Model)
		animator:Step(GetOverrideDanceMusicTime())
	end
	m.Destroy = function(figure: Model?)
		animator = nil
	end
	return m
end)

AddModule(function()
	local m = {}
	m.ModuleType = "DANCE"
	m.Name = "Shucks"
	m.Description = "ILL WATCH AS YOU BLEED\nFOR I WARNED YOU AND WARNED YOU\nYOU DID NOT HEED\nIT'S YOUR FAULT, AND HERS TOO\nWHY I DID WHAT I DID, IT WAS ALL FOR YOU\nAW SHUCKS!"
	m.Assets = {"detg shucks.anim@MARKET/zipfileairysport/detg shucks.anim", "shucks.mp3@MARKET/zipfileairysport/shucks.mp3"}

	m.Config = function(parent: GuiBase2d)
	end

	local animator = nil
	m.Init = function(figure: Model)
		SetOverrideDanceMusic(AssetGetContentId("shucks.mp3"), "Shucks - duccly, sturm, redtv53/ricky index", 1, NumberRange.new(0, 40))
		animator = AnimLib.Animator.new()
		animator.rig = figure
		animator.looped = true
		animator.map = {{0, 5.88}, {0, 5.69999}}
		animator.track = AnimLib.Track.fromfile(AssetGetPathFromFilename("detg shucks.anim"))
	end
	m.Update = function(dt: number, figure: Model)
		animator:Step(GetOverrideDanceMusicTime())
	end
	m.Destroy = function(figure: Model?)
		animator = nil
	end
	return m
end)

return modules