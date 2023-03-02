local system = util.processingSystem(typedef.ParticleSystemEntity)

local profile: AppleCake.Profile
local particleCount: integer
local counter: AppleCake.Counter
function system:preProcess(_: number)
	particleCount = 0
	profile = appleCake.profile('system.update_particles', nil, profile)
end

function system:process(entity: typedef.ParticleSystemEntity, dt: number)
	if config.particle.enabled then
		local pos = entity.pos or vec2()
		for _, ps in ipairs(entity.particles) do
			if entity.velocityEmission then
				local vel = entity.pos - entity.lastPos
				local speed = vel.length
				ps:setEmissionRate(speed / dt * entity.velocityEmission)
			end
			ps:moveTo(pos.x, pos.y)
			ps:update(dt)
			particleCount = particleCount + ps:getCount() as integer
		end
	end
end

function system:postProcess(_: number)
	appleCake.counter('particle-count', {total = particleCount}, counter)
end

util.makeSystemProfiled(system, 'system.update_particles')

return system