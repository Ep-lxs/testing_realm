
spawn(
    function()
        local j =
            loadstring(game:HttpGet("https://raw.githubusercontent.com/starlolq/lua-scripts/main/devilui", true))()
        local k =
            j:CreateWindow("YT - DEVIL Script", game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
        local l = k:CreateTab("Pick Up")
        getgenv().autopickupitems = false
        l:CreateToggle(
            "Auto PickUp Items",
            function(m)
                getgenv().autopickupitems = m
                if m then
                    spawn(
                        function()
                            while autopickupitems do
                                wait()
                                pcall(
                                    function()
                                        local n = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart
                                        local o = game:GetService("ReplicatedStorage")
                                        for b, c in pairs(game:GetService("Workspace"):GetChildren()) do
                                            if
                                                c:FindFirstChild("Pickup") and c:IsA("BasePart") or
                                                    c:IsA("UnionOpreation")
                                             then
                                                if (n.Position - c.Position).Magnitude < 50 then
                                                    game:GetService("ReplicatedStorage").Events.Pickup:FireServer(c)
                                                end
                                            end
                                        end
                                        for b, c in pairs(game:GetService("Workspace").Items:GetChildren()) do
                                            if
                                                c:FindFirstChild("Pickup") and c:IsA("BasePart") or
                                                    c:IsA("UnionOpreation")
                                             then
                                                if (n.Position - c.Position).Magnitude < 50 then
                                                    game:GetService("ReplicatedStorage").Events.Pickup:FireServer(c)
                                                end
                                            end
                                        end
                                    end
                                )
                            end
                        end
                    )
                end
            end
        )
        getgenv().autopickupEssence = false
        l:CreateToggle(
            "Auto PickUp XP(Essence)",
            function(m)
                getgenv().autopickupEssence = m
                if m then
                    spawn(
                        function()
                            while autopickupEssence do
                                wait()
                                pcall(
                                    function()
                                        local n = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart
                                        local o = game:GetService("ReplicatedStorage")
                                        for b, c in pairs(game:GetService("Workspace"):GetChildren()) do
                                            if c:FindFirstChild("Pickup") then
                                                if c:IsA("BasePart") or c:IsA("UnionOpreation") then
                                                    if c.Name == "Essence" then
                                                        if (n.Position - c.Position).Magnitude < 50 then
                                                            game:GetService("ReplicatedStorage").Events.Pickup:FireServer(
                                                                c
                                                            )
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                        for b, c in pairs(game:GetService("Workspace").Items:GetChildren()) do
                                            if c:FindFirstChild("Pickup") then
                                                if c:IsA("BasePart") or c:IsA("UnionOpreation") then
                                                    if c.Name == "Essence" then
                                                        if (n.Position - c.Position).Magnitude < 50 then
                                                            game:GetService("ReplicatedStorage").Events.Pickup:FireServer(
                                                                c
                                                            )
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                )
                            end
                        end
                    )
                end
            end
        )
        getgenv().autopickupCoin = false
        l:CreateToggle(
            "Auto PickUp Coin",
            function(m)
                getgenv().autopickupCoin = m
                if m then
                    spawn(
                        function()
                            while autopickupCoin do
                                wait()
                                pcall(
                                    function()
                                        local p = game:GetService("Players")
                                        local n = p.LocalPlayer.Character.HumanoidRootPart
                                        local q = game:GetService("Workspace")
                                        local o = game:GetService("ReplicatedStorage")
                                        for b, c in pairs(q:GetChildren()) do
                                            if
                                                c:FindFirstChild("Pickup") and c:IsA("BasePart") or
                                                    c:IsA("UnionOpreation")
                                             then
                                                if c.Name == "Coin" then
                                                    if (n.Position - c.Position).Magnitude < 50 then
                                                        game:GetService("ReplicatedStorage").Events.Pickup:FireServer(c)
                                                    end
                                                end
                                            end
                                        end
                                        for b, c in pairs(game:GetService("Workspace").Items:GetChildren()) do
                                            if
                                                c:FindFirstChild("Pickup") and c:IsA("BasePart") or
                                                    c:IsA("UnionOpreation")
                                             then
                                                if c.Name == "Coin" then
                                                    if (n.Position - c.Position).Magnitude < 50 then
                                                        game:GetService("ReplicatedStorage").Events.Pickup:FireServer(c)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                )
                            end
                        end
                    )
                end
            end
        )
        getgenv().autopickupBloodfruit = false
        l:CreateToggle(
            "Auto PickUp Bloodfruit",
            function(m)
                getgenv().autopickupBloodfruit = m
                if m then
                    spawn(
                        function()
                            while autopickupBloodfruit do
                                wait()
                                pcall(
                                    function()
                                        local n = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart
                                        local o = game:GetService("ReplicatedStorage")
                                        for b, c in pairs(game:GetService("Workspace"):GetChildren())
