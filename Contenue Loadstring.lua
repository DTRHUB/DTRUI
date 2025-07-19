local DTR = {}


local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer


local Gui, drag
local frames = {}
local tabs = {}
local encadres = {}
local currentKeybind = Enum.KeyCode.RightShift
local watermarkFrame = nil
local watermarkActive = false
local guiOpen = true


function DTR.Load()

    Gui = Instance.new("ScreenGui")
    Gui.Name = "DTR_GUI"
    Gui.ResetOnSpawn = false
    Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Gui.Parent = CoreGui


    drag = Instance.new("Frame", Gui)
    drag.Size = UDim2.new(0, 1040, 0, 600)
    drag.Position = UDim2.new(0.25, 0, 0.2, 0)
    drag.BackgroundTransparency = 1
    drag.Active = true
    drag.Draggable = true
    Instance.new("UICorner", drag).CornerRadius = UDim.new(0, 8)


    local left = Instance.new("Frame", drag)
    left.Size = UDim2.new(0, 235, 0, 535)
    left.Position = UDim2.new(0, 0, 0, 50)
    left.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    left.BackgroundTransparency = 0.3
    Instance.new("UICorner", left).CornerRadius = UDim.new(0, 6)


    local sidebarTitle = Instance.new("TextLabel", left)
    sidebarTitle.Text = "3008 - DTR"
    sidebarTitle.Font = Enum.Font.SourceSansBold
    sidebarTitle.TextSize = 53
    sidebarTitle.TextColor3 = Color3.new(1, 1, 1)
    sidebarTitle.BackgroundTransparency = 1
    sidebarTitle.Size = UDim2.new(1, -20, 0, 40)
    sidebarTitle.Position = UDim2.new(0, 10, 0, 15)
    sidebarTitle.TextXAlignment = Enum.TextXAlignment.Center

   
    local icon = Instance.new("ImageLabel", left)
    icon.Size = UDim2.new(0, 64, 0, 64)
    icon.Position = UDim2.new(0, 10, 1, -74)
    icon.BackgroundTransparency = 1
    icon.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)

  
    local nameLabel = Instance.new("TextLabel", left)
    nameLabel.Size = UDim2.new(0, 140, 0, 32)
    nameLabel.Position = UDim2.new(0, 82, 1, -58)
    nameLabel.Text = LocalPlayer.DisplayName
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextSize = 18
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left


    for i, name in ipairs({ "Players", "Visuals", "Misc", "Settings" }) do
        local btn = Instance.new("TextButton", left)
        btn.Name = name .. "Button"
        btn.Text = name
        btn.Size = UDim2.new(0, 200, 0, 50)
        btn.Position = UDim2.new(0.05, 0, 0.2 + (i - 1) * 0.14, 0)
        btn.Font = Enum.Font.SourceSansBold
        btn.TextScaled = true
        btn.BackgroundTransparency = 1
        btn.TextColor3 = Color3.new(1, 1, 1)
        tabs[name] = btn

        local frame = Instance.new("Frame", drag)
        frame.Name = name .. "Frame"
        frame.Position = UDim2.new(0, 240, 0, 50)
        frame.Size = UDim2.new(0, 785, 0, 535)
        frame.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
        frame.Visible = name == "Players"
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
        frames[name] = frame
        encadres[name] = {}

       
        local bar = Instance.new("Frame", frame)
        bar.Size = UDim2.new(1, 0, 0, 50)
        bar.Position = UDim2.new(0, 0, 0, 0)
        bar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 8)

        local sectionTitle = Instance.new("TextLabel", bar)
        sectionTitle.Text = name .. " Section"
        sectionTitle.Font = Enum.Font.SourceSansBold
        sectionTitle.TextSize = 24
        sectionTitle.TextColor3 = Color3.new(1, 1, 1)
        sectionTitle.BackgroundTransparency = 1
        sectionTitle.Size = UDim2.new(1, 0, 1, 0)
        sectionTitle.TextXAlignment = Enum.TextXAlignment.Center

      
        for j = 0, 1 do
            local box = Instance.new("Frame", frame)
            box.Size = UDim2.new(0.44, 0, 0, 300)
            box.Position = UDim2.new(0.05 + j * 0.51, 0, 0.15, 0)
            box.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)
            table.insert(encadres[name], box)
        end
    end

    
    local function switchTab(tabName)
        for name, frame in pairs(frames) do
            frame.Visible = name == tabName
            tabs[name].BackgroundColor3 = name == tabName and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(0, 0, 0, 0)
        end
    end

    for name, btn in pairs(tabs) do
        btn.MouseButton1Click:Connect(function()
            switchTab(name)
        end)
    end

    switchTab("Players")

 
    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == currentKeybind then
            guiOpen = not guiOpen
            Gui.Enabled = guiOpen
        end
    end)

    
    local boxLeft = encadres["Settings"][1]

    DTR.CreateToggle(boxLeft, "Watermark", function(state)
        DTR.CreateWatermark()
        watermarkFrame.Visible = state
    end)

    DTR.CreateKeybindBox(boxLeft, "Toggle GUI Key", currentKeybind, function(newKey)
        currentKeybind = newKey
    end)
end


function DTR.CreateToggle(parent, labelText, callback)
    if not parent then
        warn("⚠️ CreateToggle a reçu un parent nul.")
        return
    end

    local positionY = #parent:GetChildren() * 0.07
    --place du code
end


    local toggleLabel = Instance.new("TextLabel", parent)
    toggleLabel.Text = labelText
    toggleLabel.Font = Enum.Font.SourceSansBold
    toggleLabel.TextSize = 20
    toggleLabel.TextColor3 = Color3.new(1, 1, 1)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Position = UDim2.new(0.05, 0, positionY, 0)
    toggleLabel.Size = UDim2.new(0.6, 0, 0, 30)

    local toggle = Instance.new("Frame", parent)
    toggle.Size = UDim2.new(0, 86, 0, 33)
    toggle.Position = UDim2.new(0.7, 0, positionY, 0)
    toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)

    local toggleColor = Instance.new("Frame", toggle)
    toggleColor.Size = UDim2.new(1, 0, 1, 0)
    toggleColor.BackgroundColor3 = Color3.fromRGB(22, 31, 34)
    Instance.new("UICorner", toggleColor).CornerRadius = UDim.new(1, 0)

    local toggleCircle = Instance.new("ImageButton", toggle)
    toggleCircle.Size = UDim2.new(0, 23, 0, 23)
    toggleCircle.Position = UDim2.new(0, 6, 0.5, -11)
    toggleCircle.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", toggleCircle).CornerRadius = UDim.new(1, 0)

    local toggled = false
    toggleCircle.MouseButton1Click:Connect(function()
        toggled = not toggled
        toggleColor.BackgroundColor3 = toggled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(22, 31, 34)
        local goal = { Position = toggled and UDim2.new(1, -29, 0.5, -11) or UDim2.new(0, 6, 0.5, -11) }
        TweenService:Create(toggleCircle, TweenInfo.new(0.15, Enum.EasingStyle.Quad), goal):Play()
        if callback then callback(toggled) end
    end)
end



function DTR.CreateSlider(parent, labelText, minValue, maxValue, defaultValue, callback)
    local positionY = #parent:GetChildren() * 0.07

    local label = Instance.new("TextLabel", parent)
    label.Text = labelText .. ": " .. defaultValue
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 18
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0.9, 0, 0, 30)
    label.Position = UDim2.new(0.05, 0, positionY, 0)

    local slider = Instance.new("TextBox", parent)
    slider.Size = UDim2.new(0.9, 0, 0, 30)
    slider.Position = UDim2.new(0.05, 0, positionY + 0.09, 0)
    slider.BackgroundColor3 = Color3.fromRGB(22, 31, 34)
    slider.TextColor3 = Color3.new(1, 1, 1)
    slider.Font = Enum.Font.SourceSansBold
    slider.TextSize = 18
    slider.Text = tostring(defaultValue)
    slider.ClearTextOnFocus = false

    slider.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local val = tonumber(slider.Text)
            if val and val >= minValue and val <= maxValue then
                label.Text = labelText .. ": " .. val
                if callback then callback(val) end
            else
                slider.Text = tostring(defaultValue)
            end
        end
    end)
end



function DTR.CreateTextbox(parent, labelText, placeholder, callback)
    local positionY = #parent:GetChildren() * 0.07

    local label = Instance.new("TextLabel", parent)
    label.Text = labelText
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 18
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0.9, 0, 0, 30)
    label.Position = UDim2.new(0.05, 0, positionY, 0)

    local box = Instance.new("TextBox", parent)
    box.Size = UDim2.new(0.9, 0, 0, 30)
    box.Position = UDim2.new(0.05, 0, positionY + 0.09, 0)
    box.BackgroundColor3 = Color3.fromRGB(22, 31, 34)
    box.TextColor3 = Color3.new(1, 1, 1)
    box.Font = Enum.Font.SourceSansBold
    box.TextSize = 18
    box.Text = placeholder or ""
    box.ClearTextOnFocus = false

    box.FocusLost:Connect(function(enterPressed)
        if enterPressed and callback then
            callback(box.Text)
        end
    end)
end



function DTR.CreateKeybindBox(parent, labelText, defaultKey, onChange)
    local positionY = #parent:GetChildren() * 0.07

    local label = Instance.new("TextLabel", parent)
    label.Text = labelText .. ": " .. defaultKey.Name
    label.Size = UDim2.new(0.9, 0, 0, 30)
    label.Position = UDim2.new(0.05, 0, positionY, 0)
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 18

    local input = Instance.new("TextBox", parent)
    input.Size = UDim2.new(0.9, 0, 0, 30)
    input.Position = UDim2.new(0.05, 0, positionY + 0.09, 0)
    input.BackgroundColor3 = Color3.fromRGB(22, 31, 34)
    input.TextColor3 = Color3.new(1, 1, 1)
    input.Font = Enum.Font.SourceSansBold
    input.TextSize = 18
    input.Text = "Press a Key"
    input.ClearTextOnFocus = true

    input.Focused:Connect(function()
        input.Text = "Waiting..."
    end)

    UIS.InputBegan:Connect(function(inputKey)
        if input:IsFocused() and inputKey.KeyCode ~= Enum.KeyCode.Unknown then
            label.Text = labelText .. ": " .. inputKey.KeyCode.Name
            input.Text = "Bind: " .. inputKey.KeyCode.Name
            input:ReleaseFocus()
            if onChange then onChange(inputKey.KeyCode) end
        end
    end)
end



function DTR.CreateColorPicker(parent, labelText, defaultColor, callback)
    local positionY = #parent:GetChildren() * 0.07
    defaultColor = defaultColor or Color3.fromRGB(0, 170, 255)

    local button = Instance.new("TextButton", parent)
    button.Size = UDim2.new(0.9, 0, 0, 35)
    button.Position = UDim2.new(0.05, 0, positionY, 0)
    button.BackgroundColor3 = defaultColor
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 18
    button.Text = labelText .. " (Click)"

    button.MouseButton1Click:Connect(function()
        if callback then callback(defaultColor) end
    end)
end



function DTR.CreateWatermark()
    if watermarkFrame then return end 

    watermarkFrame = Instance.new("Frame")
    watermarkFrame.Name = "DTR_Watermark"
    watermarkFrame.Size = UDim2.new(0, 420, 0, 35)
    watermarkFrame.Position = UDim2.new(0, 10, 0.4, 0)
    watermarkFrame.BackgroundColor3 = Color3.fromRGB(22, 31, 34)
    watermarkFrame.Visible = false
    watermarkFrame.Parent = CoreGui
    Instance.new("UICorner", watermarkFrame).CornerRadius = UDim.new(0, 6)

    local watermarkText = Instance.new("TextLabel", watermarkFrame)
    watermarkText.Size = UDim2.new(1, 0, 1, 0)
    watermarkText.BackgroundTransparency = 1
    watermarkText.TextColor3 = Color3.new(1, 1, 1)
    watermarkText.Font = Enum.Font.SourceSansBold
    watermarkText.TextSize = 18
    watermarkText.TextXAlignment = Enum.TextXAlignment.Center
    watermarkText.Text = "3008 - DTR SCRIPT BY LEVEN | FPS: ??"

    local fps = 0
    RunService.RenderStepped:Connect(function()
        fps += 1
    end)

    task.spawn(function()
        while true do
            if watermarkFrame.Visible then
                watermarkText.Text = "3008 - DTR SCRIPT BY LEVEN | FPS: " .. tostring(fps)
            end
            fps = 0
            wait(1)
        end
    end)
end




if encadres["Settings"] and encadres["Settings"][1] then
    local boxLeft = encadres["Settings"][1]
 
else
    warn(" encadres['Settings'] introuvable. As-tu bien appelé DTR.Load() ?")
end


DTR.CreateToggle(boxLeft, "Watermark", function(state)
    DTR.CreateWatermark()
    watermarkFrame.Visible = state
end)

DTR.CreateKeybindBox(boxLeft, "Toggle GUI Key", currentKeybind, function(newKey)
    currentKeybind = newKey
end)


return DTR