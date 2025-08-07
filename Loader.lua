-- Modern UI Library with Hover Effects, Auto-Open Tab, Fixed Dragging
-- By ChatGPT

local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local DraggingSlider = false

-- Utility: Create instance with props
local function Create(class, props)
    local inst = Instance.new(class)
    for i, v in pairs(props or {}) do
        inst[i] = v
    end
    return inst
end

-- Utility: Hover effect
local function AddHoverEffect(button, normalColor, hoverColor)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), { BackgroundColor3 = hoverColor }):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), { BackgroundColor3 = normalColor }):Play()
    end)
end

function Library:CreateWindow(title)
    local ScreenGui = Create("ScreenGui", { Name = "ModernUILib", ResetOnSpawn = false, Parent = game:GetService("CoreGui") })

    local Main = Create("Frame", {
        Size = UDim2.new(0, 600, 0, 400),
        Position = UDim2.new(0.5, -300, 0.5, -200),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0,
        Parent = ScreenGui
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Main })
    Create("UIStroke", { Color = Color3.fromRGB(60, 60, 60), Thickness = 1, Parent = Main })

    local Title = Create("TextLabel", {
        Text = title or "Modern UI",
        Font = Enum.Font.GothamSemibold,
        TextSize = 20,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = Main
    })

    local TabsFrame = Create("Frame", {
        Size = UDim2.new(0, 150, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        Parent = Main
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = TabsFrame })

    local ContentFrame = Create("Frame", {
        Size = UDim2.new(1, -160, 1, -50),
        Position = UDim2.new(0, 160, 0, 45),
        BackgroundTransparency = 1,
        Parent = Main
    })

    Create("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabsFrame
    })

    -- Smooth Drag (no tweening)
    local dragging, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not DraggingSlider then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = startPos + UDim2.new(0, delta.X, 0, delta.Y)
        end
    end)

    local Tabs = {}

    function Tabs:Tab(name)
        local normalColor = Color3.fromRGB(40, 40, 40)
        local hoverColor = Color3.fromRGB(60, 60, 60)
        local activeColor = Color3.fromRGB(0, 170, 255)

        local TabButton = Create("TextButton", {
            Text = name,
            Font = Enum.Font.GothamSemibold,
            TextSize = 14,
            BackgroundColor3 = normalColor,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Size = UDim2.new(1, -10, 0, 30),
            Parent = TabsFrame,
            AutoButtonColor = false
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = TabButton })
        AddHoverEffect(TabButton, normalColor, hoverColor)

        local TabPage = Create("ScrollingFrame", {
            Visible = false,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 4,
            Parent = ContentFrame
        })
        Create("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = TabPage
        })

        -- On Click
        TabButton.MouseButton1Click:Connect(function()
            for _, child in pairs(ContentFrame:GetChildren()) do
                if child:IsA("ScrollingFrame") then
                    child.Visible = false
                end
            end
            for _, btn in pairs(TabsFrame:GetChildren()) do
                if btn:IsA("TextButton") then
                    TweenService:Create(btn, TweenInfo.new(0.2), { BackgroundColor3 = normalColor }):Play()
                end
            end
            TweenService:Create(TabButton, TweenInfo.new(0.2), { BackgroundColor3 = activeColor }):Play()
            TabPage.Visible = true
        end)

        -- Auto-select first tab
        if #ContentFrame:GetChildren() == 1 then
            TabPage.Visible = true
            TabButton.BackgroundColor3 = activeColor
        end

        local Elements = {}

        function Elements:AddButton(text, callback)
            local Btn = Create("TextButton", {
                Text = text,
                Font = Enum.Font.GothamSemibold,
                TextSize = 14,
                BackgroundColor3 = Color3.fromRGB(50, 50, 50),
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Size = UDim2.new(1, -10, 0, 30),
                Parent = TabPage
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Btn })
            AddHoverEffect(Btn, Color3.fromRGB(50, 50, 50), Color3.fromRGB(70, 70, 70))
            Btn.MouseButton1Click:Connect(function()
                pcall(callback)
            end)
        end

        -- ✅ FIXED CHECKBOX TEXT ALIGNMENT HERE:
        function Elements:AddCheckbox(text, default, callback)
            local Holder = Create("Frame", {
                Size = UDim2.new(1, -10, 0, 30),
                BackgroundTransparency = 1,
                Parent = TabPage
            })

            local Box = Create("Frame", {
                Size = UDim2.new(0, 24, 0, 24),
                BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                Position = UDim2.new(0, 0, 0.5, -12),
                Parent = Holder
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Box })

            local Fill = Create("Frame", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = Color3.fromRGB(0, 170, 255),
                BackgroundTransparency = 1,
                Parent = Box
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Fill })

            local Label = Create("TextButton", {
                Text = text,
                Font = Enum.Font.Gotham,
                TextSize = 14,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 30, 0, 0),
                Size = UDim2.new(1, -35, 1, 0),
                TextYAlignment = Enum.TextYAlignment.Center,
                Parent = Holder
            })

            local Checked = default or false

            local function update()
                TweenService:Create(Fill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundTransparency = Checked and 0 or 1
                }):Play()
            end

            update()

            local function toggle()
                Checked = not Checked
                update()
                if callback then callback(Checked) end
            end

            Box.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    toggle()
                end
            end)
            Label.MouseButton1Click:Connect(toggle)
        end

        function Elements:AddSlider(text, min, max, default, callback)
            local Holder = Create("Frame", {
                Size = UDim2.new(1, -10, 0, 80),
                BackgroundTransparency = 1,
                Parent = TabPage
            })

            local Label = Create("TextLabel", {
                Text = text .. ": " .. tostring(default),
                Font = Enum.Font.Gotham,
                TextSize = 14,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20),
                Parent = Holder
            })

            local SliderBack = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 10),
                Position = UDim2.new(0, 0, 0, 25),
                BackgroundColor3 = Color3.fromRGB(50, 50, 50),
                Parent = Holder
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = SliderBack })

            local Slider = Create("Frame", {
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = Color3.fromRGB(0, 170, 255),
                Parent = SliderBack
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Slider })

            local dragging = false

            SliderBack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    DraggingSlider = true
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                    DraggingSlider = false
                end
            end)

            RunService.RenderStepped:Connect(function()
                if dragging then
                    local mouse = UserInputService:GetMouseLocation().X
                    local pos = SliderBack.AbsolutePosition.X
                    local size = SliderBack.AbsoluteSize.X
                    local percent = math.clamp((mouse - pos) / size, 0, 1)
                    local value = math.floor(min + (max - min) * percent)
                    Slider.Size = UDim2.new(percent, 0, 1, 0)
                    Label.Text = text .. ": " .. tostring(value)
                    if callback then callback(value) end
                end
            end)
        end

        function Elements:AddDropdown(text, list, callback)
            local Dropdown = Create("TextButton", {
                Text = text,
                Font = Enum.Font.Gotham,
                TextSize = 14,
                BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Size = UDim2.new(1, -10, 0, 30),
                Parent = TabPage,
                AutoButtonColor = false
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Dropdown })
            AddHoverEffect(Dropdown, Color3.fromRGB(60, 60, 60), Color3.fromRGB(80, 80, 80))

            local Open = false

            local ListFrame = Create("Frame", {
                Size = UDim2.new(1, -10, 0, 0),
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                ClipsDescendants = true,
                Parent = TabPage
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = ListFrame })

            Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = ListFrame
            })

            Dropdown.MouseButton1Click:Connect(function()
                Open = not Open
                ListFrame.Size = Open and UDim2.new(1, -10, 0, #list * 30) or UDim2.new(1, -10, 0, 0)
            end)

            for _, item in ipairs(list) do
                local Btn = Create("TextButton", {
                    Text = item,
                    Font = Enum.Font.Gotham,
                    TextSize = 14,
                    BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Size = UDim2.new(1, 0, 0, 30),
                    Parent = ListFrame,
                    AutoButtonColor = false
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Btn })
                AddHoverEffect(Btn, Color3.fromRGB(60, 60, 60), Color3.fromRGB(80, 80, 80))
                Btn.MouseButton1Click:Connect(function()
                    Dropdown.Text = item
                    if callback then callback(item) end
                    Open = false
                    ListFrame.Size = UDim2.new(1, -10, 0, 0)
                end)
            end
        end

        function Elements:AddText(text)
            Create("TextLabel", {
                Text = text,
                Font = Enum.Font.Gotham,
                TextSize = 14,
                TextColor3 = Color3.fromRGB(200, 200, 200),
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -10, 0, 25),
                Parent = TabPage
            })
        end

        return Elements
    end

    return Tabs
end

return Library
