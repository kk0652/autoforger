local fns = {}

local defaultDelays = { -- should it be here? Though it needs some sorting if so
    Hand        = 295,
    Dart        = 195,
    Staff       = 160,
    Book        = 360,
    Hammer      = 295,
    Spear       = 295,
    SpiralSpear = 295,
    Axe         = 295,
    Bomb        = 295,
    Sword       = 295,
    -- ReForged
    Slingshot   = 395,-- should it be higher? 420??
    SoulStaff   = 295,
    SpiceBomb   = 295,
    Spatula     = 295,
    Gauntlet    = 200,
    Pocketwatch = 360,
    -- Hallowed Forge
    Graveaxe    = 160,
}

local function GetWeapon(weapon)
    if weapon ~= nil then
        if weapon:HasTag('blowdart') then
            return 'Dart'
        elseif weapon.prefab:find('staff') then
            return 'Staff'
        elaeif weapon:HasTag('book') then
            return 'Book'
        elseif weapon.prefab:find('hammer') then
            return 'Hammer'
        elseif weapon.prefab:find('pithpike') then
            return 'Spear'
        elseif weapon.prefab:find('spiralspear') then
            return 'SpiralSpear'
       elseif weapon.prefab:find('lucy') then
           return 'Axe'
       elseif weapon.prefab:find('firebomb') then
           return 'Bomb'
       elseif weapon.prefab:find('blacksmithsedge') then
           return 'Sword'
       -- ReForged
       elseif weapon.prefab:find('slingshot') then
           return 'Slingshot'
       elseif weapon:HasTag('soulstealer') then
           return 'SoulStaff'
        end
       elseif weapon.prefab:find('spice_bomb') then
           return 'SpiceBomb'
       elseif weapon.prefab:find('spatula') then
           return 'Spatula'
       elseif weapon.prefab:find('gauntlet') then
           return 'Gauntlet'
       elseif weapon.prefab:find('pocketwatch') then
           return 'Pocketwatch'
       -- Hallowed Forge
    end
    return 'Hand'
end

local function GetScreenName() -- does it need to be part of fns?
    local screen = GLOBAL.TheFrontEnd:GetActiveScreen()
    local screenName = screen and screen.name or ''
    return screenName
end

function fns.GetDefaultDelay(weapon)
    return defaultDelays(GetWeapon(weapon))
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
