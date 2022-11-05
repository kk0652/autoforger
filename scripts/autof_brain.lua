local Brain = {}

local sensors = require'autof_sensors'

local BINARY_NUMERATION = false

function Brain:Initialize(plr)
	fns.print("initializing brain")
	if plr.autof_brainTask == nil then
		plr.autof_brainTask = plr:DoPeriodicTask(FRAMES * 10, function()
			Brain.mobs = sensors.GetMobsDataTable()
			Brain.team = sensors.GetTeamDataTable()
			Brain.items = sensors.GetItemsDataTable()
		end)
	end
	self.actionlist = {
		'walk',
		'attack',
		'pickup',
		'drop',
		'castaoe',
		'revive',
		'idle',

	}
	self.moblist = {
		'pig',
		'croc',
		'tort',
		'scorp',
		'rilla',
		'boarrior',
		'rhino',
		'swine',
		'roach',
		'mummy',
		'battlestandard_heal',
		{'aurastone','battlestandard'},
		--'unknown'
	}
	self.mobsHP = {
		TUNING.FORGE.PITPIG,
		TUNING.FORGE.CROCOMMANDER.HEALTH,
		TUNING.FORGE.SNORTOISE.HEALTH,
		TUNING.FORGE.SCORPEON.HEALTH,
		TUNING.FORGE.BOARILLA.HEALTH,
		TUNING.FORGE.BOARRIOR.HEALTH,
		TUNING.FORGE.RHINOCEBRO.HEALTH,
		TUNING.FORGE.SWINECLOPS.HEALTH,
		340,
		340,
		TUNING.FORGE.BATTLESTANDARD.HEALTH,
		TUNING.FORGE.BATTLESTANDARD.HEALTH
	}
	if BINARY_NUMERATION == true then
		self.binaryActionIndices = fns.GenerateBinaryIndexingTableForOptions(#self.actionlist)
		self.binaryMobIndices = fns.GenerateBinaryIndexingTableForOptions(#self.mobs)
		self.binaryTeamIndices = fns.GenerateBinaryIndexingTableForOptions(16)
	end
	self.playerlist = {
		'spectator',
		'willow',
		'wickerbottom',
		'wes',
		'waxwell',
		'wathgrithr',
		'webber',
		'wendy', -- wendy
		'wormwood',
		'wanda',
		'walter',
		'wurt',
		'wilson',
		'warly',
		'wolfgang',
		'wx78',
		'winona',
		'woodie',
		'wortox', -- wortox ftw
	}
end

local function FromLocalToGlobal(index, case) -- return in-game instance from an index for brain table
	fns.print('From local to global call [', index, case, ']')
	if case == 'player' and Brain.team[index] then
		return Ents[Brain.team[index].guid]
	elseif case == 'mob' and Brain.mobs[index] then
		return Ents[Brain.mobs[index].guid]
	elseif case == 'item' and Brain.items[index] then
		return Ents[Brain.items[index].guid]
	end
end

local function FromGlobalToLocal(guid, case) --  return index from brain table from guid
	fns.print('From global to local call [', guid, "("..(Ents[guid] and Ents[guid].prefab or "unexistent inst")..")", case, ']')
	if case == 'player' then
		for i = 1, #Brain.team do
			if Brain.team[i].guid == guid then
				return i
			end
		end
	elseif case == 'mob' then
		for i = 1, #Brain.mobs do
			if Brain.mobs[i].guid == guid then
				return i
			end
		end
	elseif case == 'item' then
		for i = 1, #Brain.items do
			if Brain.items[i].guid == guid then
				return i
			end
		end
	end
end

local function GetNormalizedPosition(pos)
	return {pos.x / 65, pos.z / 65}
end

local function GetResolvedAndNormalizedAggro(userid)
	for i = 1, #Brain.team do
		if Brain.team[i].userid == userid then
			return BINARY_NUMERATION and Brain.binaryTeamIndices[i] or i / 16
		end
	end
	return BINARY_NUMERATION and Brain.binaryTeamIndices[16] or 1. -- 16 is unknown player / none aggro at all
end

local function GetPrefabsIndex(prefab) -- binary index
	for i = 1, #Brain.moblist do
		if prefab:find(Brain.moblist[i]) then
			return (BINARY_NUMERATION and Brain.binaryMobIndices[i] or false), i
		end
	end
	return (BINARY_NUMERATION and {1,1,1,1} or 16) -- IF #Brain.mobs >= 16 THEN THIS MAY CAUSE ISSUES -- bruh there's so much more that can (and will) cause issues, why care?
end

local blankMobTemplate = {}
for j = 1, (BINARY_NUMERATION and 16 or 10) do
	blankMobTemplate[j] = 0
end

function Brain:GetNormalizedMobData()
	local normalized = {}
	local t, j
	for i = 1, MOB_MEMORY_SIZE do
		if Brain.mobs[i] then
			t, j = GetPrefabsIndex(Brain.mobs[i].prefab)
			normalized[i] = {
				t or j / 16, -- 4 (1)
				GetNormalizedPosition(Brain.mobs[i].rel_pos), -- 2
				(Brain.mobs[i].hit_quantity or 0) / Brain.mobsHP[j], -- 1
				GetResolvedAndNormalizedAggro(Brain.mobs[i].aggro), -- 4 (1)
				(Brain.mobs[i].cc and 1 or 0), -- 1
				(Brain.mobs[i].inheal and 1 or 0), -- 1
				(Brain.mobs[i].guard and 1 or 0), -- 1
				(Brain.mobs[i].debuff and 1 or 0), -- 1
				(Brain.mobs[i].attack_time % 300) / 300, -- 1
			}
		else
			normalized[i] = blankMobTemplate
		end
	end
	return fns.FlattenSecondAndExtendFirst({}, normalized) 
end

function Brain:GetNormalizedTeamData()
	local normalized = {}

	for i = 1, PLAYER_MEMORY_SIZE do
		if Brain.team[i] then

			normalized[i] = {

			}
		end
	end
end

function Brain:NormalizeAction(params)
	local normalized = {}
	
    
end

function Brain:NextTask()

end

function Brain:ActionReport(params) -- functions from different module(s) will intercept rpcs and actionbuttons usages and report them to brain, so it would know what exactly you did
	Brain.manual_action = params.action

end

return Brain