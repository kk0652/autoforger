local Brain = {}

local sensors = require'autof_sensors'

function Brain:Initialize(plr)
	if plr.brainTask == nil then
		plr.brainTask = plr:DoPeriodicTask(FRAMES * 10, function()
			Brain.mobs = sensors.GetMobsDataTable()
			Brain.team = sensors.GetTeamDataTable()
			Brain.items = sensors.GetItemsDataTable()
		end)
	end
	Brain.actionlist = {
		'walk',
		'attack',
		'pickup',
		'drop',
		'castaoe',
		'revive',
		'idle',

	}
	Brain.binaryActionIndices = fns.GenerateBinaryIndexingTableForOptions(Brain.actionlist)
	-- for encoding mobs (prebfabs) in binary
	Brain.moblist = {
		'pig',
		'croc',
		'turtle',
		'scorp',
		'makaka',
		'borov',
		'rhino',
		'swine',
	}
	Brain.binaryMobIndices = fns.GenerateBinaryIndexingTableForOptions(Brain.moblist)
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

function Brain:GetNormalizedMobs()
	local normalized = {}
	for i = 1, MOB_MEMORY_SIZE do

		if Brain.mobs[i] then

function Brain:NormalizeAction(params)
	local normalized = {}
	
    
end

function Brain:NextTask()

end

function Brain:ActionReport(params) -- functions from different module(s) will intercept rpcs and actionbuttons usages and report them to brain, so it would know what exactly you did
	Brain.manual_action = params.action

end
