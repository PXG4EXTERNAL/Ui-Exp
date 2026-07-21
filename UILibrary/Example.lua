-- =====================================================================
--  UILibrary — Example LocalScript
--  Drop this into StarterPlayerScripts or run via executor.
--  Shows all component types: Slider, Toggle, Button, Keybind, Label
-- =====================================================================

-- Load the library (loadstring from GitHub)
local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/PXG4EXTERNAL/Ui-Exp/main/UILibrary/Library.lua",
    true
))()

if not Library then
    warn("UILibrary failed to load.")
    return
end

-- ── Create the main window ──────────────────────────────────────────
local Window = Library:CreateWindow({
    Title = "Settings",
    Size  = UDim2.new(0, 900, 0, 560),
})

-- ══════════════════════════════════════════════════════════════════
--  TAB: All
-- ══════════════════════════════════════════════════════════════════
local AllTab = Window:CreateTab("All")

-- ── Audio Section ─────────────────────────────────────────────────
local AudioSection = AllTab:CreateSection("Audio")

AudioSection:AddSlider("Music Volume", {
    Description = "Adjusts all game music volume",
    Min         = 0,
    Max         = 2,
    Default     = 0,
    Increment   = 0.1,
    Callback    = function(value)
        -- e.g. game:GetService("SoundService").MusicVolume = value
    end,
})

AudioSection:AddSlider("SFX Volume", {
    Description = "Adjusts all game sound effect volume",
    Min         = 0,
    Max         = 2,
    Default     = 1,
    Increment   = 0.1,
    Callback    = function(value)
    end,
})

AudioSection:AddSlider("Ambient Volume", {
    Description = "Adjusts all ambient volume",
    Min         = 0,
    Max         = 2,
    Default     = 1.1,
    Increment   = 0.1,
    Callback    = function(value)
    end,
})

-- ── Gameplay Section ──────────────────────────────────────────────
local GameplaySection = AllTab:CreateSection("Gameplay")

GameplaySection:AddButton("Teleport To Spawn", {
    Description = "Go to your current map's spawn point",
    Callback    = function()
        local player = game:GetService("Players").LocalPlayer
        local char   = player.Character
        if char then
            local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
            if spawn then
                char:SetPrimaryPartCFrame(spawn.CFrame + Vector3.new(0, 5, 0))
            end
        end
    end,
})

GameplaySection:AddToggle("Auto Skip Waves", {
    Description = "Automatically vote to skip waves",
    Default     = true,
    Callback    = function(value)
    end,
})

GameplaySection:AddToggle("Auto Vote Start", {
    Description = "Automatically vote to start games",
    Default     = true,
    Callback    = function(value)
    end,
})

GameplaySection:AddToggle("Show Match End Rewards", {
    Description = "Show reward pop-ups after matches",
    Default     = true,
    Callback    = function(value)
    end,
})

GameplaySection:AddToggle("Display Pinned Quests", {
    Description = "Display all pinned quest quests in-game",
    Default     = false,
    Callback    = function(value)
    end,
})

GameplaySection:AddToggle("Select Unit on Placement", {
    Description = "Automatically select placed units",
    Default     = true,
    Callback    = function(value)
    end,
})

GameplaySection:AddToggle("Show Max Range on Placement", {
    Description = "Show units' max range when placing",
    Default     = false,
    Callback    = function(value)
    end,
})

GameplaySection:AddToggle("Display Path Visualizers", {
    Description = "Display path visualizers in-game",
    Default     = true,
    Callback    = function(value)
    end,
})

GameplaySection:AddToggle("Auto Retry", {
    Description = "Automatically retry after game over",
    Default     = false,
    Callback    = function(value)
    end,
})

GameplaySection:AddToggle("Auto Next", {
    Description = "Automatically go to next wave",
    Default     = false,
    Callback    = function(value)
    end,
})

-- ══════════════════════════════════════════════════════════════════
--  TAB: Audio
-- ══════════════════════════════════════════════════════════════════
local AudioTab = Window:CreateTab("Audio")

local AudioSec2 = AudioTab:CreateSection("Audio Settings")

AudioSec2:AddSlider("Music Volume", {
    Description = "Adjusts all game music volume",
    Min = 0, Max = 2, Default = 0, Increment = 0.1,
    Callback = function(v) end,
})
AudioSec2:AddSlider("SFX Volume", {
    Description = "Adjusts all game sound effect volume",
    Min = 0, Max = 2, Default = 1, Increment = 0.1,
    Callback = function(v) end,
})
AudioSec2:AddSlider("Ambient Volume", {
    Description = "Adjusts all ambient volume",
    Min = 0, Max = 2, Default = 1.1, Increment = 0.1,
    Callback = function(v) end,
})

-- ══════════════════════════════════════════════════════════════════
--  TAB: Gameplay
-- ══════════════════════════════════════════════════════════════════
local GameplayTab = Window:CreateTab("Gameplay")

local GpSec = GameplayTab:CreateSection("Gameplay Settings")

GpSec:AddToggle("Auto Skip Waves",       { Description = "Automatically vote to skip waves",   Default = true,  Callback = function(v) end })
GpSec:AddToggle("Auto Vote Start",        { Description = "Automatically vote to start games",  Default = true,  Callback = function(v) end })
GpSec:AddToggle("Show Match End Rewards", { Description = "Show reward pop-ups after matches",  Default = true,  Callback = function(v) end })
GpSec:AddToggle("Display Pinned Quests",  { Description = "Display pinned quest quests",        Default = false, Callback = function(v) end })
GpSec:AddToggle("Select Unit on Placement",{Description = "Automatically select placed units",  Default = true,  Callback = function(v) end })
GpSec:AddToggle("Show Max Range",         { Description = "Show units max range when placing",  Default = false, Callback = function(v) end })
GpSec:AddToggle("Display Path Visualizers",{Description = "Display path visualizers in-game",  Default = true,  Callback = function(v) end })

GpSec:AddButton("Teleport To Spawn", {
    Description = "Go to your current map's spawn point",
    Callback = function() end,
})

-- ══════════════════════════════════════════════════════════════════
--  TAB: Graphics
-- ══════════════════════════════════════════════════════════════════
local GraphicsTab = Window:CreateTab("Graphics")
local GfxSec      = GraphicsTab:CreateSection("Graphics Settings")

GfxSec:AddSlider("Render Distance", {
    Description = "Controls how far the game renders",
    Min = 128, Max = 2048, Default = 512, Increment = 128,
    Callback = function(v)
        workspace.StreamingMinRadius = v
    end,
})
GfxSec:AddToggle("Bloom Effect",       { Description = "Enable bloom post-processing",     Default = true,  Callback = function(v) end })
GfxSec:AddToggle("Depth of Field",     { Description = "Enable depth of field blur",        Default = false, Callback = function(v) end })
GfxSec:AddToggle("Shadows",            { Description = "Enable dynamic shadows",            Default = true,  Callback = function(v) end })

-- ══════════════════════════════════════════════════════════════════
--  TAB: Units
-- ══════════════════════════════════════════════════════════════════
local UnitsTab = Window:CreateTab("Units")
local UnitSec  = UnitsTab:CreateSection("Unit Settings")

UnitSec:AddToggle("Show Unit Range",   { Description = "Always show unit range circles",    Default = false, Callback = function(v) end })
UnitSec:AddToggle("Show Unit Level",   { Description = "Display unit level above unit",     Default = true,  Callback = function(v) end })
UnitSec:AddToggle("Unit Animations",   { Description = "Enable unit idle animations",       Default = true,  Callback = function(v) end })

-- ══════════════════════════════════════════════════════════════════
--  TAB: Enemies
-- ══════════════════════════════════════════════════════════════════
local EnemiesTab = Window:CreateTab("Enemies")
local EnemySec   = EnemiesTab:CreateSection("Enemy Settings")

EnemySec:AddToggle("Show Health Bars",   { Description = "Display enemy health bars",       Default = true,  Callback = function(v) end })
EnemySec:AddToggle("Show Enemy Names",   { Description = "Display enemy name labels",       Default = false, Callback = function(v) end })

-- ══════════════════════════════════════════════════════════════════
--  TAB: Miscellaneous
-- ══════════════════════════════════════════════════════════════════
local MiscTab = Window:CreateTab("Miscellaneous")
local MiscSec = MiscTab:CreateSection("Miscellaneous Settings")

MiscSec:AddToggle("Chat Notifications",   { Description = "Show in-game chat notifications", Default = true,  Callback = function(v) end })
MiscSec:AddToggle("FPS Counter",          { Description = "Display FPS counter on-screen",   Default = false, Callback = function(v) end })
MiscSec:AddToggle("Ping Display",         { Description = "Show current ping",                Default = true,  Callback = function(v) end })
MiscSec:AddToggle("Auto-Collect Items",   { Description = "Automatically collect dropped items", Default = false, Callback = function(v) end })

-- ══════════════════════════════════════════════════════════════════
--  TAB: Keybinds
-- ══════════════════════════════════════════════════════════════════
local KeybindsTab = Window:CreateTab("Keybinds")
local KbSec       = KeybindsTab:CreateSection("Keybind Settings")

KbSec:AddKeybind("Open Settings", {
    Default  = Enum.KeyCode.P,
    Callback = function(key)
        -- Rebind the key that opens this menu
    end,
})
KbSec:AddKeybind("Teleport to Spawn", {
    Default  = Enum.KeyCode.T,
    Callback = function(key) end,
})
KbSec:AddKeybind("Toggle HUD", {
    Default  = Enum.KeyCode.H,
    Callback = function(key) end,
})

-- ══════════════════════════════════════════════════════════════════
--  TAB: Testing
-- ══════════════════════════════════════════════════════════════════
local TestingTab = Window:CreateTab("Testing")
local TestSec    = TestingTab:CreateSection("Debug / Testing")

TestSec:AddButton("Print Player Info", {
    Description = "Prints your character info to output",
    Callback    = function()
        local p = game:GetService("Players").LocalPlayer
        print("Name:", p.Name, "| UserId:", p.UserId)
    end,
})
TestSec:AddButton("Reset Character", {
    Description = "Resets your character",
    Callback    = function()
        local p = game:GetService("Players").LocalPlayer
        if p.Character then
            p.Character:FindFirstChildOfClass("Humanoid"):ChangeState(
                Enum.HumanoidStateType.Dead)
        end
    end,
})
TestSec:AddToggle("God Mode (test)",  { Description = "Set health to max (debug only)", Default = false, Callback = function(v) end })
TestSec:AddToggle("NoClip (test)",    { Description = "Walk through walls (debug only)", Default = false, Callback = function(v) end })

TestSec:AddLabel("UILibrary v1.0.0 — github.com/PXG4EXTERNAL/Ui-Exp")
