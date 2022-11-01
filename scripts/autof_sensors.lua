local Sensors = {}

local fns = require'autof_functions'

function Sensors.GetTeamStatus()
	if not fns.IsInGame() then return end
	local status = {}
	for i = 1, #AllPlayers - 1 do
		dothings()
	end
	return status
end

function Sensors.GetSettings()
	if not fns.IsInGame() then return end
	return REFORGED_SETTINGS.gameplay
end

function Sensors.UpdateMobs(mobs)
	local updated = {}
	local j = 1
	for i = 1, #mobs do
		if fns.ISTargetValid(mobs[i]) then
			updated[j] = mobs[i]
			j = j + 1
		end
	end

	local x, _, z = ThePlayer:GetPosition():Get()
	local ents = TheSim:FindEntities(x, _, z, 50, {"LA_mob"})
	for i = 1, #ents do
		if ents[i].marked == nil then
			ents[i].marked = true
			updated[j] = ents[i]
			j = j + 1
		end
	end

	return updated
end

