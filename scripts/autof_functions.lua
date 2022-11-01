local fns = {}

function fns.IsTargetValid(target)
	return target ~= nil and target:IsValid() and target.replica.health ~= nil and not target.replica.health:IsDead()
end

function fns.SendRPC(...)
	if ThePlayer.__k ~= nil then
		TheNet:SendRPCToServer(...)
	else
		SendRPCToServer(...)
	end
end

function fns.print(...)
	print("[Autof]:", ...)
end

function fns.IsInGame()
	return ThePlayer ~= nil
end

local function fns.GetScreenName()
    local screen = GLOBAL.TheFrontEnd:GetActiveScreen()
    local screenName = screen and screen.name or ''
    return screenName
end

local function fns.IsHUDScreen()
    local screenName = fns.GetScreenName()
    return screenName:find('HUD') ~= nil
end

local function fns.IsLobbyScreen()
    local screenName = fns.GetScreenName()
    return screenName:find('LobbyScreen') ~= nil
end

return fns
