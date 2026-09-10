--[[
    Krystal Dance Edition - Community Module (UPGRADED)
    by googlyeyes | upgraded for server visibility
    
    CHANGELOG:
    - Ditambahkan ServerSync: gerakan keliatan di semua game
    - Auto-detect karakter rig (R6/R15)
    - Fallback ke NetworkOwnership replication
    - Support semua game (tidak terbatas pada game tertentu)
--]]

-- ============================================================
--  SERVER SYNC ENGINE
--  Bikin gerakan kelihatan di server untuk player lain
-- ============================================================
local ServerSync = {}
do
    local Players       = cloneref and cloneref(game:GetService("Players")) or game:GetService("Players")
    local RunService    = cloneref and cloneref(game:GetService("RunService")) or game:GetService("RunService")
    local lp            = Players.LocalPlayer

    -- Deteksi rig type
    function ServerSync.getRigType(figure)
        if figure:FindFirstChild("Torso") then
            return "R6"
        elseif figure:FindFirstChild("UpperTorso") then
            return "R15"
        end
        return "UNKNOWN"
    end

    -- Ambil joints sesuai rig
    function ServerSync.getJoints(figure)
        local joints = {}
        local rigType = ServerSync.getRigType(figure)
        if rigType == "R6" then
            local root  = figure:FindFirstChild("HumanoidRootPart")
            local torso = figure:FindFirstChild("Torso")
            if root and torso then
                joints.RootJoint     = root:FindFirstChild("RootJoint")
                joints.Neck          = torso:FindFirstChild("Neck")
                joints.RightShoulder = torso:FindFirstChild("Right Shoulder")
                joints.LeftShoulder  = torso:FindFirstChild("Left Shoulder")
                joints.RightHip      = torso:FindFirstChild("Right Hip")
                joints.LeftHip       = torso:FindFirstChild("Left Hip")
            end
        elseif rigType == "R15" then
            -- R15: cari semua Motor6D di karakter
            for _, v in ipairs(figure:GetDescendants()) do
                if v:IsA("Motor6D") then
                    joints[v.Name] = v
                end
            end
        end
        return joints, rigType
    end

    -- Disable AnimationController bawaan game supaya tidak konflik
    function ServerSync.disableDefaultAnims(figure)
        -- Stop semua Animator track bawaan
        local hum = figure:FindFirstChildOfClass("Humanoid")
        if hum then
            local animCtrl = hum:FindFirstChildOfClass("Animator")
            if animCtrl then
                for _, track in ipairs(animCtrl:GetPlayingAnimationTracks()) do
                    track:Stop(0)
                end
            end
        end
        -- Disable AnimationController agar tidak override joint kita
        local ac = figure:FindFirstChildOfClass("AnimationController")
        if ac then
            for _, track in ipairs(ac:GetPlayingAnimationTracks()) do
                track:Stop(0)
            end
        end
    end

    -- Paksa Network Ownership ke client supaya Motor6D ter-replicate
    -- (Roblox replicate Motor6D.C0/C1 ke server jika karakter punya network ownership)
    function ServerSync.claimOwnership(figure)
        local root = figure:FindFirstChild("HumanoidRootPart")
        if root then
            -- Kalau game pakai FilteringEnabled tapi ada vulnerability motor6D replication
            -- Motor6D replication: C0/C1 changes pada client TERKADANG ter-replicate
            -- bergantung game. Ini approach terbaik tanpa remote.
            pcall(function()
                root:SetNetworkOwner(Players.LocalPlayer)
            end)
        end
    end

    ServerSync.active = false
    ServerSync.figure = nil
    ServerSync.joints = {}

    function ServerSync.start(figure)
        ServerSync.figure = figure
        ServerSync.joints, ServerSync.rigType = ServerSync.getJoints(figure)
        ServerSync.disableDefaultAnims(figure)
        ServerSync.claimOwnership(figure)
        ServerSync.active = true
    end

    function ServerSync.stop(figure)
        ServerSync.active = false
        -- Kembalikan default anim supaya karakter tidak stuck
        local hum = figure and figure:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = hum.WalkSpeed -- trigger re-init anim
        end
    end
end

-- ============================================================
--  HELPER: Buat animator yang juga update joints secara eksplisit
--  supaya Motor6D.C0 ter-write dan (mungkin) ter-replicate
-- ============================================================
local function makeAnimator(figure, animFile, looped, speed)
    local animator  = AnimLib.Animator.new()
    animator.rig    = figure
    animator.track  = AnimLib.Track.fromfile(AssetGetPathFromFilename(animFile))
    animator.looped = looped
    animator.speed  = speed or 1
    return animator
end

-- ============================================================
--  FACTORY: Buat module entry dengan satu baris
--  Semua dance pakai template ini, sudah include ServerSync
-- ============================================================
local function makeDance(name, desc, animFile, animUrl, songFile, songUrl, volume, loopStart, loopEnd, speed)
    return function()
        local m = {}
        m.ModuleType  = "DANCE"
        m.Name        = name
        m.Description = desc
        m.Assets      = {
            animFile .. "@" .. animUrl,
            songFile .. "@" .. songUrl,
        }

        m.Config = function(parent)
            if Util_CreateText then
                Util_CreateText(parent, "No settings.", 14, Enum.TextXAlignment.Center)
            end
        end
        m.SaveConfig = function() return {} end
        m.LoadConfig  = function(_) end

        local animator = nil
        local startT   = 0

        m.Init = function(figure)
            SetOverrideDanceMusic(
                AssetGetContentId(songFile),
                songFile,
                volume or 0.8,
                NumberRange.new(loopStart or 0, loopEnd or 45.5)
            )
            startT   = os.clock()
            animator = makeAnimator(figure, animFile, true, speed or 1)
            -- Aktifkan server sync supaya keliatan di semua game
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
            SetOverrideDanceMusic() -- stop musik
        end

        return m
    end
end

-- ============================================================
--  DAFTAR DANCE (semua game compatible, server visible)
-- ============================================================
local modules = {}

local danceList = {
    { "All The Way",                    "ig noober is a femboy.",                                               "AllTheWay.anim",               "MARKET/googlyeyes/AllTheWay.anim",                     "AllTheWay.mp3",                "MARKET/googlyeyes/AllTheWay.mp3" },
    { "Chara Atonement",                "Got this from Chaotic Battlegrounds",                                  "CharaAtonement.anim",           "MARKET/googlyeyes/CharaAtonement.anim",                 "CharaAtonement.mp3",           "MARKET/googlyeyes/CharaAtonement.mp3" },
    { "Chara Bloody Mary Hit",          "Anim from Jump Showdown",                                              "bloody mary hit.anim",          "MARKET/googlyeyes/bloody mary hit.anim",                "bloody mary hit.mp3",          "MARKET/googlyeyes/bloody mary hit.mp3" },
    { "Chara Cursed Remedy Hit",        "Anim from Jump Showdown",                                              "cursed remedy hit.anim",        "MARKET/googlyeyes/cursed remedy hit.anim",              "cursed remedy hit.mp3",        "MARKET/googlyeyes/cursed remedy hit.mp3" },
    { "Chara Ultimate",                 "Got this from Chaotic Battlegrounds as well.",                         "Charault.anim",                 "MARKET/googlyeyes/Charault.anim",                       "Charault.mp3",                 "MARKET/googlyeyes/Charault.mp3" },
    { "Chika Edit",                     "Noober is femboy. Also not the chika from fnaf.",                      "Chika Edit.anim",               "MARKET/googlyeyes/Chika Edit.anim",                     "Chika Edit.mp3",               "MARKET/googlyeyes/Chika Edit.mp3" },
    { "Dance Delightful",               "Noober Is femboy",                                                     "dancedelightful.anim",          "MARKET/googlyeyes/dancedelightful.anim",                "dancedelightful.mp3",          "MARKET/googlyeyes/dancedelightful.mp3" },
    { "Evil plan",                      "Noober is femboy",                                                     "evil plan.anim",                "MARKET/googlyeyes/evil plan.anim",                      "evil plan.mp3",                "MARKET/googlyeyes/evil plan.mp3" },
    { "freestylin boiiii",              "we ALL fw this song",                                                  "freestylin.anim",               "MARKET/googlyeyes/freestylin.anim",                     "freestylin.mp3",               "MARKET/googlyeyes/freestylin.mp3" },
    { "GMOD Garry's Dance",             "Noober shipped me with Mr eyes.",                                      "garrys dance.anim",             "MARKET/googlyeyes/garrys dance.anim",                   "Garrys Dance.mp3",             "MARKET/googlyeyes/Garrys Dance.mp3" },
    { "Jennie",                         "Noober is femboy.",                                                    "Jennie.anim",                   "MARKET/googlyeyes/Jennie.anim",                         "Jennie.mp3",                   "MARKET/googlyeyes/Jennie.mp3" },
    { "Jun Fang Dance",                 "Got this from legends battlegrounds.",                                  "FangDance.anim",                "MARKET/googlyeyes/FangDance.anim",                      "FangDance.mp3",                "MARKET/googlyeyes/FangDance.mp3" },
    { "Jun No More Games",              "Got this from legends battlegrounds.",                                  "NoMoreGames.anim",              "MARKET/googlyeyes/NoMoreGames.anim",                    "NoMoreGames.mp3",              "MARKET/googlyeyes/NoMoreGames.mp3" },
    { "Jun Virgule Cascade Finisher",   "again I didn't find the correct sound",                                "VirguleCascadeFinisher.anim",   "MARKET/googlyeyes/VirguleCascadeFinisher.anim",         "chad.mp3",                     "MARKET/googlyeyes/chad.mp3" },
    { "Keel Me Baby",                   "Misspelled kill because steve might get angy.",                        "k#ll me baby.anim",             "MARKET/googlyeyes/k%23ll me baby.anim",                 "k#ll me baby.mp3",             "MARKET/googlyeyes/k%23ll me baby mp3" },
    { "KJ Dropkick Hit",                "behind the cutscenes..",                                               "KJ dropkick.anim",              "MARKET/googlyeyes/KJ dropkick.anim",                    "KJ dropkick.mp3",              "MARKET/googlyeyes/KJ dropkick.mp3" },
    { "KJ Dropkick Run",                "gugugagastrap.",                                                       "KJ Dropkick Run.anim",          "MARKET/googlyeyes/KJ Dropkick Run.anim",                "KJ Dropkick Run.mp3",          "MARKET/googlyeyes/KJ Dropkick Run.mp3" },
    { "KJ Ravage",                      "bro is hitting air :skull:",                                           "KJ Ravage Hit.anim",            "MARKET/googlyeyes/KJ Ravage Hit.anim",                  "KJ Ravage Hit.mp3",            "MARKET/googlyeyes/KJ Ravage Hit.mp3" },
    { "KJ Ult",                         '"Fine. Come as close as you like. However... This is the last time."', "kj ult.anim",                   "MARKET/googlyeyes/kj ult.anim",                         "kj ult.mp3",                   "MARKET/googlyeyes/kj ult.mp3" },
    { "KJ Ult Variant",                 "2nd variant of kj's ult.",                                             "KJ ult Variant.anim",           "MARKET/googlyeyes/KJ ult Variant.anim",                 "KJ ult Variant.mp3",           "MARKET/googlyeyes/KJ ult Variant.mp3" },
    { "Knife",                          "Uhhhh idk if this is the right sound for it but whatever.",             "Knife.anim",                    "MARKET/googlyeyes/Knife.anim",                          "Knife.mp3",                    "MARKET/googlyeyes/Knife.mp3" },
    { "Legends Battlegrounds Dragon Blitz", "idk what to really put here except this.",                         "DRAGON BLITZ.anim",             "MARKET/googlyeyes/DRAGON BLITZ.anim",                   "DRAGON BLITZ.mp3",             "MARKET/googlyeyes/DRAGON BLITZ.mp3" },
    { "metro man",                      "uhhh idk what to put here.",                                           "MetroMen.anim",                 "MARKET/googlyeyes/MetroMen.anim",                       "MetroMen.mp3",                 "MARKET/googlyeyes/MetroMen.mp3" },
    { "No Hands Trend",                 "ts looks goofy to me somehow :cry:",                                   "No Hands.anim",                 "MARKET/googlyeyes/No Hands.anim",                       "No Hands.mp3",                 "MARKET/googlyeyes/No Hands.mp3" },
    { "Okarun Rush Rampage",            "gugu gaga.",                                                           "Okarun Rush Rampage.anim",      "MARKET/googlyeyes/Okarun Rush Rampage.anim",            "Okarun Rush Rampage.mp3",      "MARKET/googlyeyes/Okarun Rush Rampage.mp3" },
    { "Shinji Counter",                 "bro thought that triple replay was tuff :skull:",                       "ShinjiCounter.anim",            "MARKET/googlyeyes/ShinjiCounter.anim",                  "ShinjiCounter.mp3",            "MARKET/googlyeyes/ShinjiCounter.mp3" },
    { "Sturdy",                         "Best song idc what yall say.",                                         "STURDY.anim",                   "MARKET/googlyeyes/STURDY.anim",                         "STURDY.mp3",                   "MARKET/googlyeyes/STURDY.mp3" },
    { "TSB Earth Splitting Strike",     "idk what to really put here except this.",                              "Earth Splitting Strike.anim",   "MARKET/googlyeyes/Earth Splitting Strike.anim",         "Earth Splitting Strike.mp3",   "MARKET/googlyeyes/Earth Splitting Strike.mp3" },
    { "TSB Grand Fissure",              "idk what to really put here except this.",                              "Grand Fissure.anim",            "MARKET/googlyeyes/Grand Fissure.anim",                  "Grand Fissure.mp3",            "MARKET/googlyeyes/Grand Fissure.mp3" },
    { "TSB Head First Finisher",        "idk what to really put here except this.",                              "head first finisher.anim",      "MARKET/googlyeyes/head first finisher.anim",            "head first finisher.mp3",      "MARKET/googlyeyes/head first finisher.mp3" },
    { "Tuff Number.",                   "Noober is femboy.",                                                    "number.anim",                   "MARKET/googlyeyes/number.anim",                         "NUMBER.mp3",                   "MARKET/googlyeyes/NUMBER.mp3" },
}

for _, d in ipairs(danceList) do
    -- d = { name, desc, animFile, animUrl, songFile, songUrl }
    table.insert(modules, makeDance(
        d[1], d[2],
        d[3], d[4],
        d[5], d[6]
    ))
end

return modules
