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

Three built-in themes. Pass the name string to `CreateWindow`.

| Name | Accent Color |
|------|-------------|
| `Dark` | Indigo `#6366F1` |
| `Midnight` | Sky Blue `#38BDF8` |
| `Crimson` | Red `#DC3250` |

---

## 🪟 Creating a Window

```lua
local Window = AxiomUI:CreateWindow({
    Title     = "My Hub",
    SubTitle  = "v1.0",            -- optional subtitle under title
    Theme     = "Dark",            -- "Dark" | "Midnight" | "Crimson"
    Size      = UDim2.new(0, 580, 0, 430),
    Position  = UDim2.new(0.5, -290, 0.5, -215),
    Icon      = "◈",               -- any UTF-8 glyph or emoji
    ToggleKey = Enum.KeyCode.RightShift,  -- key to show/hide window
})
```

### Window Methods

| Method | Description |
|--------|-------------|
| `Window:Notify(opts)` | Fire a toast notification |
| `Window:SetTheme(name)` | Swap theme at runtime |
| `Window:Destroy()` | Remove the window and notify layer |

---

## 📋 Tabs

Tabs appear in the left sidebar. The first tab created is activated automatically.

```lua
local Tab = Window:CreateTab({
    Name = "Combat",
    Icon = "⚔",   -- optional
})
```

---

## 📁 Sections

Sections are labeled containers inside a tab. Add all elements into a section.

```lua
local Section = Tab:CreateSection({
    Name = "Settings",
})
```

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
    Flag        = "GodMode",            -- getgenv().GodMode updated live
    Callback    = function(value)
        -- value is true or false
    end,
})

MyToggle:Set(true)   -- set programmatically
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
    Suffix      = " studs",   -- appended to displayed value
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

Text input field. Callback fires on `FocusLost`.

```lua
local MyTextbox = Section:AddTextbox({
    Name        = "Target Player",
    Placeholder = "Enter username...",
    Default     = "",
    Flag        = "TargetName",
    Callback    = function(text)
        -- text is the current string value
    end,
})

MyTextbox:Set("PlayerName")
MyTextbox:Get()   -- returns current string
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

MyLabel:Set("Status: Inactive")   -- update text at any time
```

---

### ➖ Separator

A 1px horizontal divider. No return value.

```lua
Section:AddSeparator()
```

---

## 🔔 Notifications

Fire toast notifications from anywhere using the Window reference.

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
    SubTitle  = "v1.0",
    Theme     = "Midnight",
    ToggleKey = Enum.KeyCode.RightShift,
})

local Tab = Window:CreateTab({ Name = "Player", Icon = "👤" })

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
    Name    = "Infinite Jump",
    Default = false,
    Flag    = "InfJump",
    Callback = function(enabled)
        -- your infinite jump logic
    end,
})

Section:AddSeparator()

Section:AddButton({
    Name     = "Reset Character",
    Callback = function()
        game.Players.LocalPlayer.Character.Humanoid.Health = 0
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
AxiomUI:Destroy()   -- removes all AxiomUI windows and the notify layer
Window:Destroy()    -- removes only this specific window
```

---

*AxiomUI Executor Edition — built for speed, runs clean.*
