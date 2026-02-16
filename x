-- Auto Fish With UI (Dropdown + Toggle + Drag + Minimize)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local Client = Players.LocalPlayer

-- ================= SETTINGS =================
local TargetNames = {
    ["Antares"] = true,
    ["Ultraviolet"] = true,
    ["Supernove"] = true,
["Prismatic Star"] = true
}

local Flags = {
    Farm = "Self"
}

local Running = false
local Connections = {}

-- ================= FUNCTIONS =================

local function GetRoot(Character)
    return Character and Character:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid(Character)
    return Character and Character:FindFirstChild("Humanoid")
end

local function CastOnly()
    local Character = Client.Character
    if not Character then return end

    local Humanoid = GetHumanoid(Character)
    local Root = GetRoot(Character)
    if not Root then return end

    local Rod = Character:FindFirstChild("Rod")
    if not Rod then return end

    local Farming = Flags.Farm == "Self"
        and Root
        or workspace:FindFirstChild("Galaxies")
        and workspace.Galaxies:FindFirstChild(Flags.Farm)
        or Root

    local FarmPos = Farming:GetPivot().Position + Vector3.new(0, 5, 0)
    local FarmLook = Farming:GetPivot().LookVector

    ReplicatedStorage.Events.Global.Cast:FireServer(
        Humanoid,
        FarmPos,
        FarmLook,
        Rod.Model.Nodes.RodTip.Attachment
    )
end

local function Withdraw()
    local Character = Client.Character
    if not Character then return end
    
    local Humanoid = GetHumanoid(Character)
    if not Humanoid then return end
    
    ReplicatedStorage.Events.Global.WithdrawBobber:FireServer(Humanoid)
end

-- Auto Confirm Items
local ClientRecieveItems = ReplicatedStorage.Events.Global.ClientRecieveItems

ClientRecieveItems.OnClientEvent:Connect(function(...)
    if not Running then return end

    local Data = {...}
    local Info = Data[4] or {}

    local FoundTarget = false

    for _, StarData in pairs(Info) do
        local Name = StarData.name
        
        if Name and TargetNames[Name] then
            FoundTarget = true
            break
        end
    end

    if FoundTarget then
        Withdraw()
    end

    -- kecil delay biar ga terlalu robotic
    task.wait(math.random(8,15)/100)

    if Running then
        CastOnly()
    end
end)

-- ================= LOOP =================


-- ================= COMPACT CLEAN UI =================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "AutoFishUI"

local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.Size = UDim2.new(0, 260, 0, 170)
Main.Position = UDim2.new(0.5, -130, 0.5, -85)
Main.BackgroundColor3 = Color3.fromRGB(25,25,30)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

Instance.new("UICorner", Main).CornerRadius = UDim.new(0,10)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(55,55,65)

-- Title
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,35)
Title.BackgroundColor3 = Color3.fromRGB(30,30,36)
Title.Text = "Auto Fish"
Title.Font = Enum.Font.GothamSemibold
Title.TextSize = 15
Title.TextColor3 = Color3.fromRGB(220,220,220)
Title.BorderSizePixel = 0
Instance.new("UICorner", Title).CornerRadius = UDim.new(0,10)

-- Toggle
local Toggle = Instance.new("TextButton", Main)
Toggle.Size = UDim2.new(0.9,0,0,32)
Toggle.Position = UDim2.new(0.05,0,0,45)
Toggle.BackgroundColor3 = Color3.fromRGB(40,40,48)
Toggle.Text = "Start"
Toggle.Font = Enum.Font.GothamMedium
Toggle.TextSize = 13
Toggle.TextColor3 = Color3.fromRGB(220,220,220)
Toggle.BorderSizePixel = 0
Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0,8)

-- Dropdown Main Button
local Dropdown = Instance.new("TextButton", Main)
Dropdown.Size = UDim2.new(0.9,0,0,30)
Dropdown.Position = UDim2.new(0.05,0,0,90)
Dropdown.BackgroundColor3 = Color3.fromRGB(40,40,48)
Dropdown.Text = Flags.Farm
Dropdown.Font = Enum.Font.Gotham
Dropdown.TextSize = 13
Dropdown.TextColor3 = Color3.fromRGB(220,220,220)
Dropdown.BorderSizePixel = 0
Instance.new("UICorner", Dropdown).CornerRadius = UDim.new(0,8)

-- Dropdown List Container
local DropFrame = Instance.new("Frame", Main)
DropFrame.Size = UDim2.new(0.9,0,0,70)
DropFrame.Position = UDim2.new(0.05,0,0,125)
DropFrame.BackgroundColor3 = Color3.fromRGB(32,32,38)
DropFrame.Visible = false
DropFrame.BorderSizePixel = 0
Instance.new("UICorner", DropFrame).CornerRadius = UDim.new(0,8)

local Scroll = Instance.new("ScrollingFrame", DropFrame)
Scroll.Size = UDim2.new(1,0,1,0)
Scroll.CanvasSize = UDim2.new(0,0,0,0)
Scroll.ScrollBarThickness = 4
Scroll.BackgroundTransparency = 1

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0,4)

-- ================= FUNCTIONS =================

local function RefreshDropdown()
    for _,v in pairs(Scroll:GetChildren()) do
        if v:IsA("TextButton") then
            v:Destroy()
        end
    end
    
    local Options = {"Self"}
    
    if workspace:FindFirstChild("Galaxies") then
        for _,Galaxy in pairs(workspace.Galaxies:GetChildren()) do
            table.insert(Options, Galaxy.Name)
        end
    end
    
    for _,Name in pairs(Options) do
        local Option = Instance.new("TextButton")
        Option.Size = UDim2.new(1,-6,0,25)
        Option.BackgroundColor3 = Color3.fromRGB(45,45,55)
        Option.Text = Name
        Option.Font = Enum.Font.Gotham
        Option.TextSize = 12
        Option.TextColor3 = Color3.fromRGB(220,220,220)
        Option.BorderSizePixel = 0
        Instance.new("UICorner", Option).CornerRadius = UDim.new(0,6)
        
        Option.Parent = Scroll
        
        Option.MouseButton1Click:Connect(function()
            Flags.Farm = Name
            Dropdown.Text = Name
            DropFrame.Visible = false
        end)
    end
    
    task.wait()
    Scroll.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 4)
end

RefreshDropdown()

-- ================= UI LOGIC =================

Toggle.MouseButton1Click:Connect(function()
    Running = not Running
    
    if Running then
        Toggle.Text = "Stop"
        Toggle.BackgroundColor3 = Color3.fromRGB(70,130,255)
        
        CastOnly() -- mulai sekali
    else
        Toggle.Text = "Start"
        Toggle.BackgroundColor3 = Color3.fromRGB(40,40,48)
    end
end)

Dropdown.MouseButton1Click:Connect(function()
    DropFrame.Visible = not DropFrame.Visible
end)
