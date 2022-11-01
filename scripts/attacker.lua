local Attacker = {}

local fns = require'autof_functions'

function Attacker.Attack(target, delay, attackRange, position)
	local controller = ThePlayer.components.playercontroller
	local weapon = ThePlayer.replica.combat:GetWeapon()
	local seconds = delay * .001
	local range = target:GetPhysicsRadius(0) + attackRange
	if not fns.IsTargetValid(target) or range * range < ThePlayer:GetDistanceSqToInst(target) then
		return -1
	end
	if controller:CanLocomote() then
		local act = ThePlayer.components.playeractionpicker:GetLeftClickActions(target:GetPosition(), target)[1]
		if not act then return -1 end
		act.preview_cb = function()
			fns.SendRPC(RPC.LeftClick, ACTIONS.ATTACK.code, position.x, position.z, target, true, nil, nil, ThePlayer.__k)
		end
		act.action_key = ThePlayer.__k
		controller:DoAction(act)
	else
		fns.SendRPC(RPC.LeftClick, ACTIONS.ATTACK.code, position.x, position.z, target, true, nil, nil, ThePlayer.__k)
	end
	if weapon and (weapon:HasTag("blowdart") or weapon:HasTag("slingshot")) then
		return seconds - 4 * FRAMES
	else
		return seconds
	end
end