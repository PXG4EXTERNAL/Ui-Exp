# UILibrary — Handoff Document
> Last updated: 2026-07-21  
> Repo: https://github.com/PXG4EXTERNAL/Ui-Exp  
> Branch: `main`

---

## 1. What Was Built & Why

The user wants a **Roblox Lua UI Library** that visually replicates the dark settings menu seen in a tower-defence game (resembling "Anime Vanguards"). The workflow agreed upon was:

1. **Build the library in Lua code** (we are here — complete ✅)
2. **Test & refine it in Roblox Studio** (next step)
3. **Polish into a fully releasable library** (future)

The visual reference was a settings panel with:
- Left sidebar (category tabs with coloured left-edge accent strips)
- Top bar (title "Settings" + search input + red ✕ close button)
- Two-column grid of toggle/button cards on the right
- Full-width slider cards with a value box + draggable track
- Teal section headers

Comparable libraries for reference: [Obsidian](https://github.com/deividcomsono/Obsidian), Rayfield, Fluent, Orion.

---

## 2. Repository Structure (current state)

```
Ui-Exp/
├── README.md                  ← Full API documentation
├── UILibrary/
│   ├── Library.lua            ← THE LIBRARY (loadstring this)
│   ├── Loader.lua             ← Convenience loadstring wrapper
│   └── Example.lua            ← Complete working example (all 8 tabs)
└── Loader-UI                  ← Original placeholder file (pre-existing, ignore)
```

**Raw URL for loadstring (use this in scripts):**
```
https://raw.githubusercontent.com/PXG4EXTERNAL/Ui-Exp/main/UILibrary/Library.lua
```

---

## 3. Library Architecture

`Library.lua` is a **single-file Lua module** that returns a `Library` table.  
All UI is built from Roblox Instances programmatically — no external assets required for layout/colour.

### Object hierarchy

```
Library
 └── :CreateWindow(config)  → Window
      └── :CreateTab(name, iconId?)  → Tab
           └── :CreateSection(name, iconId?)  → Section
                ├── :AddSlider(name, config)   → SliderObj
                ├── :AddToggle(name, config)   → ToggleObj
                ├── :AddButton(name, config)   → ButtonObj
                ├── :AddKeybind(name, config)  → KeybindObj
                └── :AddLabel(text)
```

### Key internal tables in Library.lua

| Table | Location (top of file) | Purpose |
|-------|------------------------|---------|
| `C` | ~line 14 | All colours — edit here to restyle |
| `Icons` | ~line 74 | Asset IDs — replace with your uploads |
| `TabAccents` | ~line 88 | Per-tab sidebar strip colours |

---

## 4. Component Details

### Slider
- Full-width card (1 column, `LayoutOrder` placed directly in the `ScrollingFrame` page)
- Left: name + description  
- Middle: dark value box (`Frame` + `TextLabel`) showing current value  
- Right: track bar (`Frame`) + fill (`Frame`) + thumb (`Frame`)  
- Drag logic: `UserInputService.InputBegan` on track/thumb → `InputChanged` → `InputEnded`
- Snaps to `Increment`, clamps to `[Min, Max]`

### Toggle
- Half-width card (placed in `UIGridLayout`, 2 columns)
- Top-right: coloured square button (green ✓ / red ✗)
- Click toggles state; tweens `BackgroundColor3` via `TweenService`
- Icon swaps between `Icons.CheckIcon` and `Icons.CrossIcon`

### Button
- Half-width card (same grid as Toggle)
- Top-right: grey square icon button
- Brief hover tween on click (`ButtonBG → ButtonHover → ButtonBG`)

### Keybind
- Full-width card (placed in page, not grid)
- Right side: `TextButton` showing current key name
- Click → sets `waiting = true` → listens on `UserInputService.InputBegan` for next key press

### Search
- `TextBox` in top bar
- On `Text` changed: iterates `Window._allItems` (flat list of `{label, frame}`)
- Hides cards where `label:lower()` doesn't contain query string

---

## 5. Visual Design Spec (for Roblox Studio reference)

| Element | Colour (RGB) | Corner Radius | Notes |
|---------|-------------|---------------|-------|
| Window BG | 18, 18, 22 | 10px | Dark near-black |
| Sidebar BG | 24, 24, 28 | 0 | Slightly lighter |
| Tab button | 30, 30, 36 | 8px | Inactive state |
| Active tab | accent colour | 8px | Each tab has unique accent |
| Section header text | 0, 195, 225 | — | Teal, bold |
| Card BG | 28, 28, 33 | 8px | 1px border: 45,45,55 |
| Slider track | 40, 40, 48 | 5px | |
| Slider fill | 0, 162, 255 | 5px | Blue |
| Slider thumb | 220, 220, 230 | 9px (circle) | 18×18 |
| Value box | 20, 20, 24 | 6px | 1px border |
| Toggle ON | 60, 185, 75 | 8px | Green |
| Toggle OFF | 210, 45, 45 | 8px | Red |
| Action button | 65, 65, 72 | 8px | Grey |
| Close button | 215, 45, 45 | 18px (circle) | 36×36 |
| Search box | 30, 30, 36 | 7px | 1px border: 55,55,65 |

**Font:** `Enum.Font.Gotham` (body) / `Enum.Font.GothamBold` (titles, values)

---

## 6. Asset IDs — Action Required

The library currently uses **placeholder asset IDs** from Roblox's default icon set. To get pixel-perfect visuals matching the screenshot:

### Assets the user provided (in repo attached_assets/):
- `Untitled_design_1784640075397.png` — toggle buttons: green ✓ ON, red ✗ OFF, grey person/teleport action button (2 variants each: normal + outlined glow)
- `96636463928154_1784640075398.png` — slider bar/track background
- `image_2026-07-21_194252161_1784640075398.png` — full settings menu reference screenshot

### Steps to replace placeholders:
1. Upload each PNG to Roblox (Game Explorer → Images, or toolbox upload)
2. Copy the asset IDs
3. Edit `Icons` table at **~line 74** in `Library.lua`:

```lua
local Icons = {
    CheckIcon    = "rbxassetid://YOUR_GREEN_CHECK_ID",
    CrossIcon    = "rbxassetid://YOUR_RED_CROSS_ID",
    TeleportIcon = "rbxassetid://YOUR_TELEPORT_ID",
    -- tab icons: All, Audio, Gameplay, Graphics, Units, Enemies, Miscellaneous, Keybinds, Testing
    All          = "rbxassetid://...",
    Audio        = "rbxassetid://...",
    -- etc.
}
```

4. For the slider track (the arrow-shaped bar from the third image), update the `track` Frame in `AddSlider` to use an `ImageLabel` instead of a plain `Frame`.

---

## 7. Known Limitations / TODO

| # | Issue | Fix |
|---|-------|-----|
| 1 | Tab icons use generic Roblox default asset IDs | Upload real icons, update `Icons` table |
| 2 | Slider track is a plain coloured Frame | Replace with `ImageLabel` using the provided arrow-shaped slider asset |
| 3 | Decorative teal swirl/tentacle beside "Settings" title not implemented | Add `ImageLabel` with the swirl asset to the title area of the sidebar |
| 4 | Toggle uses `ImageLabel` for ✓/✗ — stock icons may not match exactly | Replace with provided button assets (the green/red button PNGs) |
| 5 | `UIGridLayout` cell heights are fixed at 80px | May need tuning for different description lengths |
| 6 | No mobile / touch optimisation for slider dragging | Add `Enum.UserInputType.Touch` handling to slider InputBegan |
| 7 | No `Window:Toggle()` method to show/hide | Add with a tween on `win.Visible` or `win.Size` |
| 8 | No persistent settings (saves to DataStore) | Add a wrapper that calls `DataStoreService` in each callback |

---

## 8. How to Test in Roblox Studio

1. Open Roblox Studio → any baseplate
2. In Explorer: **StarterPlayer → StarterPlayerScripts** → Insert `LocalScript`
3. Paste this into the LocalScript:

```lua
local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/PXG4EXTERNAL/Ui-Exp/main/UILibrary/Library.lua",
    true
))()

local Window = Library:CreateWindow({ Title = "Settings" })
local Tab     = Window:CreateTab("Gameplay")
local Section = Tab:CreateSection("Gameplay")

Section:AddSlider("Music Volume", {
    Description = "Adjusts all game music volume",
    Min = 0, Max = 2, Default = 1, Increment = 0.1,
    Callback = function(v) print("Volume:", v) end,
})
Section:AddToggle("Auto Skip Waves", {
    Description = "Automatically vote to skip waves",
    Default = true,
    Callback = function(v) print("Skip:", v) end,
})
Section:AddButton("Teleport To Spawn", {
    Description = "Go to your current map's spawn point",
    Callback = function() print("Teleport!") end,
})
```

4. Enable **Allow HTTP Requests**: Game Settings → Security → Allow HTTP Requests ✓
5. Press **Play** (F5) — the settings window should appear in the centre of the screen

---

## 9. Git Workflow

The Replit workspace does **not** share a git remote with the user's GitHub repo. All git operations were done from a **temporary clone at `/tmp/ui-lib/`** inside the Replit container.

To push future changes from Replit:
```bash
cd /tmp/ui-lib
# Make edits to files in /tmp/ui-lib/UILibrary/
git add -A
git commit -m "your message"
git push origin main
```

Or re-clone fresh:
```bash
cd /tmp && rm -rf ui-lib
git clone https://YOUR_PAT@github.com/PXG4EXTERNAL/Ui-Exp.git ui-lib
cd ui-lib
# edit files, then:
git add -A && git commit -m "msg" && git push origin main
```

The PAT is stored in Replit Secrets as `GITHUB_PERSONAL_ACCESS_TOKEN`. It is injected automatically via `${GITHUB_PERSONAL_ACCESS_TOKEN}` in shell commands.

---

## 10. Next Steps (in order)

| Priority | Task | Details |
|----------|------|---------|
| 🔴 High | Upload assets to Roblox | Upload toggle buttons, slider bar, swirl decoration; update `Icons` table |
| 🔴 High | Test in Studio | Follow §8 above; verify layout, dragging, toggles, search |
| 🟡 Medium | Replace slider track with ImageLabel | Use `96636463928154` asset — arrow-shaped bar |
| 🟡 Medium | Add swirl decoration to title | `ImageLabel` in `titleBar` inside sidebar |
| 🟡 Medium | Fine-tune `UIGridLayout` cell heights | Adjust `CellSize` based on real description text lengths |
| 🟢 Low | Add `Window:Toggle()` | Show/hide with size tween |
| 🟢 Low | Add DataStore persistence | Save toggle/slider values per player |
| 🟢 Low | Mobile / touch support | Add `UserInputType.Touch` to slider drag |
| 🟢 Low | Package as `.rbxm` model | Export from Studio for easy installation |

---

## 11. Full API Reference (quick cheat sheet)

```lua
-- Window
local Win = Library:CreateWindow({ Title, Size?, Parent? })
Win:CreateTab(name, iconId?)   → Tab
Win:Destroy()

-- Tab
local Tab = Win:CreateTab("Name", "rbxassetid://...")
Tab:CreateSection(name, iconId?)  → Section

-- Section
local Sec = Tab:CreateSection("Name")
Sec:AddSlider(name, { Description?, Min, Max, Default, Increment, Callback(v) })
Sec:AddToggle(name, { Description?, Default, Callback(bool) })
Sec:AddButton(name, { Description?, Icon?, Callback() })
Sec:AddKeybind(name,{ Default?, Callback(KeyCode) })
Sec:AddLabel(text)

-- Return values
local s = Sec:AddSlider(...) ; s:Set(1.5) ; s:Get()  → number
local t = Sec:AddToggle(...) ; t:Set(true); t:Get()  → boolean
```

---

## 12. Reference Images (in repo as attached_assets in the Replit workspace)

| File | Contents |
|------|----------|
| `Untitled_design_1784640075397.png` | Button asset sheet: toggle ON (green ✓), toggle OFF (red ✗), action button (grey person icon) — two size variants each |
| `image_2026-07-21_194252161_1784640075398.png` | Full settings menu reference screenshot (the target visual) |
| `96636463928154_1784640075398.png` | Slider bar/track asset (arrow-shaped horizontal bar with transparent fill area) |

These files are in the **Replit workspace** at `attached_assets/` — they are NOT in the GitHub repo yet. Upload them to Roblox to get the asset IDs needed for §6.

---

*End of handoff — everything needed to continue is in this document.*
