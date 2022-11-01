local Tasks = {}

local fns = require'autof_functions'

attack = {
	fn = function(params)

	end
}

pickup = {
	fn = function(params)

	end
}

drop = {
	fn = function(params)

	end
}

castaoe = {
	fn = function(params)

	end
}

gotopos = {
	fn = function(params)

	end
}

revive = {
	fn = function(params)

	end
}

query = { -- query the chat
	fn = function(params)

	end
}

gotosector = {
	fn = function(params)

	end,
	sequence = {"gotopos"}
}

haul = {
	fn = function(params)
	
	end,
	sequence = {"pickup", "gotosector", "drop"}
}

dodge = {
	fn = function(params)

	end,
	sequence = {"gotopos","gotopos","gotopos"}
}

cancel = {
	fn = function(params)

	end,
	sequence = {"attack", "castaoe"}
}
