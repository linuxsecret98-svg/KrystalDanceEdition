--[[
    Krystal Dance Edition - Memeili Module (UPGRADED)
    ServerSync: gerakan visible ke player lain
--]]

local ServerSync = {}
do
    local Players = cloneref and cloneref(game:GetService("Players")) or game:GetService("Players")
    function ServerSync.start(figure)
        local hum = figure:FindFirstChildOfClass("Humanoid")
        if hum then
            local anim = hum:FindFirstChildOfClass("Animator")
            if anim then
                for _, t in ipairs(anim:GetPlayingAnimationTracks()) do t:Stop(0) end
            end
        end
        local root = figure:FindFirstChild("HumanoidRootPart")
        if root then
            pcall(function() root:SetNetworkOwner(Players.LocalPlayer) end)
        end
    end
    function ServerSync.stop(_) end
end

local modules = {}

local dances = {
    {
        name      = "Miss Me (Hello Neighbor Mix)",
        desc      = "Music Goes hard asf",
        anim      = "MissMeFix.anim",
        animUrl   = "MARKET/Memeili/MissMeFix.anim",
        song      = "TungBung.mp3",
        songUrl   = "MARKET/Memeili/TungBung.mp3",
        volume    = 0.8,
        loopStart = 0,
        loopEnd   = 45.5,
    },
    {
        name      = "Real one knows this isn't avgn\xF0\x9F\x98\x82\xE2\x9C\x8C",
        desc      = "SON NO COPYING \xF0\x9F\x98\x82\xF0\x9F\x98\x82\xF0\x9F\x98\x82",
        anim      = "KwikFlip.anim",
        animUrl   = "MARKET/Memeili/KwikFlip.anim",
        song      = "Kwik Flip.mp3",
        songUrl   = "MARKET/Memeili/Kwik%20Flip.mp3",
        volume    = 0.8,
        loopStart = 0,
        loopEnd   = 45.5,
    },
}

for _, d in ipairs(dances) do
    local dc = d
    table.insert(modules, function()
        local m = {}
        m.ModuleType  = "DANCE"
        m.Name        = dc.name
        m.Description = dc.desc
        m.Assets      = {
            dc.anim .. "@" .. dc.animUrl,
            dc.song .. "@" .. dc.songUrl,
        }
        m.Config     = function(p) if Util_CreateText then Util_CreateText(p, "No settings.", 14, Enum.TextXAlignment.Center) end end
        m.SaveConfig = function() return {} end
        m.LoadConfig = function(_) end

        local animator = nil
        local startT   = 0

        m.Init = function(figure)
            SetOverrideDanceMusic(
                AssetGetContentId(dc.song),
                dc.song,
                dc.volume,
                NumberRange.new(dc.loopStart, dc.loopEnd)
            )
            startT        = os.clock()
            animator      = AnimLib.Animator.new()
            animator.rig    = figure
            animator.track  = AnimLib.Track.fromfile(AssetGetPathFromFilename(dc.anim))
            animator.looped = true
            animator.speed  = 1
            ServerSync.start(figure)
        end

        m.Update = function(dt, figure)
            if animator then
                animator:Step(os.clock() - startT)
            end
        end

        m.Destroy = function(figure)
            ServerSync.stop(figure)
            animator = nil
        end

        return m
    end)
end

return modules
