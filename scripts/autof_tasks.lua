local behaviors = require('autof_behaviors') -- TODO: Needed?
local fns = require('autof_functions')
local sensors = require('autof_sensors')

local tasks = {
	attack = {
		fn = function(params) -- target, delay, attackrange, position (wtf is position lol)
			local player = params.plr
                        local target = params.target
                        local delay = params.delay * .001
                        local aktrange = params.attackrange -- player.replica.combat:GetAttackRangeWithWeapon() ???
                        local weapon = params.weapon -- player.replica.combat:GetWeapon() ???
                        local range = target:GetPhysicsRadius(0) + atkrange
                        local dist = params.dist -- player:GetDistanceSqToInst(target) ???
                        local x, _, z = params.position:Get()
                        if not (sensors.IsTargetValid(target) or sensors.IsTargetAlive(target)) or range*range < dist then
                            return false
                        end
                        if player.components.playercontroller.locomotor ~= nil then
                            local act = player.components.playeractionpicker:GetLeftClickActions(target:GetPosition(), target)[1]
                            if not act then return false end
                        else

                        end
                        return true
		end,
	},
	pickup = {
		fn = function(params)
			local player = params.plr 
			local x, y, z = player.Transform:GetWorldPosition()
			local _inventoryitems = TheSim:FindEntities(x, y, z, params.range or 20, {"_inventoryitem"})
			for j = 1, #_inventoryitems do
			    if _inventoryitems[j].prefab == params.item then
				    local x1, y1, z1 = _inventoryitems[j].Transform:GetWorldPosition()
					if player.components.playercontroller.locomotor ~= nil then
					    local buffaction = BufferedAction(player, _inventoryitems[j], ACTIONS.PICKUP, nil, nil, nil, nil, player.__k) -- i store action key in theplayer.__k, just.. just
						buffaction.preview_cb = function()
						    fns.SendRPC(RPC.LeftClick, ACTIONS.PICKUP.code, x1, z1, _inventoryitems[j], true, nil, nil, player.__k)
						end
						buffaction.action_key = player.__k
						player.components.playercontroller:DoAction(buffaction)
						return
					else
					    fns.SendRPC(RPC.LeftClick, ACTIONS.PICKUP.code, x1, z1, _inventoryitems[j], true, nil, nil, ThePlayer.__k)
						return
					end
				end
			end
		end,
	},
	drop = {
		fn = function(params)

		end,
	},
	castaoe = {
		fn = function(params)

		end,
	},
	gotopos = {
		fn = function(params)

		end,
	},
	revive = {
		fn = function(params)

		end,
	},
	query = { -- query the chat
		fn = function(params)
            -- TheNet:Say(params.message, params.whisperer) ??? | on a second thought i don't think i'll be using this nor really comunicate with chat at all
		end,
	},
	goindirection = { -- welcome the newcomer, he's probably stuck in here now...
		fn = function(params)

		end
	}
	gotosector = { -- this one too, will be eliminated i think
		fn = function(params)

		end,
		sequence = {'gotopos'},
	},
	haul = { -- and this
		fn = function(params)
		
		end,
		sequence = {'pickup', 'gotosector', 'drop'},
	},
	dodge = { --  prettu much all complex actions
		fn = function(params)

		end,
		sequence = {'gotopos', 'gotopos', 'gotopos'},
	},
	cancel = { -- yeah you too
		fn = function(params)

		end,
		sequence = {'attack', 'castaoe'},
	},
}
