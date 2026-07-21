-- =====================================================================
--  UILibrary  |  Settings UI Library for Roblox
--  Matches the dark settings panel style (sidebar + sliders + toggles)
--  API mirrors popular Roblox UI libraries (Obsidian / Rayfield style)
-- =====================================================================

local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")

-- ── Colour palette ────────────────────────────────────────────────────
local C = {
    BG            = Color3.fromRGB(18,  18,  22),   -- main window bg
    SidebarBG     = Color3.fromRGB(24,  24,  28),   -- left sidebar
    SidebarItem   = Color3.fromRGB(30,  30,  36),   -- tab button bg
    ActiveTab     = Color3.fromRGB(0,   162, 255),  -- selected tab highlight
    ActiveTabText = Color3.fromRGB(255, 255, 255),
    InactiveText  = Color3.fromRGB(175, 175, 185),
    SectionTeal   = Color3.fromRGB(0,   195, 225),  -- section header colour
    CardBG        = Color3.fromRGB(28,  28,  33),   -- setting card bg
    CardBorder    = Color3.fromRGB(45,  45,  55),
    SliderTrack   = Color3.fromRGB(40,  40,  48),
    SliderFill    = Color3.fromRGB(0,   162, 255),
    SliderThumb   = Color3.fromRGB(220, 220, 230),
    ValueBox      = Color3.fromRGB(20,  20,  24),
    ToggleON      = Color3.fromRGB(60,  185, 75),
    ToggleOFF     = Color3.fromRGB(210, 45,  45),
    ToggleIcon    = Color3.fromRGB(255, 255, 255),
    ButtonBG      = Color3.fromRGB(65,  65,  72),
    ButtonHover   = Color3.fromRGB(85,  85,  95),
    SearchBG      = Color3.fromRGB(30,  30,  36),
    SearchBorder  = Color3.fromRGB(55,  55,  65),
    CloseBtn      = Color3.fromRGB(215, 45,  45),
    CloseBtnHover = Color3.fromRGB(240, 70,  70),
    White         = Color3.fromRGB(255, 255, 255),
    DescGray      = Color3.fromRGB(140, 140, 155),
    TweenInfo     = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
}

-- ── Helpers ───────────────────────────────────────────────────────────
local function make(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
    if parent then inst.Parent = parent end
    return inst
end

local function corner(radius, parent)
    return make("UICorner", {CornerRadius = UDim.new(0, radius)}, parent)
end

local function stroke(thickness, colour, parent)
    return make("UIStroke", {Thickness = thickness, Color = colour, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, parent)
end

local function pad(t, r, b, l, parent)
    return make("UIPadding", {
        PaddingTop    = UDim.new(0, t),
        PaddingRight  = UDim.new(0, r),
        PaddingBottom = UDim.new(0, b),
        PaddingLeft   = UDim.new(0, l),
    }, parent)
end

local function tween(inst, props)
    TweenService:Create(inst, C.TweenInfo, props):Play()
end

local function hoverEffect(btn, normal, hover)
    btn.MouseEnter:Connect(function()    tween(btn, {BackgroundColor3 = hover})  end)
    btn.MouseLeave:Connect(function()    tween(btn, {BackgroundColor3 = normal}) end)
end

-- ── Icon assets (Roblox asset IDs) ───────────────────────────────────
--  Replace these with your own asset IDs once uploaded to Roblox.
local Icons = {
    All          = "rbxassetid://7733960981",
    Audio        = "rbxassetid://7733715400",
    Gameplay     = "rbxassetid://7733958882",
    Graphics     = "rbxassetid://7734053495",
    Units        = "rbxassetid://7733998724",
    Enemies      = "rbxassetid://7733957785",
    Miscellaneous= "rbxassetid://7733992780",
    Keybinds     = "rbxassetid://7734001774",
    Testing      = "rbxassetid://7733957785",
    Search       = "rbxassetid://3926305904",
    Close        = "rbxassetid://3926305904",
    SectionIcon  = "rbxassetid://7734053495",
    CheckIcon    = "rbxassetid://3926307682",   -- ✓
    CrossIcon    = "rbxassetid://3926305904",   -- ✗
    TeleportIcon = "rbxassetid://7734001774",
}

-- Accent colours per sidebar tab (left bar strip)
local TabAccents = {
    Color3.fromRGB(0,   162, 255),  -- blue   (All)
    Color3.fromRGB(130, 80,  230),  -- purple (Audio)
    Color3.fromRGB(0,   195, 145),  -- teal   (Gameplay)
    Color3.fromRGB(230, 160, 30),   -- amber  (Graphics)
    Color3.fromRGB(210, 45,  45),   -- red    (Units)
    Color3.fromRGB(200, 80,  200),  -- pink   (Enemies)
    Color3.fromRGB(100, 100, 220),  -- indigo (Misc)
    Color3.fromRGB(0,   180, 100),  -- green  (Keybinds)
    Color3.fromRGB(255, 130, 0),    -- orange (Testing)
}

-- ─────────────────────────────────────────────────────────────────────
--  Library
-- ─────────────────────────────────────────────────────────────────────
local Library = {}
Library.__index = Library

function Library:CreateWindow(config)
    config = config or {}
    local title  = config.Title  or "Settings"
    local size   = config.Size   or UDim2.new(0, 900, 0, 560)
    local parent = config.Parent or (RunService:IsRunning()
        and game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
        or  game:GetService("CoreGui"))

    -- ── Root ScreenGui ─────────────────────────────────────────────
    local gui = make("ScreenGui", {
        Name              = "UILibrary",
        ResetOnSpawn      = false,
        ZIndexBehavior    = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset    = true,
    }, parent)

    -- ── Main window frame ──────────────────────────────────────────
    local win = make("Frame", {
        Name              = "Window",
        Size              = size,
        Position          = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        BackgroundColor3  = C.BG,
        BorderSizePixel   = 0,
        ClipsDescendants  = true,
    }, gui)
    corner(10, win)
    stroke(1, Color3.fromRGB(50, 50, 60), win)

    -- Drag support
    local dragging, dragStart, startPos
    win.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = input.Position
            startPos  = win.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            win.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    -- ── Left sidebar ───────────────────────────────────────────────
    local sidebar = make("Frame", {
        Name             = "Sidebar",
        Size             = UDim2.new(0, 218, 1, 0),
        BackgroundColor3 = C.SidebarBG,
        BorderSizePixel  = 0,
    }, win)

    -- Title block inside sidebar
    local titleBar = make("Frame", {
        Name             = "TitleBar",
        Size             = UDim2.new(1, 0, 0, 62),
        BackgroundTransparency = 1,
    }, sidebar)

    make("TextLabel", {
        Name             = "Title",
        Size             = UDim2.new(1, -16, 1, 0),
        Position         = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text             = title,
        TextColor3       = C.White,
        TextSize         = 22,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
    }, titleBar)

    -- Divider under title
    make("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 0, 62),
        BackgroundColor3 = Color3.fromRGB(40, 40, 50),
        BorderSizePixel  = 0,
    }, sidebar)

    -- Tab list (scroll)
    local tabList = make("ScrollingFrame", {
        Name             = "TabList",
        Size             = UDim2.new(1, 0, 1, -63),
        Position         = UDim2.new(0, 0, 0, 63),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100),
        CanvasSize       = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, sidebar)
    make("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, tabList)
    pad(8, 8, 8, 8, tabList)

    -- ── Top bar (right side) ───────────────────────────────────────
    local topBar = make("Frame", {
        Name             = "TopBar",
        Size             = UDim2.new(1, -218, 0, 54),
        Position         = UDim2.new(0, 218, 0, 0),
        BackgroundColor3 = Color3.fromRGB(22, 22, 27),
        BorderSizePixel  = 0,
    }, win)
    make("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Color3.fromRGB(40, 40, 50),
        BorderSizePixel  = 0,
    }, topBar)

    -- Search box
    local searchBox = make("Frame", {
        Name             = "SearchBox",
        Size             = UDim2.new(1, -66, 0, 32),
        Position         = UDim2.new(0, 12, 0.5, -16),
        BackgroundColor3 = C.SearchBG,
        BorderSizePixel  = 0,
    }, topBar)
    corner(7, searchBox)
    stroke(1, C.SearchBorder, searchBox)

    local searchInput = make("TextBox", {
        Name             = "Input",
        Size             = UDim2.new(1, -10, 1, 0),
        Position         = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        PlaceholderText  = "Search...",
        PlaceholderColor3= Color3.fromRGB(110, 110, 125),
        TextColor3       = C.White,
        TextSize         = 14,
        Font             = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        TextXAlignment   = Enum.TextXAlignment.Left,
    }, searchBox)

    -- Close button
    local closeBtn = make("TextButton", {
        Name             = "CloseBtn",
        Size             = UDim2.new(0, 36, 0, 36),
        Position         = UDim2.new(1, -46, 0.5, -18),
        BackgroundColor3 = C.CloseBtn,
        Text             = "✕",
        TextColor3       = C.White,
        TextSize         = 16,
        Font             = Enum.Font.GothamBold,
        BorderSizePixel  = 0,
    }, topBar)
    corner(18, closeBtn)
    hoverEffect(closeBtn, C.CloseBtn, C.CloseBtnHover)
    closeBtn.MouseButton1Click:Connect(function()
        tween(win, {Size = UDim2.new(0, size.X.Offset, 0, 0)})
        task.delay(0.2, function() gui:Destroy() end)
    end)

    -- ── Content area ───────────────────────────────────────────────
    local contentHolder = make("Frame", {
        Name             = "ContentHolder",
        Size             = UDim2.new(1, -218, 1, -54),
        Position         = UDim2.new(0, 218, 0, 54),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
    }, win)

    -- ── Window object returned to user ─────────────────────────────
    local Window = {
        _gui         = gui,
        _win         = win,
        _tabList     = tabList,
        _contentHolder = contentHolder,
        _searchInput = searchInput,
        _tabs        = {},
        _activeTab   = nil,
        _tabIndex    = 0,
        _allItems    = {},   -- flat list for search: {label, frame}
    }

    -- Search logic
    searchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local q = searchInput.Text:lower()
        for _, item in ipairs(Window._allItems) do
            local match = q == "" or item.label:lower():find(q, 1, true)
            item.frame.Visible = match ~= nil
        end
    end)

    function Window:CreateTab(name, iconId)
        self._tabIndex = self._tabIndex + 1
        local idx     = self._tabIndex
        local accentC = TabAccents[idx] or C.ActiveTab

        -- Sidebar button
        local tabBtn = make("TextButton", {
            Name             = "Tab_"..name,
            Size             = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = C.SidebarItem,
            Text             = "",
            LayoutOrder      = idx,
            BorderSizePixel  = 0,
        }, tabList)
        corner(8, tabBtn)

        -- Left accent strip
        local accent = make("Frame", {
            Size             = UDim2.new(0, 4, 0.7, 0),
            Position         = UDim2.new(0, 0, 0.15, 0),
            BackgroundColor3 = accentC,
            BorderSizePixel  = 0,
        }, tabBtn)
        corner(4, accent)

        -- Icon
        local icon = make("ImageLabel", {
            Size             = UDim2.new(0, 20, 0, 20),
            Position         = UDim2.new(0, 14, 0.5, -10),
            BackgroundTransparency = 1,
            Image            = iconId or Icons[name] or Icons.All,
            ImageColor3      = C.InactiveText,
        }, tabBtn)

        -- Label
        local label = make("TextLabel", {
            Size             = UDim2.new(1, -44, 1, 0),
            Position         = UDim2.new(0, 40, 0, 0),
            BackgroundTransparency = 1,
            Text             = name,
            TextColor3       = C.InactiveText,
            TextSize         = 14,
            Font             = Enum.Font.Gotham,
            TextXAlignment   = Enum.TextXAlignment.Left,
        }, tabBtn)

        -- Tab content page
        local page = make("ScrollingFrame", {
            Name             = "Page_"..name,
            Size             = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel  = 0,
            Visible          = false,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100),
            CanvasSize       = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
        }, contentHolder)
        make("UIListLayout", {Padding = UDim.new(0, 0), SortOrder = Enum.SortOrder.LayoutOrder}, page)
        pad(10, 14, 14, 14, page)

        local tabObj = {
            _name       = name,
            _btn        = tabBtn,
            _icon       = icon,
            _label      = label,
            _page       = page,
            _accentColor= accentC,
            _window     = Window,
            _sectionIdx = 0,
        }

        -- Select this tab
        local function selectTab()
            -- Deactivate current
            if Window._activeTab then
                local prev = Window._activeTab
                tween(prev._btn,   {BackgroundColor3 = C.SidebarItem})
                tween(prev._icon,  {ImageColor3      = C.InactiveText})
                tween(prev._label, {TextColor3       = C.InactiveText})
                prev._page.Visible = false
            end
            Window._activeTab = tabObj
            tween(tabBtn,  {BackgroundColor3 = accentC})
            tween(icon,    {ImageColor3      = C.White})
            tween(label,   {TextColor3       = C.White})
            page.Visible = true
        end

        tabBtn.MouseButton1Click:Connect(selectTab)
        table.insert(Window._tabs, tabObj)

        -- Auto-select first tab
        if #Window._tabs == 1 then selectTab() end

        -- ── Tab API ──────────────────────────────────────────────
        function tabObj:CreateSection(sectionName, iconId2)
            self._sectionIdx = self._sectionIdx + 1
            local sIdx = self._sectionIdx

            -- Section header row
            local headerRow = make("Frame", {
                Name            = "SectionHeader_"..sectionName,
                Size            = UDim2.new(1, 0, 0, 36),
                BackgroundTransparency = 1,
                LayoutOrder     = sIdx * 100,
            }, page)

            make("ImageLabel", {
                Size            = UDim2.new(0, 18, 0, 18),
                Position        = UDim2.new(0, 0, 0.5, -9),
                BackgroundTransparency = 1,
                Image           = iconId2 or Icons.SectionIcon,
                ImageColor3     = C.SectionTeal,
            }, headerRow)

            make("TextLabel", {
                Size            = UDim2.new(1, -28, 1, 0),
                Position        = UDim2.new(0, 26, 0, 0),
                BackgroundTransparency = 1,
                Text            = sectionName,
                TextColor3      = C.SectionTeal,
                TextSize        = 16,
                Font            = Enum.Font.GothamBold,
                TextXAlignment  = Enum.TextXAlignment.Left,
            }, headerRow)

            -- Grid container for cards (2 columns for toggles/buttons, auto-expand)
            local grid = make("Frame", {
                Name            = "Grid_"..sectionName,
                Size            = UDim2.new(1, 0, 0, 0),
                AutomaticSize   = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                LayoutOrder     = sIdx * 100 + 1,
            }, page)

            -- UIGridLayout (2-column) placed inside grid
            local gridLayout = make("UIGridLayout", {
                CellSize        = UDim2.new(0.5, -6, 0, 80),
                CellPaddingH    = UDim.new(0, 12),
                CellPaddingV    = UDim.new(0, 8),
                SortOrder       = Enum.SortOrder.LayoutOrder,
                FillDirectionMaxCells = 2,
                StartCorner     = Enum.StartCorner.TopLeft,
                FillDirection   = Enum.FillDirection.Horizontal,
            }, grid)

            local sectionObj = {
                _page    = page,
                _grid    = grid,
                _layout  = gridLayout,
                _window  = Window,
                _itemIdx = 0,
            }

            -- ── Slider ────────────────────────────────────────────
            function sectionObj:AddSlider(name, config)
                config = config or {}
                self._itemIdx = self._itemIdx + 1

                -- Sliders span full width — remove from grid, use list
                -- We'll place sliders in the page directly as full-width cards
                local card = make("Frame", {
                    Name            = "Slider_"..name,
                    Size            = UDim2.new(1, 0, 0, 72),
                    BackgroundColor3= C.CardBG,
                    BorderSizePixel = 0,
                    LayoutOrder     = sIdx * 100 + 2 + self._itemIdx,
                }, page)
                corner(8, card)
                stroke(1, C.CardBorder, card)
                pad(10, 14, 10, 14, card)

                -- Register for search
                table.insert(Window._allItems, {label = name, frame = card})

                -- Left: name + desc
                make("TextLabel", {
                    Name            = "Name",
                    Size            = UDim2.new(0.45, 0, 0, 20),
                    Position        = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text            = name,
                    TextColor3      = C.White,
                    TextSize        = 14,
                    Font            = Enum.Font.GothamBold,
                    TextXAlignment  = Enum.TextXAlignment.Left,
                }, card)

                if config.Description then
                    make("TextLabel", {
                        Name            = "Desc",
                        Size            = UDim2.new(0.45, 0, 0, 18),
                        Position        = UDim2.new(0, 0, 0, 22),
                        BackgroundTransparency = 1,
                        Text            = config.Description,
                        TextColor3      = C.DescGray,
                        TextSize        = 12,
                        Font            = Enum.Font.Gotham,
                        TextXAlignment  = Enum.TextXAlignment.Left,
                        TextWrapped     = true,
                    }, card)
                end

                -- Right: value box + slider track
                local min       = config.Min       or 0
                local max       = config.Max       or 1
                local default   = config.Default   or min
                local increment = config.Increment or 0.1
                local callback  = config.Callback  or function() end

                local current = math.clamp(default, min, max)

                local function fmt(v)
                    if increment >= 1 then return tostring(math.floor(v))
                    else return string.format("%.1f", v) end
                end

                -- Value box
                local valBox = make("Frame", {
                    Size            = UDim2.new(0, 36, 0, 30),
                    Position        = UDim2.new(0.46, 0, 0.5, -15),
                    BackgroundColor3= C.ValueBox,
                    BorderSizePixel = 0,
                }, card)
                corner(6, valBox)
                stroke(1, Color3.fromRGB(55, 55, 70), valBox)

                local valLabel = make("TextLabel", {
                    Size            = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text            = fmt(current),
                    TextColor3      = C.White,
                    TextSize        = 13,
                    Font            = Enum.Font.GothamBold,
                }, valBox)

                -- Slider track
                local track = make("Frame", {
                    Size            = UDim2.new(1, -44, 0, 10),
                    Position        = UDim2.new(0, 40, 0.5, -5),
                    -- Re-anchor: put track to the right of valBox
                    AnchorPoint     = Vector2.new(0, 0),
                    BackgroundColor3= C.SliderTrack,
                    BorderSizePixel = 0,
                }, card)
                -- Readjust: starts after valBox (≈50% + 44px gap)
                track.Position = UDim2.new(0.46, 46, 0.5, -5)
                track.Size     = UDim2.new(0.54, -60, 0, 10)
                corner(5, track)

                -- Fill bar
                local fill = make("Frame", {
                    Size            = UDim2.new(0, 0, 1, 0),
                    BackgroundColor3= C.SliderFill,
                    BorderSizePixel = 0,
                }, track)
                corner(5, fill)

                -- Thumb
                local thumb = make("Frame", {
                    Size            = UDim2.new(0, 18, 0, 18),
                    AnchorPoint     = Vector2.new(0.5, 0.5),
                    Position        = UDim2.new(0, 0, 0.5, 0),
                    BackgroundColor3= C.SliderThumb,
                    BorderSizePixel = 0,
                    ZIndex          = 2,
                }, track)
                corner(9, thumb)

                local function setSliderValue(v)
                    v = math.clamp(v, min, max)
                    -- Snap to increment
                    v = math.round((v - min) / increment) * increment + min
                    v = math.clamp(v, min, max)
                    current = v
                    local pct = (v - min) / (max - min)
                    fill.Size       = UDim2.new(pct, 0, 1, 0)
                    thumb.Position  = UDim2.new(pct, 0, 0.5, 0)
                    valLabel.Text   = fmt(v)
                    callback(v)
                end

                setSliderValue(current)

                -- Drag logic
                local draggingSlider = false
                local function onInput(input)
                    if input.UserInputType ~= Enum.UserInputType.MouseMovement
                    and input.UserInputType ~= Enum.UserInputType.Touch then return end
                    if not draggingSlider then return end
                    local trackPos  = track.AbsolutePosition
                    local trackSize = track.AbsoluteSize
                    local pct = math.clamp((input.Position.X - trackPos.X) / trackSize.X, 0, 1)
                    setSliderValue(min + (max - min) * pct)
                end

                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSlider = true
                        onInput(input)
                    end
                end)
                thumb.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSlider = true
                    end
                end)
                UserInputService.InputChanged:Connect(onInput)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSlider = false
                    end
                end)

                local sliderObj = {
                    Frame = card,
                    Set = function(_, v) setSliderValue(v) end,
                    Get = function() return current end,
                }
                return sliderObj
            end

            -- ── Toggle ────────────────────────────────────────────
            function sectionObj:AddToggle(name, config)
                config = config or {}
                self._itemIdx = self._itemIdx + 1

                local enabled   = config.Default   ~= nil and config.Default or false
                local callback  = config.Callback  or function() end

                local card = make("TextButton", {
                    Name            = "Toggle_"..name,
                    Size            = UDim2.new(0, 0, 0, 0),   -- grid controls size
                    BackgroundColor3= C.CardBG,
                    BorderSizePixel = 0,
                    Text            = "",
                    LayoutOrder     = self._itemIdx,
                    AutoButtonColor = false,
                }, grid)
                corner(8, card)
                stroke(1, C.CardBorder, card)
                pad(10, 10, 10, 10, card)

                table.insert(Window._allItems, {label = name, frame = card})

                make("TextLabel", {
                    Name            = "Name",
                    Size            = UDim2.new(1, -46, 0, 20),
                    BackgroundTransparency = 1,
                    Text            = name,
                    TextColor3      = C.White,
                    TextSize        = 13,
                    Font            = Enum.Font.GothamBold,
                    TextXAlignment  = Enum.TextXAlignment.Left,
                }, card)

                if config.Description then
                    make("TextLabel", {
                        Name            = "Desc",
                        Size            = UDim2.new(1, -46, 0, 28),
                        Position        = UDim2.new(0, 0, 0, 22),
                        BackgroundTransparency = 1,
                        Text            = config.Description,
                        TextColor3      = C.DescGray,
                        TextSize        = 11,
                        Font            = Enum.Font.Gotham,
                        TextXAlignment  = Enum.TextXAlignment.Left,
                        TextWrapped     = true,
                    }, card)
                end

                -- Toggle button (top-right of card)
                local togBtn = make("Frame", {
                    Name            = "TogBtn",
                    Size            = UDim2.new(0, 36, 0, 36),
                    Position        = UDim2.new(1, -36, 0, 2),
                    BackgroundColor3= enabled and C.ToggleON or C.ToggleOFF,
                    BorderSizePixel = 0,
                }, card)
                corner(8, togBtn)

                local togIcon = make("ImageLabel", {
                    Size            = UDim2.new(0, 22, 0, 22),
                    Position        = UDim2.new(0.5, -11, 0.5, -11),
                    BackgroundTransparency = 1,
                    Image           = enabled and Icons.CheckIcon or Icons.CrossIcon,
                    ImageColor3     = C.White,
                }, togBtn)

                local function setToggle(v)
                    enabled = v
                    tween(togBtn, {BackgroundColor3 = v and C.ToggleON or C.ToggleOFF})
                    togIcon.Image = v and Icons.CheckIcon or Icons.CrossIcon
                    callback(v)
                end

                card.MouseButton1Click:Connect(function() setToggle(not enabled) end)

                local toggleObj = {
                    Frame  = card,
                    Set    = function(_, v) setToggle(v) end,
                    Get    = function() return enabled end,
                }
                return toggleObj
            end

            -- ── Button ────────────────────────────────────────────
            function sectionObj:AddButton(name, config)
                config = config or {}
                self._itemIdx = self._itemIdx + 1

                local callback = config.Callback or function() end

                local card = make("TextButton", {
                    Name            = "Button_"..name,
                    Size            = UDim2.new(0, 0, 0, 0),
                    BackgroundColor3= C.CardBG,
                    BorderSizePixel = 0,
                    Text            = "",
                    LayoutOrder     = self._itemIdx,
                    AutoButtonColor = false,
                }, grid)
                corner(8, card)
                stroke(1, C.CardBorder, card)
                pad(10, 10, 10, 10, card)

                table.insert(Window._allItems, {label = name, frame = card})

                make("TextLabel", {
                    Name            = "Name",
                    Size            = UDim2.new(1, -46, 0, 20),
                    BackgroundTransparency = 1,
                    Text            = name,
                    TextColor3      = C.White,
                    TextSize        = 13,
                    Font            = Enum.Font.GothamBold,
                    TextXAlignment  = Enum.TextXAlignment.Left,
                }, card)

                if config.Description then
                    make("TextLabel", {
                        Name            = "Desc",
                        Size            = UDim2.new(1, -46, 0, 28),
                        Position        = UDim2.new(0, 0, 0, 22),
                        BackgroundTransparency = 1,
                        Text            = config.Description,
                        TextColor3      = C.DescGray,
                        TextSize        = 11,
                        Font            = Enum.Font.Gotham,
                        TextXAlignment  = Enum.TextXAlignment.Left,
                        TextWrapped     = true,
                    }, card)
                end

                -- Icon button (top-right)
                local iconBtn = make("Frame", {
                    Name            = "IconBtn",
                    Size            = UDim2.new(0, 36, 0, 36),
                    Position        = UDim2.new(1, -36, 0, 2),
                    BackgroundColor3= C.ButtonBG,
                    BorderSizePixel = 0,
                }, card)
                corner(8, iconBtn)

                make("ImageLabel", {
                    Size            = UDim2.new(0, 22, 0, 22),
                    Position        = UDim2.new(0.5, -11, 0.5, -11),
                    BackgroundTransparency = 1,
                    Image           = config.Icon or Icons.TeleportIcon,
                    ImageColor3     = C.White,
                }, iconBtn)

                card.MouseButton1Click:Connect(function()
                    tween(iconBtn, {BackgroundColor3 = C.ButtonHover})
                    task.delay(0.15, function()
                        tween(iconBtn, {BackgroundColor3 = C.ButtonBG})
                    end)
                    callback()
                end)

                return {Frame = card}
            end

            -- ── Label (plain text row) ────────────────────────────
            function sectionObj:AddLabel(text)
                self._itemIdx = self._itemIdx + 1
                local lbl = make("TextLabel", {
                    Name            = "Label_"..text,
                    Size            = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1,
                    Text            = text,
                    TextColor3      = C.DescGray,
                    TextSize        = 13,
                    Font            = Enum.Font.Gotham,
                    TextXAlignment  = Enum.TextXAlignment.Left,
                    LayoutOrder     = sIdx * 100 + 2 + self._itemIdx,
                }, page)
                return lbl
            end

            -- ── Keybind ───────────────────────────────────────────
            function sectionObj:AddKeybind(name, config)
                config = config or {}
                self._itemIdx = self._itemIdx + 1
                local currentKey  = config.Default   or Enum.KeyCode.Unknown
                local callback    = config.Callback  or function() end
                local waiting     = false

                local card = make("Frame", {
                    Name            = "Keybind_"..name,
                    Size            = UDim2.new(1, 0, 0, 72),
                    BackgroundColor3= C.CardBG,
                    BorderSizePixel = 0,
                    LayoutOrder     = sIdx * 100 + 2 + self._itemIdx,
                }, page)
                corner(8, card)
                stroke(1, C.CardBorder, card)
                pad(10, 14, 10, 14, card)

                table.insert(Window._allItems, {label = name, frame = card})

                make("TextLabel", {
                    Size            = UDim2.new(0.6, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text            = name,
                    TextColor3      = C.White,
                    TextSize        = 14,
                    Font            = Enum.Font.GothamBold,
                    TextXAlignment  = Enum.TextXAlignment.Left,
                }, card)

                local keyBtn = make("TextButton", {
                    Size            = UDim2.new(0, 90, 0, 30),
                    Position        = UDim2.new(1, -90, 0.5, -15),
                    BackgroundColor3= C.ValueBox,
                    BorderSizePixel = 0,
                    Text            = tostring(currentKey.Name),
                    TextColor3      = C.White,
                    TextSize        = 13,
                    Font            = Enum.Font.GothamBold,
                }, card)
                corner(6, keyBtn)
                stroke(1, Color3.fromRGB(55, 55, 70), keyBtn)

                keyBtn.MouseButton1Click:Connect(function()
                    waiting = true
                    keyBtn.Text = "..."
                    local c = UserInputService.InputBegan:Wait()
                    if c.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey  = c.KeyCode
                        keyBtn.Text = tostring(c.KeyCode.Name)
                        callback(currentKey)
                    end
                    waiting = false
                end)

                return {Frame = card, Get = function() return currentKey end}
            end

            return sectionObj
        end

        return tabObj
    end

    function Window:Destroy()
        gui:Destroy()
    end

    return Window
end

return Library
