local Sensors = {}

local fns = require'autof_functions'

local mobMemorySize = 12
local sameMobMemoryMax = 8
local playersEquips = {}

function playersEquips.add(whom, slot, what)
	if playersEquips[whom] == nil then
		playersEquips[whom] = {}
	end
	playersEquips[whom][slot] = what
end

local function GetSettings()
	if not fns.IsInGame() then return end
	return REFORGED_SETTINGS.gameplay
end

local function IsTargetValid(target)
    return target ~= nil and target:IsValid()
end

local function IsTargetAlive(target)
    return target ~= nil and target.replica.health ~= nil and not target.replica.health:IsDead()
end 

local function FindEntities(tags, r)
	local x, _, z = ThePlayer:GetPosition():Get()
	return TheSim:FindEntities(x, 0, z, r or 60, tags)
end

local function UpdateMobs(mobs)
	local updated = {}
	local j = 1
	for i = 1, #mobs do
		if fns.ISTargetValid(mobs[i]) then
			updated[j] = mobs[i]
			j = j + 1
		end
	end

	local ents = Sensors.FindEntities({"LA_mob"})
	for i = 1, #ents do
		if ents[i].marked == nil then
			ents[i].marked = true
			updated[j] = ents[i]
			j = j + 1
		end
	end

	return updated
end

local function GetRelativePos(inst)
	local center = TheWorld.net.center_pos or TheWorld.components.lavaarenaevent:GetArenaCenterPoint() -- idk which one would work on client, but i'd bet on former
	local pos = inst.Transform:GetPosition()
	return Vector3(pos.x - center.x, 0, pos.z - center.z)
end

local function GetAggro(inst)
	return ent.replica.combat:GetTarget().userid or ''
end

local function IsInHeal(inst)
	return inst:HasTag('_isinheals')
end

local function ResolveItemSlot(inst)
	if fns.CheckDebugString(inst, "build: armor") then
		return 'body'
	elseif fns.CheckDebugString(inst, 'build: hat') then
		return 'head'
	else
		return 'hand'
	end
end

local function InitializeScanner()
	if ThePlayer.autofScanner ~= nil then return end
	ThePlayer.autofScanner = ThePlayer:StartThread(function()
		local ents
		local ent
		while true do
			ents = FindEntities({"LA_mob"}, 12)
			for i = 1, #ents do
				ent = ents[i]
				if        fns.CheckDebugString(ent, "zip:attack Frame: 0")
				or       fns.CheckDebugString(ent, "zip:attack1 Frame: 0")
				or      fns.CheckDebugString(ent, "zip:attack1b Frame: 0")
				or       fns.CheckDebugString(ent, "zip:attack2 Frame: 0")
				or       fns.CheckDebugString(ent, "zip:attack3 Frame: 0")
				or       fns.CheckDebugString(ent, "zip:attack4 Frame: 0")
				or       fns.CheckDebugString(ent, "zip:attack5 Frame: 0")
				or          fns.CheckDebugString(ent, "zip:spit Frame: 0")
				or 	  fns.CheckDebugString(ent, "zip:attack_pre Frame: 0")
				or   fns.CheckDebugString(ent, "zip:attack2_pre Frame: 0")
				or      fns.CheckDebugString(ent, "zip:roll_pre Frame: 0")
				or        fns.CheckDebugString(ent, "zip:taunt2 Frame: 0")
				or     fns.CheckDebugString(ent, "zip:bellyflop Frame: 0")
				or fns.CheckDebugString(ent, "zip:block_counter Frame: 0")
				then
					ent.last_attack = GetTime()
				end
			end
			ents = FindEntities({"LA_mob"})
			for i = 1, #ents do
				if CheckDebugString(ent, "hit") then
					if ent.hitq ~= nil then
						ent.hitq = ent.hitq + 1
					else
						ent.hitq = 1
					end
				end
			end
			ents = FindEntities({"_inventoryitem"})
			for i = 1, #ents do
				ent = ents[i]
				if ent.marked == nil then
					ent:DoPeriodicTask(.5 function()
						if ent:HasTag("INLIMBO") then
							if  ent.eqby == nil then
								playersEquips.add(ent:GetNearestPlayer().userid, ResolveItemSlot(ent), ent)
								ent.eqby = ent:GetNearestPlayer().userid
							end
						elseif ent.eqby ~= nil then
							playersEquips[ent.eqby][ResolveItemSlot(ent)] = nil
							ent.eqby = nil
						end
					end)
					ent.marked = true
				end
			end
		end
	end)
end


local function ExtractDataFromMob(mob)
	return {
			prefab = ent.prefab,
			rel_pos = GetRelativePos(ent),
			hit_quantity = ent.hitq or 0,
			aggro = GetAggro(ent),
			cc = fns.CheckDebugString(ent, "sleep") or fns.CheckDebugString(ent, "fossilized"),
			inheal = IsInHeal(ent),
			guard = fns.CheckDebugString(ent, "zip:hide") or fns.CheckDebugString(ent, "turtillus_basic.zip:attack2"),
			debuff = ent:HasTag("haunted"),
			attack_time = ent.last_attack or 0,
			epic = ent:HasTag('epic')
			}
end

local function GetMobsDataTable()
	--[[
	Data of one mob is a table of this format:
	{
	prefab,
	relative_position,
	quantity of hit animations,
	mob's aggro (playerid),
	is it in sleep\petri,
	is in sleep circle -- it can be in heal but not sleep, have to remember that
	is it in guard,
	is it debuffed, -- only haunted counts though
	last time it attacked,
	is mob EPIC -- это в основном я добавил чтобы использовать в этой функции)
	}

	Эта функция сначала ищет mobMemorySize ближайших мобов вокруг (если мобов определенного типа больше sameMobMemoryMax, то начиная с sameMobMemoryMax + 1 они пропускаются),
						 собирает инфу о них
						 потом, на случай, если все эти мобы - мелкие, а босс пропущен:
						 она ищет всех боссов
						 проходится по каждому боссу
						 и если этот босс не был уже помещен в дату (not marked),
						 помещает его в дату вместо какого-то не эпичного моба
						 ну и потом снимает отметки с мобов чтобы помечать потом снова

	--]]
	if not fns.IsInGame() then return end
	local ents = FindEntities({"LA_mob"})
	local seenMobs = {} -- to not store a shit ton of one kind of mobs when there're some other mobs behind them
	local ent
	local mobsData = {}
	local j = 1
	for i = 1, #ents do
		ent = ents[i]
		if j > mobMemorySize then break end
		if seenMobs[ent.prefab] ~= nil then
			seenMobs[ent.prefab] = seenMobs[ent.prefab] + 1
		else
			seenMobs[ent.prefab] = 1
		end
		if seenMobs[ent.prefab] <= sameMobMemoryMax then
			mobsData[j] = ExtractDataFromMob(ent)
			j = j + 1
			ent.marked = true
		end
	end
	local epicents = FindEntities({"LA_mob", "epic"}) -- epik! epicckck1!\
	for i = 1, #epicents do
		if not epicents[i].marked then
			for k = j, 1, -1 do
				if not mobsData[k].epic then
					mobsData[k] = ExtractDataFromMob(epicents[i])
					j = k
					break
				end
			end
		end
	end
	for i = 1, #ents do
		ents[i].marked = nil
	end
	return mobsData
end

local function GetEquips(userid)
	return playersEquips[userid] or {}
end

local function GetTeamData()
	--[[
	data of one player:
	{
	prefab,
	relative_position,
	%health,
	equips_hands,
	equips_body,
	equips_head,
	userid,
	iscasting_long,
	}

	--]]
	if not fns.IsInGame() then return end
	local playersData = {}
	local players = FindEntities({"player"})
	local player
	local equips
	for i = 2, #players do
		player = players[i]
		if player.prefab ~= 'spectator' then
			equips = GetEquips(player.userid)
			playersData[i - 1] = {
				prefab = player.prefab,
				rel_pos = GetRelativePos(player),
				health = GetPlayerHealth(player),
				eqhand = equips.hand,
				eqbody = equips.body,
				eqhead = equips.head,
				userid = player.userid,
				iscasting = CheckDebugString(player, "zip: staff") -- i don't think it will really be useful, but oh well
			}
		end
	end
	return status
end