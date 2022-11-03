local fns = require('autof_functions')

local tasks = {
	attack = {
		fn = function(params)

		end,
	},
	pickup = {
		fn = function(params)
			 -- player? | i just use ThePlayer since it'a a client mod 
			local x, y, z = ThePlayer.Transform:GetWorldPosition()
			local _inventoryitems = TheSim:FindEntities(x, y, z, params.range or 20, {"_inventoryitem"})
			for j = 1, #_inventoryitems do
			    if _inventoryitems[j].prefab == params.item then
				    local x1, y1, z1 = _inventoryitems[j].Transform:GetWorldPosition()
					if ThePlayer.components.playercontroller.locomotor ~= nil then
					    local buffaction = BufferedAction(ThePlayer, _inventoryitems[j], ACTIONS.PICKUP, nil, nil, nil, nil, ThePlayer.__k) -- i store action key in theplayer.__k, just.. just
						buffaction.preview_cb = function()
						    fns.SendRPC(RPC.LeftClick, ACTIONS.PICKUP.code, x1, z1, _inventoryitems[j], true, nil, nil, ThePlayer.__k)
						end
						buffaction.action_key = ThePlayer.__k
						ThePlayer.components.playercontroller:DoAction(buffaction)
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