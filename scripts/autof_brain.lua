local Brain = {}

local sensors = require'autof_sensors'

function Brain:Initialize(plr)
	
end

function Brain:SetBehavior(behavior)
    
end

function Brain:NextTask()

end

function Brain:ActionReport(params) -- functions from different module(s) will intercept rpcs and actionbuttons usages and report them to brain, so it would know what exactly you did
	Brain.manual_action = params.action

end
