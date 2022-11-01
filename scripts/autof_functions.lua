local fns = {}

local delaysTable = { -- should it be here? Though it needs some sorting if so
    Dart        = 170,
    Staff       = 135,
    Book        = 335,
    Hammer      = 270,
    Spear       = 270,
    SpiralSpear = 270,
    Gauntlet    = 170,
    Pocketwatch = 335,
    Lucy        = 335,
    Sword       = 270,
    Spatula     = 270,
    SoulStaff   = 270,
    Bomb        = 270,
}

local function GetWeapon(weapon)
    -- later, just don't touch it
end

local function GetScreenName() -- does it need to be part of fns?
    local screen = GLOBAL.TheFrontEnd:GetActiveScreen()
    local screenName = screen and screen.name or ''
    return screenName
end

function fns.GetDefaultDelay(weapon)
    return delaysTable(GetWeapon(weapon))
end

function fns.IsTargetValid(target)
    return target ~= nil and target:IsValid()
end

function fns.IsTargetAlive(target)
    return target ~= nil and target.replica.health ~= nil and not target.replica.health:IsDead()
end 

function fns.SendRPC(...)
    if ThePlayer.__k ~= nil then
	TheNet:SendRPCToServer(...)
    else
	SendRPCToServer(...) -- do we really need? I think it should be deprecated
    end
end

function fns.print(...)
    print("[Autof]:", ...)
end

function fns.IsInGame()
    return ThePlayer ~= nil
end

function fns.GetRFSettings()
    if not IsInGame() then return end
    return REFORGED_SETTINGS ~= nil and REFORGED_SETTINGS.gameplay
end

function fns.IsHUDScreen()
    local screenName = GetScreenName()
    return screenName:find('HUD') ~= nil
end

function fns.IsLobbyScreen()
    local screenName = GetScreenName()
    return screenName:find('LobbyScreen') ~= nil
end

return fns
