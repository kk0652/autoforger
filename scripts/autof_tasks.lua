local fns = require('autof_functions')

local tasks = {
	attack = {
		fn = function(params)

		end,
	},
	pickup = {
		fn = function(params)
			local player = params.requester -- player?
			local x, y, z = player.Transform:GetWorldPosition()
			local _inventoryitems = TheSim:FindEntities(x, y, z, params.range or 20, {"_inventoryitem"})
			for j = 1, #_inventoryitems do
			    if _inventoryitems[j].prefab == params.item then
				    local x1, y1, z1 = _inventoryitems[j].Transform:GetWorldPosition()
					if player.components.playercontroller.locomotor ~= nil then
					    local buffaction = BufferedAction(player, _inventoryitems[j], ACTIONS.PICKUP, nil, nil, nil, nil, params.action_key)
						buffaction.preview_cb = function()
						    fns.SendRPC(RPC.LeftClick, ACTIONS.PICKUP.code, x1, z1, _inventoryitems[j], true, nil, nil, params.action_key)
						end
						buffaction.action_key = params.action_key
						player.components.playercontroller:DoAction(buffaction)
						return
					else
					    fns.SendRPC(RPC.LeftClick, ACTIONS.PICKUP.code, x1, z1, _inventoryitems[j], true, nil, nil, params.action_key)
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
            -- TheNet:Say(params.message, params.whisperer) ???
		end,
	},
	gotosector = {
		fn = function(params)

		end,
		sequence = {'gotopos'},
	},
	haul = {
		fn = function(params)
		
		end,
		sequence = {'pickup', 'gotosector', 'drop'},
	},
	dodge = {
		fn = function(params)

		end,
		sequence = {'gotopos', 'gotopos', 'gotopos'},
	},
	cancel = {
		fn = function(params)

		end,
		sequence = {'attack', 'castaoe'},
	},
}