-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")

-- Variables & Functions
local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage.Remotes
local Channel = TextChatService:FindFirstChild("RBXGeneral", true)

local Thread = {
    Cache = {},
    Connections = {},
}
 
function Thread:New(Name, Callback)
    Thread.Cache[Name] = true
    
    task.spawn(function()
        while Thread.Cache[Name] do
            Callback()
        end
    end)
end
 
function Thread:Disconnect(Name)
    if Thread.Cache[Name] then
        Thread.Cache[Name] = nil
    end
end

function Thread:Maid(Name, Connection)
    if not Connection then return end
    Thread.Connections[Name] = Connection

	return Connection
end
 
function Thread:Unmaid(Name)
    local Found = Thread.Connections[Name]
    if not Found then return end
 
    Found:Disconnect()
    Thread.Connections[Name] = nil
end

-- Ui
local function Notify(Text)
	StarterGui:SetCore("SendNotification", {
		Title = "RQCCC HUB",
		Text = Text,
		Duration = 10,
		Button1 = "OK"
	})
end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ReliefScript/Basic-Library/refs/heads/main/main.lua"))()

local Root = Library:Init("RQCCC HUB")
local GameTab = Root:Tab("Game")
local AutoFarmTab = Root:Tab("AutoFarm")
local PlayerTab = Root:Tab("Player")

local Notes = {"A", "A#", "B", "C", "C#", "D", "D#", "E", "F"}
GameTab:Toggle("Crash", function(Toggled)
	if Toggled then
		Thread:New("Crash", function()
			task.wait()

			local Backpack = LocalPlayer.Backpack
			if not Backpack then return end

			local Char = LocalPlayer.Character
			if not Char then return end

			local Guitar = Backpack:FindFirstChild("Guitar") or Char:FindFirstChild("Guitar")
			if not Guitar then return end

			Guitar.Parent = Char
			for i = 1, 10 do
				for _, Note in Notes do
					Remotes.PlayGuitarNote:FireServer(Note)
				end
			end
		end)
	else
		Thread:Disconnect("Crash")

		local Backpack = LocalPlayer.Backpack
		if not Backpack then return end

		local Char = LocalPlayer.Character
		if not Char then return end

		local Guitar = Backpack:FindFirstChild("Guitar") or Char:FindFirstChild("Guitar")
		if not Guitar then return end

		Guitar.Parent = Backpack
	end
end)

GameTab:Toggle("GodMode", function(Toggled)
	local Pad = workspace.Parts.Decoration["Healing Pond"].Pad
	if not Pad then return end

	if Toggled then
		Pad.Transparency = 1
		Thread:New("GodMode", function()
			task.wait()

			local Char = LocalPlayer.Character
			if not Char then return end

			local Root = Char:FindFirstChild("HumanoidRootPart")
			if not Root then return end

			local Old = Pad.CFrame
			Pad.CFrame = Root.CFrame
			task.wait()
			Pad.CFrame = Old
		end)
	else
		Pad.Transparency = 0.3
		Thread:Disconnect("GodMode")
	end
end)

GameTab:Toggle("AutoAttack", function(Toggled)
	if Toggled then
		Thread:New("AutoAttack", function()
			task.wait()

			local Char = LocalPlayer.Character
			if not Char then return end

			local Root = Char:FindFirstChild("HumanoidRootPart")
			if not Root then return end

			Remotes.UseItem:FireServer(Root.Position + Vector3.new(0, 100, 0))
		end)
	else
		Thread:Disconnect("AutoAttack")
	end
end)

PlayerTab:Toggle("Noclip", function(Toggled)
	if Toggled then
		Thread:New("Noclip", function()
			RunService.Stepped:Wait()

			local Char = LocalPlayer.Character
			if not Char then return end

			for _, BP in Char:GetChildren() do
				if BP:IsA("BasePart") then
					BP.CanCollide = false
				end
			end
		end)
	else
		Thread:Disconnect("Noclip")
	end
end)

local Speed = nil
PlayerTab:Slider("Speed", 1, 200, 16, function(Num)
	Speed = Num
end)

local JP = nil
PlayerTab:Slider("Jump Power", 1, 500, 50, function(Num)
	JP = Num
end)

local Reach = nil
GameTab:Slider("Reach", 1, 2048, 1, function(Num)
	Reach = Num
end)

Thread:New("Loops", function()
	task.wait()

	local Char = LocalPlayer.Character
	if not Char then return end

	local Hum = Char:FindFirstChildOfClass("Humanoid")
	if not Hum then return end

	if Speed then
		Hum.WalkSpeed = Speed
	end

	if JP then
		Hum.JumpPower = JP
	end

	if not Reach then return end

	local Tool = Char:FindFirstChildOfClass("Tool")
	if not Tool then return end

	local Handle = Tool:FindFirstChild("Handle")
	if not Handle then return end

	Handle.Size = Vector3.new(Reach, Reach, Reach)
end)

local EnemyFolder = workspace.Enemies
local function GetEnemies(WeaponDamage)
	local Enemies = {}
	for _, Enemy in EnemyFolder:GetChildren() do
		if #Enemies >= 300 then break end

		local Hum = Enemy:FindFirstChildOfClass("Humanoid")
		if not Hum then continue end

		if Hum.MaxHealth > (WeaponDamage * 3000) then continue end
		if Hum.MaxHealth < (WeaponDamage / 300) then continue end
		if Hum.Health <= 0 then Enemy:Destroy() continue end
		
		local Root = Enemy:FindFirstChild("HumanoidRootPart")
		if not Root then continue end
		
		Root:ClearAllChildren()
		table.insert(Enemies, Root)
	end
	return Enemies
end

AutoFarmTab:Toggle("AutoFarm", function(Toggled)
	if Toggled then
		Thread:New("AutoFarm", function()
			task.wait()

			local Char = LocalPlayer.Character
			if not Char then return end

			local Tool = Char:FindFirstChildOfClass("Tool")
			if not Tool then return end

			local MaxDmg = Tool:FindFirstChild("MaxDmg")
			if not MaxDmg then return end

			local Handle = Tool:FindFirstChild("Handle")
			if not Handle then return end

			for _, Root in GetEnemies(MaxDmg.Value) do
				Root.CanCollide = false
				Root.CFrame = Handle.CFrame
			end

			Remotes.UseItem:FireServer(Handle.Position)
		end)
	else
		Thread:Disconnect("AutoFarm")
	end
end)

local Handler = LocalPlayer.PlayerScripts.ClientEventHandler
AutoFarmTab:Toggle("AntiLag", function(Toggled)
	if Toggled then
		Handler.Enabled = false
	else
		Handler.Enabled = true
	end
end)

local Platform
local Old
AutoFarmTab:Toggle("Hidden", function(Toggled)
	if Toggled then
		local Char = LocalPlayer.Character
		Old = Char:GetPivot()
		Platform = Instance.new("Part")
		Platform.Anchored = true
		Platform.Parent = workspace
		Platform.Size = Vector3.new(10, 1, 10)
		Platform.Position = Vector3.new(0, 9e5, 0)
		Char:PivotTo(Platform.CFrame * CFrame.new(0, 10, 0))
	else
		local Char = LocalPlayer.Character
		Platform:Destroy()
		Char:PivotTo(Old)
		Old = nil
	end
end)

AutoFarmTab:Toggle("AutoBestWeapon", function(Toggled)
	if Toggled then
		local Char = LocalPlayer.Character
		local Backpack = LocalPlayer.Backpack

		local Best = {0, nil}
		Char.Humanoid:UnequipTools()

		for _, Tool in Backpack:GetChildren() do
			if Tool:IsA("Tool") then
				local Dmg = Tool:FindFirstChild("MaxDmg") and Tool.MaxDmg.Value
				if Dmg and Dmg > Best[1] then
					Best = {Dmg, Tool}
				end
			end
		end

		Best[2].Parent = Char

		Thread:Maid("Backpack", Backpack.ChildAdded:Connect(function(Tool)
			local Dmg = Tool:WaitForChild("MaxDmg", 0.5)
			if Dmg then
				Dmg = Dmg.Value
				if Dmg > Best[1] then
					Best = {Dmg, Tool}
					LocalPlayer.Character.Humanoid:UnequipTools()
					Best[2].Parent = LocalPlayer.Character
				end
			end
		end))
	else
		Thread:Unmaid("Backpack")
	end
end)

local Security = {"Update Testers", "Project Super Tester", "Administrators", "Contributors", "Secret Agents", "Developers", "Holder"}
local function CheckPlayer(Player)
	if not Player:IsInGroup(7843339) then return end

	local Rank = Player:GetRoleInGroup(7843339)
	if not table.find(Security, Rank) then return end
	
	Notify(`{Player.Name}: {Rank}`)
end

GameTab:Toggle("ModDetect", function(Toggled)
	if Toggled then
		for _, Player in Players:GetPlayers() do
			CheckPlayer(Player)
		end
		Thread:Maid("OnJoin", Players.PlayerAdded:Connect(CheckPlayer))
	else
		Thread:Unmaid("OnJoin")
	end
end)
