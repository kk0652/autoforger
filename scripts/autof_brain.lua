local Brain = {}

local behaviors = require('autof_behaviors')

function Brain:Initialize()
	Brain.owner = ThePlayer
	Brain.team = {}
	Brain.mobs = {}
	Brain.settings = {}
	Brain.role = ''
	Brain.consecutiveFailedTask = {name = '', n = 0}
	Brain.expectedWave = {}
	Brain.light = 'no'
	Brain.expectedLights = {}
end

function Brain:SetBehavior(behavior)
    
end

function Brain:NextTask()

end

function Brain:EvaluateYourActions()
	-- the hardest part probably


end

