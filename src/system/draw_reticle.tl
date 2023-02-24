local system = util.drawSystem(typedef.AimEntity)

function system:preProcess(_: number)
	love.graphics.push 'all'
	love.graphics.setColor(1, 1, 1, 1)
end

function system:process(entity: typedef.AimEntity, _: number)
	local pos = entity.pos
	local opacity = entity.opacity or 1
	
	-- Reticle
	local aim = entity.aim * config.reticle.distance + pos
	love.graphics.setColor(color.withAlpha(color.player, opacity * 0.5))
	love.graphics.circle('fill', aim.x, aim.y, config.reticle.radius, 32)
end

function system:postProcess(_: number)
	love.graphics.pop()
end

return system