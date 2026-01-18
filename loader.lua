local Hub = {
    [428375933] = "TheLegendofTheBoneSwordRPG"
}

local Id = game.PlaceId

local function Notify(Text)
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "RQCCC HUB",
		Text = Text,
		Duration = 10,
		Button1 = "OK"
	})
end

local Found = false
for TargetId, Name in Hub do
    if Id == TargetId then
        Notify("Game loaded. Discord copied to clipboard. Join for more scripts.")
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ReliefScript/RQCCC-HUB/refs/heads/main/games/" .. Name .. ".lua"))()
        Found = true
        break
    end
end

if not Found then
    Notify("Game not found. Discord copied to clipboard. Join for more scripts.")
end

if setclipboard then
	setclipboard("https://discord.com/invite/EbhtGYbuTa")
end

task.spawn(function()
	local Req = syn and syn.request or request or http_request or fluxus and fluxus.request or httprequest
	if Req then
		Req({
			Url = "http://127.0.0.1:6463/rpc?v=1",
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json",
				["Origin"] = "https://discord.com",
			},
			Body = HttpService:JSONEncode({
				cmd = "INVITE_BROWSER",
				args = {
					code = "EbhtGYbuTa"
				},
				nonce = HttpService:GenerateGUID(false)
			}),
		})
	end
end)
