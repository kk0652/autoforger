local Brain = {}


local BINARY_NUMERATION = false

function Brain:Initialize(plr)
	fns.print("initializing brain")

	self.owner = plr

	self.actionlist = {
		'idle',
		'walk',
		'attack',
		'pickup',
		'drop',
		'castaoe',
		'revive',

	}
	self.moblist = {
		'pig',
		'croc',
		'snort',
		'scorp',
		'rilla',
		'boarrior',
		'rhino',
		'swine',
		'roach',
		'mummy',
		'battlestandard_heal',
		'battlestandard',
		'aurastone',
		--'unknown'
	}
	self.mobsHP = {
		TUNING.FORGE.PITPIG.HEALTH,
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
	self.handitemlist = {
		'forge_slingshot',
		'forginghammer',
		'forgedarts',
		'petrifyingtome',
		'teleport_staff',
		'riledlucy',
		'lavaarena_seeddarts',
		'pithpike',
		'portalstaff',
		'firebomb',
		'lavaarena_gauntlet',
		'lavaarena_spatula',
		'bacontome',
		'pocketwatch_reforged',
		'forge_trident',
		'moltendarts',
		'spiralspear',
		'lavaarena_seeddart2',
		'blacsmithsedge',
		'infernalstaff',
		'spice_bomb',
		'livingstaff',
		'' -- hallowed
	}
	self.bodyitemlist = {
		'reedtunic',
		'forge_woodarmor',
		'featheredtunic',
		'silkenarmor',
		'jaggedarmor',
		'splintmail',
		'steadfastarmor',
		'steadfastgrandarmor',
		'whisperinggrandarmor',
		'silkengrandarmor',
		'jaggedgrandarmor',
		'' -- hallowed
	}
	self.headitemlist = {
		'lavaarena_chefhat',
		'crystaltiara',
		'featheredwreath',
		'barbedhelm',
		'noxhelm',
		'wovengarland',
		'flowerheadband',
		'clairvoyantcrown',
		'resplendentnoxhelm',
		'blossomedwreath',
		'' -- hallowed
	}
end



local function FromLocalToGlobal(index, case) -- return in-game instance from an index for brain table
	fns.print('From local to global call [', index, case, ']')
	if case == 1 and Brain.team[index] then
		return Ents[Brain.team[index].guid]
	elseif case == 2 and Brain.mobs[index] then
		return Ents[Brain.mobs[index].guid]
	elseif case == 3 and Brain.items[index] then
		return Ents[Brain.items[index].guid]
	end
end

local function FromGlobalToLocal(guid, case) --  return index from brain table from guid
	--fns.print('From global to local call [', guid, "("..(Ents[guid] and Ents[guid].prefab or "unexistent inst")..")", case, ']')
	if case == 1 then
		for i = 1, #Brain.team do
			if Brain.team[i].guid == guid then
				return i
			end
		end
	elseif case == 2 then
		for i = 1, #Brain.mobs do
			if Brain.mobs[i].guid == guid then
				return i
			end
		end
	elseif case == 3 then
		for i = 1, #Brain.items do
			if Brain.items[i].guid == guid then
				return i
			end
		end
	end
end

local function GetNormalizedPosition(pos)
	return {(pos.x + 32.5) / 65, (pos.z + 32.5) / 65}
end

local function GetResolvedAndNormalizedUserid(userid)
	for i = 1, #Brain.team do
		if Brain.team[i].userid == userid then
			return BINARY_NUMERATION and Brain.binaryTeamIndices[i] or i / 16
		end
	end
	return BINARY_NUMERATION and Brain.binaryTeamIndices[16] or 1. -- 16 is unknown player / none aggro at all
end

local function GetNormalizedPrefab(prefab, case, slot)
	if case == 1 then -- mob
		for i = 1, #Brain.moblist do
			if prefab:find(Brain.moblist[i]) then
				return (BINARY_NUMERATION and Brain.binaryMobIndices[i] or false), i
			end
		end
		return (BINARY_NUMERATION and {1,1,1,1} or 16), 8 -- IF #Brain.moblist >= 16 THEN THIS MAY CAUSE ISSUES -- bruh there's so much more that can (and will) cause issues, why care?
	elseif case == 2 then -- player
		for i = 1, #Brain.playerlist do
			if prefab == Brain.playerlist[i] then
				return i / 19
			end
		end
		return 1
	elseif case == 3 then -- item
		if slot == 'hand' then
			for i = 1, #Brain.handitemlist do
				if prefab == Brain.handitemlist[i] then
					return i / 32
				end
			end
			return prefab and 1 or 0
		elseif slot == 'body' then
			for i = 1, #Brain.bodyitemlist do
				if prefab == Brain.bodyitemlist[i] then
					return i / 20
				end
			end
			return prefab and 1 or 0
		elseif slot == 'head' then
			for i = 1, #Brain.headitemlist do
				if prefab == Brain.headitemlist[i] then
					return i / 20
				end
			end
			return prefab and 1 or 0
		end
	end
end

local blankMobTemplate = {}
for j = 1, (BINARY_NUMERATION and 16 or 10) do
	blankMobTemplate[j] = 0
end
local blankPlayerTemplate = {}
for j = 1, 9 do
	blankPlayerTemplate[j] = 0
end
local blankItemTemplate = {}
for j = 1, 4 do
	blankItemTemplate[j] = 0
end

local function NormalzeDirection(direction)
	local l = math.sqrt(direction.x ^ 2 + direction.z ^ 2)
	return {(direction.x / l + 1) / 2 , (direction.z / l + 1) / 2}
end

local function ResolveSlotInNumbers(slot)
	if slot == 'hand' then
		return 1
	elseif slot == 'body' then
		return 2
	elseif slot == 'head' then
		return 3
	end
	fns.print('Resolve slot in number gone wrong! slot:', slot)
end

function Brain:GetNormalizedMobData()
	Brain.mobs = Brain.owner.autofSensors.GetMobsDataTable()
	local normalized = {}
	local t, j
	for i = 1, MOB_MEMORY_SIZE do
		if Brain.mobs[i] then
			t, j = GetNormalizedPrefab(Brain.mobs[i].prefab, 1)
			normalized[i] = {
				t or j / 16, -- 4 (1)
				GetNormalizedPosition(Brain.mobs[i].rel_pos), -- 2
				(Brain.mobs[i].hit_quantity or 0) / Brain.mobsHP[j], -- 1
				GetResolvedAndNormalizedUserid(Brain.mobs[i].aggro), -- 4 (1)
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
	Brain.team = Brain.owner.autofSensors.GetTeamDataTable()
	local normalized = {}
	for i = 1, PLAYER_MEMORY_SIZE do
		if Brain.team[i] then
			normalized[i] = {
				GetNormalizedPrefab(Brain.team[i].prefab, 2), -- 1
				GetNormalizedPosition(Brain.team[i].rel_pos), -- 2
				Brain.team[i].health, -- 1
				GetNormalizedPrefab(Brain.team[i].eqhand, 3, 'hand'), -- 1
				GetNormalizedPrefab(Brain.team[i].eqbody, 3, 'body'), -- 1
				GetNormalizedPrefab(Brain.team[i].eqhead, 3, 'head'), -- 1
				i / 16, -- 1
				(Brain.team[i].iscasting and 1 or 0) -- 1
			}
		else
			normalized[i] = blankPlayerTemplate
		end		
	end
	return fns.FlattenSecondAndExtendFirst({}, normalized)
end

function Brain:GetNormalizedItemData()
	Brain.items = Brain.owner.autofSensors.GetItemsDataTable()
	local normalized = {}
	local slot
	for i = 1, ITEM_MEMORY_SIZE do
		if Brain.items[i] then
			if Brain.items[i].slot == 'hand' then
				slot = 0
			elseif Brain.items[i].slot == 'body' then
				slot = .5
			else 
				slot = 1
			end
			normalized[i] = {
				GetNormalizedPrefab(Brain.items[i].prefab, 3, Brain.items[i].slot), -- 1
				slot, -- 1
				GetNormalizedPosition(Brain.items[i].rel_pos), -- 2
			}
		else
			normalized[i] = blankItemTemplate
		end
	end
	return fns.FlattenSecondAndExtendFirst({}, normalized)
end

function Brain:GetNormalizedArenaEntsData() -- heal circles and fissures
	local normalized = {}
	local healz = ThePlayer.autofSensors.GetHealingCircles()
	local fissures = ThePlayer.autofSensors.GetFissures()
	for i = 1, 2 do
		if healz[i] then
			normalized[i] = {1, GetNormalizedPosition(healz[i])}
		else
			normalized[i] = {0, 0, 0}
		end
	end
	for i = 3, 5 do
		if fissures[i - 2] then
			normalized[i] = {1, GetNormalizedPosition(fissures[i - 2][1]), fissures[i - 2][2]}
		else
			normalized[i] = {0, 0, 0, 0}
		end
	end
	return fns.FlattenSecondAndExtendFirst({}, normalized)
end

function Brain:GetNormalizedPlayerData()
	local equips = ThePlayer.replica.inventory:GetEquips()
	local normalized = {
		GetNormalizedPrefab(ThePlayer.prefab, 2),									  -- 1
		GetNormalizedPosition(ThePlayer.autofSensors.GetRelativePosition(ThePlayer)), -- 2
		ThePlayer.autofSensors.GetSelfHPPercent(), 									  -- 1
		GetNormalizedPrefab(equips.hands, 3, 'hand'),								  -- 1
		GetNormalizedPrefab(equips.body, 3, 'body'), 								  -- 1
		GetNormalizedPrefab(equips.head, 3, 'head'), 								  -- 1
		1, 																			  -- 1!
		(Brain.currentWeaponCharge or 0), 											  -- 1
		ThePlayer.replica.combat:GetAttackRangeWithWeapon() / 10 					  -- 1
	}
	return fns.FlattenSecondAndExtendFirst({}, normalized)

end

function Brain:GetNormalizedTime()
	return GetTime() / 7200
end

function Brain:FetchAllNormalizedData()
	return fns.FlattenSecondAndExtendFirst({}, {
		Brain:GetNormalizedTime(),
		Brain:GetNormalizedPlayerData(),
		Brain:GetNormalizedTeamData(),
		Brain:GetNormalizedMobData(),
		Brain:GetNormalizedItemData(),
		Brain:GetNormalizedArenaEntsData(),
	})
end

function Brain:GetNormalizedAction(action)
	local normalized = {}
	local j = 1
	if action.name == 'idle' then
		normalized[j] = 1
	else
		normalized[j] = 0
	end
	j = j + 1
	if action.name == 'walk' then
		normalized[j] = 1
		normalized[j + 1] = NormalzeDirection(action.params)
	else
		normalized[j] = 0
		normalized[j + 1] = {0, 0}
	end
	j = j + 2
	if action.name == 'attack' then
		normalized[j] = 1
		normalized[j + 1] = (FromGlobalToLocal(action.params, 2) or 0) / MOB_MEMORY_SIZE
		if normalized[j + 1] == 0 then
			fns.print("I couldn't figure out who exactly you were attacking, but okay, I'll let it slip")
		end
	else
		normalized[j] = 0
		normalized[j + 1] = 0
	end
	j = j + 2
	if action.name == 'pickup' then
		normalized[j] = 1
		normalized[j + 1] = (FromGlobalToLocal(action.params, 3) or 0) / ITEM_MEMORY_SIZE
		if normalized[j + 1] == 0 then
	--		fns.print('you\'re picking shit up so fast i can\'t even realize it')
			fns.print("You likely have picked item too fast after you dropped it, but it's okay, I'm not crashing yet")
		end
	else
		normalized[j] = 0
		normalized[j + 1] = 0
	end
	j = j + 2
	if action.name == 'drop' then
		normalized[j] = 1
		normalized[j + 1] = (ResolveSlotInNumbers(action.params) - 1) * .5
	else
		normalized[j] = 0
		normalized[j + 1] = 0
	end
	j = j + 2
	if action.name == 'castaoe' then
		normalized[j] = 1
		normalized[j + 1] = GetNormalizedPosition(action.params)
	else
		normalized[j] = 0
		normalized[j + 1] = {0, 0}
	end
	j = j + 2
	if action.name == 'revive' then
		normalized[j] = 1
		normalized[j + 1] = (FromGlobalToLocal(action.params, 1) or 0) / PLAYER_MEMORY_SIZE
		if normalized[j + 1] == 0 then
			fns.print("This event should be so rare, I don't expect anyone actually bumping into this")
		end
	else
		normalized[j] = 0
		normalized[j + 1] = 0
	end
	return fns.FlattenSecondAndExtendFirst({}, normalized)
end

function Brain:LabelDataAndWaitForNext(normalized_actions)
	local labelled = {}
	if Brain.fetchedData then
		labelled = {label = normalized_actions, data = Brain.fetchedData}
	end
	Brain.fetchedData = Brain:FetchAllNormalizedData()
	return labelled
end

return Brain