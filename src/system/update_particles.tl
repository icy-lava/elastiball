local system = util.processingSystem(typedef.ParticleSystemEntity)

function system:process(entity: typedef.ParticleSystemEntity, dt: number)
	local pos = entity.pos or vec2()
	for _, ps in ipairs(entity.particles) do
		ps:moveTo(pos.x, pos.y)
		ps:update(dt)
	end
end

return system