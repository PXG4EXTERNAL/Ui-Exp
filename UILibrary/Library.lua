-- =====================================================================
--  UILibrary v2.0  |  Settings UI for Roblox
--  Visual: Anime Vanguards-style dark panel (sidebar + grid cards)
--  API:    Obsidian / LinoriaLib patterns
--  Assets: Downloaded from GitHub repo, no rbxassetid needed
-- =====================================================================

-- ── Executor-safe service refs ─────────────────────────────────────
local cloneref = (cloneref or clonereference or function(i) return i end)
local CoreGui  = cloneref(game:GetService("CoreGui"))
local Players  = cloneref(game:GetService("Players"))
local RunSvc   = cloneref(game:GetService("RunService"))
local TweenSvc = cloneref(game:GetService("TweenService"))
local UIS      = cloneref(game:GetService("UserInputService"))

-- Executor globals (nil-safe)
local getgenv        = getgenv        or function() return shared end
local getcustomasset = getcustomasset or nil
local writefile      = writefile      or nil
local isfile         = isfile         or nil
local isfolder       = isfolder       or nil
local makefolder     = makefolder     or nil
local protectgui     = protectgui     or (syn and syn.protect_gui) or function() end
local gethui         = gethui         or function() return CoreGui end

local LocalPlayer = Players.LocalPlayer

-- ── Library singleton ──────────────────────────────────────────────
local Library = {}
Library.__index = Library

Library.Version  = "2.0.0"
Library.Toggles  = {}   -- Toggle elements keyed by Index string
Library.Options  = {}   -- Slider / Dropdown / Input / Keybind elements
Library.Window   = nil

-- ── Colour palette ─────────────────────────────────────────────────
local C = {
    BG            = Color3.fromRGB(18,  18,  22),
    SidebarBG     = Color3.fromRGB(24,  24,  28),
    SidebarItem   = Color3.fromRGB(30,  30,  36),
    SidebarActive = Color3.fromRGB(36,  36,  44),
    ActiveTab     = Color3.fromRGB(0,   162, 255),
    ActiveText    = Color3.fromRGB(255, 255, 255),
    InactiveText  = Color3.fromRGB(175, 175, 185),
    SectionTeal   = Color3.fromRGB(0,   195, 225),
    CardBG        = Color3.fromRGB(28,  28,  33),
    CardBorder    = Color3.fromRGB(45,  45,  55),
    SliderFill    = Color3.fromRGB(0,   162, 255),
    SliderThumb   = Color3.fromRGB(220, 220, 230),
    ValueBox      = Color3.fromRGB(20,  20,  24),
    ToggleON      = Color3.fromRGB(60,  185, 75),
    ToggleOFF     = Color3.fromRGB(210, 45,  45),
    ButtonBG      = Color3.fromRGB(65,  65,  72),
    ButtonHover   = Color3.fromRGB(85,  85,  95),
    SearchBG      = Color3.fromRGB(30,  30,  36),
    SearchBorder  = Color3.fromRGB(55,  55,  65),
    InputBG       = Color3.fromRGB(22,  22,  28),
    DropdownBG    = Color3.fromRGB(22,  22,  28),
    DropdownItem  = Color3.fromRGB(32,  32,  40),
    DropdownHover = Color3.fromRGB(45,  45,  58),
    CloseBtn      = Color3.fromRGB(215, 45,  45),
    CloseBtnHover = Color3.fromRGB(240, 70,  70),
    NotifyBG      = Color3.fromRGB(26,  26,  32),
    Divider       = Color3.fromRGB(40,  40,  50),
    White         = Color3.fromRGB(255, 255, 255),
    DescGray      = Color3.fromRGB(140, 140, 155),
    TI            = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
}

-- ── Asset Manager ──────────────────────────────────────────────────
-- Assets are served directly from this GitHub repo.
-- In an executor (getcustomasset available): downloaded to local storage
-- for faster loads on subsequent runs.
-- In Roblox Studio (HTTP enabled): served via HTTPS URL directly.

local ASSET_BASE = "https://raw.githubusercontent.com/PXG4EXTERNAL/Ui-Exp/main/UILibrary/assets/"
local LOCAL_ROOT = "UILibrary/assets/"

local AssetFiles = {
    CheckIcon    = "check.png",
    CrossIcon    = "cross.png",
    TeleportIcon = "teleport.png",
    SliderTrack  = "slider-track.png",
    SearchIcon   = "search.png",
    CloseIcon    = "close.png",
    SectionIcon  = "section.png",
    TabAll       = "tab-all.png",
    TabAudio     = "tab-audio.png",
    TabGameplay  = "tab-gameplay.png",
    TabGraphics  = "tab-graphics.png",
    TabUnits     = "tab-units.png",
    TabEnemies   = "tab-enemies.png",
    TabMisc      = "tab-misc.png",
    TabKeybinds  = "tab-keybinds.png",
    TabTesting   = "tab-testing.png",
}

local _resolved = {}

local function _ensureFolder(path)
    if not isfolder or not makefolder then return end
    local parts = string.split(path, "/")
    local cur = ""
    for i = 1, #parts - 1 do
        cur = cur .. (i > 1 and "/" or "") .. parts[i]
        if not isfolder(cur) then pcall(makefolder, cur) end
    end
end

local function _resolveOne(name, file)
    local url   = ASSET_BASE .. file
    local local_ = LOCAL_ROOT .. file

    if getcustomasset and writefile and isfile then
        if not isfile(local_) then
            _ensureFolder(local_)
            local ok, data = pcall(game.HttpGet, game, url, true)
            if ok and data then pcall(writefile, local_, data) end
        end
        local ok, id = pcall(getcustomasset, local_)
        if ok and id then return id end
    end

    return url  -- direct HTTPS fallback (Studio + HTTP Requests enabled)
end

-- Preload all assets synchronously so they're ready when UI is built
local function PreloadAssets()
    for name, file in pairs(AssetFiles) do
        local ok, result = pcall(_resolveOne, name, file)
        _resolved[name] = ok and result or (ASSET_BASE .. file)
    end
end
PreloadAssets()

local function Asset(name)
    return _resolved[name] or (ASSET_BASE .. (AssetFiles[name] or ""))
end

-- ── UI Helpers ─────────────────────────────────────────────────────
local function New(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
    if parent then inst.Parent = parent end
    return inst
end

local function Corner(r, p)
    return New("UICorner", {CornerRadius = UDim.new(0, r)}, p)
end

local function Stroke(t, col, p)
    return New("UIStroke", {
        Thickness = t, Color = col,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, p)
end

local function Pad(t, r, b, l, p)
    return New("UIPadding", {
        PaddingTop    = UDim.new(0, t),
        PaddingRight  = UDim.new(0, r),
        PaddingBottom = UDim.new(0, b),
        PaddingLeft   = UDim.new(0, l),
    }, p)
end

local function Tween(inst, props)
    TweenSvc:Create(inst, C.TI, props):Play()
end

local function Hover(btn, normal, hov)
    btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = hov}) end)
    btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = normal}) end)
end

-- ── Element base constructor ───────────────────────────────────────
-- Creates a Toggles or Options entry with Value, OnChanged, Set, Get.
local function NewElement(kind, index, defaultValue)
    assert(type(index) == "string", "Element index must be a string")

    local elem = {
        Index   = index,
        Value   = defaultValue,
        _cbs    = {},
        Visible = true,
    }

    function elem:OnChanged(cb)
        table.insert(self._cbs, cb)
        return self  -- chainable
    end

    function elem:_fire(val)
        self.Value = val
        for _, cb in ipairs(self._cbs) do
            task.spawn(function() pcall(cb, val) end)
        end
    end

    if kind == "Toggle" then
        Library.Toggles[index] = elem
    else
        Library.Options[index] = elem
    end

    return elem
end

-- ── Notification system ────────────────────────────────────────────
local _notifyGui
local function _ensureNotifyGui()
    if _notifyGui and _notifyGui.Parent then return end
    _notifyGui = New("ScreenGui", {
        Name = "UILibNotifications", ResetOnSpawn = false,
        DisplayOrder = 9999, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    pcall(protectgui, _notifyGui)
    _notifyGui.Parent = gethui()
end

function Library:Notify(cfg)
    cfg = cfg or {}
    local title    = cfg.Title   or "Notification"
    local content  = cfg.Content or ""
    local duration = cfg.Duration or 5

    _ensureNotifyGui()

    -- Measure offset (stack below previous)
    local yOffset = 10
    for _, n in ipairs(_notifyGui:GetChildren()) do
        if n:IsA("Frame") then yOffset = yOffset + n.AbsoluteSize.Y + 6 end
    end

    local frame = New("Frame", {
        Size = UDim2.new(0, 290, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = C.NotifyBG, BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -10, 0, yOffset),
        BackgroundTransparency = 1,
    }, _notifyGui)
    Corner(8, frame)
    Stroke(1, Color3.fromRGB(55, 55, 70), frame)
    Pad(10, 12, 10, 12, frame)
    New("UIListLayout", {
        Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = Enum.FillDirection.Vertical,
    }, frame)

    New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, Text = title,
        TextColor3 = C.White, TextSize = 14, Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left, RichText = true,
        LayoutOrder = 1,
    }, frame)

    New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, Text = content,
        TextColor3 = C.DescGray, TextSize = 12, Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
        RichText = true, LayoutOrder = 2,
    }, frame)

    -- Progress bar
    local bar = New("Frame", {
        Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = C.ActiveTab,
        BorderSizePixel = 0, LayoutOrder = 3,
    }, frame)
    Corner(2, bar)

    Tween(frame, {BackgroundTransparency = 0})
    TweenSvc:Create(bar, TweenInfo.new(duration, Enum.EasingStyle.Linear),
        {Size = UDim2.new(0, 0, 0, 2)}):Play()

    task.delay(duration, function()
        Tween(frame, {BackgroundTransparency = 1})
        task.wait(0.25)
        pcall(frame.Destroy, frame)
    end)
end

-- ── Tab accent strip colours ───────────────────────────────────────
local TAB_ACCENTS = {
    Color3.fromRGB(0,   162, 255),
    Color3.fromRGB(130, 80,  230),
    Color3.fromRGB(0,   195, 145),
    Color3.fromRGB(230, 160, 30),
    Color3.fromRGB(210, 45,  45),
    Color3.fromRGB(200, 80,  200),
    Color3.fromRGB(100, 100, 220),
    Color3.fromRGB(0,   180, 100),
    Color3.fromRGB(255, 130, 0),
}

-- ══════════════════════════════════════════════════════════════════
--  Library:CreateWindow
-- ══════════════════════════════════════════════════════════════════
function Library:CreateWindow(cfg)
    cfg = cfg or {}
    local title  = cfg.Title  or "Settings"
    local size   = cfg.Size   or UDim2.new(0, 900, 0, 560)
    local parent = cfg.Parent or (RunSvc:IsRunning()
        and LocalPlayer:WaitForChild("PlayerGui")
        or  CoreGui)

    -- ScreenGui
    local gui = New("ScreenGui", {
        Name = "UILibrary", ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true,
    })
    pcall(protectgui, gui)
    gui.Parent = parent

    -- Main window frame
    local win = New("Frame", {
        Name = "Window",
        Size = size,
        Position = UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2),
        BackgroundColor3 = C.BG, BorderSizePixel = 0, ClipsDescendants = true,
    }, gui)
    Corner(10, win)
    Stroke(1, Color3.fromRGB(50, 50, 60), win)

    -- Drag logic
    local dragging, dragStart, startPos
    win.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = inp.Position; startPos = win.Position
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local d = inp.Position - dragStart
            win.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    -- ── Left sidebar ───────────────────────────────────────────────
    local sidebar = New("Frame", {
        Name = "Sidebar", Size = UDim2.new(0, 218, 1, 0),
        BackgroundColor3 = C.SidebarBG, BorderSizePixel = 0,
    }, win)

    New("TextLabel", {
        Size = UDim2.new(1, -16, 0, 62), Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1, Text = title,
        TextColor3 = C.White, TextSize = 22,
        Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
    }, sidebar)

    New("Frame", {
        Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 0, 62),
        BackgroundColor3 = C.Divider, BorderSizePixel = 0,
    }, sidebar)

    local tabList = New("ScrollingFrame", {
        Name = "TabList",
        Size = UDim2.new(1, 0, 1, -63), Position = UDim2.new(0, 0, 0, 63),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, sidebar)
    New("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, tabList)
    Pad(8, 8, 8, 8, tabList)

    -- ── Top bar (search + close) ───────────────────────────────────
    local topBar = New("Frame", {
        Size = UDim2.new(1, -218, 0, 52), Position = UDim2.new(0, 218, 0, 0),
        BackgroundTransparency = 1, BorderSizePixel = 0,
    }, win)

    local searchFrame = New("Frame", {
        Size = UDim2.new(1, -58, 0, 34), Position = UDim2.new(0, 10, 0.5, -17),
        BackgroundColor3 = C.SearchBG, BorderSizePixel = 0,
    }, topBar)
    Corner(8, searchFrame)
    Stroke(1, C.SearchBorder, searchFrame)
    Pad(0, 12, 0, 12, searchFrame)

    local searchInput = New("TextBox", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        PlaceholderText = "Search...", PlaceholderColor3 = C.DescGray,
        Text = "", TextColor3 = C.White, TextSize = 14,
        Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
    }, searchFrame)

    local closeBtn = New("TextButton", {
        Size = UDim2.new(0, 34, 0, 34), Position = UDim2.new(1, -44, 0.5, -17),
        BackgroundColor3 = C.CloseBtn, BorderSizePixel = 0,
        Text = "✕", TextColor3 = C.White, TextSize = 14, Font = Enum.Font.GothamBold,
    }, topBar)
    Corner(8, closeBtn)
    Hover(closeBtn, C.CloseBtn, C.CloseBtnHover)

    New("Frame", {
        Size = UDim2.new(1, -218, 0, 1), Position = UDim2.new(0, 218, 0, 52),
        BackgroundColor3 = C.Divider, BorderSizePixel = 0,
    }, win)

    -- ── Content area ───────────────────────────────────────────────
    local content = New("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -218, 1, -53), Position = UDim2.new(0, 218, 0, 53),
        BackgroundTransparency = 1, BorderSizePixel = 0,
    }, win)

    -- ── Window object ──────────────────────────────────────────────
    local Window = {
        Gui        = gui,
        Frame      = win,
        Tabs       = {},
        _tabCount  = 0,
        _activeTab = nil,
        _allItems  = {},   -- { label:string, frame:GuiObject } — used by search
    }

    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

    function Window:Toggle()
        win.Visible = not win.Visible
    end

    -- Search: filter all registered items by label
    searchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local q = searchInput.Text:lower()
        for _, item in ipairs(Window._allItems) do
            item.frame.Visible = q == "" or (item.label:lower():find(q, 1, true) ~= nil)
        end
    end)

    -- ════════════════════════════════════════════════════════════════
    --  Window:AddTab
    -- ════════════════════════════════════════════════════════════════
    function Window:AddTab(name, iconAssetKey)
        self._tabCount = self._tabCount + 1
        local idx = self._tabCount
        local accent = TAB_ACCENTS[(idx - 1) % #TAB_ACCENTS + 1]

        -- Sidebar button
        local tabBtn = New("TextButton", {
            Name = "Tab_" .. name,
            Size = UDim2.new(1, 0, 0, 42),
            BackgroundColor3 = C.SidebarItem, BorderSizePixel = 0,
            Text = "", LayoutOrder = idx,
        }, tabList)
        Corner(8, tabBtn)

        -- Left accent strip (only visible when selected)
        local accentBar = New("Frame", {
            Size = UDim2.new(0, 3, 0.7, 0), Position = UDim2.new(0, 0, 0.15, 0),
            BackgroundColor3 = accent, BorderSizePixel = 0, Visible = false,
        }, tabBtn)
        Corner(2, accentBar)

        -- Icon
        local iconLabel
        if iconAssetKey then
            iconLabel = New("ImageLabel", {
                Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 12, 0.5, -10),
                BackgroundTransparency = 1,
                Image = Asset(iconAssetKey), ScaleType = Enum.ScaleType.Fit,
            }, tabBtn)
        end
        local textX = iconAssetKey and 38 or 12
        local textW = iconAssetKey and -44 or -16

        local tabLabel = New("TextLabel", {
            Name = "Label",
            Size = UDim2.new(1, textW, 1, 0), Position = UDim2.new(0, textX, 0, 0),
            BackgroundTransparency = 1, Text = name,
            TextColor3 = C.InactiveText, TextSize = 14,
            Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left,
        }, tabBtn)

        -- Page (scrollable, right side)
        local page = New("ScrollingFrame", {
            Name = "Page_" .. name,
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
            BorderSizePixel = 0, ScrollBarThickness = 3,
            ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
        }, content)
        New("UIListLayout", {
            Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder,
        }, page)
        Pad(10, 10, 10, 10, page)

        local Tab = {
            Name        = name,
            Button      = tabBtn,
            Page        = page,
            AccentBar   = accentBar,
            Label       = tabLabel,
            _sectionIdx = 0,
            Window      = Window,
        }
        table.insert(self.Tabs, Tab)

        local function selectTab()
            for _, t in ipairs(Window.Tabs) do
                t.Page.Visible      = false
                t.AccentBar.Visible = false
                Tween(t.Button, {BackgroundColor3 = C.SidebarItem})
                t.Label.TextColor3 = C.InactiveText
                t.Label.Font       = Enum.Font.Gotham
            end
            page.Visible      = true
            accentBar.Visible = true
            Tween(tabBtn, {BackgroundColor3 = C.SidebarActive})
            tabLabel.TextColor3 = C.ActiveText
            tabLabel.Font       = Enum.Font.GothamBold
            Window._activeTab   = Tab
        end
        tabBtn.MouseButton1Click:Connect(selectTab)
        if idx == 1 then selectTab() end

        -- ════════════════════════════════════════════════════════════
        --  Tab:AddSection
        -- ════════════════════════════════════════════════════════════
        function Tab:AddSection(secName, secIconKey)
            self._sectionIdx = self._sectionIdx + 1
            local sIdx = self._sectionIdx
            return _buildSection(secName, secIconKey, page, sIdx, Window)
        end

        return Tab
    end

    Library.Window = Window
    return Window
end

-- ════════════════════════════════════════════════════════════════════
--  Internal: _buildSection
--  Creates the section header + grid/list containers, returns a
--  Section object with all Add* methods. Re-used by DependencyBox.
-- ════════════════════════════════════════════════════════════════════
function _buildSection(secName, secIconKey, parentFrame, orderBase, Window)
    -- Section header
    local header = New("Frame", {
        Name = "Hdr_" .. secName,
        Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1,
        BorderSizePixel = 0, LayoutOrder = orderBase * 1000,
    }, parentFrame)

    New("ImageLabel", {
        Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 0, 0.5, -8),
        BackgroundTransparency = 1,
        Image = Asset(secIconKey or "SectionIcon"),
        ScaleType = Enum.ScaleType.Fit, ImageColor3 = C.SectionTeal,
    }, header)

    New("TextLabel", {
        Size = UDim2.new(1, -22, 1, 0), Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1, Text = secName,
        TextColor3 = C.SectionTeal, TextSize = 14,
        Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
    }, header)

    -- 2-column grid (Toggles, Buttons)
    local grid = New("Frame", {
        Name = "Grid_" .. secName,
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, BorderSizePixel = 0,
        LayoutOrder = orderBase * 1000 + 1,
    }, parentFrame)
    New("UIGridLayout", {
        CellSize = UDim2.new(0.5, -4, 0, 72),
        CellPaddingHorizontal = UDim.new(0, 8),
        CellPaddingVertical   = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
    }, grid)

    -- Full-width list (Sliders, Inputs, Dropdowns, Keybinds, Labels)
    local list = New("Frame", {
        Name = "List_" .. secName,
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, BorderSizePixel = 0,
        LayoutOrder = orderBase * 1000 + 2,
    }, parentFrame)
    New("UIListLayout", {
        Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder,
    }, list)

    local Section = {_gridIdx = 0, _listIdx = 0}

    -- ── AddToggle ─────────────────────────────────────────────────
    function Section:AddToggle(index, cfg)
        cfg = cfg or {}
        local val = cfg.Default ~= nil and cfg.Default or false
        local elem = NewElement("Toggle", index, val)
        if cfg.Callback then elem:OnChanged(cfg.Callback) end

        self._gridIdx = self._gridIdx + 1
        local card = New("Frame", {
            Name = "Toggle_" .. index,
            BackgroundColor3 = C.CardBG, BorderSizePixel = 0,
            LayoutOrder = self._gridIdx,
        }, grid)
        Corner(8, card)
        Stroke(1, C.CardBorder, card)
        table.insert(Window._allItems, {label = cfg.Text or index, frame = card})

        New("TextLabel", {
            Size = UDim2.new(1, -48, 0, 0), Position = UDim2.new(0, 10, 0, 10),
            AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
            Text = cfg.Text or index, TextColor3 = C.White, TextSize = 13,
            Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
        }, card)

        if cfg.Description then
            New("TextLabel", {
                Size = UDim2.new(1, -48, 0, 0), Position = UDim2.new(0, 10, 0, 30),
                AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
                Text = cfg.Description, TextColor3 = C.DescGray, TextSize = 11,
                Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
            }, card)
        end

        local togBtn = New("ImageButton", {
            Size = UDim2.new(0, 34, 0, 34), Position = UDim2.new(1, -42, 0, 8),
            BackgroundColor3 = val and C.ToggleON or C.ToggleOFF,
            BorderSizePixel = 0,
            Image = Asset(val and "CheckIcon" or "CrossIcon"),
            ScaleType = Enum.ScaleType.Fit, ImageColor3 = C.White,
        }, card)
        Corner(6, togBtn)

        local function setState(newVal)
            elem:_fire(newVal)
            Tween(togBtn, {BackgroundColor3 = newVal and C.ToggleON or C.ToggleOFF})
            togBtn.Image = Asset(newVal and "CheckIcon" or "CrossIcon")
        end
        togBtn.MouseButton1Click:Connect(function() setState(not elem.Value) end)

        function elem:Set(v) setState(v) end
        function elem:Get() return self.Value end

        -- DependencyBox: sub-container visible only when toggle is ON
        function elem:AddDependencyBox()
            local depOrder = (Section._listIdx or 0) + 900
            local depFrame = New("Frame", {
                Name = "Depbox_" .. index,
                Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1, BorderSizePixel = 0,
                Visible = elem.Value, LayoutOrder = depOrder,
            }, list)
            New("UIListLayout", {
                Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder,
            }, depFrame)
            self:OnChanged(function(v) depFrame.Visible = v end)
            return _buildSection("", nil, depFrame, 1, Window)
        end

        return elem
    end

    -- ── AddButton ─────────────────────────────────────────────────
    function Section:AddButton(text, cfg)
        cfg = cfg or {}
        self._gridIdx = self._gridIdx + 1

        local card = New("Frame", {
            Name = "Btn_" .. text,
            BackgroundColor3 = C.CardBG, BorderSizePixel = 0,
            LayoutOrder = self._gridIdx,
        }, grid)
        Corner(8, card)
        Stroke(1, C.CardBorder, card)
        table.insert(Window._allItems, {label = text, frame = card})

        New("TextLabel", {
            Size = UDim2.new(1, -48, 0, 0), Position = UDim2.new(0, 10, 0, 10),
            AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
            Text = text, TextColor3 = C.White, TextSize = 13,
            Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
        }, card)

        if cfg.Description then
            New("TextLabel", {
                Size = UDim2.new(1, -48, 0, 0), Position = UDim2.new(0, 10, 0, 30),
                AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
                Text = cfg.Description, TextColor3 = C.DescGray, TextSize = 11,
                Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
            }, card)
        end

        local iconBtn = New("ImageButton", {
            Size = UDim2.new(0, 34, 0, 34), Position = UDim2.new(1, -42, 0, 8),
            BackgroundColor3 = C.ButtonBG, BorderSizePixel = 0,
            Image = Asset(cfg.Icon or "TeleportIcon"),
            ScaleType = Enum.ScaleType.Fit, ImageColor3 = C.White,
        }, card)
        Corner(6, iconBtn)
        Hover(iconBtn, C.ButtonBG, C.ButtonHover)
        iconBtn.MouseButton1Click:Connect(function()
            if cfg.Callback then task.spawn(function() pcall(cfg.Callback) end) end
        end)
    end

    -- ── AddSlider ─────────────────────────────────────────────────
    function Section:AddSlider(index, cfg)
        cfg = cfg or {}
        local min_    = cfg.Min      or 0
        local max_    = cfg.Max      or 1
        local rnd     = cfg.Rounding ~= nil and cfg.Rounding or 1
        local default = math.clamp(cfg.Default or min_, min_, max_)

        local elem = NewElement("Option", index, default)
        if cfg.Callback then elem:OnChanged(cfg.Callback) end

        self._listIdx = self._listIdx + 1
        local card = New("Frame", {
            Name = "Slider_" .. index,
            Size = UDim2.new(1, 0, 0, 72), BackgroundColor3 = C.CardBG,
            BorderSizePixel = 0, LayoutOrder = self._listIdx,
        }, list)
        Corner(8, card)
        Stroke(1, C.CardBorder, card)
        Pad(10, 14, 10, 14, card)
        table.insert(Window._allItems, {label = cfg.Text or index, frame = card})

        New("TextLabel", {
            Size = UDim2.new(0.45, 0, 0, 20), Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1, Text = cfg.Text or index,
            TextColor3 = C.White, TextSize = 14, Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, card)

        if cfg.Description then
            New("TextLabel", {
                Size = UDim2.new(0.45, 0, 0, 18), Position = UDim2.new(0, 0, 0, 22),
                BackgroundTransparency = 1, Text = cfg.Description,
                TextColor3 = C.DescGray, TextSize = 12, Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
            }, card)
        end

        local cur = default
        local function fmt(v)
            return rnd == 0 and tostring(math.floor(v))
                or string.format("%." .. rnd .. "f", v)
        end

        local valBox = New("Frame", {
            Size = UDim2.new(0, 40, 0, 30), Position = UDim2.new(0.46, 0, 0.5, -15),
            BackgroundColor3 = C.ValueBox, BorderSizePixel = 0,
        }, card)
        Corner(6, valBox)
        Stroke(1, Color3.fromRGB(55, 55, 70), valBox)
        local valLbl = New("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
            Text = fmt(cur), TextColor3 = C.White, TextSize = 13,
            Font = Enum.Font.GothamBold,
        }, valBox)

        local track = New("ImageLabel", {
            Size = UDim2.new(0.54, -60, 0, 34), Position = UDim2.new(0.46, 50, 0.5, -17),
            BackgroundTransparency = 1, BorderSizePixel = 0,
            Image = Asset("SliderTrack"), ScaleType = Enum.ScaleType.Stretch,
            ClipsDescendants = false,
        }, card)

        local fill = New("Frame", {
            Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = C.SliderFill, BorderSizePixel = 0,
        }, track)
        Corner(5, fill)

        local thumb = New("Frame", {
            Size = UDim2.new(0, 18, 0, 18),
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
            BackgroundColor3 = C.SliderThumb, BorderSizePixel = 0, ZIndex = 2,
        }, track)
        Corner(9, thumb)

        local function setSlider(v)
            v = math.clamp(v, min_, max_)
            v = tonumber(string.format("%." .. rnd .. "f", v))
            cur = v
            elem:_fire(v)
            local pct = (v - min_) / (max_ - min_)
            fill.Size      = UDim2.new(pct, 0, 1, 0)
            thumb.Position = UDim2.new(pct, 0, 0.5, 0)
            valLbl.Text    = fmt(v)
        end
        setSlider(cur)

        local dragging = false
        local function onDrag(inp)
            if not dragging then return end
            if inp.UserInputType ~= Enum.UserInputType.MouseMovement
            and inp.UserInputType ~= Enum.UserInputType.Touch then return end
            local tp = track.AbsolutePosition; local ts = track.AbsoluteSize
            setSlider(min_ + (max_ - min_) * math.clamp((inp.Position.X - tp.X) / ts.X, 0, 1))
        end
        track.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; onDrag(i) end
        end)
        thumb.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
        end)
        UIS.InputChanged:Connect(onDrag)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)

        function elem:Set(v) setSlider(v) end
        function elem:Get() return cur end

        return elem
    end

    -- ── AddInput (text field) ─────────────────────────────────────
    function Section:AddInput(index, cfg)
        cfg = cfg or {}
        local elem = NewElement("Option", index, cfg.Default or "")
        if cfg.Callback then elem:OnChanged(cfg.Callback) end

        self._listIdx = self._listIdx + 1
        local card = New("Frame", {
            Name = "Input_" .. index,
            Size = UDim2.new(1, 0, 0, 64), BackgroundColor3 = C.CardBG,
            BorderSizePixel = 0, LayoutOrder = self._listIdx,
        }, list)
        Corner(8, card)
        Stroke(1, C.CardBorder, card)
        Pad(10, 14, 10, 14, card)
        table.insert(Window._allItems, {label = cfg.Text or index, frame = card})

        New("TextLabel", {
            Size = UDim2.new(0.45, 0, 0, 20), Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1, Text = cfg.Text or index,
            TextColor3 = C.White, TextSize = 14, Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, card)

        if cfg.Description then
            New("TextLabel", {
                Size = UDim2.new(0.45, 0, 0, 16), Position = UDim2.new(0, 0, 0, 22),
                BackgroundTransparency = 1, Text = cfg.Description,
                TextColor3 = C.DescGray, TextSize = 11, Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, card)
        end

        local inputFrame = New("Frame", {
            Size = UDim2.new(0.54, -60, 0, 32), Position = UDim2.new(0.46, 50, 0.5, -16),
            BackgroundColor3 = C.InputBG, BorderSizePixel = 0,
        }, card)
        Corner(6, inputFrame)
        Stroke(1, C.SearchBorder, inputFrame)
        Pad(0, 8, 0, 8, inputFrame)

        local box = New("TextBox", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
            Text = cfg.Default or "",
            PlaceholderText = cfg.Placeholder or "Type here...",
            PlaceholderColor3 = C.DescGray, TextColor3 = C.White,
            TextSize = 13, Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false,
        }, inputFrame)

        box.FocusLost:Connect(function() elem:_fire(box.Text) end)

        function elem:Set(v) box.Text = v; self:_fire(v) end
        function elem:Get() return box.Text end

        return elem
    end

    -- ── AddDropdown ───────────────────────────────────────────────
    function Section:AddDropdown(index, cfg)
        cfg = cfg or {}
        local vals    = cfg.Values  or {}
        local isMulti = cfg.Multi   or false
        local default = cfg.Default or (vals[1] or "")
        local selected = {}

        if isMulti then
            if type(default) == "table" then
                for _, v in ipairs(default) do selected[v] = true end
            else selected[default] = true end
        else
            selected[default] = true
        end

        local elem = NewElement("Option", index, isMulti and {} or default)
        if cfg.Callback then elem:OnChanged(cfg.Callback) end

        self._listIdx = self._listIdx + 1
        local card = New("Frame", {
            Name = "DD_" .. index,
            Size = UDim2.new(1, 0, 0, 64), BackgroundColor3 = C.CardBG,
            BorderSizePixel = 0, LayoutOrder = self._listIdx,
            ClipsDescendants = false, ZIndex = 5,
        }, list)
        Corner(8, card)
        Stroke(1, C.CardBorder, card)
        Pad(10, 14, 10, 14, card)
        table.insert(Window._allItems, {label = cfg.Text or index, frame = card})

        New("TextLabel", {
            Size = UDim2.new(0.45, 0, 0, 20), Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1, Text = cfg.Text or index,
            TextColor3 = C.White, TextSize = 14, Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6,
        }, card)

        if cfg.Description then
            New("TextLabel", {
                Size = UDim2.new(0.45, 0, 0, 16), Position = UDim2.new(0, 0, 0, 22),
                BackgroundTransparency = 1, Text = cfg.Description,
                TextColor3 = C.DescGray, TextSize = 11, Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6,
            }, card)
        end

        local function getDisplayText()
            if isMulti then
                local keys = {}
                for k, v in pairs(selected) do if v then table.insert(keys, k) end end
                return #keys == 0 and "None selected" or table.concat(keys, ", ")
            else
                for k, v in pairs(selected) do if v then return tostring(k) end end
                return "Select..."
            end
        end

        local dropBtn = New("TextButton", {
            Size = UDim2.new(0.54, -60, 0, 32), Position = UDim2.new(0.46, 50, 0.5, -16),
            BackgroundColor3 = C.InputBG, BorderSizePixel = 0,
            Text = getDisplayText(), TextColor3 = C.White,
            TextSize = 13, Font = Enum.Font.GothamBold, ZIndex = 6,
        }, card)
        Corner(6, dropBtn)
        Stroke(1, C.SearchBorder, dropBtn)

        local dropList = New("Frame", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            Position = UDim2.new(0, 0, 1, 6),
            BackgroundColor3 = C.DropdownBG, BorderSizePixel = 0,
            Visible = false, ClipsDescendants = false, ZIndex = 20,
        }, card)
        Corner(8, dropList)
        Stroke(1, C.CardBorder, dropList)
        New("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder}, dropList)
        Pad(4, 4, 4, 4, dropList)

        local isOpen = false

        local function buildItems()
            for _, c in ipairs(dropList:GetChildren()) do
                if c:IsA("TextButton") then c:Destroy() end
            end
            for i, v in ipairs(vals) do
                local active = selected[v]
                local item = New("TextButton", {
                    Name = tostring(v), Size = UDim2.new(1, 0, 0, 28),
                    BackgroundColor3 = active and C.DropdownHover or C.DropdownItem,
                    BorderSizePixel = 0, Text = tostring(v),
                    TextColor3 = C.White, TextSize = 13, Font = Enum.Font.Gotham,
                    LayoutOrder = i, ZIndex = 21,
                }, dropList)
                Corner(6, item)
                Hover(item, active and C.DropdownHover or C.DropdownItem, C.DropdownHover)

                item.MouseButton1Click:Connect(function()
                    if isMulti then
                        selected[v] = not selected[v]
                        item.BackgroundColor3 = selected[v] and C.DropdownHover or C.DropdownItem
                        local res = {}
                        for k, on in pairs(selected) do if on then table.insert(res, k) end end
                        elem:_fire(res)
                    else
                        for k in pairs(selected) do selected[k] = false end
                        selected[v] = true
                        isOpen = false; dropList.Visible = false
                        buildItems()
                        elem:_fire(v)
                    end
                    dropBtn.Text = getDisplayText()
                end)
            end
        end
        buildItems()

        dropBtn.MouseButton1Click:Connect(function()
            isOpen = not isOpen; dropList.Visible = isOpen
        end)
        UIS.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 and isOpen then
                task.wait()
                isOpen = false; dropList.Visible = false
            end
        end)

        function elem:Set(v)
            for k in pairs(selected) do selected[k] = false end
            if isMulti and type(v) == "table" then
                for _, k in ipairs(v) do selected[k] = true end
            else selected[v] = true end
            buildItems(); dropBtn.Text = getDisplayText(); self:_fire(v)
        end
        function elem:Get() return self.Value end
        function elem:SetValues(newVals) vals = newVals; buildItems() end

        return elem
    end

    -- ── AddKeybind ────────────────────────────────────────────────
    function Section:AddKeybind(index, cfg)
        cfg = cfg or {}
        local curKey = cfg.Default or Enum.KeyCode.Unknown
        local waiting = false

        local elem = NewElement("Option", index, curKey)
        if cfg.Callback then elem:OnChanged(cfg.Callback) end

        self._listIdx = self._listIdx + 1
        local card = New("Frame", {
            Name = "KB_" .. index,
            Size = UDim2.new(1, 0, 0, 56), BackgroundColor3 = C.CardBG,
            BorderSizePixel = 0, LayoutOrder = self._listIdx,
        }, list)
        Corner(8, card)
        Stroke(1, C.CardBorder, card)
        Pad(10, 14, 10, 14, card)
        table.insert(Window._allItems, {label = cfg.Text or index, frame = card})

        New("TextLabel", {
            Size = UDim2.new(1, -110, 1, 0), Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1, Text = cfg.Text or index,
            TextColor3 = C.White, TextSize = 14, Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, card)

        local keyBtn = New("TextButton", {
            Size = UDim2.new(0, 96, 0, 32), Position = UDim2.new(1, -96, 0.5, -16),
            BackgroundColor3 = C.ValueBox, BorderSizePixel = 0,
            Text = tostring(curKey.Name), TextColor3 = C.White,
            TextSize = 13, Font = Enum.Font.GothamBold,
        }, card)
        Corner(6, keyBtn)
        Stroke(1, Color3.fromRGB(55, 55, 70), keyBtn)

        keyBtn.MouseButton1Click:Connect(function()
            if waiting then return end
            waiting = true
            keyBtn.Text = "..."
            keyBtn.BackgroundColor3 = C.ActiveTab
            local conn
            conn = UIS.InputBegan:Connect(function(inp, gpe)
                if gpe then return end
                if inp.UserInputType == Enum.UserInputType.Keyboard then
                    curKey = inp.KeyCode
                    keyBtn.Text = tostring(inp.KeyCode.Name)
                    keyBtn.BackgroundColor3 = C.ValueBox
                    elem:_fire(curKey)
                    waiting = false
                    conn:Disconnect()
                end
            end)
        end)

        function elem:Set(key)
            curKey = key; keyBtn.Text = tostring(key.Name); self:_fire(key)
        end
        function elem:Get() return curKey end

        return elem
    end

    -- ── AddLabel ──────────────────────────────────────────────────
    function Section:AddLabel(text)
        self._listIdx = self._listIdx + 1
        return New("TextLabel", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1, Text = text,
            TextColor3 = C.DescGray, TextSize = 13, Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true, RichText = true, LayoutOrder = self._listIdx,
        }, list)
    end

    -- ── AddDivider ────────────────────────────────────────────────
    function Section:AddDivider()
        self._listIdx = self._listIdx + 1
        New("Frame", {
            Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = C.Divider,
            BorderSizePixel = 0, LayoutOrder = self._listIdx,
        }, list)
    end

    return Section
end

return Library
