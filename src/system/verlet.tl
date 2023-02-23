local system = util.processingSystem(typedef.VerletEntity)

local attractorSystem: tiny.System<typedef.AttractorEntity> = require 'system.attractor'

function system:process(entity: typedef.VerletEntity, _: number)
	if not entity.pinned then
		entity.pos, entity.lastPos = entity.pos * 2 - entity.lastPos, entity.pos
		
		local attractors = util.findSystemInstance(self.world.systems, attractorSystem).entities
		for _, attractor in ipairs(attractors) do
			local attr = attractor.attraction
			local delta = (attractor.pos - entity.pos)
			local dist2 = delta.length2
			if not attr.distMax or dist2 < attr.distMin ^ 2 then
				-- FIXME: this doesn't take delta time into account
				local force = 1 / (1 + math.max((attr.distMin or 100) ^ 2, dist2)) * attr.force
				entity.pos = entity.pos + delta.normalized * force
			end
		end
	end
end

return system