local player = game:GetService("Players").LocalPlayer
local coreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- ลบ GUI เดิมถ้ามี
if coreGui:FindFirstChild("RewardViewerGui") then
    coreGui:FindFirstChild("RewardViewerGui"):Destroy()
end

-- สร้าง ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "RewardViewerGui"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.Parent = gethui and gethui() or (syn and syn.protect_gui and syn.protect_gui(gui) or coreGui)

-- พื้นหลังดำเต็มจอ
local blackout = Instance.new("Frame")
blackout.Name = "Blackout"
blackout.BackgroundColor3 = Color3.new(0, 0, 0)
blackout.BackgroundTransparency = 0
blackout.BorderSizePixel = 0
blackout.Size = UDim2.new(1, 0, 1, 0)
blackout.Position = UDim2.new(0, 0, 0, 0)
blackout.ZIndex = 9999
blackout.Active = true
blackout.Selectable = true
blackout.Parent = gui

-- ปุ่ม Toggle ธรรมดา
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 100, 0, 40)
toggleButton.Position = UDim2.new(1, -110, 0, 10)
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleButton.Text = "Toggle"
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 18
toggleButton.ZIndex = 10001
toggleButton.Parent = gui

-- ScrollingFrame สำหรับแสดงรายการ
local scroll = Instance.new("ScrollingFrame")
scroll.Name = "Scroll"
scroll.Size = UDim2.new(0.8, 0, 0.7, 0)
scroll.Position = UDim2.new(0.1, 0, 0.2, 0)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.BackgroundColor3 = Color3.new(0, 0, 0)
scroll.BackgroundTransparency = 0
scroll.BorderSizePixel = 0
scroll.ZIndex = 10000
scroll.ClipsDescendants = true
scroll.Parent = blackout

-- UIListLayout จัดเรียงแนวตั้งแบบตรงกลาง
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = scroll

-- หัวข้อ GUYITEMS
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Text = "GUYITEMS"
title.Font = Enum.Font.GothamBlack
title.TextSize = 36
title.TextColor3 = Color3.fromRGB(255, 0, 0)
title.BackgroundTransparency = 1
title.AnchorPoint = Vector2.new(0.5, 0)
title.Position = UDim2.new(0.5, 0, 0.1, 0)
title.Size = UDim2.new(0.6, 0, 0, 40)
title.TextXAlignment = Enum.TextXAlignment.Center
title.TextYAlignment = Enum.TextYAlignment.Center
title.ZIndex = 10001
title.Parent = blackout

-- STATUS Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Text = ""
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 20
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
statusLabel.BackgroundTransparency = 1
statusLabel.Size = UDim2.new(1, -20, 0, 30)
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.TextYAlignment = Enum.TextYAlignment.Center
statusLabel.ZIndex = 10000
statusLabel.Parent = scroll

-- ฟังก์ชันสำหรับโหลดรายการ
local function updateScrollItems()
    for _, child in pairs(scroll:GetChildren()) do
        if child:IsA("TextLabel") and child ~= statusLabel then
            child:Destroy()
        end
    end

    local sourceFrame = player:FindFirstChild("PlayerGui")
        and player.PlayerGui:FindFirstChild("CountDown")
        and player.PlayerGui.CountDown:FindFirstChild("Frame")
        and player.PlayerGui.CountDown.Frame:FindFirstChild("Recieved")
        and player.PlayerGui.CountDown.Frame.Recieved:FindFirstChild("ScrollingFrame")

    if sourceFrame then
        local items = {}

        for _, item in pairs(sourceFrame:GetChildren()) do
            if item:IsA("Frame") and item.Name ~= "Template" and item:FindFirstChild("RewardName") and item.RewardName:IsA("TextLabel") then
                local text = item.RewardName.Text
                table.insert(items, text)
            end
        end

        table.sort(items)

        for _, text in ipairs(items) do
            local label = Instance.new("TextLabel")
            label.Text = text
            label.Font = Enum.Font.GothamBold
            label.TextSize = 22
            label.TextColor3 = Color3.new(1, 1, 1)
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, -20, 0, 30)
            label.TextXAlignment = Enum.TextXAlignment.Center
            label.TextYAlignment = Enum.TextYAlignment.Center
            label.ZIndex = 10000
            label.Parent = scroll
        end

        local statusText = ""
        pcall(function()
            statusText = player.PlayerGui.CountDown.Frame["Next Reward"].Text
        end)
        statusLabel.Text = "STATUS: " .. statusText
        statusLabel.Parent = scroll

        task.wait()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    else
        local errorLabel = Instance.new("TextLabel")
        errorLabel.Text = "ไม่พบ ScrollingFrame ที่กำหนด"
        errorLabel.Font = Enum.Font.GothamBold
        errorLabel.TextSize = 24
        errorLabel.TextColor3 = Color3.new(1, 0.3, 0.3)
        errorLabel.BackgroundTransparency = 1
        errorLabel.Size = UDim2.new(1, -20, 0, 50)
        errorLabel.Position = UDim2.new(0, 10, 0.1, 0)
        errorLabel.TextXAlignment = Enum.TextXAlignment.Center
        errorLabel.TextYAlignment = Enum.TextYAlignment.Center
        errorLabel.ZIndex = 10000
        errorLabel.Parent = scroll
    end
end

-- ฟังก์ชันสำหรับอัพเดทคำอธิบาย
local RAMAccount, SettingAcc = loadstring(game:HttpGet('https://raw.githubusercontent.com/ic3w0lf22/Roblox-Account-Manager/master/RAMAccount.lua'))()
local MyAccount = RAMAccount.new(player.Name)
local AutoSetDescription = true
local function updateDescription()
    local items = {}
    local sourceFrame = player:FindFirstChild("PlayerGui")
        and player.PlayerGui:FindFirstChild("CountDown")
        and player.PlayerGui.CountDown:FindFirstChild("Frame")
        and player.PlayerGui.CountDown.Frame:FindFirstChild("Recieved")
        and player.PlayerGui.CountDown.Frame.Recieved:FindFirstChild("ScrollingFrame")

    if sourceFrame then
        for _, item in pairs(sourceFrame:GetChildren()) do
            if item:IsA("Frame") and item.Name ~= "Template" and item:FindFirstChild("RewardName") and item.RewardName:IsA("TextLabel") then
                local text = item.RewardName.Text
                local lowerText = string.lower(text)
                if string.find(lowerText, "ziru") then
                    table.insert(items, text)
                end
            end
        end
    end

    local descriptionText = table.concat(items, ", ")
    -- อัพเดท description ตามรายการที่ได้
    if MyAccount then
        local setDescriptionSuccess = MyAccount:SetDescription(descriptionText)
        if setDescriptionSuccess ~= false then
            print("SET")
        else
            messagebox("You Not Open Allow Modify Methods", "Alert", 0)
            AutoSetDescription = false
        end
    else
        messagebox("Can't Connect To RAM", "Alert", 0)
        AutoSetDescription = false
    end
end

spawn(function()
    while true do
        if AutoSetDescription then
            updateDescription()
        else
            print("AutoSetDescription ปิดอยู่ พยายามเปิดใหม่...")
            MyAccount = RAMAccount.new(game:GetService('Players').LocalPlayer.Name)
            AutoSetDescription = true
        end
        wait(10)
    end
end)

-- อัปเดตครั้งแรก
updateScrollItems()

-- เช็คข้อมูลใหม่ทุก 1 วินาที
spawn(function()
    while true do
        updateScrollItems()
        task.wait(1)
    end
end)

-- ตั้งค่า FPS ทันทีเมื่อเริ่มต้น (จำกัด FPS ให้เป็น 5 เมื่อเริ่ม)
setfpscap(5)

-- ตั้งค่า FPS เมื่อเปิดปิด UI
local visible = true
toggleButton.MouseButton1Click:Connect(function()
    visible = not visible
    blackout.Visible = visible

    -- เมื่อเปิด UI
    if visible then
        setfpscap(5)  -- ตั้งค่า FPS เป็น 5 เมื่อเปิด UI
    else
        -- เมื่อปิด UI
        setfpscap(30)  -- ตั้งค่า FPS เป็น 30 เมื่อปิด UI
    end
end)
