local system = util.processingSystem(typedef.VerletEntity)

local attractorSystem: tiny.System<typedef.AttractorEntity> = require 'system.attractor'

function system:process(entity: typedef.VerletEntity, _: number)
	if not entity.pinned then
		entity.pos, entity.lastPos = entity.pos * 2 - entity.lastPos, entity.pos
		
		local attractors = util.findSystemInstance(self.world.systems, attractorSystem).entities
		for _, attr in ipairs(attractors) do
			local delta = (attr.pos - entity.pos)
			local dist2 = delta.length2
			if not attr.attractionMaxDist or dist2 < attr.attractionMaxDist ^ 2 then
				local force = 1 / (1 + math.max((attr.attractionMinDist or 100) ^ 2, dist2)) * attr.attraction
				entity.pos = entity.pos + delta.normalized * force
			end
		end
	end
end

return system