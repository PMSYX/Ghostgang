-- =====================================================================
-- 👻 GHOSTGANG PREMIUM UI LIBRARY 👻
-- =====================================================================
local GhostgangLibrary = {}

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- 🎨 Theme สีเริ่มต้น
local theme = {
    MainBG = Color3.fromRGB(32, 32, 32), PanelBG = Color3.fromRGB(43, 43, 43), 
    ElementBG = Color3.fromRGB(55, 55, 55), ElementHover = Color3.fromRGB(65, 65, 65), 
    Accent = Color3.fromRGB(96, 205, 255), TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 180), Border = Color3.fromRGB(60, 60, 60)
}

-- ⚙️ ฟังก์ชันสร้างหน้าต่างหลัก
function GhostgangLibrary:CreateWindow(WindowConfig)
    local WindowName = WindowConfig.Title or "Ghostgang Hub"
    local ConfigFileName = (WindowConfig.ConfigName or "Ghostgang_Save") .. ".json"
    
    -- 🛡️ ระบบซ่อน UI (gethui)
    local targetGui = CoreGui
    if gethui then pcall(function() targetGui = gethui() end) end

    if targetGui:FindFirstChild("Ghostgang_Framework") then 
        targetGui.Ghostgang_Framework:Destroy() 
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Ghostgang_Framework"
    ScreenGui.Parent = targetGui

    local MainFrame = Instance.new("CanvasGroup", ScreenGui)
    MainFrame.Size = UDim2.new(0, 480, 0, 520)
    MainFrame.Position = UDim2.new(0.5, -240, 0.5, -260)
    MainFrame.BackgroundColor3 = theme.MainBG
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", MainFrame).Color = theme.Border

    -- 🏷️ Title Bar
    local TitleBar = Instance.new("Frame", MainFrame)
    TitleBar.Size = UDim2.new(1, 0, 0, 40); TitleBar.BackgroundTransparency = 1
    local TitleText = Instance.new("TextLabel", TitleBar)
    TitleText.Size = UDim2.new(1, -20, 1, 0); TitleText.Position = UDim2.new(0, 15, 0, 0)
    TitleText.Text = WindowName; TitleText.TextColor3 = theme.TextPrimary
    TitleText.BackgroundTransparency = 1; TitleText.Font = Enum.Font.GothamMedium
    TitleText.TextSize = 13; TitleText.TextXAlignment = Enum.TextXAlignment.Left

    -- 📑 พื้นที่สำหรับสร้าง Tab
    local TabBar = Instance.new("Frame", MainFrame)
    TabBar.Size = UDim2.new(1, -30, 0, 30); TabBar.Position = UDim2.new(0, 15, 0, 45)
    TabBar.BackgroundTransparency = 1
    local TabLayout = Instance.new("UIListLayout", TabBar)
    TabLayout.FillDirection = Enum.FillDirection.Horizontal; TabLayout.Padding = UDim.new(0, 8)

    local ContentArea = Instance.new("Frame", MainFrame)
    ContentArea.Size = UDim2.new(1, -30, 1, -95); ContentArea.Position = UDim2.new(0, 15, 0, 85)
    ContentArea.BackgroundTransparency = 1

    -- 📐 ระบบลากหน้าต่าง (Drag)
    local dragInput, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = input.Position; startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragStart = nil end
            end)
        end
    end)
    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragStart then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- 📦 ตารางสำหรับคืนค่าให้ผู้ใช้ (Return Object)
    local WindowObj = {}
    local isFirstTab = true

    -- 🌟 ฟังก์ชันสร้างหน้าต่างย่อย (Tab)
    function WindowObj:CreateTab(TabName)
        local tabBtn = Instance.new("TextButton", TabBar)
        tabBtn.Size = UDim2.new(0, 95, 1, 0)
        tabBtn.BackgroundColor3 = theme.ElementBG
        tabBtn.BackgroundTransparency = isFirstTab and 0 or 1 
        tabBtn.Text = TabName; tabBtn.TextColor3 = isFirstTab and theme.TextPrimary or theme.TextSecondary
        tabBtn.Font = Enum.Font.GothamMedium; tabBtn.TextSize = 12
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)
        
        local page = Instance.new("ScrollingFrame", ContentArea)
        page.Size = UDim2.new(1, 0, 1, 0); page.BackgroundTransparency = 1
        page.ScrollBarThickness = 2; page.ScrollBarImageColor3 = theme.Accent
        page.Visible = isFirstTab; page.BorderSizePixel = 0
        local pageLayout = Instance.new("UIListLayout", page)
        pageLayout.Padding = UDim.new(0, 8)
        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() 
            page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 25) 
        end)

        -- ระบบกดเปลี่ยนหน้า
        tabBtn.MouseButton1Click:Connect(function()
            for _, child in ipairs(TabBar:GetChildren()) do
                if child:IsA("TextButton") then child.BackgroundTransparency = 1; child.TextColor3 = theme.TextSecondary end
            end
            for _, child in ipairs(ContentArea:GetChildren()) do
                if child:IsA("ScrollingFrame") then child.Visible = false end
            end
            tabBtn.BackgroundTransparency = 0; tabBtn.TextColor3 = theme.TextPrimary
            page.Visible = true
        end)
        
        isFirstTab = false

        -- 📦 ตารางสำหรับคืนค่าคำสั่งย่อยใน Tab
        local TabObj = {}

        -- 🔘 ฟังก์ชันสร้างปุ่มใน Tab
        function TabObj:CreateButton(BtnName, callback)
            local wrapper = Instance.new("Frame", page)
            wrapper.Size = UDim2.new(1, -10, 0, 35); wrapper.BackgroundTransparency = 1
            local btn = Instance.new("TextButton", wrapper)
            btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundColor3 = theme.ElementBG
            btn.TextColor3 = theme.TextPrimary; btn.Font = Enum.Font.GothamMedium
            btn.TextSize = 12; btn.Text = BtnName; btn.AutoButtonColor = false
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            Instance.new("UIStroke", btn).Color = theme.Border
            
            btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = theme.ElementHover}):Play() end)
            btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = theme.ElementBG}):Play() end)
            btn.MouseButton1Click:Connect(callback)
        end

        -- 🕹️ ฟังก์ชันสร้างสวิตช์ (Toggle) ใน Tab
        function TabObj:CreateToggle(ToggleName, callback)
            local state = false
            local wrapper = Instance.new("Frame", page)
            wrapper.Size = UDim2.new(1, -10, 0, 35); wrapper.BackgroundTransparency = 1
            local bg = Instance.new("Frame", wrapper)
            bg.Size = UDim2.new(1, 0, 1, 0); bg.BackgroundColor3 = theme.PanelBG
            Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 6)
            Instance.new("UIStroke", bg).Color = theme.Border
            
            local lbl = Instance.new("TextLabel", bg)
            lbl.Size = UDim2.new(0.6, 0, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0)
            lbl.Text = ToggleName; lbl.TextColor3 = theme.TextPrimary
            lbl.BackgroundTransparency = 1; lbl.Font = Enum.Font.Gotham; lbl.TextSize = 12
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            
            local toggleBtn = Instance.new("TextButton", bg)
            toggleBtn.Size = UDim2.new(0, 40, 0, 20); toggleBtn.Position = UDim2.new(1, -50, 0.5, -10)
            toggleBtn.BackgroundColor3 = theme.ElementBG; toggleBtn.Text = ""
            Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)
            local circle = Instance.new("Frame", toggleBtn)
            circle.Size = UDim2.new(0, 14, 0, 14); circle.Position = UDim2.new(0, 3, 0.5, -7)
            circle.BackgroundColor3 = Color3.fromRGB(200,200,200)
            Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

            toggleBtn.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = state and Color3.fromRGB(0,0,0) or Color3.fromRGB(200,200,200)}):Play()
                TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = state and theme.Accent or theme.ElementBG}):Play()
                callback(state)
            end)
        end

        return TabObj
    end

    return WindowObj
end

return GhostgangLibrary
