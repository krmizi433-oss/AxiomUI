-- ============================================================
--  AXIOM UI LIBRARY  •  Executor Edition  •  v4
-- ============================================================

if getgenv().AxiomUI then
	getgenv().AxiomUI:Destroy()
end

local AxiomUI   = {}
AxiomUI.__index = AxiomUI

-- ── SERVICES ─────────────────────────────────────────────────
local Players            = game:GetService("Players")
local TweenService       = game:GetService("TweenService")
local UserInputService   = game:GetService("UserInputService")
local CoreGui            = game:GetService("CoreGui")
local RunService         = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ── EXECUTOR COMPAT ──────────────────────────────────────────
-- Executors differ on where ScreenGuis must be parented.
-- CoreGui is safest across Synapse X, Fluxus, Krnl, Arceus X.
local function getGuiParent()
	local ok, _ = pcall(function()
		local t = Instance.new("ScreenGui")
		t.Parent = CoreGui
		t:Destroy()
	end)
	return ok and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
end
local GUI_PARENT = getGuiParent()

-- ── THEMES ───────────────────────────────────────────────────
local Themes = {
	Dark = {
		Background   = Color3.fromRGB(15, 15, 21),
		Topbar       = Color3.fromRGB(22, 22, 32),
		TabBar       = Color3.fromRGB(18, 18, 27),
		TabActive    = Color3.fromRGB(99, 102, 241),
		TabInactive  = Color3.fromRGB(32, 32, 46),
		Section      = Color3.fromRGB(24, 24, 36),
		Element      = Color3.fromRGB(30, 30, 44),
		ElementHover = Color3.fromRGB(40, 40, 58),
		Accent       = Color3.fromRGB(99, 102, 241),
		AccentDim    = Color3.fromRGB(67, 70, 180),
		Text         = Color3.fromRGB(232, 232, 245),
		SubText      = Color3.fromRGB(120, 120, 148),
		Border       = Color3.fromRGB(44, 44, 62),
		Slider       = Color3.fromRGB(99, 102, 241),
		SliderBg     = Color3.fromRGB(42, 42, 60),
		Toggle       = Color3.fromRGB(99, 102, 241),
		ToggleOff    = Color3.fromRGB(55, 55, 75),
		Notify       = Color3.fromRGB(22, 22, 34),
		NotifyBorder = Color3.fromRGB(99, 102, 241),
		Close        = Color3.fromRGB(232, 72,  85),
		Minimize     = Color3.fromRGB(255, 189, 46),
		Maximize     = Color3.fromRGB(52, 199, 89),
	},
	Midnight = {
		Background   = Color3.fromRGB(8,  10, 18),
		Topbar       = Color3.fromRGB(12, 14, 26),
		TabBar       = Color3.fromRGB(10, 12, 22),
		TabActive    = Color3.fromRGB(56, 189, 248),
		TabInactive  = Color3.fromRGB(22, 24, 40),
		Section      = Color3.fromRGB(14, 16, 30),
		Element      = Color3.fromRGB(18, 20, 36),
		ElementHover = Color3.fromRGB(26, 28, 48),
		Accent       = Color3.fromRGB(56, 189, 248),
		AccentDim    = Color3.fromRGB(30, 140, 200),
		Text         = Color3.fromRGB(226, 232, 248),
		SubText      = Color3.fromRGB(100, 110, 140),
		Border       = Color3.fromRGB(30, 34, 56),
		Slider       = Color3.fromRGB(56, 189, 248),
		SliderBg     = Color3.fromRGB(30, 34, 56),
		Toggle       = Color3.fromRGB(56, 189, 248),
		ToggleOff    = Color3.fromRGB(40, 44, 64),
		Notify       = Color3.fromRGB(12, 14, 28),
		NotifyBorder = Color3.fromRGB(56, 189, 248),
		Close        = Color3.fromRGB(232, 72,  85),
		Minimize     = Color3.fromRGB(255, 189, 46),
		Maximize     = Color3.fromRGB(52, 199, 89),
	},
	Crimson = {
		Background   = Color3.fromRGB(16, 10, 12),
		Topbar       = Color3.fromRGB(24, 14, 18),
		TabBar       = Color3.fromRGB(20, 12, 15),
		TabActive    = Color3.fromRGB(220, 50, 80),
		TabInactive  = Color3.fromRGB(36, 20, 26),
		Section      = Color3.fromRGB(26, 15, 19),
		Element      = Color3.fromRGB(32, 18, 23),
		ElementHover = Color3.fromRGB(44, 24, 30),
		Accent       = Color3.fromRGB(220, 50, 80),
		AccentDim    = Color3.fromRGB(160, 30, 55),
		Text         = Color3.fromRGB(240, 228, 230),
		SubText      = Color3.fromRGB(140, 110, 118),
		Border       = Color3.fromRGB(55, 28, 35),
		Slider       = Color3.fromRGB(220, 50, 80),
		SliderBg     = Color3.fromRGB(50, 26, 32),
		Toggle       = Color3.fromRGB(220, 50, 80),
		ToggleOff    = Color3.fromRGB(60, 32, 40),
		Notify       = Color3.fromRGB(22, 12, 16),
		NotifyBorder = Color3.fromRGB(220, 50, 80),
		Close        = Color3.fromRGB(232, 72, 85),
		Minimize     = Color3.fromRGB(255, 189, 46),
		Maximize     = Color3.fromRGB(52, 199, 89),
	},
}

-- ── UTILITY ──────────────────────────────────────────────────
local function tw(obj, props, t, style, dir)
	TweenService:Create(obj,
		TweenInfo.new(t or 0.18,
			style or Enum.EasingStyle.Quart,
			dir   or Enum.EasingDirection.Out),
		props):Play()
end

local function corner(p, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 8)
	c.Parent = p
	return c
end

local function stroke(p, col, thick)
	local s = Instance.new("UIStroke")
	s.Color     = col
	s.Thickness = thick or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = p
	return s
end

local function pad(p, t, r, b, l)
	local u = Instance.new("UIPadding")
	u.PaddingTop    = UDim.new(0, t or 8)
	u.PaddingRight  = UDim.new(0, r or 8)
	u.PaddingBottom = UDim.new(0, b or 8)
	u.PaddingLeft   = UDim.new(0, l or 8)
	u.Parent = p
	return u
end

local function list(p, dir, spacing, ha)
	local l = Instance.new("UIListLayout")
	l.FillDirection       = dir     or Enum.FillDirection.Vertical
	l.SortOrder           = Enum.SortOrder.LayoutOrder
	l.Padding             = UDim.new(0, spacing or 6)
	l.HorizontalAlignment = ha      or Enum.HorizontalAlignment.Left
	l.Parent = p
	return l
end

local function ripple(parent, theme)
	if not parent or not parent.Parent then return end
	local r = Instance.new("Frame")
	r.Size                   = UDim2.new(0, 0, 0, 0)
	r.Position               = UDim2.new(0.5, 0, 0.5, 0)
	r.AnchorPoint            = Vector2.new(0.5, 0.5)
	r.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
	r.BackgroundTransparency = 0.78
	r.ZIndex                 = 20
	r.Parent                 = parent
	corner(r, 100)
	tw(r, {Size = UDim2.new(2, 0, 2, 0), BackgroundTransparency = 1}, 0.45)
	task.delay(0.45, function() if r and r.Parent then r:Destroy() end end)
end

-- ── DRAG ─────────────────────────────────────────────────────
-- connTable (optional): caller-owned array; every RBXScriptConnection this
-- function makes gets pushed there so the caller can tear them down on destroy.
local function makeDraggable(root, handle, connTable)
	local drag, start, origin = false, nil, nil
	local changedConn = nil

	local function push(c)
		if connTable then table.insert(connTable, c) end
		return c
	end

	push(handle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch then
			drag   = true
			start  = i.Position
			origin = root.Position
			if changedConn then changedConn:Disconnect() end
			changedConn = push(i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then drag = false end
			end))
		end
	end))
	push(UserInputService.InputChanged:Connect(function(i)
		if drag and (i.UserInputType == Enum.UserInputType.MouseMovement
		          or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - start
			root.Position = UDim2.new(
				origin.X.Scale, origin.X.Offset + d.X,
				origin.Y.Scale, origin.Y.Offset + d.Y)
		end
	end))
end

-- ── NOTIFY SYSTEM ─────────────────────────────────────────────
local _notifySg    = nil
local _notifyCont  = nil
local _notifyQueue  = {}
local _notifyActive = 0
local NOTIFY_MAX    = 4

local function ensureNotify(theme)
	if _notifySg and _notifySg.Parent then return end
	_notifySg              = Instance.new("ScreenGui")
	_notifySg.Name         = "AxiomNotify"
	_notifySg.ResetOnSpawn = false
	_notifySg.DisplayOrder = 9999
	_notifySg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	_notifySg.Parent       = GUI_PARENT

	_notifyCont                         = Instance.new("Frame")
	_notifyCont.Name                    = "Container"
	_notifyCont.Size                    = UDim2.new(0, 310, 1, -32)
	_notifyCont.Position                = UDim2.new(1, -326, 0, 16)
	_notifyCont.BackgroundTransparency  = 1
	_notifyCont.Parent                  = _notifySg
	list(_notifyCont, Enum.FillDirection.Vertical, 8)
end

local function _showNotif(opts, theme)
	local title    = opts.Title       or "Notification"
	local desc     = opts.Description or ""
	local duration = opts.Duration    or 4
	local nIcon    = opts.Icon        or "●"

	ensureNotify(theme)
	_notifyActive += 1

	local frame                     = Instance.new("Frame")
	frame.Name                      = "Notif"
	frame.Size                      = UDim2.new(1, 0, 0, 0)
	frame.BackgroundColor3          = theme.Notify
	frame.AutomaticSize             = Enum.AutomaticSize.Y
	frame.BackgroundTransparency    = 1
	frame.ClipsDescendants          = true
	frame.Parent                    = _notifyCont
	corner(frame, 10)
	stroke(frame, theme.NotifyBorder, 1.5)

	local bar                  = Instance.new("Frame")
	bar.Size                   = UDim2.new(0, 3, 1, 0)
	bar.BackgroundColor3       = theme.Accent
	bar.BorderSizePixel        = 0
	bar.ZIndex                 = 2
	bar.Parent                 = frame
	corner(bar, 3)

	local inner                     = Instance.new("Frame")
	inner.Size                      = UDim2.new(1, -14, 1, 0)
	inner.Position                  = UDim2.new(0, 14, 0, 0)
	inner.BackgroundTransparency    = 1
	inner.AutomaticSize             = Enum.AutomaticSize.Y
	inner.Parent                    = frame
	pad(inner, 10, 10, 10, 8)
	list(inner, Enum.FillDirection.Vertical, 3)

	local tl                    = Instance.new("TextLabel")
	tl.Size                     = UDim2.new(1, 0, 0, 18)
	tl.BackgroundTransparency   = 1
	tl.Text                     = nIcon .. "  " .. title
	tl.TextColor3               = theme.Text
	tl.Font                     = Enum.Font.GothamBold
	tl.TextSize                 = 13
	tl.TextXAlignment           = Enum.TextXAlignment.Left
	tl.Parent                   = inner

	if desc ~= "" then
		local dl                    = Instance.new("TextLabel")
		dl.Size                     = UDim2.new(1, 0, 0, 0)
		dl.AutomaticSize            = Enum.AutomaticSize.Y
		dl.BackgroundTransparency   = 1
		dl.Text                     = desc
		dl.TextColor3               = theme.SubText
		dl.Font                     = Enum.Font.Gotham
		dl.TextSize                 = 12
		dl.TextWrapped              = true
		dl.TextXAlignment           = Enum.TextXAlignment.Left
		dl.Parent                   = inner
	end

	local prog                  = Instance.new("Frame")
	prog.Size                   = UDim2.new(1, -14, 0, 2)
	prog.Position               = UDim2.new(0, 14, 1, -2)
	prog.BackgroundColor3       = theme.Accent
	prog.BackgroundTransparency = 0.3
	prog.BorderSizePixel        = 0
	prog.Parent                 = frame

	tw(frame,  {BackgroundTransparency = 0}, 0.2)
	tw(prog,   {Size = UDim2.new(0, 0, 0, 2)}, duration, Enum.EasingStyle.Linear)

	task.delay(duration, function()
		tw(frame, {BackgroundTransparency = 1}, 0.25)
		task.delay(0.3, function()
			pcall(function() if frame and frame.Parent then frame:Destroy() end end)
			_notifyActive = math.max(0, _notifyActive - 1)
			if #_notifyQueue > 0 then
				local nxt = table.remove(_notifyQueue, 1)
				_showNotif(nxt.opts, nxt.theme)
			end
		end)
	end)
end

local function Notify(opts, theme)
	opts = opts or {}
	if _notifyActive < NOTIFY_MAX then
		_showNotif(opts, theme)
	else
		table.insert(_notifyQueue, {opts = opts, theme = theme})
	end
end

-- ── KEYBIND MANAGER ──────────────────────────────────────────
-- Shared across all windows; toggle visibility with a key
local _keybindConn = nil
local _keybindKey  = Enum.KeyCode.RightShift

-- ── CREATE WINDOW ─────────────────────────────────────────────
function AxiomUI:CreateWindow(opts)
	opts = opts or {}
	local title      = opts.Title    or "Axiom"
	local subtitle   = opts.SubTitle or ""
	local themeName  = opts.Theme    or "Dark"
	local wSize      = opts.Size     or UDim2.new(0, 580, 0, 430)
	local wPos       = opts.Position or UDim2.new(0.5, -290, 0.5, -215)
	local wIcon      = opts.Icon     or "◈"
	local toggleKey  = opts.ToggleKey or Enum.KeyCode.RightShift

	local theme = (type(opts.Theme) == "table" and opts.Theme) or Themes[themeName] or Themes.Dark

	-- ── ScreenGui (executor-safe parent) ──────────────────────
	local sg              = Instance.new("ScreenGui")
	sg.Name               = "AxiomUI_" .. title
	sg.ResetOnSpawn       = false
	sg.ZIndexBehavior     = Enum.ZIndexBehavior.Sibling
	sg.DisplayOrder       = 500
	sg.IgnoreGuiInset     = true
	sg.Parent             = GUI_PARENT

	-- ── Root window frame ─────────────────────────────────────
	local win             = Instance.new("Frame")
	win.Name              = "Window"
	win.Size              = UDim2.new(0, 0, 0, 0)
	win.Position          = UDim2.new(
		wPos.X.Scale, wPos.X.Offset + wSize.X.Offset / 2,
		wPos.Y.Scale, wPos.Y.Offset + wSize.Y.Offset / 2)
	win.BackgroundColor3  = theme.Background
	win.ClipsDescendants  = true
	win.Parent            = sg
	corner(win, 12)
	stroke(win, theme.Border, 1.5)

	-- Drop shadow via blurred image label
	local shadow              = Instance.new("ImageLabel")
	shadow.Size               = UDim2.new(1, 40, 1, 40)
	shadow.Position           = UDim2.new(0, -20, 0, 14)
	shadow.BackgroundTransparency = 1
	shadow.Image              = "rbxassetid://6014261993"
	shadow.ImageColor3        = Color3.fromRGB(0, 0, 0)
	shadow.ImageTransparency  = 0.55
	shadow.ScaleType          = Enum.ScaleType.Slice
	shadow.SliceCenter        = Rect.new(49, 49, 450, 450)
	shadow.ZIndex             = 0
	shadow.Parent             = win

	-- Open animation
	tw(win, {Size = wSize, Position = wPos}, 0.32,
		Enum.EasingStyle.Back, Enum.EasingDirection.Out)

	-- ── TOPBAR ────────────────────────────────────────────────
	local topbar              = Instance.new("Frame")
	topbar.Name               = "Topbar"
	topbar.Size               = UDim2.new(1, 0, 0, 48)
	topbar.BackgroundColor3   = theme.Topbar
	topbar.BorderSizePixel    = 0
	topbar.ZIndex             = 3
	topbar.Parent             = win
	corner(topbar, 12)

	-- square off bottom corners of topbar
	local tbFill              = Instance.new("Frame")
	tbFill.Size               = UDim2.new(1, 0, 0, 12)
	tbFill.Position           = UDim2.new(0, 0, 1, -12)
	tbFill.BackgroundColor3   = theme.Topbar
	tbFill.BorderSizePixel    = 0
	tbFill.Parent             = topbar

	-- Icon + title
	local iconLbl             = Instance.new("TextLabel")
	iconLbl.Size              = UDim2.new(0, 28, 0, 28)
	iconLbl.Position          = UDim2.new(0, 14, 0.5, -14)
	iconLbl.BackgroundTransparency = 1
	iconLbl.Text              = wIcon
	iconLbl.Font              = Enum.Font.GothamBold
	iconLbl.TextSize          = 18
	iconLbl.TextColor3        = theme.Accent
	iconLbl.ZIndex            = 4
	iconLbl.Parent            = topbar

	local titleLbl            = Instance.new("TextLabel")
	titleLbl.Size             = UDim2.new(0, 200, 0, 18)
	titleLbl.Position         = UDim2.new(0, 48, 0.5, subtitle ~= "" and -18 or -9)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text             = title
	titleLbl.Font             = Enum.Font.GothamBold
	titleLbl.TextSize         = 15
	titleLbl.TextColor3       = theme.Text
	titleLbl.TextXAlignment   = Enum.TextXAlignment.Left
	titleLbl.ZIndex           = 4
	titleLbl.Parent           = topbar

	if subtitle ~= "" then
		local subLbl            = Instance.new("TextLabel")
		subLbl.Size             = UDim2.new(0, 260, 0, 14)
		subLbl.Position         = UDim2.new(0, 48, 0.5, 2)
		subLbl.BackgroundTransparency = 1
		subLbl.Text             = subtitle
		subLbl.Font             = Enum.Font.Gotham
		subLbl.TextSize         = 11
		subLbl.TextColor3       = theme.SubText
		subLbl.TextXAlignment   = Enum.TextXAlignment.Left
		subLbl.ZIndex           = 4
		subLbl.Parent           = topbar
	end

	-- Search bar (executor perk — Rayfield has this, we do it better)
	local searchBg            = Instance.new("Frame")
	searchBg.Size             = UDim2.new(0, 160, 0, 26)
	searchBg.Position         = UDim2.new(0.5, -80, 0.5, -13)
	searchBg.BackgroundColor3 = theme.Element
	searchBg.ZIndex           = 4
	searchBg.Parent           = topbar
	corner(searchBg, 6)
	stroke(searchBg, theme.Border, 1)

	local searchBox           = Instance.new("TextBox")
	searchBox.Size            = UDim2.new(1, -28, 1, 0)
	searchBox.Position        = UDim2.new(0, 26, 0, 0)
	searchBox.BackgroundTransparency = 1
	searchBox.PlaceholderText = "Search elements..."
	searchBox.PlaceholderColor3 = theme.SubText
	searchBox.Text            = ""
	searchBox.Font            = Enum.Font.Gotham
	searchBox.TextSize        = 12
	searchBox.TextColor3      = theme.Text
	searchBox.ClearTextOnFocus = false
	searchBox.ZIndex          = 5
	searchBox.Parent          = searchBg

	local searchIcon          = Instance.new("TextLabel")
	searchIcon.Size           = UDim2.new(0, 22, 1, 0)
	searchIcon.BackgroundTransparency = 1
	searchIcon.Text           = "⌕"
	searchIcon.Font           = Enum.Font.GothamBold
	searchIcon.TextSize       = 14
	searchIcon.TextColor3     = theme.SubText
	searchIcon.ZIndex         = 5
	searchIcon.Parent         = searchBg

	-- Window controls
	local ctrlFrame           = Instance.new("Frame")
	ctrlFrame.Size            = UDim2.new(0, 62, 0, 16)
	ctrlFrame.Position        = UDim2.new(1, -76, 0.5, -8)
	ctrlFrame.BackgroundTransparency = 1
	ctrlFrame.ZIndex          = 5
	ctrlFrame.Parent          = topbar
	list(ctrlFrame, Enum.FillDirection.Horizontal, 6, Enum.HorizontalAlignment.Right)

	local function ctrlBtn(col, sym)
		local b                 = Instance.new("TextButton")
		b.Size                  = UDim2.new(0, 14, 0, 14)
		b.BackgroundColor3      = col
		b.Text                  = ""
		b.AutoButtonColor       = false
		b.ZIndex                = 6
		b.ClipsDescendants      = true
		b.Parent                = ctrlFrame
		corner(b, 100)
		local lbl               = Instance.new("TextLabel")
		lbl.Size                = UDim2.new(1, 0, 1, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text                = sym
		lbl.Font                = Enum.Font.GothamBold
		lbl.TextSize            = 8
		lbl.TextColor3          = Color3.fromRGB(20, 20, 20)
		lbl.TextTransparency    = 1
		lbl.ZIndex              = 7
		lbl.Parent              = b
		b.MouseEnter:Connect(function() lbl.TextTransparency = 0 end)
		b.MouseLeave:Connect(function() lbl.TextTransparency = 1 end)
		return b, lbl
	end

	local minBtn  = ctrlBtn(theme.Minimize, "−")
	local closeBtn = ctrlBtn(theme.Close,   "×")

	local minimized = false
	minBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		tw(win, {Size = minimized and UDim2.new(wSize.X.Scale, wSize.X.Offset, 0, 48) or wSize}, 0.22)
	end)

	closeBtn.MouseButton1Click:Connect(function()
		tw(win, {BackgroundTransparency = 1, Size = UDim2.new(0, wSize.X.Offset, 0, 0)}, 0.22)
		task.delay(0.25, function() sg:Destroy() end)
	end)

	-- every long-lived RBXScriptConnection (sliders, color pickers, drag) lives
	-- here so Destroy() can actually kill them instead of leaking them
	local _winConnections = {}

	makeDraggable(win, topbar, _winConnections)

	-- Toggle key
	if _keybindConn then _keybindConn:Disconnect() end
	_keybindKey = toggleKey
	_keybindConn = UserInputService.InputBegan:Connect(function(i, gp)
		if gp then return end
		if i.KeyCode == _keybindKey then
			win.Visible = not win.Visible
		end
	end)

	-- ── TAB BAR ───────────────────────────────────────────────
	local tabBar              = Instance.new("Frame")
	tabBar.Name               = "TabBar"
	tabBar.Size               = UDim2.new(0, 148, 1, -48)
	tabBar.Position           = UDim2.new(0, 0, 0, 48)
	tabBar.BackgroundColor3   = theme.TabBar
	tabBar.BorderSizePixel    = 0
	tabBar.ClipsDescendants   = true
	tabBar.Parent             = win

	local tabScroll           = Instance.new("ScrollingFrame")
	tabScroll.Size            = UDim2.new(1, 0, 1, -8)
	tabScroll.Position        = UDim2.new(0, 0, 0, 8)
	tabScroll.BackgroundTransparency = 1
	tabScroll.BorderSizePixel = 0
	tabScroll.ScrollBarThickness = 2
	tabScroll.ScrollBarImageColor3 = theme.Accent
	tabScroll.CanvasSize      = UDim2.new(0, 0, 0, 0)
	tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	tabScroll.Parent          = tabBar
	pad(tabScroll, 0, 6, 6, 6)
	list(tabScroll, Enum.FillDirection.Vertical, 4)

	-- separator line between tabbar and content
	local sep                 = Instance.new("Frame")
	sep.Size                  = UDim2.new(0, 1, 1, -48)
	sep.Position              = UDim2.new(0, 148, 0, 48)
	sep.BackgroundColor3      = theme.Border
	sep.BorderSizePixel       = 0
	sep.Parent                = win

	-- ── CONTENT AREA ──────────────────────────────────────────
	local contentArea         = Instance.new("Frame")
	contentArea.Name          = "Content"
	contentArea.Size          = UDim2.new(1, -149, 1, -48)
	contentArea.Position      = UDim2.new(0, 149, 0, 48)
	contentArea.BackgroundColor3 = theme.Background
	contentArea.ClipsDescendants = true
	contentArea.Parent        = win

	-- ── TAB STATE ─────────────────────────────────────────────
	local tabs         = {}
	local activeTab    = nil
	local activeBtn    = nil

	-- Search filter: hide/show elements by label text
	local allElements  = {} -- {frame, labelText, page}

	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local q = searchBox.Text:lower()
		for _, e in ipairs(allElements) do
			-- Only touch elements belonging to the currently active tab's page —
			-- otherwise clearing the search pops hidden-tab elements visible
			-- and they bleed through once that tab is switched to.
			if not activeTab or e.page == activeTab._page then
				if q == "" then
					e.frame.Visible = true
				else
					e.frame.Visible = e.label:lower():find(q, 1, true) ~= nil
				end
			end
		end
	end)

	-- ── Window object ─────────────────────────────────────────
	local Window = {_theme = theme, _sg = sg, _win = win}

	-- registered elements for config system: {flag, obj, default}
	local _flagRegistry = {}

	function Window:Notify(o)
		Notify(o, theme)
	end

	function Window:Destroy()
		if _keybindConn then _keybindConn:Disconnect(); _keybindConn = nil end
		for _, c in ipairs(_winConnections) do
			pcall(function() c:Disconnect() end)
		end
		_winConnections = {}
		sg:Destroy()
		-- Only destroy the shared notify layer if no other AxiomUI windows remain
		local remaining = 0
		for _, child in ipairs(GUI_PARENT:GetChildren()) do
			if child.Name:find("^AxiomUI_") and child ~= sg then
				remaining += 1
			end
		end
		if remaining == 0 and _notifySg then
			pcall(function() _notifySg:Destroy() end)
			_notifySg   = nil
			_notifyCont = nil
		end
	end

	function Window:SetTheme(name)
		theme = (type(name) == "table" and name) or Themes[name] or theme
	end

	function Window:SetTitle(str)
		if titleLbl then titleLbl.Text = str end
	end

	function Window:GetFlag(key)
		return getgenv()[key]
	end

	function Window:SetFlag(key, val)
		getgenv()[key] = val
		for _, reg in ipairs(_flagRegistry) do
			if reg.flag == key and reg.obj and reg.obj.Set then
				reg.obj:Set(val)
			end
		end
	end

	function Window:SaveConfig(name)
		local data = {}
		for _, reg in ipairs(_flagRegistry) do
			if reg.flag then
				local v = getgenv()[reg.flag]
				if type(v) == "boolean" or type(v) == "number" or type(v) == "string" then
					data[reg.flag] = v
				elseif type(v) == "userdata" and v.R then
					data[reg.flag] = {r = v.R, g = v.G, b = v.B}
				end
			end
		end
		local ok, svc = pcall(function() return game:GetService("HttpService") end)
		if ok then
			local json = svc:JSONEncode(data)
			pcall(writefile, (name or "axiom_config") .. ".json", json)
		end
	end

	function Window:LoadConfig(name)
		local ok, content = pcall(readfile, (name or "axiom_config") .. ".json")
		if not ok or not content then return end
		local svc = game:GetService("HttpService")
		local ok2, data = pcall(function() return svc:JSONDecode(content) end)
		if not ok2 or type(data) ~= "table" then return end
		for _, reg in ipairs(_flagRegistry) do
			if reg.flag and data[reg.flag] ~= nil then
				local v = data[reg.flag]
				if type(v) == "table" and v.r then
					v = Color3.new(v.r, v.g, v.b)
				end
				if reg.obj and reg.obj.Set then reg.obj:Set(v) end
			end
		end
	end

	function Window:ResetConfig()
		for _, reg in ipairs(_flagRegistry) do
			if reg.obj and reg.obj.Set and reg.default ~= nil then
				reg.obj:Set(reg.default)
			end
		end
	end

	function Window:CreateWatermark(opts)
		opts = opts or {}
		local wText = opts.Text or title
		local wPos  = opts.Position or UDim2.new(0, 8, 0, 8)

		local wmSg              = Instance.new("ScreenGui")
		wmSg.Name               = "AxiomWatermark"
		wmSg.ResetOnSpawn       = false
		wmSg.DisplayOrder       = 9998
		wmSg.IgnoreGuiInset     = true
		wmSg.Parent             = GUI_PARENT

		local wmFrame               = Instance.new("Frame")
		wmFrame.Size               = UDim2.new(0, 0, 0, 28)
		wmFrame.Position           = wPos
		wmFrame.BackgroundColor3   = theme.Topbar
		wmFrame.AutomaticSize      = Enum.AutomaticSize.X
		wmFrame.Parent             = wmSg
		corner(wmFrame, 7)
		stroke(wmFrame, theme.Border, 1)
		pad(wmFrame, 6, 12, 6, 12)

		local wmLbl                 = Instance.new("TextLabel")
		wmLbl.Size                 = UDim2.new(0, 0, 1, 0)
		wmLbl.AutomaticSize        = Enum.AutomaticSize.X
		wmLbl.BackgroundTransparency = 1
		wmLbl.Text                 = wText
		wmLbl.Font                 = Enum.Font.GothamBold
		wmLbl.TextSize             = 12
		wmLbl.TextColor3           = theme.Text
		wmLbl.Parent               = wmFrame

		-- FPS counter update
		local _fpsConn = nil
		if opts.ShowFPS then
			_fpsConn = RunService.Heartbeat:Connect(function(dt)
				local fps = math.floor(1 / dt + 0.5)
				wmLbl.Text = wText .. "  |  " .. fps .. " FPS"
			end)
		end

		local WM = {}
		function WM:SetText(t) wText = t; wmLbl.Text = t end
		function WM:Destroy()
			if _fpsConn then _fpsConn:Disconnect(); _fpsConn = nil end
			wmSg:Destroy()
		end
		return WM
	end

	-- ── CREATE TAB ────────────────────────────────────────────
	function Window:CreateTab(tOpts)
		tOpts = tOpts or {}
		local tName = tOpts.Name  or ("Tab " .. (#tabs + 1))
		local tIcon = tOpts.Icon  or nil

		-- Tab button
		local tBtn              = Instance.new("TextButton")
		tBtn.Name               = "Tab_" .. tName
		tBtn.Size               = UDim2.new(1, 0, 0, 36)
		tBtn.BackgroundColor3   = theme.TabInactive
		tBtn.Text               = ""
		tBtn.AutoButtonColor    = false
		tBtn.LayoutOrder        = #tabs + 1
		tBtn.ClipsDescendants   = true
		tBtn.ZIndex             = 2
		tBtn.Parent             = tabScroll
		corner(tBtn, 7)

		local tRow              = Instance.new("Frame")
		tRow.Size               = UDim2.new(1, 0, 1, 0)
		tRow.BackgroundTransparency = 1
		tRow.ZIndex             = 3
		tRow.Parent             = tBtn
		pad(tRow, 0, 8, 0, 10)
		list(tRow, Enum.FillDirection.Horizontal, 7)

		if tIcon then
			local icoL          = Instance.new("TextLabel")
			icoL.Name           = "TIcon"
			icoL.Size           = UDim2.new(0, 16, 1, 0)
			icoL.BackgroundTransparency = 1
			icoL.Text           = tIcon
			icoL.Font           = Enum.Font.Gotham
			icoL.TextSize       = 14
			icoL.TextColor3     = theme.SubText
			icoL.ZIndex         = 4
			icoL.Parent         = tRow
		end

		local tLbl              = Instance.new("TextLabel")
		tLbl.Name               = "TLabel"
		tLbl.Size               = UDim2.new(1, tIcon and -23 or 0, 1, 0)
		tLbl.BackgroundTransparency = 1
		tLbl.Text               = tName
		tLbl.Font               = Enum.Font.GothamSemibold
		tLbl.TextSize           = 13
		tLbl.TextColor3         = theme.SubText
		tLbl.TextXAlignment     = Enum.TextXAlignment.Left
		tLbl.ZIndex             = 4
		tLbl.Parent             = tRow

		-- Active indicator bar (left edge)
		local ind               = Instance.new("Frame")
		ind.Name                = "Indicator"
		ind.Size                = UDim2.new(0, 3, 0.55, 0)
		ind.Position            = UDim2.new(0, -3, 0.225, 0)
		ind.BackgroundColor3    = theme.Accent
		ind.BorderSizePixel     = 0
		ind.Visible             = false
		ind.ZIndex              = 5
		ind.Parent              = tBtn
		corner(ind, 4)

		-- Page
		local page              = Instance.new("ScrollingFrame")
		page.Name               = "Page_" .. tName
		page.Size               = UDim2.new(1, 0, 1, 0)
		page.BackgroundTransparency = 1
		page.BorderSizePixel    = 0
		page.ScrollBarThickness = 3
		page.ScrollBarImageColor3 = theme.Accent
		page.CanvasSize         = UDim2.new(0, 0, 0, 0)
		page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		page.Visible            = false
		page.ZIndex             = 1
		page.Parent             = contentArea
		pad(page, 10, 10, 10, 10)
		list(page, Enum.FillDirection.Vertical, 8)

		local Tab = {_page = page, _theme = theme}

		local function activate()
			if activeTab then activeTab._page.Visible = false end
			if activeBtn then
				tw(activeBtn, {BackgroundColor3 = theme.TabInactive}, 0.14)
				local ol = activeBtn:FindFirstChild("TLabel", true)
				if ol then ol.TextColor3 = theme.SubText end
				local oi = activeBtn:FindFirstChild("TIcon", true)
				if oi then oi.TextColor3 = theme.SubText end
				local ii = activeBtn:FindFirstChild("Indicator")
				if ii then ii.Visible = false end
			end
			activeTab  = Tab
			activeBtn  = tBtn
			page.Visible = true
			tw(tBtn, {BackgroundColor3 = theme.TabActive}, 0.14)
			tLbl.TextColor3 = theme.Text
			ind.Visible     = true
			tw(ind, {Position = UDim2.new(0, 0, 0.225, 0)}, 0.14)
			if tIcon then
				local icoL = tBtn:FindFirstChild("TIcon", true)
				if icoL then icoL.TextColor3 = theme.Text end
			end
			ripple(tBtn, theme)
		end
		Tab._activate = activate

		tBtn.MouseButton1Click:Connect(activate)
		tBtn.MouseEnter:Connect(function()
			if activeTab ~= Tab then tw(tBtn, {BackgroundColor3 = theme.ElementHover}, 0.1) end
		end)
		tBtn.MouseLeave:Connect(function()
			if activeTab ~= Tab then tw(tBtn, {BackgroundColor3 = theme.TabInactive}, 0.1) end
		end)

		table.insert(tabs, Tab)
		if #tabs == 1 then activate() end

		function Tab:SetVisible(v)
			tBtn.Visible = v
			if not v and activeTab == Tab then
				-- Closing the active tab — hand off to the first remaining
				-- visible tab using its own activate(), so the indicator,
				-- text color, and tab-button highlight all update correctly
				-- instead of just flipping page.Visible with stale styling.
				local fallback = nil
				for _, t in ipairs(tabs) do
					if t ~= Tab and t._page then
						-- find its button to confirm it's actually visible
						for _, btn in ipairs(tabScroll:GetChildren()) do
							if btn:IsA("TextButton") and btn.Name == "Tab_" .. (t._page.Name:gsub("^Page_", "")) and btn.Visible then
								fallback = t
								break
							end
						end
					end
					if fallback then break end
				end
				if fallback and fallback._activate then
					fallback._activate()
				else
					page.Visible = false
					activeTab = nil
					activeBtn = nil
				end
			end
		end

		function Tab:SetBadge(text)
			local existing = tBtn:FindFirstChild("Badge")
			if existing then existing:Destroy() end
			if not text or text == "" then return end
			local badge               = Instance.new("TextLabel")
			badge.Name               = "Badge"
			badge.Size               = UDim2.new(0, 0, 0, 16)
			badge.AutomaticSize      = Enum.AutomaticSize.X
			badge.Position           = UDim2.new(1, -4, 0, 4)
			badge.AnchorPoint        = Vector2.new(1, 0)
			badge.BackgroundColor3   = theme.Accent
			badge.Text               = text
			badge.Font               = Enum.Font.GothamBold
			badge.TextSize           = 9
			badge.TextColor3         = Color3.fromRGB(255, 255, 255)
			badge.ZIndex             = 6
			badge.Parent             = tBtn
			corner(badge, 4)
			pad(badge, 2, 5, 2, 5)
		end

		-- ── CREATE SECTION ────────────────────────────────────
		function Tab:CreateSection(sOpts)
			sOpts = sOpts or {}
			local sName = sOpts.Name or "Section"

			local sf                    = Instance.new("Frame")
			sf.Name                     = "Sec_" .. sName
			sf.Size                     = UDim2.new(1, 0, 0, 0)
			sf.BackgroundColor3         = theme.Section
			sf.AutomaticSize            = Enum.AutomaticSize.Y
			sf.Parent                   = page
			corner(sf, 9)
			stroke(sf, theme.Border, 1)

			local si                    = Instance.new("Frame")
			si.Size                     = UDim2.new(1, 0, 1, 0)
			si.BackgroundTransparency   = 1
			si.AutomaticSize            = Enum.AutomaticSize.Y
			si.Parent                   = sf
			pad(si, 10, 10, 10, 10)
			list(si, Enum.FillDirection.Vertical, 7)

			-- header
			local hdr                   = Instance.new("Frame")
			hdr.Size                    = UDim2.new(1, 0, 0, 22)
			hdr.BackgroundTransparency  = 1
			hdr.LayoutOrder             = 0
			hdr.Parent                  = si

			local hline                 = Instance.new("Frame")
			hline.Size                  = UDim2.new(1, 0, 0, 1)
			hline.Position              = UDim2.new(0, 0, 1, -1)
			hline.BackgroundColor3      = theme.Border
			hline.BorderSizePixel       = 0
			hline.Parent                = hdr

			local hlbl                  = Instance.new("TextLabel")
			hlbl.Size                   = UDim2.new(1, 0, 1, 0)
			hlbl.BackgroundTransparency = 1
			hlbl.Text                   = sName:upper()
			hlbl.Font                   = Enum.Font.GothamBold
			hlbl.TextSize               = 10
			hlbl.TextColor3             = theme.Accent
			hlbl.TextXAlignment         = Enum.TextXAlignment.Left
			hlbl.Parent                 = hdr

			local lo      = 1
			local function nlo() lo += 1 return lo end

			local S = {}

			-- ── BUTTON ──────────────────────────────────────
			function S:AddButton(o)
				o = o or {}
				local lbl  = o.Name or "Button"
				local desc = o.Description or ""
				local cb   = o.Callback or function() end

				local e                   = Instance.new("TextButton")
				e.Name                    = "Btn_" .. lbl
				e.Size                    = UDim2.new(1, 0, 0, desc ~= "" and 48 or 34)
				e.BackgroundColor3        = theme.Element
				e.Text                    = ""
				e.AutoButtonColor         = false
				e.ClipsDescendants        = true
				e.LayoutOrder             = nlo()
				e.Parent                  = si
				corner(e, 7)
				stroke(e, theme.Border, 1)

				local ep                  = Instance.new("Frame")
				ep.Size                   = UDim2.new(1, 0, 1, 0)
				ep.BackgroundTransparency = 1
				ep.Parent                 = e
				pad(ep, 8, 10, 8, 12)

				local ll                  = Instance.new("TextLabel")
				ll.Size                   = UDim2.new(1, -30, 0, 16)
				ll.BackgroundTransparency = 1
				ll.Text                   = lbl
				ll.Font                   = Enum.Font.GothamSemibold
				ll.TextSize               = 13
				ll.TextColor3             = theme.Text
				ll.TextXAlignment         = Enum.TextXAlignment.Left
				ll.Parent                 = ep

				if desc ~= "" then
					local dl                  = Instance.new("TextLabel")
					dl.Size                   = UDim2.new(1, 0, 0, 14)
					dl.Position               = UDim2.new(0, 0, 0, 20)
					dl.BackgroundTransparency = 1
					dl.Text                   = desc
					dl.Font                   = Enum.Font.Gotham
					dl.TextSize               = 11
					dl.TextColor3             = theme.SubText
					dl.TextXAlignment         = Enum.TextXAlignment.Left
					dl.Parent                 = ep
				end

				local arr                 = Instance.new("TextLabel")
				arr.Size                  = UDim2.new(0, 20, 0, 20)
				arr.Position              = UDim2.new(1, -28, 0.5, -10)
				arr.BackgroundTransparency = 1
				arr.Text                  = "›"
				arr.Font                  = Enum.Font.GothamBold
				arr.TextSize              = 20
				arr.TextColor3            = theme.SubText
				arr.Parent                = e

				e.MouseEnter:Connect(function()
					tw(e,   {BackgroundColor3 = theme.ElementHover}, 0.1)
					tw(arr, {TextColor3 = theme.Accent}, 0.1)
				end)
				e.MouseLeave:Connect(function()
					tw(e,   {BackgroundColor3 = theme.Element}, 0.1)
					tw(arr, {TextColor3 = theme.SubText}, 0.1)
				end)
				e.MouseButton1Click:Connect(function()
					ripple(e, theme)
					task.spawn(cb)
				end)

				table.insert(allElements, {frame = e, label = lbl, page = page})
				return e
			end

			-- ── TOGGLE ──────────────────────────────────────
			function S:AddToggle(o)
				o = o or {}
				local lbl  = o.Name or "Toggle"
				local desc = o.Description or ""
				local def  = o.Default ~= nil and o.Default or false
				local cb   = o.Callback or function() end
				local flag = o.Flag    -- optional global flag key

				local state = def

				local e                   = Instance.new("Frame")
				e.Name                    = "Tog_" .. lbl
				e.Size                    = UDim2.new(1, 0, 0, desc ~= "" and 48 or 34)
				e.BackgroundColor3        = theme.Element
				e.LayoutOrder             = nlo()
				e.Parent                  = si
				corner(e, 7)
				stroke(e, theme.Border, 1)
				pad(e, 8, 10, 8, 12)

				local ll                  = Instance.new("TextLabel")
				ll.Size                   = UDim2.new(1, -58, 0, 16)
				ll.BackgroundTransparency = 1
				ll.Text                   = lbl
				ll.Font                   = Enum.Font.GothamSemibold
				ll.TextSize               = 13
				ll.TextColor3             = theme.Text
				ll.TextXAlignment         = Enum.TextXAlignment.Left
				ll.Parent                 = e

				if desc ~= "" then
					local dl                  = Instance.new("TextLabel")
					dl.Size                   = UDim2.new(1, -58, 0, 14)
					dl.Position               = UDim2.new(0, 0, 0, 22)
					dl.BackgroundTransparency = 1
					dl.Text                   = desc
					dl.Font                   = Enum.Font.Gotham
					dl.TextSize               = 11
					dl.TextColor3             = theme.SubText
					dl.TextXAlignment         = Enum.TextXAlignment.Left
					dl.Parent                 = e
				end

				local track               = Instance.new("TextButton")
				track.Size                = UDim2.new(0, 44, 0, 23)
				track.Position            = UDim2.new(1, -52, 0.5, -11.5)
				track.BackgroundColor3    = state and theme.Toggle or theme.ToggleOff
				track.Text                = ""
				track.AutoButtonColor     = false
				track.Parent              = e
				corner(track, 100)

				local knob                = Instance.new("Frame")
				knob.Size                 = UDim2.new(0, 17, 0, 17)
				knob.Position             = state
					and UDim2.new(1, -20, 0.5, -8.5)
					or  UDim2.new(0, 3,  0.5, -8.5)
				knob.BackgroundColor3     = Color3.fromRGB(255, 255, 255)
				knob.BorderSizePixel      = 0
				knob.ZIndex               = 2
				knob.Parent               = track
				corner(knob, 100)

				local T = {}
				local function set(v)
					state = v
					tw(track, {BackgroundColor3 = v and theme.Toggle or theme.ToggleOff}, 0.18)
					tw(knob,  {Position = v
						and UDim2.new(1, -20, 0.5, -8.5)
						or  UDim2.new(0, 3,  0.5, -8.5)}, 0.18)
					if flag then getgenv()[flag] = v end
					task.spawn(cb, v)
				end

				track.MouseButton1Click:Connect(function()
					ripple(track, theme)
					set(not state)
				end)

				function T:Set(v) set(v) end
				function T:Get() return state end

				if flag then
					getgenv()[flag] = state
					table.insert(_flagRegistry, {flag = flag, obj = T, default = def})
				end
				table.insert(allElements, {frame = e, label = lbl, page = page})
				return T
			end

			-- ── SLIDER ──────────────────────────────────────
			function S:AddSlider(o)
				o = o or {}
				local lbl    = o.Name     or "Slider"
				local desc   = o.Description or ""
				local mn     = o.Min      or 0
				local mx     = o.Max      or 100
				local def    = o.Default  or mn
				local sfx    = o.Suffix   or ""
				local cb     = o.Callback or function() end
				local flag   = o.Flag

				local v = math.clamp(def, mn, mx)

				local e                   = Instance.new("Frame")
				e.Name                    = "Sld_" .. lbl
				e.Size                    = UDim2.new(1, 0, 0, desc ~= "" and 60 or 50)
				e.BackgroundColor3        = theme.Element
				e.LayoutOrder             = nlo()
				e.Parent                  = si
				corner(e, 7)
				stroke(e, theme.Border, 1)
				pad(e, 8, 12, 12, 12)

				local topRow              = Instance.new("Frame")
				topRow.Size               = UDim2.new(1, 0, 0, 16)
				topRow.BackgroundTransparency = 1
				topRow.Parent             = e

				local ll                  = Instance.new("TextLabel")
				ll.Size                   = UDim2.new(1, -65, 1, 0)
				ll.BackgroundTransparency = 1
				ll.Text                   = lbl
				ll.Font                   = Enum.Font.GothamSemibold
				ll.TextSize               = 13
				ll.TextColor3             = theme.Text
				ll.TextXAlignment         = Enum.TextXAlignment.Left
				ll.Parent                 = topRow

				local vl                  = Instance.new("TextLabel")
				vl.Size                   = UDim2.new(0, 60, 1, 0)
				vl.Position               = UDim2.new(1, -60, 0, 0)
				vl.BackgroundTransparency = 1
				vl.Text                   = tostring(v) .. sfx
				vl.Font                   = Enum.Font.GothamBold
				vl.TextSize               = 12
				vl.TextColor3             = theme.Accent
				vl.TextXAlignment         = Enum.TextXAlignment.Right
				vl.Parent                 = topRow

				if desc ~= "" then
					local dl                  = Instance.new("TextLabel")
					dl.Size                   = UDim2.new(1, 0, 0, 13)
					dl.Position               = UDim2.new(0, 0, 0, 18)
					dl.BackgroundTransparency = 1
					dl.Text                   = desc
					dl.Font                   = Enum.Font.Gotham
					dl.TextSize               = 11
					dl.TextColor3             = theme.SubText
					dl.TextXAlignment         = Enum.TextXAlignment.Left
					dl.Parent                 = e
				end

				local tr                  = Instance.new("Frame")
				tr.Size                   = UDim2.new(1, 0, 0, 6)
				tr.Position               = UDim2.new(0, 0, 1, -14)
				tr.BackgroundColor3       = theme.SliderBg
				tr.ClipsDescendants       = false
				tr.Parent                 = e
				corner(tr, 100)

				local fill                = Instance.new("Frame")
				fill.Size                 = UDim2.new((v - mn) / (mx - mn), 0, 1, 0)
				fill.BackgroundColor3     = theme.Slider
				fill.BorderSizePixel      = 0
				fill.Parent               = tr
				corner(fill, 100)

				local knob                = Instance.new("Frame")
				knob.Size                 = UDim2.new(0, 14, 0, 14)
				knob.AnchorPoint          = Vector2.new(0.5, 0.5)
				knob.Position             = UDim2.new((v - mn) / (mx - mn), 0, 0.5, 0)
				knob.BackgroundColor3     = Color3.fromRGB(255, 255, 255)
				knob.BorderSizePixel      = 0
				knob.ZIndex               = 2
				knob.Parent               = tr
				corner(knob, 100)
				stroke(knob, theme.Accent, 2)

				local dragging = false
				local function upd(i)
					local rel = math.clamp(
						(i.Position.X - tr.AbsolutePosition.X) / tr.AbsoluteSize.X, 0, 1)
					v = math.clamp(math.round(mn + (mx - mn) * rel), mn, mx)
					local t = (v - mn) / (mx - mn)
					tw(fill,  {Size = UDim2.new(t, 0, 1, 0)},   0.05)
					tw(knob,  {Position = UDim2.new(t, 0, 0.5, 0)}, 0.05)
					vl.Text = tostring(v) .. sfx
					if flag then getgenv()[flag] = v end
					task.spawn(cb, v)
				end

				table.insert(_winConnections, tr.InputBegan:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true; upd(i)
					end
				end))
				table.insert(_winConnections, UserInputService.InputChanged:Connect(function(i)
					if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then upd(i) end
				end))
				table.insert(_winConnections, UserInputService.InputEnded:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
				end))

				local Sl = {}
				function Sl:Set(val)
					v = math.clamp(val, mn, mx)
					local t = (v - mn) / (mx - mn)
					tw(fill,  {Size = UDim2.new(t, 0, 1, 0)},   0.1)
					tw(knob,  {Position = UDim2.new(t, 0, 0.5, 0)}, 0.1)
					vl.Text = tostring(v) .. sfx
					if flag then getgenv()[flag] = v end
				end
				function Sl:Get() return v end

				if flag then
					getgenv()[flag] = v
					table.insert(_flagRegistry, {flag = flag, obj = Sl, default = def})
				end
				table.insert(allElements, {frame = e, label = lbl, page = page})
				return Sl
			end

			-- ── DROPDOWN ────────────────────────────────────
			function S:AddDropdown(o)
				o = o or {}
				local lbl  = o.Name     or "Dropdown"
				local opts = o.Options  or {}
				local def  = o.Default  or opts[1] or "None"
				local cb   = o.Callback or function() end
				local flag = o.Flag
				local multi = o.MultiSelect or false

				local selected  = multi and {} or def
				local open      = false

				local cont              = Instance.new("Frame")
				cont.Name               = "DD_" .. lbl
				cont.Size               = UDim2.new(1, 0, 0, 34)
				cont.BackgroundColor3   = theme.Element
				cont.LayoutOrder        = nlo()
				cont.ClipsDescendants   = false
				cont.ZIndex             = 4
				cont.Parent             = si
				corner(cont, 7)
				stroke(cont, theme.Border, 1)

				local hdr               = Instance.new("TextButton")
				hdr.Size                = UDim2.new(1, 0, 0, 34)
				hdr.BackgroundTransparency = 1
				hdr.Text                = ""
				hdr.AutoButtonColor     = false
				hdr.ZIndex              = 5
				hdr.Parent              = cont
				pad(hdr, 8, 10, 8, 12)

				local function selText()
					if multi then
						local keys = {}
						for k in pairs(selected) do table.insert(keys, k) end
						return #keys == 0 and "None" or table.concat(keys, ", ")
					end
					return tostring(selected)
				end

				local hl                = Instance.new("TextLabel")
				hl.Size                 = UDim2.new(1, -30, 1, 0)
				hl.BackgroundTransparency = 1
				hl.Text                 = lbl .. ":  " .. selText()
				hl.Font                 = Enum.Font.GothamSemibold
				hl.TextSize             = 13
				hl.TextColor3           = theme.Text
				hl.TextXAlignment       = Enum.TextXAlignment.Left
				hl.ZIndex               = 6
				hl.Parent               = hdr

				local chev              = Instance.new("TextLabel")
				chev.Size               = UDim2.new(0, 20, 1, 0)
				chev.Position           = UDim2.new(1, -28, 0, 0)
				chev.BackgroundTransparency = 1
				chev.Text               = "⌄"
				chev.Font               = Enum.Font.GothamBold
				chev.TextSize           = 14
				chev.TextColor3         = theme.SubText
				chev.ZIndex             = 6
				chev.Parent             = hdr

				-- Parented to sg directly, not cont — cont sits inside the
				-- ScrollingFrame page, which clips anything that overflows
				-- it. Reparenting to the ScreenGui escapes that clip and the
				-- list no longer gets cut off near the bottom of a tab.
				local lst               = Instance.new("Frame")
				lst.Name                = "List_" .. lbl
				lst.Size                = UDim2.new(0, 0, 0, 0)
				lst.BackgroundColor3    = theme.TabBar
				lst.ClipsDescendants    = true
				lst.ZIndex              = 50
				lst.Visible             = false
				lst.Parent              = sg
				corner(lst, 8)
				stroke(lst, theme.Border, 1)

				local function syncListPosition()
					lst.Position = UDim2.new(
						0, cont.AbsolutePosition.X - win.AbsolutePosition.X,
						0, cont.AbsolutePosition.Y - win.AbsolutePosition.Y + cont.AbsoluteSize.Y + 4)
					lst.Size = UDim2.new(0, cont.AbsoluteSize.X, lst.Size.Y.Scale, lst.Size.Y.Offset)
				end

				local li                = Instance.new("Frame")
				li.Size                 = UDim2.new(1, 0, 1, 0)
				li.BackgroundTransparency = 1
				li.AutomaticSize        = Enum.AutomaticSize.Y
				li.ZIndex               = 13
				li.Parent               = lst
				pad(li, 4, 4, 4, 4)
				list(li, Enum.FillDirection.Vertical, 2)

				local _ddScrollConn = nil

				local function rebuild()
					for _, c in ipairs(li:GetChildren()) do
						if c:IsA("TextButton") then c:Destroy() end
					end
					for _, opt in ipairs(opts) do
						local isOn = multi and selected[opt] or opt == selected
						local ob   = Instance.new("TextButton")
						ob.Size    = UDim2.new(1, 0, 0, 28)
						ob.BackgroundColor3 = isOn and theme.Accent or theme.Element
						ob.BackgroundTransparency = isOn and 0 or 0.4
						ob.Text    = (multi and (isOn and "✓  " or "   ") or "") .. opt
						ob.Font    = Enum.Font.GothamSemibold
						ob.TextSize = 12
						ob.TextColor3 = isOn and theme.Text or theme.SubText
						ob.AutoButtonColor = false
						ob.ZIndex  = 14
						ob.Parent  = li
						corner(ob, 5)
						ob.MouseEnter:Connect(function()
							if not isOn then tw(ob, {BackgroundTransparency = 0, BackgroundColor3 = theme.Accent}, 0.1); ob.TextColor3 = theme.Text end
						end)
						ob.MouseLeave:Connect(function()
							if not isOn then tw(ob, {BackgroundTransparency = 0.4, BackgroundColor3 = theme.Element}, 0.1); ob.TextColor3 = theme.SubText end
						end)
						ob.MouseButton1Click:Connect(function()
							if multi then
								if selected[opt] then
									selected[opt] = nil
								else
									selected[opt] = true
								end
							else
								selected = opt
								open = false
								tw(lst, {Size = UDim2.new(0, cont.AbsoluteSize.X, 0, 0)}, 0.15)
								tw(chev, {Rotation = 0}, 0.15)
								if _ddScrollConn then _ddScrollConn:Disconnect(); _ddScrollConn = nil end
								task.delay(0.15, function() lst.Visible = false end)
							end
							hl.Text = lbl .. ":  " .. selText()
							rebuild()
							if flag then getgenv()[flag] = selected end
							task.spawn(cb, selected)
						end)
					end
				end
				rebuild()

				hdr.MouseButton1Click:Connect(function()
					open = not open
					if open then
						local h = math.min(#opts * 30 + 8, 180)
						syncListPosition()
						lst.Visible = true
						lst.Size = UDim2.new(0, cont.AbsoluteSize.X, 0, 0)
						tw(lst, {Size = UDim2.new(0, cont.AbsoluteSize.X, 0, h)}, 0.2)
						tw(chev, {Rotation = 180}, 0.2)
						-- Page is scrollable — keep the floating list pinned
						-- under cont while open, instead of drifting off
						-- once the user scrolls the tab.
						_ddScrollConn = RunService.Heartbeat:Connect(syncListPosition)
					else
						tw(lst, {Size = UDim2.new(0, cont.AbsoluteSize.X, 0, 0)}, 0.15)
						tw(chev, {Rotation = 0}, 0.15)
						if _ddScrollConn then _ddScrollConn:Disconnect(); _ddScrollConn = nil end
						task.delay(0.15, function() lst.Visible = false end)
					end
				end)

				local D = {}
				function D:Set(val)
					selected = val; hl.Text = lbl .. ":  " .. selText(); rebuild()
					if flag then getgenv()[flag] = selected end
				end
				function D:Get() return selected end
				function D:AddOption(opt) table.insert(opts, opt); rebuild() end
				function D:RemoveOption(opt)
					for i, v in ipairs(opts) do if v == opt then table.remove(opts, i); break end end
					rebuild()
				end
				if flag then
					getgenv()[flag] = selected
					table.insert(_flagRegistry, {flag = flag, obj = D, default = def})
				end
				table.insert(allElements, {frame = cont, label = lbl, page = page})
				-- lst lives under sg now, not cont — destroying the section
				-- frame won't clean it up, so wire it to the page's removal.
				page.AncestryChanged:Connect(function(_, parent)
					if not parent then lst:Destroy() end
				end)
				return D
			end

			-- ── TEXTBOX ─────────────────────────────────────
			function S:AddTextbox(o)
				o = o or {}
				local lbl  = o.Name        or "Textbox"
				local ph   = o.Placeholder or "Enter text..."
				local def  = o.Default     or ""
				local cb   = o.Callback    or function() end
				local flag = o.Flag

				local e                   = Instance.new("Frame")
				e.Name                    = "TB_" .. lbl
				e.Size                    = UDim2.new(1, 0, 0, 56)
				e.BackgroundColor3        = theme.Element
				e.LayoutOrder             = nlo()
				e.Parent                  = si
				corner(e, 7)
				stroke(e, theme.Border, 1)
				pad(e, 8, 10, 8, 12)

				local ll                  = Instance.new("TextLabel")
				ll.Size                   = UDim2.new(1, 0, 0, 14)
				ll.BackgroundTransparency = 1
				ll.Text                   = lbl
				ll.Font                   = Enum.Font.GothamSemibold
				ll.TextSize               = 12
				ll.TextColor3             = theme.SubText
				ll.TextXAlignment         = Enum.TextXAlignment.Left
				ll.Parent                 = e

				local ibg                 = Instance.new("Frame")
				ibg.Size                  = UDim2.new(1, 0, 0, 26)
				ibg.Position              = UDim2.new(0, 0, 0, 18)
				ibg.BackgroundColor3      = theme.TabBar
				ibg.Parent                = e
				corner(ibg, 5)
				local ibgStroke = stroke(ibg, theme.Border, 1)

				local box                 = Instance.new("TextBox")
				box.Size                  = UDim2.new(1, -16, 1, 0)
				box.Position              = UDim2.new(0, 8, 0, 0)
				box.BackgroundTransparency = 1
				box.PlaceholderText       = ph
				box.PlaceholderColor3     = theme.SubText
				box.Text                  = def
				box.Font                  = Enum.Font.Gotham
				box.TextSize              = 12
				box.TextColor3            = theme.Text
				box.TextXAlignment        = Enum.TextXAlignment.Left
				box.ClearTextOnFocus      = false
				box.Parent                = ibg

				box.Focused:Connect(function()
					tw(ibg, {BackgroundColor3 = theme.ElementHover}, 0.1)
					ibgStroke.Color = theme.Accent
					ibgStroke.Thickness = 1.5
				end)
				box.FocusLost:Connect(function(enter)
					tw(ibg, {BackgroundColor3 = theme.TabBar}, 0.1)
					ibgStroke.Color = theme.Border
					ibgStroke.Thickness = 1
					if flag then getgenv()[flag] = box.Text end
					task.spawn(cb, box.Text)
				end)

				local TB = {}
				function TB:Set(v) box.Text = v; if flag then getgenv()[flag] = v end end
				function TB:Get() return box.Text end
				if flag then
					getgenv()[flag] = def
					table.insert(_flagRegistry, {flag = flag, obj = TB, default = def})
				end
				table.insert(allElements, {frame = e, label = lbl, page = page})
				return TB
			end

			-- ── KEYBIND ─────────────────────────────────────
			function S:AddKeybind(o)
				o = o or {}
				local lbl  = o.Name    or "Keybind"
				local def  = o.Default or Enum.KeyCode.Unknown
				local cb   = o.Callback or function() end
				local flag = o.Flag

				local binding  = def
				local listening = false

				local e                   = Instance.new("Frame")
				e.Name                    = "KB_" .. lbl
				e.Size                    = UDim2.new(1, 0, 0, 34)
				e.BackgroundColor3        = theme.Element
				e.LayoutOrder             = nlo()
				e.Parent                  = si
				corner(e, 7)
				stroke(e, theme.Border, 1)
				pad(e, 8, 10, 8, 12)

				local ll                  = Instance.new("TextLabel")
				ll.Size                   = UDim2.new(1, -90, 1, 0)
				ll.BackgroundTransparency = 1
				ll.Text                   = lbl
				ll.Font                   = Enum.Font.GothamSemibold
				ll.TextSize               = 13
				ll.TextColor3             = theme.Text
				ll.TextXAlignment         = Enum.TextXAlignment.Left
				ll.Parent                 = e

				local kbBtn               = Instance.new("TextButton")
				kbBtn.Size                = UDim2.new(0, 80, 0, 22)
				kbBtn.Position            = UDim2.new(1, -88, 0.5, -11)
				kbBtn.BackgroundColor3    = theme.TabBar
				kbBtn.Text                = binding.Name
				kbBtn.Font                = Enum.Font.GothamBold
				kbBtn.TextSize            = 11
				kbBtn.TextColor3          = theme.Accent
				kbBtn.AutoButtonColor     = false
				kbBtn.Parent              = e
				corner(kbBtn, 5)
				stroke(kbBtn, theme.Border, 1)

				kbBtn.MouseButton1Click:Connect(function()
					listening = true
					kbBtn.Text       = "..."
					kbBtn.TextColor3 = theme.SubText
				end)

				UserInputService.InputBegan:Connect(function(i, gp)
					if not listening then return end
					if i.UserInputType == Enum.UserInputType.Keyboard then
						binding          = i.KeyCode
						listening        = false
						local justBound  = true
						kbBtn.Text       = binding.Name
						kbBtn.TextColor3 = theme.Accent
						if flag then getgenv()[flag] = binding end
						task.spawn(cb, binding)
						task.defer(function() justBound = false end)
						-- store justBound so the fire-handler can see it
						-- (closure shares the upvalue)
					end
				end)

				-- Fire callback when key pressed (not just bound).
				-- justBound is declared in the outer bind-handler closure and
				-- stays true for one deferred frame after rebinding, preventing
				-- the newly assigned key from double-firing on the bind frame.
				local justBound = false
				UserInputService.InputBegan:Connect(function(i, gp)
					if gp then return end
					if listening then return end
					if justBound then return end
					if i.KeyCode == binding then
						task.spawn(cb, binding)
					end
				end)

				local KB = {}
				function KB:Set(key) binding = key; kbBtn.Text = key.Name end
				function KB:Get() return binding end
				if flag then
					getgenv()[flag] = def
					table.insert(_flagRegistry, {flag = flag, obj = KB, default = def})
				end
				table.insert(allElements, {frame = e, label = lbl, page = page})
				return KB
			end

			-- ── COLOR PICKER ────────────────────────────────
			function S:AddColorPicker(o)
				o = o or {}
				local lbl  = o.Name    or "Color"
				local def  = o.Default or Color3.fromRGB(99, 102, 241)
				local cb   = o.Callback or function() end
				local flag = o.Flag

				local H, Sa, V_ = def:ToHSV()
				local currentColor = def
				local pickerOpen   = false

				local cont              = Instance.new("Frame")
				cont.Name               = "CP_" .. lbl
				cont.Size               = UDim2.new(1, 0, 0, 34)
				cont.BackgroundColor3   = theme.Element
				cont.LayoutOrder        = nlo()
				cont.ClipsDescendants   = false
				cont.ZIndex             = 4
				cont.Parent             = si
				corner(cont, 7)
				stroke(cont, theme.Border, 1)
				pad(cont, 8, 10, 8, 12)

				local ll                = Instance.new("TextLabel")
				ll.Size                 = UDim2.new(1, -46, 1, 0)
				ll.BackgroundTransparency = 1
				ll.Text                 = lbl
				ll.Font                 = Enum.Font.GothamSemibold
				ll.TextSize             = 13
				ll.TextColor3           = theme.Text
				ll.TextXAlignment       = Enum.TextXAlignment.Left
				ll.ZIndex               = 5
				ll.Parent               = cont

				local swatch            = Instance.new("TextButton")
				swatch.Size             = UDim2.new(0, 32, 0, 20)
				swatch.Position         = UDim2.new(1, -40, 0.5, -10)
				swatch.BackgroundColor3 = currentColor
				swatch.Text             = ""
				swatch.AutoButtonColor  = false
				swatch.ZIndex           = 5
				swatch.Parent           = cont
				corner(swatch, 5)
				stroke(swatch, theme.Border, 1)

				-- Picker popup — parented to sg, not cont. cont sits inside
				-- the ScrollingFrame page, so anything anchored to it gets
				-- clipped the moment it overflows the page bounds.
				local popup             = Instance.new("Frame")
				popup.Name              = "Picker_" .. lbl
				popup.Size              = UDim2.new(0, 200, 0, 190)
				popup.BackgroundColor3  = theme.Section
				popup.Visible           = false
				popup.ZIndex            = 50
				popup.ClipsDescendants  = true
				popup.Parent            = sg
				corner(popup, 10)
				stroke(popup, theme.Border, 1.5)
				pad(popup, 8, 8, 8, 8)

				local _cpScrollConn = nil
				local function syncPopupPosition()
					popup.Position = UDim2.new(
						0, cont.AbsolutePosition.X - win.AbsolutePosition.X - 4,
						0, cont.AbsolutePosition.Y - win.AbsolutePosition.Y + cont.AbsoluteSize.Y + 6)
				end

				-- SV gradient field
				local svField           = Instance.new("ImageLabel")
				svField.Size            = UDim2.new(1, 0, 0, 110)
				svField.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
				svField.Image           = "rbxassetid://6020299385" -- white-to-transparent + black gradient
				svField.ZIndex          = 21
				svField.Parent          = popup
				corner(svField, 6)

				local svCursor          = Instance.new("Frame")
				svCursor.Size           = UDim2.new(0, 10, 0, 10)
				svCursor.AnchorPoint    = Vector2.new(0.5, 0.5)
				svCursor.Position       = UDim2.new(Sa, 0, 1 - V_, 0)
				svCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				svCursor.BorderSizePixel = 0
				svCursor.ZIndex         = 22
				svCursor.Parent         = svField
				corner(svCursor, 100)
				stroke(svCursor, Color3.fromRGB(40, 40, 40), 1.5)

				-- Hue bar
				local hueBar            = Instance.new("ImageLabel")
				hueBar.Size             = UDim2.new(1, 0, 0, 16)
				hueBar.Position         = UDim2.new(0, 0, 0, 118)
				hueBar.Image            = ""
				hueBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				-- Use a hue gradient via UIGradient
				hueBar.ZIndex           = 21
				hueBar.Parent           = popup
				corner(hueBar, 4)

				local hueGrad           = Instance.new("UIGradient")
				hueGrad.Color           = ColorSequence.new({
					ColorSequenceKeypoint.new(0,    Color3.fromHSV(0,   1, 1)),
					ColorSequenceKeypoint.new(0.167,Color3.fromHSV(0.167,1,1)),
					ColorSequenceKeypoint.new(0.333,Color3.fromHSV(0.333,1,1)),
					ColorSequenceKeypoint.new(0.5,  Color3.fromHSV(0.5,  1,1)),
					ColorSequenceKeypoint.new(0.667,Color3.fromHSV(0.667,1,1)),
					ColorSequenceKeypoint.new(0.833,Color3.fromHSV(0.833,1,1)),
					ColorSequenceKeypoint.new(1,    Color3.fromHSV(1,   1,1)),
				})
				hueGrad.Parent          = hueBar

				local hueCursor         = Instance.new("Frame")
				hueCursor.Size          = UDim2.new(0, 4, 1, 4)
				hueCursor.AnchorPoint   = Vector2.new(0.5, 0.5)
				hueCursor.Position      = UDim2.new(H, 0, 0.5, 0)
				hueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				hueCursor.BorderSizePixel = 0
				hueCursor.ZIndex        = 22
				hueCursor.Parent        = hueBar
				corner(hueCursor, 3)
				stroke(hueCursor, Color3.fromRGB(40, 40, 40), 1.5)

				-- Hex input
				local hexBg             = Instance.new("Frame")
				hexBg.Size              = UDim2.new(1, 0, 0, 26)
				hexBg.Position          = UDim2.new(0, 0, 0, 142)
				hexBg.BackgroundColor3  = theme.Element
				hexBg.ZIndex            = 21
				hexBg.Parent            = popup
				corner(hexBg, 5)
				stroke(hexBg, theme.Border, 1)

				local hexBox            = Instance.new("TextBox")
				hexBox.Size             = UDim2.new(1, -32, 1, 0)
				hexBox.Position         = UDim2.new(0, 8, 0, 0)
				hexBox.BackgroundTransparency = 1
				hexBox.Font             = Enum.Font.GothamBold
				hexBox.TextSize         = 12
				hexBox.TextColor3       = theme.Text
				hexBox.Text             = ""
				hexBox.PlaceholderText  = "#RRGGBB"
				hexBox.PlaceholderColor3 = theme.SubText
				hexBox.ZIndex           = 22
				hexBox.Parent           = hexBg

				local function colorToHex(c)
					return string.format("#%02X%02X%02X",
						math.floor(c.R * 255 + 0.5),
						math.floor(c.G * 255 + 0.5),
						math.floor(c.B * 255 + 0.5))
				end

				local function applyColor()
					currentColor         = Color3.fromHSV(H, Sa, V_)
					swatch.BackgroundColor3 = currentColor
					svField.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
					svCursor.Position    = UDim2.new(Sa, 0, 1 - V_, 0)
					hueCursor.Position   = UDim2.new(H, 0, 0.5, 0)
					hexBox.Text          = colorToHex(currentColor)
					if flag then getgenv()[flag] = currentColor end
					task.spawn(cb, currentColor)
				end

				local svDrag = false
				local hueDrag = false

				table.insert(_winConnections, svField.InputBegan:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then svDrag = true end
				end))
				table.insert(_winConnections, hueBar.InputBegan:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then hueDrag = true end
				end))
				table.insert(_winConnections, UserInputService.InputEnded:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then
						svDrag = false; hueDrag = false
					end
				end))
				table.insert(_winConnections, UserInputService.InputChanged:Connect(function(i)
					if i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
					if svDrag then
						Sa = math.clamp((i.Position.X - svField.AbsolutePosition.X) / svField.AbsoluteSize.X, 0, 1)
						V_ = 1 - math.clamp((i.Position.Y - svField.AbsolutePosition.Y) / svField.AbsoluteSize.Y, 0, 1)
						applyColor()
					elseif hueDrag then
						H  = math.clamp((i.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
						applyColor()
					end
				end))

				hexBox.FocusLost:Connect(function()
					local hex = hexBox.Text:gsub("#", "")
					if #hex == 6 then
						local r = tonumber(hex:sub(1,2), 16)
						local g = tonumber(hex:sub(3,4), 16)
						local b = tonumber(hex:sub(5,6), 16)
						if r and g and b then
							local c = Color3.fromRGB(r, g, b)
							H, Sa, V_ = c:ToHSV()
							applyColor()
						end
					end
				end)

				swatch.MouseButton1Click:Connect(function()
					pickerOpen = not pickerOpen
					if pickerOpen then
						syncPopupPosition()
						hexBox.Text = colorToHex(currentColor)
						-- Page scrolls independently of the floating popup —
						-- keep it pinned under the swatch while open.
						_cpScrollConn = RunService.Heartbeat:Connect(syncPopupPosition)
					elseif _cpScrollConn then
						_cpScrollConn:Disconnect(); _cpScrollConn = nil
					end
					popup.Visible = pickerOpen
				end)

				applyColor()

				local CP = {}
				function CP:Set(c)
					currentColor = c; H, Sa, V_ = c:ToHSV(); applyColor()
				end
				function CP:Get() return currentColor end
				if flag then
					getgenv()[flag] = def
					table.insert(_flagRegistry, {flag = flag, obj = CP, default = def})
				end
				table.insert(allElements, {frame = cont, label = lbl, page = page})
				-- popup lives under sg now — wire its cleanup to the page,
				-- same pattern as the dropdown's floating list.
				page.AncestryChanged:Connect(function(_, parent)
					if not parent then popup:Destroy() end
				end)
				return CP
			end

			-- ── LABEL ───────────────────────────────────────
			function S:AddLabel(text, opts2)
				opts2 = opts2 or {}
				local lbl               = Instance.new("TextLabel")
				lbl.Name                = "Lbl"
				lbl.Size                = UDim2.new(1, 0, 0, 0)
				lbl.AutomaticSize       = Enum.AutomaticSize.Y
				lbl.BackgroundTransparency = 1
				lbl.Text                = text or ""
				lbl.Font                = opts2.Bold and Enum.Font.GothamBold or Enum.Font.Gotham
				lbl.TextSize            = opts2.Size or 12
				lbl.TextColor3          = opts2.Color or theme.SubText
				lbl.TextXAlignment      = Enum.TextXAlignment.Left
				lbl.TextWrapped         = true
				lbl.LayoutOrder         = nlo()
				lbl.Parent              = si

				local L = {}
				function L:Set(t) lbl.Text = t end
				return L
			end

			-- ── SEPARATOR ───────────────────────────────────
			function S:AddSeparator()
				local sep               = Instance.new("Frame")
				sep.Name                = "Sep"
				sep.Size                = UDim2.new(1, 0, 0, 1)
				sep.BackgroundColor3    = theme.Border
				sep.BorderSizePixel     = 0
				sep.LayoutOrder         = nlo()
				sep.Parent              = si
				return sep
			end

			-- ── PARAGRAPH ──────────────────────────────────────────
			function S:AddParagraph(o)
				o = o or {}
				local heading = o.Title or ""
				local body    = o.Content or o.Body or ""

				local e                   = Instance.new("Frame")
				e.Name                    = "Para"
				e.Size                    = UDim2.new(1, 0, 0, 0)
				e.AutomaticSize           = Enum.AutomaticSize.Y
				e.BackgroundColor3        = theme.Element
				e.LayoutOrder             = nlo()
				e.Parent                  = si
				corner(e, 7)
				stroke(e, theme.Border, 1)
				pad(e, 10, 12, 10, 12)

				local innerP              = Instance.new("Frame")
				innerP.Size               = UDim2.new(1, 0, 1, 0)
				innerP.AutomaticSize      = Enum.AutomaticSize.Y
				innerP.BackgroundTransparency = 1
				innerP.Parent             = e
				list(innerP, Enum.FillDirection.Vertical, 4)

				local hl
				if heading ~= "" then
					hl                    = Instance.new("TextLabel")
					hl.Size               = UDim2.new(1, 0, 0, 0)
					hl.AutomaticSize      = Enum.AutomaticSize.Y
					hl.BackgroundTransparency = 1
					hl.Text               = heading
					hl.Font               = Enum.Font.GothamBold
					hl.TextSize           = 13
					hl.TextColor3         = theme.Text
					hl.TextXAlignment     = Enum.TextXAlignment.Left
					hl.TextWrapped        = true
					hl.Parent             = innerP
				end

				local bl                  = Instance.new("TextLabel")
				bl.Size                   = UDim2.new(1, 0, 0, 0)
				bl.AutomaticSize          = Enum.AutomaticSize.Y
				bl.BackgroundTransparency = 1
				bl.Text                   = body
				bl.Font                   = Enum.Font.Gotham
				bl.TextSize               = 12
				bl.TextColor3             = theme.SubText
				bl.TextXAlignment         = Enum.TextXAlignment.Left
				bl.TextWrapped            = true
				bl.Parent                 = innerP

				local P = {}
				function P:SetTitle(t) if hl then hl.Text = t end end
				function P:SetContent(t) bl.Text = t end
				return P
			end

			-- ── PROGRESS BAR (read-only fill bar) ──────────────────
			function S:AddProgressBar(o)
				o = o or {}
				local lbl  = o.Name    or "Progress"
				local def  = o.Default or 0
				local sfx  = o.Suffix  or "%"
				local flag = o.Flag

				local pv = math.clamp(def, 0, 100)

				local e                   = Instance.new("Frame")
				e.Name                    = "PB_" .. lbl
				e.Size                    = UDim2.new(1, 0, 0, 44)
				e.BackgroundColor3        = theme.Element
				e.LayoutOrder             = nlo()
				e.Parent                  = si
				corner(e, 7)
				stroke(e, theme.Border, 1)
				pad(e, 8, 12, 12, 12)

				local topRow              = Instance.new("Frame")
				topRow.Size               = UDim2.new(1, 0, 0, 16)
				topRow.BackgroundTransparency = 1
				topRow.Parent             = e

				local ll                  = Instance.new("TextLabel")
				ll.Size                   = UDim2.new(1, -65, 1, 0)
				ll.BackgroundTransparency = 1
				ll.Text                   = lbl
				ll.Font                   = Enum.Font.GothamSemibold
				ll.TextSize               = 13
				ll.TextColor3             = theme.Text
				ll.TextXAlignment         = Enum.TextXAlignment.Left
				ll.Parent                 = topRow

				local vl                  = Instance.new("TextLabel")
				vl.Size                   = UDim2.new(0, 60, 1, 0)
				vl.Position               = UDim2.new(1, -60, 0, 0)
				vl.BackgroundTransparency = 1
				vl.Text                   = tostring(math.floor(pv)) .. sfx
				vl.Font                   = Enum.Font.GothamBold
				vl.TextSize               = 12
				vl.TextColor3             = theme.Accent
				vl.TextXAlignment         = Enum.TextXAlignment.Right
				vl.Parent                 = topRow

				local tr                  = Instance.new("Frame")
				tr.Size                   = UDim2.new(1, 0, 0, 6)
				tr.Position               = UDim2.new(0, 0, 1, -14)
				tr.BackgroundColor3       = theme.SliderBg
				tr.Parent                 = e
				corner(tr, 100)

				local fill                = Instance.new("Frame")
				fill.Size                 = UDim2.new(pv / 100, 0, 1, 0)
				fill.BackgroundColor3     = theme.Slider
				fill.BorderSizePixel      = 0
				fill.Parent               = tr
				corner(fill, 100)

				local PB = {}
				function PB:Set(val)
					pv = math.clamp(val, 0, 100)
					tw(fill, {Size = UDim2.new(pv / 100, 0, 1, 0)}, 0.2)
					vl.Text = tostring(math.floor(pv)) .. sfx
					if flag then getgenv()[flag] = pv end
				end
				function PB:Get() return pv end
				if flag then
					getgenv()[flag] = pv
					table.insert(_flagRegistry, {flag = flag, obj = PB, default = def})
				end
				table.insert(allElements, {frame = e, label = lbl, page = page})
				return PB
			end

			-- ── INPUT (live keystroke callback) ─────────────────────
			function S:AddInput(o)
				o = o or {}
				local lbl  = o.Name        or "Input"
				local ph   = o.Placeholder or "Type here..."
				local def  = o.Default     or ""
				local cb   = o.Callback    or function() end
				local flag = o.Flag

				local e                   = Instance.new("Frame")
				e.Name                    = "In_" .. lbl
				e.Size                    = UDim2.new(1, 0, 0, 56)
				e.BackgroundColor3        = theme.Element
				e.LayoutOrder             = nlo()
				e.Parent                  = si
				corner(e, 7)
				stroke(e, theme.Border, 1)
				pad(e, 8, 10, 8, 12)

				local ll                  = Instance.new("TextLabel")
				ll.Size                   = UDim2.new(1, 0, 0, 14)
				ll.BackgroundTransparency = 1
				ll.Text                   = lbl
				ll.Font                   = Enum.Font.GothamSemibold
				ll.TextSize               = 12
				ll.TextColor3             = theme.SubText
				ll.TextXAlignment         = Enum.TextXAlignment.Left
				ll.Parent                 = e

				local ibg                 = Instance.new("Frame")
				ibg.Size                  = UDim2.new(1, 0, 0, 26)
				ibg.Position              = UDim2.new(0, 0, 0, 18)
				ibg.BackgroundColor3      = theme.TabBar
				ibg.Parent                = e
				corner(ibg, 5)
				local ibgS = stroke(ibg, theme.Border, 1)

				local box                 = Instance.new("TextBox")
				box.Size                  = UDim2.new(1, -16, 1, 0)
				box.Position              = UDim2.new(0, 8, 0, 0)
				box.BackgroundTransparency = 1
				box.PlaceholderText       = ph
				box.PlaceholderColor3     = theme.SubText
				box.Text                  = def
				box.Font                  = Enum.Font.Gotham
				box.TextSize              = 12
				box.TextColor3            = theme.Text
				box.ClearTextOnFocus      = false
				box.Parent                = ibg

				box.Focused:Connect(function()
					tw(ibg, {BackgroundColor3 = theme.ElementHover}, 0.1)
					ibgS.Color = theme.Accent; ibgS.Thickness = 1.5
				end)
				box.FocusLost:Connect(function()
					tw(ibg, {BackgroundColor3 = theme.TabBar}, 0.1)
					ibgS.Color = theme.Border; ibgS.Thickness = 1
				end)
				box:GetPropertyChangedSignal("Text"):Connect(function()
					if flag then getgenv()[flag] = box.Text end
					task.spawn(cb, box.Text)
				end)

				local IN = {}
				function IN:Set(v) box.Text = v; if flag then getgenv()[flag] = v end end
				function IN:Get() return box.Text end
				if flag then
					getgenv()[flag] = def
					table.insert(_flagRegistry, {flag = flag, obj = IN, default = def})
				end
				table.insert(allElements, {frame = e, label = lbl, page = page})
				return IN
			end

			-- ── TABLE (key/value stat display) ──────────────────────
			function S:AddTable(o)
				o = o or {}
				local lbl  = o.Name or "Table"
				local rows = o.Rows or {}

				local cont              = Instance.new("Frame")
				cont.Name               = "Tbl_" .. lbl
				cont.Size               = UDim2.new(1, 0, 0, 0)
				cont.AutomaticSize      = Enum.AutomaticSize.Y
				cont.BackgroundColor3   = theme.Element
				cont.LayoutOrder        = nlo()
				cont.Parent             = si
				corner(cont, 7)
				stroke(cont, theme.Border, 1)
				pad(cont, 8, 10, 8, 10)

				local innerT            = Instance.new("Frame")
				innerT.Size             = UDim2.new(1, 0, 1, 0)
				innerT.AutomaticSize    = Enum.AutomaticSize.Y
				innerT.BackgroundTransparency = 1
				innerT.Parent           = cont
				list(innerT, Enum.FillDirection.Vertical, 2)

				local rowFrames = {}

				local function buildRows()
					for _, rf in ipairs(rowFrames) do rf:Destroy() end
					rowFrames = {}
					for i, row in ipairs(rows) do
						local rf              = Instance.new("Frame")
						rf.Size               = UDim2.new(1, 0, 0, 24)
						rf.BackgroundColor3   = i % 2 == 0 and theme.TabBar or theme.Element
						rf.BackgroundTransparency = 0.4
						rf.Parent             = innerT
						corner(rf, 4)

						local kl              = Instance.new("TextLabel")
						kl.Size               = UDim2.new(0.5, -4, 1, 0)
						kl.Position           = UDim2.new(0, 8, 0, 0)
						kl.BackgroundTransparency = 1
						kl.Text               = tostring(row[1] or "")
						kl.Font               = Enum.Font.GothamSemibold
						kl.TextSize           = 12
						kl.TextColor3         = theme.SubText
						kl.TextXAlignment     = Enum.TextXAlignment.Left
						kl.Parent             = rf

						local vl              = Instance.new("TextLabel")
						vl.Size               = UDim2.new(0.5, -4, 1, 0)
						vl.Position           = UDim2.new(0.5, 4, 0, 0)
						vl.BackgroundTransparency = 1
						vl.Text               = tostring(row[2] or "")
						vl.Font               = Enum.Font.GothamBold
						vl.TextSize           = 12
						vl.TextColor3         = theme.Text
						vl.TextXAlignment     = Enum.TextXAlignment.Left
						vl.Parent             = rf

						table.insert(rowFrames, rf)
					end
				end
				buildRows()

				local TB2 = {}
				function TB2:SetRows(r) rows = r; buildRows() end
				function TB2:UpdateRow(i, key, val)
					if rows[i] then rows[i] = {key, val}; buildRows() end
				end
				return TB2
			end

			-- ── SECTION CONTROL ─────────────────────────────────────
			function S:SetVisible(v)
				sf.Visible = v
			end

			function S:Destroy()
				sf:Destroy()
			end

			return S
		end

		return Tab
	end

	return Window
end

function AxiomUI:Destroy()
	if _notifySg then pcall(function() _notifySg:Destroy() end) end
	for _, sg in ipairs(GUI_PARENT:GetChildren()) do
		if sg.Name:find("AxiomUI_") then pcall(function() sg:Destroy() end) end
	end
end

getgenv().AxiomUI = AxiomUI
return AxiomUI
