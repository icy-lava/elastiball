local system = util.drawSystem(typedef.PointEntity)

function system:preProcess(_: number)
	love.graphics.push 'all'
	love.graphics.setLineWidth(config.point.lineWidth)
	love.graphics.setColor(1, 1, 1, 1)
end

function system:process(entity: typedef.PointEntity, _: number)
	local pos = entity.pos
	love.graphics.setColor(color.point)
	love.graphics.circle('line', pos.x, pos.y, config.point.radius, 32)
	if entity.pinned then
		love.graphics.circle('fill', pos.x, pos.y, config.point.pinRadius, 32)
	end
end

function system:postProcess(_: number)
	love.graphics.pop()
end

return system