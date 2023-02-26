local system = util.processingSystem(typedef.ParticleSystemEntity)

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
		end
	end
end

return system