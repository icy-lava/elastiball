local system = util.drawSystem(typedef.ParticleSystemEntity)

function system:preProcess(_: number)
	love.graphics.push 'all'
	love.graphics.setColor(1, 1, 1, 1)
end

function system:process(entity: typedef.ParticleSystemEntity, _: number)
	for _, ps in ipairs(entity.particles) do
		love.graphics.draw(ps as love.graphics.Drawable)
	end
end

function system:postProcess(_: number)
	love.graphics.pop()
end

return system