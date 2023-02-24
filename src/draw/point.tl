return function(entity: typedef.FullEntity)
	love.graphics.setLineWidth(config.point.lineWidth)
	local pos = entity.pos
	love.graphics.setColor(color.point)
	love.graphics.circle('line', pos.x, pos.y, config.point.radius, 32)
	if entity.pinned then
		love.graphics.circle('fill', pos.x, pos.y, config.point.pinRadius, 32)
	end
end