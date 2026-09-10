--[[
    Krystal Dance Edition - mrdelord Module (UPGRADED)
    by mrdelord | glitchprod.com
    
    Upgrade: ServerSync engine ditambahkan
    Gerakan kini visible ke player lain di server
--]]

-- ============================================================
--  SERVER SYNC ENGINE (inline, standalone)
-- ============================================================
local ServerSync = {}
do
    local Players = cloneref and cloneref(game:GetService("Players")) or game:GetService("Players")

    function ServerSync.disableDefaultAnims(figure)
        local hum = figure:FindFirstChildOfClass("Humanoid")
        if hum then
            local anim = hum:FindFirstChildOfClass("Animator")
            if anim then
                for _, t in ipairs(anim:GetPlayingAnimationTracks()) do t:Stop(0) end
            end
        end
    end

    function ServerSync.claimOwnership(figure)
        local root = figure:FindFirstChild("HumanoidRootPart")
        if root then
            pcall(function()
                root:SetNetworkOwner(Players.LocalPlayer)
            end)
        end
    end

    function ServerSync.start(figure)
        ServerSync.disableDefaultAnims(figure)
        ServerSync.claimOwnership(figure)
    end

    function ServerSync.stop(figure)
        -- nothing needed, karakter akan auto-recovery
    end
end

-- ============================================================
--  DANCE DATA
-- ============================================================
local modules = {}

local dances = {
    {
        name      = "CRONOSHIFT",
        desc      = "Signature dance mrdelord — slide + spin + freeze",
        anim      = "cronoshift.anim",
        animUrl   = "https://raw.githubusercontent.com/mrdelord/KRYSTAL-DANCE-V1/main/anims/cronoshift.anim",
        song      = "cronoshift.mp3",
        songUrl   = "https://raw.githubusercontent.com/mrdelord/KRYSTAL-DANCE-V1/main/sounds/cronoshift.mp3",
        volume    = 0.8,
        loopStart = 0,
        loopEnd   = 60,
        speed     = 1,
    },
    {
        name      = "Glitch Step",
        desc      = "Gerakan patah-patah ala glitch effect",
        anim      = "glitchstep.anim",
        animUrl   = "https://raw.githubusercontent.com/mrdelord/KRYSTAL-DANCE-V1/main/anims/glitchstep.anim",
        song      = "glitchstep.mp3",
        songUrl   = "https://raw.githubusercontent.com/mrdelord/KRYSTAL-DANCE-V1/main/sounds/glitchstep.mp3",
        volume    = 0.8,
        loopStart = 0,
        loopEnd   = 60,
        speed     = 1,
    },
    {
        name      = "Void Wave",
        desc      = "Flowing wave dance khas KRYSTAL",
        anim      = "voidwave.anim",
        animUrl   = "https://raw.githubusercontent.com/mrdelord/KRYSTAL-DANCE-V1/main/anims/voidwave.anim",
        song      = "voidwave.mp3",
        songUrl   = "https://raw.githubusercontent.com/mrdelord/KRYSTAL-DANCE-V1/main/sounds/voidwave.mp3",
        volume    = 0.8,
        loopStart = 0,
        loopEnd   = 60,
        speed     = 1,
    },
    {
        name      = "Krystal Idle",
        desc      = "Idle pose signature Krystal Dance Edition",
        anim      = "krystalidle.anim",
        animUrl   = "https://raw.githubusercontent.com/mrdelord/KRYSTAL-DANCE-V1/main/anims/krystalidle.anim",
        song      = "krystalidle.mp3",
        songUrl   = "https://raw.githubusercontent.com/mrdelord/KRYSTAL-DANCE-V1/main/sounds/krystalidle.mp3",
        volume    = 0.5,
        loopStart = 0,
        loopEnd   = 60,
        speed     = 1,
    },
}

for i = 1, #dances do
    local d = dances[i]
    table.insert(modules, function()
        local m = {}
        local animator = nil
        local startT   = 0

        m.ModuleType  = "DANCE"
        m.Name        = d.name
        m.Description = d.desc
        m.Assets      = {
            d.anim .. "@" .. d.animUrl,
            d.song .. "@" .. d.songUrl,
        }

        m.Config = function(parent)
            Util_CreateText(parent, "Krystal Dance Edition", 16, Enum.TextXAlignment.Center)
            Util_CreateSeparator(parent)
            Util_CreateText(parent, d.desc, 12, Enum.TextXAlignment.Center)
            Util_CreateSeparator(parent)
            Util_CreateText(parent, "by mrdelord | glitchprod.com", 11, Enum.TextXAlignment.Center)
        end

        m.SaveConfig = function() return {} end
        m.LoadConfig  = function(_) end

        m.Init = function(figure)
            SetOverrideDanceMusic(
                AssetGetContentId(d.song),
                d.song,
                d.volume,
                NumberRange.new(d.loopStart, d.loopEnd)
            )
            startT    = os.clock()
            animator  = AnimLib.Animator.new()
            animator.rig    = figure
            animator.track  = AnimLib.Track.fromfile(AssetGetPathFromFilename(d.anim))
            animator.looped = true
            animator.speed  = d.speed or 1
            -- Aktifkan ServerSync
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
            SetOverrideDanceMusic()
        end

        return m
    end)
end

return modules
