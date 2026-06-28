# AxiomUI — Executor UI Library

> Paste-and-go UI library for Roblox executors. No `require()`. No ModuleScript. Drop it in and build.

---

## 📦 Installation

Load the library directly from GitHub using `loadstring`. One block at the top of your script — done.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/krmizi433-oss/AxiomUI/refs/heads/main/AxiomUI.lua"))()
local lib = getgenv().AxiomUI
```

> **Executor compatibility:** CoreGui parenting is attempted first (Synapse X, Fluxus, Krnl, Arceus X). Falls back to `PlayerGui` automatically if CoreGui is restricted.

---

## 🎨 Themes

Three built-in themes. Pass the name string to `CreateWindow`. You can also pass a **full custom color table** instead of a name.

| Name | Accent Color |
|------|-------------|
| `Dark` | Indigo `#6366F1` |
| `Midnight` | Sky Blue `#38BDF8` |
| `Crimson` | Red `#DC3250` |

**Custom theme:**
```lua
local Window = lib:CreateWindow({
    Theme = {
        Background   = Color3.fromRGB(10, 10, 10),
        Topbar       = Color3.fromRGB(18, 18, 18),
        TabBar       = Color3.fromRGB(14, 14, 14),
        TabActive    = Color3.fromRGB(0, 200, 100),
        TabInactive  = Color3.fromRGB(28, 28, 28),
        Section      = Color3.fromRGB(20, 20, 20),
        Element      = Color3.fromRGB(26, 26, 26),
        ElementHover = Color3.fromRGB(36, 36, 36),
        Accent       = Color3.fromRGB(0, 200, 100),
        AccentDim    = Color3.fromRGB(0, 140, 70),
        Text         = Color3.fromRGB(230, 230, 230),
        SubText      = Color3.fromRGB(120, 120, 120),
        Border       = Color3.fromRGB(40, 40, 40),
        Slider       = Color3.fromRGB(0, 200, 100),
        SliderBg     = Color3.fromRGB(38, 38, 38),
        Toggle       = Color3.fromRGB(0, 200, 100),
        ToggleOff    = Color3.fromRGB(50, 50, 50),
        Notify       = Color3.fromRGB(18, 18, 18),
        NotifyBorder = Color3.fromRGB(0, 200, 100),
        Close        = Color3.fromRGB(232, 72, 85),
        Minimize     = Color3.fromRGB(255, 189, 46),
        Maximize     = Color3.fromRGB(52, 199, 89),
    },
})
```

---

## 🪟 Creating a Window

```lua
local Window = lib:CreateWindow({
    Title     = "My Hub",
    SubTitle  = "v1.0",            -- optional subtitle under title
    Theme     = "Dark",            -- "Dark" | "Midnight" | "Crimson" | custom table
    Size      = UDim2.new(0, 580, 0, 430),
    Position  = UDim2.new(0.5, -290, 0.5, -215),
    Icon      = "◈",               -- any UTF-8 glyph or emoji
    ToggleKey = Enum.KeyCode.RightShift,
})
```

### Window Methods

| Method | Description |
|--------|-------------|
| `Window:Notify(opts)` | Fire a toast notification |
| `Window:SetTheme(name)` | Swap theme at runtime (name string or custom table) |
| `Window:SetTitle(str)` | Update the window title text at runtime |
| `Window:GetFlag(key)` | Read a flag value from `getgenv()` |
| `Window:SetFlag(key, val)` | Write a flag and call `:Set()` on the matching element |
| `Window:SaveConfig(name)` | Serialize all flag values to `name.json` via `writefile` |
| `Window:LoadConfig(name)` | Read `name.json` and restore all element states via `:Set()` |
| `Window:ResetConfig()` | Reset every element to its `Default` value |
| `Window:CreateWatermark(opts)` | Spawn a persistent always-on-top label |
| `Window:Destroy()` | Remove the window and notify layer |

---

## 💧 Watermark

A small always-visible label pinned to the screen. Optionally shows live FPS.

```lua
local WM = Window:CreateWatermark({
    Text     = "MyHub v1.0",
    Position = UDim2.new(0, 8, 0, 8),   -- optional, defaults to top-left
    ShowFPS  = true,                     -- optional, appends "  |  XX FPS"
})

WM:SetText("MyHub v2.0")   -- update label text
WM:Destroy()               -- remove watermark
```

---

## 💾 Config Save / Load

All elements with a `Flag` are included automatically. Booleans, numbers, strings, and Color3 values are supported. Requires `writefile` / `readfile` — available in most executors.

```lua
Window:SaveConfig("my_hub")    -- writes my_hub.json
Window:LoadConfig("my_hub")    -- reads my_hub.json and restores all states
Window:ResetConfig()           -- resets every element to its Default
```

---

## 📋 Tabs

Tabs appear in the left sidebar. The first tab created is activated automatically.

```lua
local Tab = Window:CreateTab({
    Name = "Combat",
    Icon = "⚔",   -- optional
})
```

### Tab Methods

| Method | Description |
|--------|-------------|
| `Tab:SetVisible(bool)` | Show or hide the tab button from the sidebar |
| `Tab:SetBadge(str)` | Show a small badge label on the tab button — pass `""` to clear |

```lua
Tab:SetBadge("NEW")     -- shows a pill badge on the tab
Tab:SetBadge("")        -- clears it
Tab:SetVisible(false)   -- hides the tab from the sidebar
```

---

## 📁 Sections

Sections are labeled containers inside a tab.

```lua
local Section = Tab:CreateSection({
    Name = "Settings",
})
```

### Section Methods

| Method | Description |
|--------|-------------|
| `Section:SetVisible(bool)` | Show or hide the entire section |
| `Section:Destroy()` | Remove the section and all its elements |

---

## 🧩 Elements

All elements are added to a **Section** object. Every element that holds state returns a control object with `:Set()` and `:Get()` methods.

> **Flags:** Any element with a `Flag` key writes its current value to `getgenv()[Flag]` in real time. Use flags to read values from anywhere in your script without storing references.

---

### 🔘 Button

Fires a callback on click. Supports an optional description line.

```lua
Section:AddButton({
    Name        = "Teleport to Spawn",
    Description = "Moves your character to spawn",  -- optional
    Callback    = function()
        -- your code here
    end,
})
```

---

### ✅ Toggle

Animated on/off switch.

```lua
local MyToggle = Section:AddToggle({
    Name        = "God Mode",
    Description = "Enables god mode",   -- optional
    Default     = false,
    Flag        = "GodMode",
    Callback    = function(value)
        -- value is true or false
    end,
})

MyToggle:Set(true)
MyToggle:Get()       -- returns current boolean
```

---

### 🎚️ Slider

Draggable number input between a min and max value.

```lua
local MySlider = Section:AddSlider({
    Name        = "Walk Speed",
    Description = "Adjusts character walk speed",  -- optional
    Min         = 0,
    Max         = 500,
    Default     = 16,
    Suffix      = " studs",
    Flag        = "WalkSpeed",
    Callback    = function(value)
        -- value is a number between Min and Max
    end,
})

MySlider:Set(100)
MySlider:Get()       -- returns current number
```

---

### 📂 Dropdown

Single-select or multi-select option list.

```lua
local MyDropdown = Section:AddDropdown({
    Name        = "Game Mode",
    Options     = {"Casual", "Ranked", "Custom"},
    Default     = "Casual",
    MultiSelect = false,   -- set true to allow multiple selections
    Flag        = "GameMode",
    Callback    = function(value)
        -- value is a string (single) or table (multi)
    end,
})

MyDropdown:Set("Ranked")
MyDropdown:Get()                  -- returns selected value
MyDropdown:AddOption("Spectate")  -- add an option at runtime
MyDropdown:RemoveOption("Custom") -- remove an option at runtime
```

---

### ✏️ Textbox

Text input. Callback fires on `FocusLost`.

```lua
local MyTextbox = Section:AddTextbox({
    Name        = "Target Player",
    Placeholder = "Enter username...",
    Default     = "",
    Flag        = "TargetName",
    Callback    = function(text)
        -- fires when the user clicks away
    end,
})

MyTextbox:Set("PlayerName")
MyTextbox:Get()   -- returns current string
```

---

### 🔤 Input (Live)

Same as Textbox but the callback fires **on every keystroke** — useful for live search, filters, or real-time updates.

```lua
local MyInput = Section:AddInput({
    Name        = "Search Player",
    Placeholder = "Type to filter...",
    Default     = "",
    Flag        = "SearchQuery",
    Callback    = function(text)
        -- fires on every character change
    end,
})

MyInput:Set("hello")
MyInput:Get()   -- returns current string
```

---

### ⌨️ Keybind

Click the button to enter binding mode, then press any key to bind it.

> The callback fires **both** when a new key is bound **and** whenever that key is pressed afterward.

```lua
local MyKeybind = Section:AddKeybind({
    Name     = "Toggle Fly",
    Default  = Enum.KeyCode.F,
    Flag     = "FlyKey",
    Callback = function(key)
        -- fires on bind and on keypress
    end,
})

MyKeybind:Set(Enum.KeyCode.G)
MyKeybind:Get()   -- returns current KeyCode
```

---

### 🎨 Color Picker

HSV gradient field + hue bar + hex input. Opens as a popup on swatch click.

```lua
local MyColor = Section:AddColorPicker({
    Name     = "ESP Color",
    Default  = Color3.fromRGB(99, 102, 241),
    Flag     = "ESPColor",
    Callback = function(color)
        -- color is a Color3 value
    end,
})

MyColor:Set(Color3.fromRGB(255, 0, 0))
MyColor:Get()   -- returns current Color3
```

---

### 🏷️ Label

Static or dynamically updated text line.

```lua
local MyLabel = Section:AddLabel("Status: Active", {
    Bold  = true,                              -- optional, default false
    Size  = 13,                                -- optional, default 12
    Color = Color3.fromRGB(99, 102, 241),      -- optional
})

MyLabel:Set("Status: Inactive")
```

---

### 📝 Paragraph

Title + body text block. Better structured than a Label for longer descriptions or changelogs.

```lua
local MyPara = Section:AddParagraph({
    Title   = "About",
    Content = "This hub was built for educational purposes only. Use responsibly.",
})

MyPara:SetTitle("Updated")
MyPara:SetContent("New version loaded.")
```

---

### 📊 Progress Bar

Read-only animated fill bar. Use `:Set()` to update the value programmatically — no user drag.

```lua
local MyBar = Section:AddProgressBar({
    Name    = "Health",
    Default = 100,     -- 0 to 100
    Suffix  = "%",     -- appended to displayed value
    Flag    = "HPBar",
})

MyBar:Set(72)    -- animates fill to 72%
MyBar:Get()      -- returns current number
```

---

### 📋 Table

Two-column key/value display with alternating row shading. Good for stat panels and info readouts.

```lua
local MyTable = Section:AddTable({
    Name = "Stats",
    Rows = {
        {"Walk Speed", "16"},
        {"Jump Power", "50"},
        {"Health",     "100"},
    },
})

MyTable:SetRows({
    {"Walk Speed", "250"},
    {"Jump Power", "100"},
})

MyTable:UpdateRow(1, "Walk Speed", "500")  -- update a single row by index
```

---

### ➖ Separator

A 1px horizontal divider. No return value.

```lua
Section:AddSeparator()
```

---

## 🔔 Notifications

Fire toast notifications from anywhere using the Window reference. Up to **4 toasts** display simultaneously — overflow queues automatically and drains as slots free.

```lua
Window:Notify({
    Title       = "Loaded",
    Description = "Script initialized successfully.",
    Duration    = 4,      -- seconds before auto-dismiss
    Icon        = "✓",    -- any UTF-8 glyph
})
```

---

## 🔍 Search

The built-in search bar in the topbar filters all elements across all tabs in real time by label name. No setup required — it works automatically on every element added via the Section methods.

---

## 💡 Full Example

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/krmizi433-oss/AxiomUI/refs/heads/main/AxiomUI.lua"))()
local lib = getgenv().AxiomUI

local Window = lib:CreateWindow({
    Title     = "My Hub",
    SubTitle  = "v3.0",
    Theme     = "Midnight",
    ToggleKey = Enum.KeyCode.RightShift,
})

local WM = Window:CreateWatermark({ Text = "My Hub v3.0", ShowFPS = true })

local Tab     = Window:CreateTab({ Name = "Player", Icon = "👤" })
local Section = Tab:CreateSection({ Name = "Movement" })

local SpeedSlider = Section:AddSlider({
    Name     = "Walk Speed",
    Min      = 16,
    Max      = 500,
    Default  = 16,
    Suffix   = " studs",
    Flag     = "WalkSpeed",
    Callback = function(v)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
    end,
})

Section:AddToggle({
    Name     = "Infinite Jump",
    Default  = false,
    Flag     = "InfJump",
    Callback = function(enabled)
        -- your infinite jump logic
    end,
})

Section:AddSeparator()

local StatsSection = Tab:CreateSection({ Name = "Info" })

local StatsTable = StatsSection:AddTable({
    Name = "Character Stats",
    Rows = {
        {"Walk Speed", "16"},
        {"Jump Power", "50"},
        {"Health",     "100"},
    },
})

local HPBar = StatsSection:AddProgressBar({
    Name    = "Health",
    Default = 100,
    Suffix  = "%",
})

Section:AddButton({
    Name     = "Save Config",
    Callback = function()
        Window:SaveConfig("my_hub")
        Window:Notify({ Title = "Saved", Icon = "✓", Duration = 2 })
    end,
})

Section:AddButton({
    Name     = "Load Config",
    Callback = function()
        Window:LoadConfig("my_hub")
        Window:Notify({ Title = "Loaded", Icon = "✓", Duration = 2 })
    end,
})

Window:Notify({
    Title       = "Ready",
    Description = "Hub loaded clean.",
    Duration    = 3,
    Icon        = "✓",
})
```

---

## 🗑️ Cleanup

```lua
lib:Destroy()          -- removes all AxiomUI windows and the notify layer
Window:Destroy()       -- removes only this specific window
```

---

*AxiomUI Executor Edition — built for speed, runs clean.*
