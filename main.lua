--[[

TO DO: 
- add UI (make visible/invisible depending on chams type, so if highlight then fill and outline transparency if adornment then transparency)

- See if saving system works as intended

AFTER TO DO:
- boxes and text (drawing.new) EWWW
]]
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local twink = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ep-lxs/gay/main/twink.lua"))()
local ArrayField = loadstring(game:HttpGet('https://raw.githubusercontent.com/UI-Interface/ArrayField/main/Source.lua'))()

local humanoidModule = twink.new("humanoid")
local characterAddedModule = twink.new("character")
local connectionsModule = twink.new("connections") -- general connections such as RunService, userinputservice, etc

local data_config = {
	file = "ESP9999",
	extension = ".lua",
}

if not config then 
	local defaultConfig = {
		ESP = {
			chams = {
				enabled = true,
				style = "Highlight", -- Highlight, BoxHandleAdornment

				transparency = 0, -- boxhandleadornment

				fillTransparecy = 0, -- highlight
				outlineTransparency = 0, -- highlight
			},

			text = {
				enabled = false,
				font = "Monospace", -- UI, System, Plex, Monospace (some executors may only support  1 font)

				offset = 40,
				transparency = 0,
				color = {255, 255, 255},

				outline = {
					enabled = true,
					color = {0, 0, 0},
				},
			},
		}
	}

	pcall(function()
		if isfile(data_config.file..data_config.extension) then
			local data = HttpService:JSONDecode(readfile(data_config.file..data_config.extension))

            --[[for name, tab in next, data do
                for setting, value in next, tab do
                    if typeof(value) == "table" then 
                        data[name][setting] = Color3.fromRGB(table.unpack(value))
                    end
                end
            end]]

			if not data.ESP.text.offset then
				data.ESP.text.offset = 40
			end

			--[[for tabName, tab in next, defaultConfig do
				for sectionName, section in next, tab do
					for setting, value in next, section do
						if not data[tabName][sectionName][setting] then
							data[tabName][sectionName][setting] = value
						end    
					end
				end
			end]]

			config = data
			ArrayField:Notify({
				Title = "Configuration loaded", 
				Content = "The configuration file for this script has been loaded from a previous session"
			})
		else 
			config = defaultConfig
		end
	end)
end

local function convertToColor(value)
	return Color3.fromRGB(table.unpack(value))
end

local function getViewportPosition(model)
    local position = model:GetPivot().Position
    local vector3, visible = workspace.CurrentCamera:WorldToViewportPoint(position)

    return Vector2.new(vector3.X, vector3.Y), visible
end

local esp = {
	list = {},
}
esp.__index = esp

function esp:Create(player: Player)
	if not player.Character then 
		return 
	end
	local object = setmetatable({}, esp)

	if config.ESP.chams.style == "Highlight" then
		local highlight = Instance.new("Highlight")
		highlight.FillTransparency = config.ESP.chams.fillTransparency
		highlight.OutlineTransparency = config.ESP.chams.outlineTransparency
		highlight.FillColor = player.TeamColor.Color
		highlight.OutlineColor = player.TeamColor.Color
		highlight.DepthMode = "AlwaysOnTop"
		highlight.Enabled = config.ESP.chams.enabled
		highlight.Adornee = player.Character
		highlight.Parent = CoreGui

		object.chams = highlight
	elseif config.ESP.chams.style == "BoxHandleAdornment" then
		object.chams = {}

		for _, v in next, player.Character:GetChildren() do
			if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
				local adornment = Instance.new("BoxHandleAdornment")
				adornment.Size = v.Size + Vector3.new(0.01, 0.01, 0.01)
				adornment.Color3 = player.TeamColor.Color
				adornment.Transparency = config.ESP.chams.transparency
				adornment.Visible = config.ESP.chams.enabled
				adornment.Adornee = v
				adornment.Parent = CoreGui

				object.chams[v.Name] = adornment
			end
		end
	end

    local textDrawing = Drawing.new("Text")
    textDrawing.Center = true
    textDrawing.Outline = config.ESP.text.outline.enabled
	textDrawing.OutlineColor = convertToColor(config.ESP.text.outline.color)
    textDrawing.Color = convertToColor(config.ESP.text.color)
    textDrawing.Font = Drawing.Fonts[config.ESP.text.enabled]
    textDrawing.Text = ""
    textDrawing.Size = 15

    object.text = textDrawing
	esp.list[player] = object
end

function esp:Destroy()
	if typeof(self.chams) == "table" then
		for _, v in next, self.chams do
			v:Destroy()
		end
	else
		self.chams:Destroy()
	end
	self.text:Remove()

	self = nil
end

function esp.Update(category: string, change: string)
	for player, data in next, esp.list do
		task.spawn(function()
			if category:lower() == "chams" then
				if change == "enabled" then
					if type(data) == "table" then
						for _, adornment in next, data do
							adornment.Visible = config.ESP.chams.enabled
						end
					else
						data.chams.Enabled = config.ESP.chams.enabled
					end
				elseif change == "style" then
					data:Destroy()
					esp:Create(player)
				elseif string.find(change:lower(), "transparency") then 
					if type(data) == "table" then
						for _, adornment in next, data do
							adornment.transparency = config.ESP.chams.transparency
						end
					else
						data.chams.OutlineTransparency, data.chams.FillTransparency = config.ESP.chams.outlineTransparency, config.ESP.chams.FillTransparency
					end
				end
			end
		end)
	end
end

local function saveConfiguration()
	pcall(function()
        --[[local data = {}

        for name, tab in next, config do
            if not data[name] then
                data[name] = {}
            end
            for setting, value in next, tab do
                data[name][setting] = value
            end
        end]]

		local JSON = HttpService:JSONEncode(config)
		writefile(data_config.file..data_config.extension, JSON)
	end)
end

local function onCharacterAdded(player: Player, character: Model)
	if not player or not character then
		return
	end

	local humanoid = character:WaitForChild("Humanoid", math.huge)
	humanoid.DisplayDistanceType = if config.ESP.text.enabled then Enum.HumanoidDisplayDistanceType.None else Enum.HumanoidDisplayDistanceType.Viewer

	humanoidModule:AddConnection(player.UserId, humanoid.Died:Once(function()
		local data = esp.list[player]
		if data then
			data:Destroy()
		end
	end))

	local data = esp.list[player]
	if data then
		data:Destroy()
	end
	esp:Create(player)
end

local function onPlayerAdded(player: Player)
	if not player or player == LocalPlayer then
		return
	end

	if player.Character then
		onCharacterAdded(player, player.Character)
	end
	characterAddedModule:AddConnection(player.UserId, player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end))
end

local function onPlayerRemoving(player: Player)
	humanoidModule:RemoveConnection(player.UserId)
	characterAddedModule:RemoveConnection(player.UserId)

	local data = esp.list[player]
	if data then
		data:Destroy()
	end
end

connectionsModule:AddConnection("preRender", RunService.PreRender:Connect(function()
	local localPosition = LocalPlayer.Character and LocalPlayer.Character:GetPivot().Position

	for player, data in next, esp.list do
		if player:IsDescendantOf(Players) then
			data.text.Visible = false
			data.text.Color = convertToColor(config.ESP.text.color)

			if player.Character then
				--local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
				--local health = humanoid and humanoid.Health or 0
				local distance = localPosition and (player.Character:GetPivot().Position - localPosition).Magnitude or -1

				local position2D, isVisible = getViewportPosition(player.Character)

				if isVisible then
					data.text.Visible = true
					data.text.Position = Vector2.new(position2D.X, position2D.Y - config.ESP.text.offset)
					data.text.Text = `[{math.floor(distance * 10) / 10}] {player.Name}` --string.format("%s\nHealth: %d, Distance: %0.1f", player.Name, health, distance)
				end
			end
		else
			data:Destroy()
		end
	end
end))

connectionsModule:AddConnection("PlayerAdded", Players.PlayerAdded:Connect(onPlayerAdded))
connectionsModule:AddConnection("PlayerRemoving", Players.PlayerRemoving:Connect(onPlayerRemoving))
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

local window = ArrayField:CreateWindow({
	Name = "Counter Blox",
	LoadingTitle = "Counter Blox",
	LoadingSubtitle = "by ???",
	ConfigurationSaving = {
		Enabled = false,
		FolderName = nil, -- Create a custom folder for your hub/game
		FileName = ""
	 },
	 Discord = {
		Enabled = false,
		Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ABCD would be ABCD
		RememberJoins = true -- Set this to false to make them join the discord every time they load it up
	 },
	 KeySystem = false, -- Set this to true to use our key system
	 KeySettings = {
		Title = "Untitled",
		Subtitle = "Key System",
		Note = "No method of obtaining the key is provided",
		FileName = "Key", -- It is recommended to use something unique as other scripts using ArrayField may overwrite your key file
		SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
		GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like ArrayField to get the key from
		Actions = {
			  [1] = {
				  Text = 'Click here to copy the key link <--',
				  OnPress = function()
					  print('Pressed')
				  end,
				  }
			  },
		Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
	 }
})

local visuals = window:CreateTab("ESP")

visuals:CreateButton({
	Name = "Destroy",
	Callback = function()
		humanoidModule:Destroy()
		characterAddedModule:Destroy()
		connectionsModule:Destroy()

		for _, data in next, esp.list do
			data:Destroy()
		end
		table.clear(esp.list)

		ArrayField:Destroy()
	end,
})

visuals:CreateSection("Chams")

visuals:CreateToggle({
	Name = "Enabled",
	CurrentValue = config.ESP.chams.enabled,
	Flag = "",
	Callback = function(bool: boolean)
		config.ESP.chams.enabled = bool
		esp.Update("chams", "enabled")
		saveConfiguration()
	end,
})

visuals:CreateDropdown({
	Name = "Style",
	Options = {"Highlight", "BoxHandleAdornment"},
	CurrentOption = config.ESP.chams.style,
	MultiSelection = false,
	Flag = "",
	Callback = function(option: string)
		config.ESP.chams.style = option
		esp.Update("chams", "style")
		saveConfiguration()
	end,
 })

visuals:CreateSection("Text")

visuals:CreateToggle({
	Name = "Enabled",
	CurrentValue = config.ESP.text.enabled,
	Flag = "",
	Callback = function(bool: boolean)
		config.ESP.chams.enabled = bool
		esp.Update("text", "enabled")
		saveConfiguration()
	end,
})