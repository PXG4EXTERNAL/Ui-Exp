# UILibrary — Roblox Settings UI Library

A clean, dark-themed Roblox UI library that recreates the exact visual style of the Anime Vanguards / tower-defence settings menu. Drop it into any Roblox game or executor script.

---

## Preview

![Settings UI Preview](https://raw.githubusercontent.com/PXG4EXTERNAL/Ui-Exp/main/assets/preview.png)

Components:
- **Left sidebar** — tabs with coloured accent strips and icons
- **Search bar** — live filters all settings
- **Sliders** — draggable with live value box
- **Toggles** — green ✓ (on) / red ✗ (off)
- **Buttons** — icon action buttons
- **Keybinds** — click-to-rebind keys
- **Labels** — plain text rows

---

## Quick Start (Loadstring)

```lua
-- LocalScript in StarterPlayerScripts
local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/PXG4EXTERNAL/Ui-Exp/main/UILibrary/Library.lua",
    true
))()

local Window = Library:CreateWindow({ Title = "Settings" })

local Tab     = Window:CreateTab("Gameplay")
local Section = Tab:CreateSection("Gameplay")

Section:AddToggle("Auto Skip Waves", {
    Description = "Automatically vote to skip waves",
    Default     = true,
    Callback    = function(enabled)
        print("Auto Skip:", enabled)
    end,
})

Section:AddSlider("Music Volume", {
    Description = "Adjusts all game music volume",
    Min         = 0,
    Max         = 2,
    Default     = 1,
    Increment   = 0.1,
    Callback    = function(value)
        game:GetService("SoundService").MusicVolume = value
    end,
})

Section:AddButton("Teleport To Spawn", {
    Description = "Go to your current map's spawn point",
    Callback    = function()
        -- teleport logic here
    end,
})
```

---

## Full API

### `Library:CreateWindow(config)`

| Key      | Type        | Default       | Description                      |
|----------|-------------|---------------|----------------------------------|
| `Title`  | string      | `"Settings"`  | Window title text                |
| `Size`   | UDim2       | `900 × 560`   | Window size                      |
| `Parent` | Instance    | `PlayerGui`   | Where to parent the ScreenGui    |

Returns a **Window** object.

---

### `Window:CreateTab(name, iconId?)`

| Param    | Type   | Description                                     |
|----------|--------|-------------------------------------------------|
| `name`   | string | Tab label shown in the sidebar                  |
| `iconId` | string | Optional `rbxassetid://...` for the tab icon    |

Returns a **Tab** object. The first tab created is auto-selected.

---

### `Tab:CreateSection(name, iconId?)`

| Param    | Type   | Description                                    |
|----------|--------|------------------------------------------------|
| `name`   | string | Section header text (teal colour)              |
| `iconId` | string | Optional icon shown beside the section header  |

Returns a **Section** object.

---

### `Section:AddSlider(name, config)`

Full-width card with a draggable slider and live value display.

| Key           | Type     | Default | Description                     |
|---------------|----------|---------|---------------------------------|
| `Description` | string   | —       | Subtitle text below name        |
| `Min`         | number   | `0`     | Minimum value                   |
| `Max`         | number   | `1`     | Maximum value                   |
| `Default`     | number   | `Min`   | Starting value                  |
| `Increment`   | number   | `0.1`   | Step size                       |
| `Callback`    | function | —       | `function(value: number)`       |

Returns `{ Frame, Set(value), Get() }`.

---

### `Section:AddToggle(name, config)`

Half-width card with a green ✓ / red ✗ toggle button.

| Key           | Type     | Default | Description               |
|---------------|----------|---------|---------------------------|
| `Description` | string   | —       | Subtitle text below name  |
| `Default`     | boolean  | `false` | Starting state            |
| `Callback`    | function | —       | `function(enabled: bool)` |

Returns `{ Frame, Set(bool), Get() }`.

---

### `Section:AddButton(name, config)`

Half-width card with a grey icon action button.

| Key           | Type     | Default | Description                          |
|---------------|----------|---------|--------------------------------------|
| `Description` | string   | —       | Subtitle text below name             |
| `Icon`        | string   | —       | `rbxassetid://...` for the icon      |
| `Callback`    | function | —       | `function()` — fired on click        |

Returns `{ Frame }`.

---

### `Section:AddKeybind(name, config)`

Full-width card with a click-to-rebind key button.

| Key        | Type         | Default               | Description                      |
|------------|--------------|-----------------------|----------------------------------|
| `Default`  | Enum.KeyCode | `Enum.KeyCode.Unknown`| Starting key                     |
| `Callback` | function     | —                     | `function(key: Enum.KeyCode)`    |

Returns `{ Frame, Get() }`.

---

### `Section:AddLabel(text)`

Plain grey text row — useful for version info or notes.

---

### `Window:Destroy()`

Removes the ScreenGui immediately.

---

## File Structure

```
UILibrary/
  Library.lua   — core library (load this with loadstring)
  Loader.lua    — convenience loader wrapper
  Example.lua   — full example with all tabs/components
README.md
```

---

## Customisation

All colours live at the top of `Library.lua` in the `C` table:

```lua
local C = {
    BG         = Color3.fromRGB(18, 18, 22),   -- main bg
    ActiveTab  = Color3.fromRGB(0, 162, 255),  -- selected tab
    ToggleON   = Color3.fromRGB(60, 185, 75),  -- green
    ToggleOFF  = Color3.fromRGB(210, 45, 45),  -- red
    -- ... etc
}
```

Icon asset IDs live in the `Icons` table — replace them with your own uploaded assets.

---

## Licence

MIT — free to use, modify, and redistribute.
