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

local function CreateColorPicker(parent, defaultColor, onColorChanged)
    local PickerFrame = Create("Frame", {
        Size = UDim2.new(1, -10, 0, 75),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        Position = UDim2.new(0, 0, 0, 25),
        Visible = false,
        Parent = parent
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = PickerFrame })

    local r = math.floor(defaultColor.R * 255)
    local g = math.floor(defaultColor.G * 255)
    local b = math.floor(defaultColor.B * 255)

    local function updateColor()
        local newColor = Color3.fromRGB(r, g, b)
        if onColorChanged then onColorChanged(newColor) end
    end

    local function createSlider(label, initial, yOffset, setChannel)
        local dragging = false

        Create("TextLabel", {
            Text = label,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 5, 0, yOffset),
            Size = UDim2.new(0, 20, 0, 20),
            Parent = PickerFrame
        })

        local SliderBack = Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(60, 60, 60),
            Position = UDim2.new(0, 30, 0, yOffset + 5),
            Size = UDim2.new(1, -40, 0, 10),
            Parent = PickerFrame
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = SliderBack })

        local Fill = Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(0, 170, 255),
            Size = UDim2.new(initial / 255, 0, 1, 0),
            Parent = SliderBack
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = Fill })

        local CaptureButton = Create("TextButton", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Text = "",
            AutoButtonColor = false,
            Parent = SliderBack
        })

        CaptureButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        RunService.RenderStepped:Connect(function()
            if dragging then
                local mouseX = UserInputService:GetMouseLocation().X
                local pos = SliderBack.AbsolutePosition.X
                local size = SliderBack.AbsoluteSize.X
                local percent = math.clamp((mouseX - pos) / size, 0, 1)
                local value = math.floor(percent * 255)
                Fill.Size = UDim2.new(percent, 0, 1, 0)
                setChannel(value)
                updateColor()
            end
        end)
    end

    createSlider("R", r, 0, function(v) r = v end)
    createSlider("G", g, 25, function(v) g = v end)
    createSlider("B", b, 50, function(v) b = v end)

    return PickerFrame
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
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Main })
    Create("UIStroke", { Color = Color3.fromRGB(60, 60, 60), Thickness = 1, Parent = Main })

    local Title = Create("TextLabel", {
        Text = title or "Modern UI",
        Font = Enum.Font.GothamSemibold,
        TextSize = 20,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(1.2, 0, 0, 40),
        Parent = Main
    })

    local TabsFrame = Create("Frame", {
        Size = UDim2.new(0, 120, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        Parent = Main
    })

    --lol
    local TabButtonFrame = Create("Frame", {
        Size = UDim2.new(0, 120, 0.83, 0),
        Position = UDim2.new(0, 0, 0.17, 0),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderSizePixel = 0,
        Parent = TabsFrame
    })

    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = TabsFrame })

    local ContentFrame = Create("Frame", {
        Size = UDim2.new(1, -130, 1, -50),
        Position = UDim2.new(0, 130, 0, 45),
        BackgroundTransparency = 1,
        Parent = Main
    })

    Create("UIListLayout", {
        Padding = UDim.new(0, 0),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabButtonFrame --TabsFrame
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
        local normalColor = Color3.fromRGB(25, 25, 25)
        local hoverColor = Color3.fromRGB(60, 60, 60)
        local activeColor = Color3.fromRGB(0, 170, 255)

        local TabButton = Create("TextButton", {
            Text = name,
            Font = Enum.Font.GothamSemibold,
            TextSize = 14,
            BackgroundColor3 = normalColor,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 40),
            Parent = TabButtonFrame, --TabsFrame
            AutoButtonColor = false
        })


        local TabPage = Create("ScrollingFrame", {
            Visible = false,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 0.1, -- Slight transparency for modern look
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            ScrollBarThickness = 2, -- Thinner, sleeker scroll bar
            ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100),
            ScrollBarImageTransparency = 0.2,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Parent = ContentFrame
        })

        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = TabPage
        })

        local layout = Create("UIListLayout", {
            Padding = UDim.new(0, 2),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = TabPage
        })

        Create("UIPadding", {
            PaddingTop = UDim.new(0, 2),
            PaddingLeft = UDim.new(0, 0),
            PaddingRight = UDim.new(0, 0),
            PaddingBottom = UDim.new(0, 2),
            Parent = TabPage
        })

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabPage.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
        end)


        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabPage.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
        end)


        -- On Click
        TabButton.MouseButton1Click:Connect(function()
            -- Step 1: Hide all tab pages
            for _, child in pairs(ContentFrame:GetChildren()) do
                if child:IsA("ScrollingFrame") then
                    child.Visible = false
                end
            end

            -- Step 2: Reset all tab button colors to normal (unselected)
            for _, btn in pairs(TabButtonFrame:GetChildren()) do
                if btn:IsA("TextButton") and btn ~= TabButton then
                    btn.BackgroundColor3 = normalColor
                end
            end

            -- Step 3: Set this tab's color to active (selected)
            TabPage.Visible = true
            if TabPage.Visible == true then
                TabButton.BackgroundColor3 = activeColor
            end
        end)

        TabButton.MouseEnter:Connect(function()
            if TabButton.BackgroundColor3 ~= activeColor then
                TweenService:Create(TabButton, TweenInfo.new(0.1), { BackgroundColor3 = hoverColor }):Play()
            end
        end)
        TabButton.MouseLeave:Connect(function()
            if TabButton.BackgroundColor3 ~= activeColor then
                TweenService:Create(TabButton, TweenInfo.new(0.1), { BackgroundColor3 = normalColor }):Play()
            end
        end)


        -- Auto-select first tab
        if #ContentFrame:GetChildren() == 1 then
            TabPage.Visible = true
            TabButton.BackgroundColor3 = activeColor
        end


        local Elements = {}


        function Elements:AddColorPicker(text, defaultColor, callback)
        local Holder = Create("Frame", {
            Size = UDim2.new(1, -10, 0, 28),
            BackgroundTransparency = 1,
            Parent = TabPage
        })

        local Label = Create("TextLabel", {
            Text = text,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, -50, 0, 22),
            TextYAlignment = Enum.TextYAlignment.Center,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Holder
        })

        local Preview = Create("TextButton", {
            Size = UDim2.new(0, 40, 0, 20),
            Position = UDim2.new(1, -50, 0, 1),
            BackgroundColor3 = defaultColor or Color3.fromRGB(255, 0, 0),
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            Parent = Holder
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Preview })

        local Picker = CreateColorPicker(Holder, Preview.BackgroundColor3, function(newColor)
            Preview.BackgroundColor3 = newColor
            if callback then
                callback(newColor)
            end
        end)

        local open = false
        Preview.MouseButton1Click:Connect(function()
            open = not open
            Picker.Visible = open
            Holder.Size = UDim2.new(1, -10, 0, open and 90 or 28)
        end)
    end








        -->|| Button ||<--
        function Elements:AddButton(text, callback)
            local Btn = Create("TextButton", {
                Text = text,
                Font = Enum.Font.GothamSemibold,
                TextSize = 14,
                BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Size = UDim2.new(1, -10, 0, 30),
                Parent = TabPage,
                AutoButtonColor = false
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Btn })
    
            -- ✅ FIXED: Now hover effect is applied
            AddHoverEffect(Btn, Color3.fromRGB(60, 60, 60), Color3.fromRGB(80, 80, 80))
    
            Btn.MouseButton1Click:Connect(function()
                pcall(callback)
            end)
        end


        -->|| Checkbox ||<--
        function Elements:AddCheckbox(text, default, callback, hasColorPicker, defaultColor, colorCallback)
    local Holder = Create("Frame", {
        Size = UDim2.new(1, -10, 0, hasColorPicker and 28 or 22),
        BackgroundTransparency = 1,
        Parent = TabPage
    })

    local Box = Create("Frame", {
        Size = UDim2.new(0, 20, 0, 20),
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        Position = UDim2.new(0, 0, 0, 1),
        Parent = Holder
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Box })
    AddHoverEffect(Box, Color3.fromRGB(60, 60, 60), Color3.fromRGB(80, 80, 80))

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
        Size = UDim2.new(1, hasColorPicker and -85 or -35, 0, 22),
        TextYAlignment = Enum.TextYAlignment.Center,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
        Parent = Holder
    })

    local Checked = default or false
    local function update()
        TweenService:Create(Fill, TweenInfo.new(0.2), {
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

    if hasColorPicker then
        local ColorPreview = Create("TextButton", {
            Size = UDim2.new(0, 40, 0, 20),
            Position = UDim2.new(1, -50, 0, 1),
            BackgroundColor3 = defaultColor or Color3.fromRGB(255, 0, 0),
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            Parent = Holder
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = ColorPreview })

        local Picker = CreateColorPicker(Holder, ColorPreview.BackgroundColor3, function(newColor)
            ColorPreview.BackgroundColor3 = newColor
            if colorCallback then colorCallback(newColor) end
        end)

        local open = false
        ColorPreview.MouseButton1Click:Connect(function()
            open = not open
            Picker.Visible = open
            Holder.Size = UDim2.new(1, -10, 0, open and 90 or 28)
        end)
    end
end




        -->|| Slider ||<--
        function Elements:AddSlider(text, min, max, default, callback)
            local Holder = Create("Frame", {
                Size = UDim2.new(1, -10, 0.02, 30), -- increased height from 80 to 100
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
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder
            })


            local SliderBack = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 15), -- increased height from 10 to 20
                Position = UDim2.new(0, 0, 0, 20), -- adjusted to appear under the label
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
            -- Dropdown button
            local Dropdown = Create("TextButton", {
                Text = text,
                Font = Enum.Font.Gotham,
                TextSize = 14,
                BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                TextColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                Size = UDim2.new(1, -10, 0, 30),
                Parent = TabPage,
                AutoButtonColor = false
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Dropdown })

            local Open = false

            -- List container
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

            -- Toggle dropdown
            Dropdown.MouseButton1Click:Connect(function()
                Open = not Open
                ListFrame.Size = Open and UDim2.new(1, -10, 0, #list * 30) or UDim2.new(1, -10, 0, 0)

                if Open then
                    Dropdown.BackgroundColor3 = activeColor
                else
                    Dropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                end
            end)

            -- Hover effects
            Dropdown.MouseEnter:Connect(function()
                if Dropdown.BackgroundColor3 ~= activeColor then
                    TweenService:Create(Dropdown, TweenInfo.new(0.1), { BackgroundColor3 = hoverColor }):Play()
                end
            end)
            Dropdown.MouseLeave:Connect(function()
                if Dropdown.BackgroundColor3 ~= activeColor then
                    Dropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                end
            end)

            -- List items
            for _, item in ipairs(list) do
                local Btn = Create("TextButton", {
                    Text = item,
                    Font = Enum.Font.Gotham,
                    TextSize = 14,
                    BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 30),
                    Parent = ListFrame,
                    AutoButtonColor = false
                })
                AddHoverEffect(Btn, Color3.fromRGB(60, 60, 60), hoverColor)
        
                Btn.MouseButton1Click:Connect(function()
                    Dropdown.Text = item
                    if callback then callback(item) end
                    Open = false
                    Dropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    ListFrame.Size = UDim2.new(1, -10, 0, 0)
                end)
            end
        end



        -->|| TextLabel ||<--
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
