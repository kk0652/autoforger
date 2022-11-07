local Sensors = {}

local fns = require'autof_functions'

local sameMobMemoryMax = 8
local playersEquips = {}
local healz = {}
local fissures = {}

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
	return TheSim:FindEntities(x, 0, z, r or 66, tags)
end

local function GetRelativePos(inst)
	local center = TheWorld.net.center_pos
	local x, _, z = inst.Transform:GetWorldPosition()
	return Vector3(x - center.x, 0, z - center.z)
end

Sensors.GetRelativePosition = GetRelativePos -- why? no apparent reason

function Sensors.GetSelfHPPercent()
	return ThePlayer.replica and ThePlayer.replica.health and ThePlayer.replica.health:GetPercent() or 0
end

local function GetAggro(inst)
	local t = inst.replica.combat:GetTarget()
	return t and t.userid or 'none'
end

local function IsInHeal(inst)
	return inst:HasTag('_isinheals')
end

local function ResolveItemSlot(inst)
	if not inst then fns.print("Item slot can't be resolved because there is no item, returning head slot") return 'head' end
	if fns.CheckDebugString(inst, "build: armor") then
		return 'body'
	elseif fns.CheckDebugString(inst, 'build: hat') then
		return 'head'
	else
		return 'hand'
	end
end

Sensors.ResolveItemSlot = ResolveItemSlot

function Sensors.InitializeScanner(plr)
	if plr.autofScanner ~= nil then return end
	plr.autofScanner = plr:StartThread(function()
		local ents
		local ent
		local f, flag -- too bad
		local p
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
				if fns.CheckDebugString(ent, "hit Frame:") then
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
					if not flag then -- i don't like this, but at least this works
						f = ent.Remove
						flag = true
					end
					p = ent:GetNearestPlayer()
					if not p then break end
					ent.Remove = function(t, ...)
						if t:GetNearestPlayer() then
							if t:GetDistanceSqToInst(t:GetNearestPlayer()) < 1.5 then
								playersEquips.add(t:GetNearestPlayer().userid, ResolveItemSlot(t), t.prefab)
							end
						end
						ent.marked = nil
						f(t, ...)
					end
					if ent:GetDistanceSqToInst(ent:GetNearestPlayer()) < 1.5 and playersEquips[p.userid] and playersEquips[p.userid][ResolveItemSlot(ent)] == ent.prefab then
						playersEquips[p.userid][ResolveItemSlot(ent)] = nil
					end
					ent.marked = true
				end
			end
			ents = FindEntities({"healingcircle"}, 25)
			p = {}
			for i = 1, #ents do
				p[i] = ents[i]
			end
			healz = p
			ents = FindEntities({"antlion_sinkhole"}, 30)
			p = {}
			for i = 1, #ents do
				p[i] = ents[i]
			end
			fissures = p
			Sleep(0)
		end
	end)
end



local function ExtractDataFromMob(ent)
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
			epic = ent:HasTag('epic'),
			guid = ent.GUID
			}
end

function Sensors.GetMobsDataTable()
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
	is mob EPIC -- это в основном я добавил чтобы использовать в этой функции),
	GUID -- мне это понадобится, потом...
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
		if j > MOB_MEMORY_SIZE then break end
		if seenMobs[ent.prefab] ~= nil then
			seenMobs[ent.prefab] = seenMobs[ent.prefab] + 1
		else
			seenMobs[ent.prefab] = 1
		end
		if seenMobs[ent.prefab] <= sameMobMemoryMax then
			mobsData[j] = ExtractDataFromMob(ent)
			j = j + 1
			ent.mark = true
		end
	end
	local epicents = FindEntities({"LA_mob", "epic"}) -- epik! epicckck1!\
	for i = 1, #epicents do
		if not epicents[i].mark then
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
		ents[i].mark = nil
	end
	return mobsData
end

local function GetEquips(userid,prefab)
	if playersEquips[userid] == nil then
		playersEquips[userid] = {hand = TUNING.GAMEMODE_STARTING_ITEMS.LAVAARENA[prefab][1], body = TUNING.GAMEMODE_STARTING_ITEMS.LAVAARENA[prefab][2]}
	end
	return playersEquips[userid]
end

local function GetPlayerHealth(player)
	return player.components.healthsyncer._healthpct:value()
end

function Sensors.GetTeamDataTable()
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
	for i = 2, math.min(#players, PLAYER_MEMORY_SIZE) do
		player = players[i]
		if player.prefab ~= 'spectator' then
			equips = GetEquips(player.userid, player.prefab:upper())
			playersData[i - 1] = {
				prefab = player.prefab,
				rel_pos = GetRelativePos(player),
				health = GetPlayerHealth(player),
				eqhand = equips.hand,
				eqbody = equips.body,
				eqhead = equips.head,
				userid = player.userid,
				iscasting = fns.CheckDebugString(player, "zip:staff"), -- i don't think it will really be useful, but oh well
				guid = player.GUID
			}
		end
	end
	return playersData
end

local function IsItemValuable(prefab)
	return prefab:find("staff") or prefab:find("sword") or prefab:find("tome") or prefab:find("lucy")
end

function Sensors.GetItemsDataTable()
	local itemsData = {}
	local ents = FindEntities({'_inventoryitem'})
	local ent
	local j = 1
	for i = 1, #ents do
		if j > ITEM_MEMORY_SIZE then
			for k = i, #ents do
				ent = ents[k]
				if IsItemValuable(ent.prefab) and not IsItemValuable(itemsData[j - 1].prefab) then
					itemsData[j - 1] = {
						prefab = ent.prefab,
						rel_pos = GetRelativePos(ent),
						slot = ResolveItemSlot(ent),
						guid = ent.GUID
					}
					j = j - 1
				end
			end
			break
		end
		ent = ents[i]
		if ent:GetPosition() ~= ThePlayer:GetPosition() then
			itemsData[j] = {
				prefab = ent.prefab,
				rel_pos = GetRelativePos(ent),
				slot = ResolveItemSlot(ent),
				guid = ent.GUID
			}
			j = j + 1
		end
	end
	return itemsData
end

function Sensors.GetHealingCircles()
	local hc = {}
	for i = 1, #healz do
		hc[i] = GetRelativePos(healz[i])
	end
	return hc
end

function Sensors.GetFissures()
	local fs = {}
	for i = 1, #fissures do
		fs[i] = {
			GetRelativePos(fissures[i]),
			(fissures[i].prefab:find("lava") and true or false)
		}
	end
	return fs
end

function Sensors.CollectAndSerializeData(inclplayers, inclmobs, inclitems, inclarenaents)
	local data = ""
	if inclplayers then
		data =  data.."\nPlayers data:"
		for k,v in ipairs(Sensors.GetTeamDataTable()) do
			data = data.."\n  Player "..k.." | "..v.prefab.." | "..v.userid..":\n".."    Health: "..math.ceil(v.health*100).." | Position: "..tostring(v.rel_pos).." | Is casting: "..tostring(v.iscasting ~= nil).."\n    Hand: "..(v.eqhand or "EMPTY").." Body: "..(v.eqbody or "EMPTY").." Head: "..(v.eqhead or "EMPTY")
		end
	end
	if inclmobs then
		data = data.."\nMobs data:"
		for k,v in ipairs(Sensors.GetMobsDataTable()) do
			data = data.."\n  Mob "..k.." | "..v.prefab..(v.epic and " | BOSS:" or ":").."\n    Hit: "..(v.hit_quantity or '0').." | Position: "..tostring(v.rel_pos).." | Aggro: "..v.aggro.."\n    CC: "..(v.cc and "true" or "false").." | Guard: "..(v.guard and "true" or "false").." | Inheal: "..(v.inheal and "true" or "false").."\n    Debuffed: "..(v.debuff and "true" or "false").." | Last attack: "..(v.attack_time or '')
		end
	end
	if inclitems then
		data = data.."\nItems data:"
		for k,v in ipairs(Sensors.GetItemsDataTable()) do
			data = data.."\n Item "..k.." | "..v.prefab.." | ".."Position: "..tostring(v.rel_pos)
		end
	end
	if inclarenaents then
		data = data.."\nArena ents data:"
		for k,v in ipairs(healz) do
			data = data.."\nHeal "..k.." - Position: "..(healz[k] and tostring(GetRelativePos(healz[k])) or "none")
		end
		for k,v in ipairs(fissures) do
			data = data.."\nFissure "..k.." - Position: "..(fissures[k] and tostring(GetRelativePos(fissures[k])) or "none")
		end
	end
	return data
end

return Sensors