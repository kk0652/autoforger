local fns = {}

local defaultDelays = { -- should it be here? Though it needs some sorting if so | why sorting, it's a hash table
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
    Slingshot   = 395,-- should it be higher? 420?? | 999)
    SoulStaff   = 295,
    SpiceBomb   = 295,
    Spatula     = 295,
    Gauntlet    = 200,
    Pocketwatch = 360,
    -- Hallowed Forge
    Graveaxe    = 160,
    HornBundle  = 295,
    FireFlask   = 295,
    EctoSpear   = 295,
    BoneCrusher = 295,
}

local function GetWeapon(weapon)
    if weapon ~= nil then
        if weapon:HasTag('blowdart') then
            return 'Dart'
        elseif weapon.prefab:find('staff') then
            return 'Staff'
        elseif weapon:HasTag('book') then
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
       elseif weapon:HasTag('slingshot') then
           return 'Slingshot'
       elseif weapon:HasTag('soulstealer') then
           return 'SoulStaff'
       elseif weapon.prefab:find('spice_bomb') then
           return 'SpiceBomb'
       elseif weapon.prefab:find('spatula') then
           return 'Spatula'
       elseif weapon.prefab:find('gauntlet') then
           return 'Gauntlet'
       elseif weapon.prefab:find('pocketwatch') then
           return 'Pocketwatch'
       -- Hallowed Forge
        elseif weapon.prefab:find('hf_grave_axe') then
            return 'Graveaxe'
        elseif weapon.prefab:find('hf_horn_bundle') then
            return 'HornBundle'
        elseif weapon.prefab:find('hf_fire_flask') then
            return 'FireFlask'
        elseif weapon.prefsb:find('hf_ectospear') then
            return 'EctoSpear'
        elseif weapon.prefsb:find('hf_bone_mace') then
            return 'BoneCrusher'
        end
        -- correct me if I'm wrong, I'm not sure about HF prefabs | idk any of them and it'll be a big while before i will think about hallowed in the context of this mod, if ever
    end
    return 'Hand'
end

local function GetScreenName() -- does it need to be part of fns? | not sure whether mod's control will become complex enough to use this, but maybe in the future
    local screen = TheFrontEnd:GetActiveScreen()
    local screenName = screen and screen.name or ''
    return screenName
end

function fns.GetDefaultDelays(weapon)
    return defaultDelays(GetWeapon(weapon))
end

function fns.SendRPC(...)
    if not ThePlayer.__k:find('.') then
	   TheNet:SendRPCToServer(...)
    else
	   SendRPCToServer(...)
    end
end

function fns.print(...)
    print("[AutoF]: ", ...)
end

function fns.IsInGame()
    return ThePlayer ~= nil
end

function fns.GetRFData()
    return REFORGED_DATA ~= nil
end

function fns.IsHUDScreen()
    local screenName = GetScreenName()
    return screenName:find('HUD') ~= nil
end

function fns.IsLobbyScreen()
    local screenName = GetScreenName()
    return screenName:find('LobbyScreen') ~= nil
end

function fns.CheckDebugString(inst, str)
    local debugstring = inst and inst.entity:GetDebugString()
    return debugstring and debugstring:find(str)
end


return fns
