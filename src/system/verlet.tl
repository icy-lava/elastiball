local system = util.processingSystem(typedef.VerletEntity)

local attractorSystem: tiny.System<typedef.AttractorEntity> = require 'system.attractor'
local solidsSystem: tiny.System<typedef.SolidsEntity> = require 'system.solids'

local profile: AppleCake.Profile
function system:preProcess(_: number)
	profile = appleCake.profile('system.verlet', nil, profile)
end

function system:process(entity: typedef.VerletEntity, dt: number)
	if not entity.pinned then
		entity.pos, entity.lastPos = entity.pos * 2 - entity.lastPos, entity.pos
		
		local attractors = util.findSystemInstance(self.world.systems, attractorSystem).entities
		for _, attractor in ipairs(attractors) do
			local attr = attractor.attraction
			local delta = (attractor.pos - entity.pos)
			local dist2 = delta.length2
			local dist = dist2 ^ 0.5
			local normal = delta / dist
			if not attr.distMax or (dist2 < attr.distMax ^ 2) then
				-- FIXME: this doesn't take delta time into account
				local force = 1 / (1 + math.max((attr.distMin or 100) ^ 2, dist2)) * attr.force
				entity.pos = entity.pos + normal * force
			end
		end
		
		-- TODO: this might be different per entity
		local radius = config.point.radius
		
		local solidsEntityArray = util.findSystemInstance(self.world.systems, solidsSystem).entities
		for _, solidsEntity in ipairs(solidsEntityArray) do
			for _, shape in ipairs(solidsEntity.solids) do
				local circle = shapes.newCircleShape(entity.pos.x, entity.pos.y, radius)
				local collides, dx, dy = shape:collidesWith(circle)
				if collides then
					local delta = vec2(-dx, -dy)
					local vel = entity.pos - entity.lastPos
					-- vel = util.reflect(vel, -delta.normalized) * 0.9
					entity.pos = entity.pos + delta * (dt ^ 2 * 5000) - vel * (dt ^ 2 * 100)
					-- entity.lastPos = entity.pos - vel
				end
			end
		end
	end
end

function system:postProcess(_: number)
	profile:stop()
end

return system