-- =====================================================================
--  UILibrary Loader
--  Place this in a LocalScript and run it to load the library.
--
--  Option A — Load directly from GitHub (raw):
--      local Library = loadstring(game:HttpGet(
--          "https://raw.githubusercontent.com/PXG4EXTERNAL/Ui-Exp/main/UILibrary/Library.lua"
--      ))()
--
--  Option B — Require locally (if placed inside the game):
--      local Library = require(script.Parent.Library)
--
--  This file uses Option A for convenience.
-- =====================================================================

local RAW_URL = "https://raw.githubusercontent.com/PXG4EXTERNAL/Ui-Exp/main/UILibrary/Library.lua"

local ok, result = pcall(function()
    return loadstring(game:HttpGet(RAW_URL, true))()
end)

if not ok then
    warn("[UILibrary] Failed to load library: " .. tostring(result))
    return nil
end

return result
