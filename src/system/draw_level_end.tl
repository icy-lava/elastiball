local system = util.drawSystem(typedef.LevelEndEntity)

function system:preProcess(_: number)
	love.graphics.push 'all'
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setLineWidth(3)
end

function system:process(entity: typedef.LevelEndEntity, _: number)
	love.graphics.setColor(color.exit)
	love.graphics.circle('line', entity.pos.x, entity.pos.y, config.exit.radius)
end

function system:postProcess(_: number)
	love.graphics.pop()
end

return system