local P = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local CG = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")

local lp = P.LocalPlayer
local Request = RS:WaitForChild("CustomerSystem"):WaitForChild("Request")
local invoke = Request.InvokeServer

local ACCENT = Color3.fromRGB(0, 255, 170)
local BG = Color3.fromRGB(13, 13, 17)
local PANEL = Color3.fromRGB(22, 22, 28)
local OFF = Color3.fromRGB(46, 46, 54)
local KNOB = Color3.fromRGB(150, 150, 162)
local GREY = Color3.fromRGB(105, 105, 120)
local WHITE = Color3.fromRGB(240, 240, 245)

local WIDTH, HEIGHT = 232, 92
local on = false

local env = getgenv()
if env.AAH then pcall(function() env.AAH:Destroy() end) end

local function rn(n)
    local t = {}
    for i = 1, n do t[i] = string.char(math.random(97, 122)) end
    return table.concat(t)
end

local function mk(cls, props, par)
    local o = Instance.new(cls)
    for k, v in pairs(props) do o[k] = v end
    o.Parent = par
    return o
end

local function assignAll()
    if lp:GetAttribute("OrderingBlocked") then return 0 end
    local ok, snap = pcall(invoke, Request, "Snapshot")
    if not ok or type(snap) ~= "table" then return 0 end
    local free, n = {}, 0
    for _, s in ipairs(snap.Seats or {}) do if s.Available then free[s.Key] = true end end
    for _, c in ipairs(snap.Customers or {}) do
        local k = c.SuggestedSeatKey
        if c.InQueue and free[k] and pcall(invoke, Request, "Assign", c.Id, k) then
            free[k] = nil
            n += 1
        end
    end
    return n
end

local sg = mk("ScreenGui", {
    Name = rn(math.random(8, 14)),
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, CG)
env.AAH = sg

local main = mk("Frame", {
    Size = UDim2.fromOffset(WIDTH, HEIGHT),
    Position = UDim2.new(1, -(WIDTH + 16), 0, 70),
    BackgroundColor3 = BG,
    BorderSizePixel = 0,
}, sg)
mk("UICorner", {CornerRadius = UDim.new(0, 12)}, main)
mk("UIStroke", {Color = ACCENT, Thickness = 1, Transparency = 0.65}, main)
mk("UIPadding", {
    PaddingTop = UDim.new(0, 12),
    PaddingBottom = UDim.new(0, 12),
    PaddingLeft = UDim.new(0, 12),
    PaddingRight = UDim.new(0, 12),
}, main)
mk("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 10),
}, main)

local row = mk("Frame", {
    Size = UDim2.new(1, 0, 0, 44),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0,
    LayoutOrder = 1,
}, main)
mk("UICorner", {CornerRadius = UDim.new(0, 10)}, row)
local rowStroke = mk("UIStroke", {Color = OFF, Thickness = 1, Transparency = 0.3}, row)

mk("TextLabel", {
    Size = UDim2.new(1, -70, 1, 0),
    Position = UDim2.fromOffset(14, 0),
    BackgroundTransparency = 1,
    Text = "Auto Assign",
    TextColor3 = WHITE,
    TextSize = 14,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left,
}, row)

local pill = mk("Frame", {
    Size = UDim2.fromOffset(42, 22),
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -12, 0.5, 0),
    BackgroundColor3 = OFF,
    BorderSizePixel = 0,
}, row)
mk("UICorner", {CornerRadius = UDim.new(1, 0)}, pill)

local knob = mk("Frame", {
    Size = UDim2.fromOffset(16, 16),
    AnchorPoint = Vector2.new(0, 0.5),
    Position = UDim2.new(0, 3, 0.5, 0),
    BackgroundColor3 = KNOB,
    BorderSizePixel = 0,
}, pill)
mk("UICorner", {CornerRadius = UDim.new(1, 0)}, knob)

local hit = mk("TextButton", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Text = "",
    ZIndex = 5,
}, row)

mk("TextLabel", {
    Size = UDim2.new(1, 0, 0, 14),
    BackgroundTransparency = 1,
    Text = "TOOLKIT",
    TextColor3 = GREY,
    TextSize = 10,
    Font = Enum.Font.GothamBold,
    LayoutOrder = 2,
}, main)

local function setOn(v)
    on = v
    local ti = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TS:Create(pill, ti, {BackgroundColor3 = v and ACCENT or OFF}):Play()
    TS:Create(knob, ti, {
        Position = UDim2.new(0, v and 23 or 3, 0.5, 0),
        BackgroundColor3 = v and BG or KNOB,
    }):Play()
    TS:Create(rowStroke, ti, {
        Color = v and ACCENT or OFF,
        Transparency = v and 0.5 or 0.3,
    }):Play()
end
hit.Activated:Connect(function() setOn(not on) end)

local ds, sp, conn
main.InputBegan:Connect(function(i)
    local t = i.UserInputType
    if t ~= Enum.UserInputType.MouseButton1 and t ~= Enum.UserInputType.Touch then return end
    ds, sp = i.Position, main.Position
    if conn then conn:Disconnect() end
    conn = UIS.InputChanged:Connect(function(m)
        if m.UserInputType == Enum.UserInputType.MouseMovement or m.UserInputType == Enum.UserInputType.Touch then
            local d = m.Position - ds
            main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end)
    i.Changed:Connect(function()
        if i.UserInputState == Enum.UserInputState.End and conn then
            conn:Disconnect()
            conn = nil
        end
    end)
end)
sg.Destroying:Connect(function() if conn then conn:Disconnect() end end)

task.spawn(function()
    while sg.Parent do
        task.wait(0.3)
        if on then assignAll() end
    end
end)
