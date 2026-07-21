-- =====================================================================
--  UILibrary v2.0 — Example Script
--  API mirrors Obsidian / LinoriaLib patterns.
--  Place in a LocalScript inside StarterPlayerScripts.
-- =====================================================================

local repo    = "https://raw.githubusercontent.com/PXG4EXTERNAL/Ui-Exp/main/"
local Library = loadstring(game:HttpGet(repo .. "UILibrary/Library.lua"))()

-- Global element tables (reference these anywhere in your script)
local Toggles = Library.Toggles
local Options  = Library.Options

-- ── Create window ─────────────────────────────────────────────────
local Window = Library:CreateWindow({
    Title = "Settings",
    -- Size = UDim2.new(0, 900, 0, 560),  -- optional, this is the default
})

-- ── Tabs (sidebar) ─────────────────────────────────────────────────
local Tabs = {
    All          = Window:AddTab("All",           "TabAll"),
    Audio        = Window:AddTab("Audio",         "TabAudio"),
    Gameplay     = Window:AddTab("Gameplay",      "TabGameplay"),
    Graphics     = Window:AddTab("Graphics",      "TabGraphics"),
    Units        = Window:AddTab("Units",         "TabUnits"),
    Enemies      = Window:AddTab("Enemies",       "TabEnemies"),
    Misc         = Window:AddTab("Miscellaneous", "TabMisc"),
    Keybinds     = Window:AddTab("Keybinds",      "TabKeybinds"),
    Testing      = Window:AddTab("Testing",       "TabTesting"),
}

-- ═══════════════════════════════════════════════════════════════════
--  AUDIO TAB
-- ═══════════════════════════════════════════════════════════════════
local AudioSec = Tabs.Audio:AddSection("Audio")

AudioSec:AddSlider("MusicVolume", {
    Text        = "Music Volume",
    Description = "Adjusts all game music volume",
    Min         = 0,
    Max         = 2,
    Default     = 1,
    Rounding    = 1,
})

AudioSec:AddSlider("SFXVolume", {
    Text        = "SFX Volume",
    Description = "Adjusts all game sound effect volume",
    Min         = 0,
    Max         = 2,
    Default     = 1,
    Rounding    = 1,
})

AudioSec:AddSlider("AmbientVolume", {
    Text        = "Ambient Volume",
    Description = "Adjusts all ambient volume",
    Min         = 0,
    Max         = 2,
    Default     = 1,
    Rounding    = 1,
})

-- ═══════════════════════════════════════════════════════════════════
--  GAMEPLAY TAB
-- ═══════════════════════════════════════════════════════════════════
local GameplaySec = Tabs.Gameplay:AddSection("Gameplay")

GameplaySec:AddButton("Teleport To Spawn", {
    Description = "Go to your current map's spawn point",
    Callback    = function()
        -- teleport logic here
        print("Teleporting to spawn...")
    end,
})

GameplaySec:AddToggle("AutoSkipWaves", {
    Text        = "Auto Skip Waves",
    Description = "Automatically vote to skip waves",
    Default     = true,
})

GameplaySec:AddToggle("AutoVoteStart", {
    Text        = "Auto Vote Start",
    Description = "Automatically vote to start games",
    Default     = true,
})

GameplaySec:AddToggle("ShowMatchEndRewards", {
    Text        = "Show Match End Rewards",
    Description = "Show reward pop-ups after matches",
    Default     = true,
})

GameplaySec:AddToggle("DisplayPinnedQuests", {
    Text        = "Display Pinned Quests",
    Description = "Display all pinned quest quests in-game",
    Default     = false,
})

GameplaySec:AddToggle("SelectUnitOnPlacement", {
    Text        = "Select Unit on Placement",
    Description = "Automatically select placed units",
    Default     = true,
})

GameplaySec:AddToggle("ShowMaxRange", {
    Text        = "Show Max Range on Placement",
    Description = "Show units' max range when placing",
    Default     = false,
})

GameplaySec:AddToggle("DisplayPathVisualizers", {
    Text        = "Display Path Visualizers",
    Description = "Display path visualizers in-game",
    Default     = true,
})

-- ─── DependencyBox example: sub-options appear only when enabled
GameplaySec:AddToggle("AdvancedMode", {
    Text    = "Advanced Mode",
    Default = false,
})

local AdvancedDepbox = Toggles.AdvancedMode:AddDependencyBox()

AdvancedDepbox:AddDropdown("PathStyle", {
    Text    = "Path Visualizer Style",
    Values  = {"Arrows", "Dots", "Solid Line"},
    Default = "Arrows",
})

AdvancedDepbox:AddToggle("ShowHitboxes", {
    Text    = "Show Unit Hitboxes",
    Default = false,
})

-- ═══════════════════════════════════════════════════════════════════
--  GRAPHICS TAB
-- ═══════════════════════════════════════════════════════════════════
local GraphicsSec = Tabs.Graphics:AddSection("Graphics")

GraphicsSec:AddDropdown("QualityLevel", {
    Text    = "Render Quality",
    Values  = {"1 - Lowest", "3", "5", "7", "10 - Max"},
    Default = "5",
})

GraphicsSec:AddToggle("ShowFPS", {
    Text    = "Show FPS Counter",
    Default = false,
})

GraphicsSec:AddToggle("ReduceParticles", {
    Text    = "Reduce Particles",
    Description = "Reduce particle effects for better performance",
    Default = false,
})

-- ═══════════════════════════════════════════════════════════════════
--  KEYBINDS TAB
-- ═══════════════════════════════════════════════════════════════════
local KeybindSec = Tabs.Keybinds:AddSection("Keybinds")

KeybindSec:AddKeybind("ToggleUI", {
    Text    = "Toggle Settings UI",
    Default = Enum.KeyCode.RightShift,
})

KeybindSec:AddKeybind("TeleportBind", {
    Text    = "Teleport to Spawn",
    Default = Enum.KeyCode.T,
})

-- ═══════════════════════════════════════════════════════════════════
--  MISCELLANEOUS TAB
-- ═══════════════════════════════════════════════════════════════════
local MiscSec = Tabs.Misc:AddSection("Miscellaneous")

MiscSec:AddInput("CustomTag", {
    Text        = "Custom Player Tag",
    Description = "Text shown above your character",
    Placeholder = "Enter tag...",
    Default     = "",
})

MiscSec:AddToggle("HideUI", {
    Text    = "Hide All UI During Wave",
    Default = false,
})

MiscSec:AddLabel("Changes take effect on the next wave. <font color='#00C3E1'>Tip:</font> use keybinds for quick access.")
MiscSec:AddDivider()
MiscSec:AddLabel("UILibrary v" .. Library.Version .. " — loaded successfully.")

-- ═══════════════════════════════════════════════════════════════════
--  Wiring up logic with OnChanged (recommended pattern)
--  Create ALL UI elements first, then connect logic below.
-- ═══════════════════════════════════════════════════════════════════

Options.MusicVolume:OnChanged(function(val)
    -- e.g. game:GetService("SoundService").MusicVolume = val
    print("Music volume →", val)
end)

Options.SFXVolume:OnChanged(function(val)
    print("SFX volume →", val)
end)

Toggles.AutoSkipWaves:OnChanged(function(val)
    print("AutoSkipWaves →", val)
end)

Options.ToggleUI:OnChanged(function(key)
    -- Rebind toggle UI
    print("UI toggle key changed to", key.Name)
end)

-- Wire the UI toggle keybind at runtime
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Options.ToggleUI.Value then
        Window:Toggle()
    end
end)

-- ── Startup notification ──────────────────────────────────────────
Library:Notify({
    Title   = "Settings Loaded",
    Content = "Welcome! Press <b>" .. tostring(Options.ToggleUI.Value.Name) .. "</b> to toggle the menu.",
    Duration = 6,
})
