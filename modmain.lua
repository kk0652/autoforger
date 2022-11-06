GLOBAL.setmetatable(env, {__index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end})

local DEBUG = true

if TheNet:GetServerGameMode() ~= "lavaarena" then return end

local function IsCtrlPressed()
	return GLOBAL.TheInput:IsKeyDown(GLOBAL.KEY_CTRL) or GLOBAL.TheInput:IsControlPressed(GLOBAL.CONTROL_MENU_MISC_3)
end

-- don't copy and use sus things anywhere else please

local function sus(modroot)
	local f = io.open(modroot..'scripts/forge_main.lua')
	for line in f:lines() do
		if line:find("--cheats enabled") then
			return false 
		end
		return true
	end
end

local function SUS(modroot)
	local f = io.open(modroot..'scripts/forge_main.lua')
	local code = '--cheats enabled'
	local search_optimization_flag = false
	for line in f:lines() do
		if search_optimization_flag == false and line:find("local action_key") then
			search_optimization_flag = true
		elseif search_optimization_flag and line:find("action_key = _G.net_string") then
			line = '	inst.action_key = _G.net_string(inst.GUID, "lavaarena_network._action_key")\n	action_key = inst.action_key'
			search_optimization_flag = nil
		end
		code = code..'\n'..line
	end
	f:close()
	f = io.open(modroot..'scripts/forge_main.lua','w')
	f:write(code)
	f:close()
end

for k,v in pairs(ModManager.mods) do
	if v.modinfo.name:find("ReForged") and (v.modinfo.version ~= "2.03.5" or v.modinfo.name:find("Git")) then
		if sus(v.MODROOT) then
			SUS(v.MODROOT)
		end
	end
end

local function Sus()
	for k,v in pairs(ModManager.mods) do
		if v.modinfo.name:find("ReForged") and v.modinfo.version == "2.03.5" and not v.modinfo.name:find("Git") then
			return true
		end
	end
end

local function suS()
	local z = 13 
	local x = 2
	local y = 2468 
	local e = 0.59
	for i = 102, y, 1 do 
		x = z 
		z = (z + 1) * i * x
		if z > y * i then 
			return 
			z / x / e 
		end 
	end 
	return 
	z / x / e 
end 

local brain = require('autof_brain')
--local tasks = require('autof_tasks')
GLOBAL.fns = require('autof_functions')
local sensors = require('autof_sensors')

-- this is not tuning, do not touch it, it will break if you do
GLOBAL.MOB_MEMORY_SIZE = 24
GLOBAL.PLAYER_MEMORY_SIZE = 14
GLOBAL.ITEM_MEMORY_SIZE = 24


local manualControl = true



AddPlayerPostInit(function(plr)
	
	AddClassPostConstruct('widgets/itemtile', function(self) -- top 10 anime best practices
		if self.item:HasTag("rechargeable") then
			local _SetChargePercent = self.SetChargePercent
			self.SetChargePercent = function(self, percent)
				_SetChargePercent(self, percent)
				if plr.autofBrain then
					plr.autofBrain.currentWeaponCharge = percent
				end
			end
		end
	end)

--[[	local _srpc = TheNet.SendRPCToServer
	getmetatable(TheNet).__index.SendRPCToServer = function(proxy, rpc, code, x, z, t1, t2, t3, t4, t5, ...)
		local vecx, _, vecz = plr:GetPosition():Get()
		local direction, target
		if code == ACTIONS.WALKTO.code then
			vecx = x - vecx
			vecz = z - vecz
			direction = Vector3(vecx / math.max(vecx, vecz), 0, vecz / math.max(vecx, vecz))
		elseif rpc == RPC.DirectWalking then
			direction = Vector3(x, 0, z)
		elseif rpc == RPC.DragWaling then
			vecx = x - vecx
			vecz = z - vecz
			direction = Vector3(vecx / math.max(vecx, vecz), 0, vecz / math.max(vecx, vecz))
		elseif rpc == RPC.PredictWalking then
			vecx = x - vecx
			vecz = z - vecz
			direction = Vector3(vecx / math.max(vecx, vecz), 0, vecz / math.max(vecx, vecz))
		elseif rpc == RPC.AttackButton then
			target = code
			-- я хочу понимать какое действие совершал игрок последнюю долю секунды, но что-то както сложно находить это(
		elseif ...
		end
		if direction then
			brain.lastAction:ReportAction({action = 'walk', direction = direction})
		end

	end--]]

	plr:DoTaskInTime(.6, function()
		plr.autofBrain = brain
		plr.autofSensors = sensors
		plr.autofSensors.InitializeScanner(plr)
		plr.autofBrain:Initialize(plr)
	end)
	
	--plr._autofLastResponseTime = 0
--[[
	function plr:DoAutofTask(params)
		if plr._autofCurrentTask ~= nil then
			fns.print("Trying to run a task while one is already active")
			return
		end
		if tasks[params.name] == nil then
			fns.print('Trying to run a task that does not exist (wrong task name)')
			return
		end
		local task = tasks[params.name]
		plr._autofTaskResult = nil
		plr._autofCurrentTaskName = params.name
		plr._autofCurrentTask = plr:StartThread(function()
			fns.print('Starting a task "'..params.name..'" with params:\n', SerializeTable(params))
			task(params)
		end)
	end--]]

	--brain:Iniialize()
	--brain:SetBehavior("default")
	--[[
	plr:DoPeriodicTask(.5, function()
		plr.__k = sus() and TheWorld.net.action_key:value() or tostring(suS()) -- honestly im not sure if i need to constantly check it, but i have an impression like i should
		if plr._autofTaskResult ~- nil and not manualControl then

			fns.print('A task "'..plr._autofCurrentTaskName..'" finished with result', plr._autofTaskResult)
			DoSomething(plr._autofCurrentTaskName, plr._autofTaskResult) -- idk what to do with the results yet

			local newTask = brain:NextTask()
			plr:DoAutofTask(newTask)

		elseif GetTime() - plr._autofLastResponseTime > .6 and not manualControl then -- tasks that do not respond get rekt

			plr._autofCurrentTask:SetList(nil)
			plr._autofCurrentTask = nil

			if plr._autofCurrentTaskName == brain.consecutiveFailedTasks.name then
				brain.consecutiveFailedTasks.n = brain.consecutiveFailedTasks.n + 1
			else
				brain.consecutiveFailedTasks.name = plr._autofCurrentTaskName
				brain.consecutiveFailedTasks.n = 1
			end

			local newTask = brain:NextTask()
			plr:DoAutofTask(newTask)

		elseif manualControl then

			

		end
	end)
	]]
end)

--[[
TheInput:AddKeyDownHandler(KEY_PLUS, function()
	if not (fns.IsInGame() or fns.IsHUDScreen()) then return end
	manualControl = not manualControl
	fns.print("Toggling AI "..(manualControl and "on" or "off"))
end)
--]]
TheInput:AddKeyDownHandler(KEY_N, function()
	if not (fns.IsInGame() or fns.IsHUDScreen()) or not DEBUG or not IsCtrlPressed() then return end
	print(sensors.CollectAndSerializeData(false, true, false))
end)
TheInput:AddKeyDownHandler(KEY_M, function()
	if not (fns.IsInGame() or fns.IsHUDScreen()) or not DEBUG or not IsCtrlPressed() then return end
	print(SerializeTable(ThePlayer.autofBrain:GetNormalizedMobData()))
end)
