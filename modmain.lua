GLOBAL.setmetatable(env, {__index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end})

local DEBUG = true
local actionsout = false

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

local sussy = false

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
			sussy = true
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
GLOBAL.MOB_MEMORY_SIZE = 16
GLOBAL.PLAYER_MEMORY_SIZE = 8
GLOBAL.ITEM_MEMORY_SIZE = 16

local manualControl = true

local BIG_DATA = {}
local count = 1

local function CustomSerializeArray(array)
	local str = '{'
	for i = 1, #array do
		str = str..array[i]..','
	end
	return str..'}'
end

local function GetThreeStrings(data)
	local newdata = {}
	newdata[1] = data.description
	newdata[2] = CustomSerializeArray(data.label)
	newdata[3] = CustomSerializeArray(data.data)
	return newdata
end

local function WriteData()
	if count > 1 then
		local file = io.open(env.MODROOT..tostring(os.time()).."forge.data", 'w')
		local strs
		for i = 1, count - 1 do
			strs = GetThreeStrings(BIG_DATA[i])
			file:write(strs[1]..'\n')
			file:write(strs[2]..'\n')
			file:write(strs[3]..'\n')
		end
		file:close()
	end
end

AddPrefabPostInit('world', function(inst) 
	inst:ListenForEvent("endofmatch", function() 
		inst:DoTaskInTime(2, WriteData) 
	end)
end)

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


	-- [[
	local prevTarget
	local isAttacking_button, isAttacking_click
	local isCasting
	local position
	local droppedItem, pickedItem
	local lastSuccessfulHitTime = 0
	local guid
	local revivedCorpse
	local startRevive = -5
	local _srpc = TheNet.SendRPCToServer
	getmetatable(TheNet).__index.SendRPCToServer = function(proxy, rpc, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10) -- so many 
	--[[
	_oldSendRPC = SendRPCToServer 
	SendRPCToServer = function(a,b,c,d,e,f,g,h,i,j,k) 
		print(a,(b or 'nil'),(c or 'nil'),(d or 'nil'),(e or 'nil'),(f or 'nil'),(g or 'nil'),(h or 'nil'),(i or 'nil'),(j or 'nil'),(k or 'nil')) 
		_oldSendRPC(a,b,c,d,e,f,g,h,i,j,k)  
	end

	RPCs 											ACTIONS
	29  - left click,								40    - cast aoe
	52  - stop walking (direct walking)				230   - walkto
	50  - stop control 								15    - attack
	1   - action button 							171   - revive
	37, 36 - lag comp on/off
	--]]

		if (rpc == RPC.ActionButton or rpc == RPC.LeftClick) and arg1 == ACTIONS.REVIVE_CORPSE.code then
			revivedCorpse = true
			guid = (rpc ~= RPC.ActionButton and arg4.GUID or arg2.GUID)
			startRevive = GetTime()
		
		else

			if revivedCorpse and (rpc ~= RPC.StopAllControls and rpc ~= RPC.StopControl and rpc ~= RPC.StopWalking and rpc ~= RPC.MovementPredictionDisabled and rpc ~= RPC.MovementPredictionEnabled) then --  not sure if that's all
				revivedCorpse = false
				guid = false 
			end

			if (rpc == RPC.ActionButton or rpc == RPC.LeftClick) and arg1 == ACTIONS.PICKUP.code then
				pickedItem = true
				guid = (rpc ~= RPC.ActionButton and arg4.GUID or arg2.GUID)

			elseif rpc == RPC.LeftClick and arg1 == ACTIONS.CASTAOE.code then
				isCasting = true
				position = Vector3(arg2, 0, arg3)

			elseif rpc == RPC.UseItemFromInvTile and arg1 == ACTIONS.UNEQUIP.code or rpc == RPC.DropItemFromInvTile then
				droppedItem = true
				guid = (rpc ~= RPC.DropItemFromInvTile and arg2.GUID or arg1.GUID) 

			elseif rpc == RPC.LeftClick and arg1 == ACTIONS.ATTACK.code then
				isAttacking_click = true
				prevTarget = arg4

			elseif rpc == RPC.AttackButton then
				isAttacking_button = true
				if arg1 then
					prevTarget = arg1
				end

			elseif rpc == RPC.StopControl and arg1 == CONTROL_PRIMARY then
				isAttacking_click = false

			elseif rpc == RPC.StopControl and arg1 == ACTIONS.ABANDON_QUEST.code then
				isAttacking_button = false

			end

		end
		_srpc(proxy, rpc, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10) -- the last one might be excessive
	end
	--]]

	plr:DoTaskInTime(.6, function()
		plr.autofBrain = brain
		plr.autofSensors = sensors
		plr.autofSensors.InitializeScanner(plr)
		plr.autofBrain:Initialize(plr)

		plr.autofActionWatcher = plr:DoPeriodicTask(.5, function()
			local posDelta, x, z
			local pos = plr:GetPosition()
			if plr.autofBrain.previousPosition then
				x = pos.x - plr.autofBrain.previousPosition.x
				z = pos.z - plr.autofBrain.previousPosition.z
				posDelta = {x = x, z = z}				
				local action
				if revivedCorpse and guid then
					action = {name = 'revive', params = guid}
				elseif pickedItem and guid then
					action = {name = 'pickup', params = guid}
				elseif isCasting and position then
					action = {name = 'castaoe', params = position}
				elseif droppedItem and guid then
					action = {name = 'drop', params = plr.autofSensors.ResolveItemSlot(Ents[guid])}
				elseif (isAttacking_click or isAttacking_button) and prevTarget then
					action = {name = 'attack', params = prevTarget.GUID}
				elseif math.abs(z) + math.abs(x) > 1.2 then
					action = {name = 'walk', params = posDelta}
				else
					action = {name = 'idle'} -- supah idol
				end

				if Profile:GetMovementPredictionEnabled() then isAttacking_button = false end
				if isAttacking_click and GetTime() - lastSuccessfulHitTime > 1 then isAttacking_click = false end

				isCasting = false
				droppedItem = false
				pickedItem = false

				if revivedCorpse and GetTime() - startRevive > (ThePlayer.prefab ~= 'wilson' and 6 or 3) then
					revivedCorpse = false
					guid = false
				end
				
				if DEBUG and actionsout then fns.print(SerializeTable(action)) end

				local label = plr.autofBrain:GetNormalizedAction(action)
				local data = plr.autofBrain:LabelDataAndWaitForNext(label)
				data.description = action.name

				if data.data then
					fns.print(#data.data, #data.label)
					BIG_DATA[count] = data
					count = count + 1
				end
			end
			plr.autofBrain.previousPosition = pos


		end)
	end)

end)

AddPrefabPostInit('damage_number', function(inst)
	if not TheWorld.ismastersim then 
		inst:ListenForEvent("damagedirty", function()
			local parent = inst.entity:GetParent() 
			if ThePlayer and parent == ThePlayer and inst.target:value() then 
				if not inst.target:value():HasTag("player") then 
					lastSuccessfulHitTime = GLOBAL.GetTime()
				end 
			end 
		end) 
	else 
		local old_PushDamageNumber = inst.PushDamageNumber 
		inst.PushDamageNumber = function(player, target, damage, ...)
			if GLOBAL.ThePlayer and player == GLOBAL.ThePlayer and target then 
				if not target:HasTag("player") then 
					lastSuccessfulHitTime = GLOBAL.GetTime() 
				end 
			end 
			old_PushDamageNumber(player, target, damage, ...) 
		end 
	end 
end)

--[[
TheInput:AddKeyDownHandler(KEY_PLUS, function()
	if not (fns.IsInGame() or fns.IsHUDScreen()) then return end
	manualControl = not manualControl
	fns.print("Toggling AI "..(manualControl and "on" or "off"))
end)
--]]
TheInput:AddKeyDownHandler(KEY_B, function()
	if not (fns.IsInGame() or fns.IsHUDScreen()) or not DEBUG or not IsCtrlPressed() then return end
	actionsout = not actionsout
	fns.print(#BIG_DATA)
end)
TheInput:AddKeyDownHandler(KEY_N, function()
	if not (fns.IsInGame() or fns.IsHUDScreen()) or not DEBUG or not IsCtrlPressed() then return end
	print(ThePlayer.autofSensors.CollectAndSerializeData(true, true, true, true))
end)
TheInput:AddKeyDownHandler(KEY_M, function()
	if not (fns.IsInGame() or fns.IsHUDScreen()) or not DEBUG or not IsCtrlPressed() then return end
	print(SerializeTable(ThePlayer.autofBrain.fetchedData))
end)
