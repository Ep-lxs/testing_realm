local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local connections = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ep-lxs/gay/main/twink.lua"))()
local ArrayField = loadstring(game:HttpGet('https://raw.githubusercontent.com/UI-Interface/ArrayField/main/Source.lua'))()

local playerConns = {}
local connectionsModule = connections.new("connections") -- general connections such as RunService, Players, etc

local data_config = {
	folder = "???",
	file = "ESP9999",
	extension = ".lua",
}

if not config then 
	pcall(function()
		if isfile(data_config.folder..data_config.file..data_config.extension) then
			local data = HttpService:JSONDecode(readfile(data_config.folder..data_config.file..data_config.extension))
			data.ESP.text.offset = nil

			config = data
			ArrayField:Notify({
				Title = "Configuration loaded", 
				Content = "The configuration file for this script has been loaded from a previous session"
			})
		else 
			config = {
				ESP = {
					teamCheck = true, -- Whether to show teammates or not (enabled = show)

					chams = {
						enabled = true,
						style = "Highlight", -- Highlight, BoxHandleAdornment
						
						teamColor = true, -- Whether to use the TeamColor or not
						color = {0, 0, 0}, -- if the TeamColor setting is disabled the color of the chams will be this

						transparency = 0, -- boxhandleadornment

						fillTransparecy = 0, -- highlight
						outlineTransparency = 0, -- highlight
					},

					text = {
						enabled = false,
						font = "Monospace", -- UI, System, Plex, Monospace (some executors may only support 1 font)

						transparency = 0,
						teamColor = false, -- Whether to use the TeamColor or not
						color = {255, 255, 255}, -- if the TeamColor setting is disabled the color of the text will be this

						outline = {
							enabled = true,
							color = {0, 0, 0},
						},
					},
				}
			}
		end
	end)
end

local function convertToColor(value)
	return Color3.fromRGB(table.unpack(value))
end

local function getViewportPosition(model: PVInstance | Vector3)
    local position = typeof(model) == "Instance" and model:GetPivot().Position or model
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
		highlight.FillColor = config.ESP.chams.teamColor and player.TeamColor.Color or convertToColor(config.ESP.chams.color)
		highlight.OutlineColor = config.ESP.chams.teamColor and player.TeamColor.Color or convertToColor(config.ESP.chams.color)
		highlight.DepthMode = "AlwaysOnTop"
		highlight.Enabled = config.ESP.chams.enabled and config.ESP.teamCheck and player.TeamColor.Color == LocalPlayer.TeamColor.Color 
		highlight.Adornee = player.Character
		highlight.Parent = CoreGui

		object.chams = highlight
	elseif config.ESP.chams.style == "BoxHandleAdornment" then
		object.chams = {}

		for _, v in next, player.Character:GetChildren() do
			if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
				local adornment = Instance.new("BoxHandleAdornment")
				adornment.Size = v.Size + Vector3.new(0.01, 0.01, 0.01)
				adornment.Color3 = config.ESP.text.teamColor and player.TeamColor.Color or convertToColor(config.ESP.text.color)
				adornment.Transparency = config.ESP.chams.transparency
				adornment.Visible = config.ESP.chams.enabled and config.ESP.teamCheck and player.TeamColor.Color == LocalPlayer.TeamColor.Color 
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
    textDrawing.Font = Drawing.Fonts[config.ESP.text.font]
	textDrawing.Visible = config.ESP.text.enabled and config.ESP.teamCheck and player.TeamColor.Color == LocalPlayer.TeamColor.Color 
    textDrawing.Text = ""
    textDrawing.Size = 14

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

function esp.Update(category: string, change: string?)
	for player, data in next, esp.list do
		task.spawn(function()
			if category:lower() == "chams" then
				if change:lower() == "enabled" or change:lower() == "teamcheck" then
					if type(data) == "table" then
						for _, adornment in next, data do
							adornment.Visible = config.ESP.chams.enabled and config.ESP.teamCheck and player.TeamColor.Color == LocalPlayer.TeamColor.Color 
						end
					else
						data.chams.Enabled = config.ESP.chams.enabled and config.ESP.teamCheck and player.TeamColor.Color == LocalPlayer.TeamColor.Color 
					end
				elseif change:lower() == "style" then
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
				elseif string.find(change:lower(), "color") then
					
				end
			elseif category:lower() == "text" then
				data.text.Visible = config.ESP.text.enabled
				data.text.Font = Drawing.Fonts[config.ESP.text.font]
				data.text.Outline = config.ESP.text.outline.enabled
				data.text.OutlineColor = convertToColor(config.ESP.text.outline.color)
			end
		end)
	end
end

local function saveConfiguration()
	pcall(function()
		local JSON = HttpService:JSONEncode(config)
		writefile(data_config.folder..data_config.file..data_config.extension, JSON)
	end)
end

local function onCharacterAdded(player: Player, character: Model)
	if not player or not character then
		return
	end

	local humanoid = character:WaitForChild("Humanoid", math.huge)
	humanoid.DisplayDistanceType = if config.ESP.text.enabled then Enum.HumanoidDisplayDistanceType.None else Enum.HumanoidDisplayDistanceType.Viewer

	playerConns[player]:AddConnection("humanoid", humanoid.Died:Once(function()
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
	playerConns[player] = connections.new()

	if player.Character then
		onCharacterAdded(player, player.Character)
	end
	playerConns[player]:AddConnection("character", player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end))
end

local function onPlayerRemoving(player: Player)
	playerConns[player]:Destroy()

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

				local position2D, isVisible = getViewportPosition(player.Character.Head.Position + Vector3.new(0, player.Character.Head.Size.Y, 0))

				if isVisible then
					data.text.Visible = true
					data.text.Position = Vector2.new(position2D.X, position2D.Y)
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
	task.spawn(onPlayerAdded, player)
end

local window = ArrayField:CreateWindow({
	Name = "Counter Blox",
	LoadingTitle = "Counter Blox",
	LoadingSubtitle = "by ???",
	ConfigurationSaving = {
		Enabled = false,
		FolderName = nil,
		FileName = ""
	 },
	 Discord = {
		Enabled = false,
		Invite = "",
		RememberJoins = true 
	 },
	 KeySystem = false,
	 KeySettings = {
		Title = "",
		Subtitle = "",
		Note = "",
		FileName = "",
		SaveKey = true, 
		GrabKeyFromSite = false,
		Actions = {
			  [1] = {
				  Text = '',
				  OnPress = function()
				  end,
				  }
			  },
		Key = {""} 
	 }
})

local visuals = window:CreateTab("ESP")

visuals:CreateButton({
	Name = "Destroy",
	Callback = function()
		for _,v in next, playerConns do
			v:Destroy()
		end
		table.clear(playerConns)
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

visuals:CreateDropdown({
	Name = "Font",
	Options = {"UI", "System", "Plex", "Monospace"},
	CurrentOption = config.ESP.text.font,
	MultiSelection = false,
	Flag = "",
	Callback = function(option: string)
		config.ESP.text.font = option
		esp.Update("text", "font")
		saveConfiguration()
	end,
})