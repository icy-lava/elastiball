return function(entity: typedef.FullEntity)
	if not entity.aim then return end
	local pos = entity.pos
	local opacity = entity.opacity or 1

	local aim = entity.aim * config.reticle.distance + pos
	love.graphics.setColor(color.withAlpha(color.reticle, opacity * 0.5))
	love.graphics.circle('fill', aim.x, aim.y, config.reticle.radius, 32)
end