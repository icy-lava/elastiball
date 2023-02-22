local system = util.processingSystem(typedef.LevelEndEntity)

local playerSystem = require 'system.player'

function system:process(entity: typedef.LevelEndEntity, dt: number)
	local player: typedef.InputEntity
	for _, sys in ipairs(self.world.systems) do
		if sys.filter == playerSystem.filter then
			assert(#sys.entities == 1)
			player = sys.entities[1] as typedef.InputEntity
		end
	end
	
	if (player.pos - entity.pos).length < config.exit.radius then
		entity.endSignal:emit()
	end
end

return system