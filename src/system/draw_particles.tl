local system = util.drawSystem(typedef.ParticleSystemEntity)

local profile: AppleCake.Profile
function system:preProcess(_: number)
	profile = appleCake.profile('system.draw_particles', nil, profile)
	love.graphics.push 'all'
end

function system:process(entity: typedef.ParticleSystemEntity, _: number)
	if config.particle.enabled then
		for _, ps in ipairs(entity.particles) do
			love.graphics.setColor(1, 1, 1, entity.opacity or 1)
			love.graphics.draw(ps as love.graphics.Drawable)
		end
	end
end

function system:postProcess(_: number)
	love.graphics.pop()
	profile:stop()
end

return system