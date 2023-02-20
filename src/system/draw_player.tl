local record Entity
	pos: vec2
end

local system: tiny.System<Entity> = util.drawSystem()

system.filter = tiny.requireAll('pos', 'player')

function system:preProcess(_: number)
	love.graphics.push 'all'
	love.graphics.setColor(1, 1, 1, 1)
end

function system:process(entity: Entity, _: number)
	local pos = entity.pos
	love.graphics.setColor(color.player)
	love.graphics.circle('fill', pos.x, pos.y, 24, 32)
end

function system:postProcess(_: number)
	love.graphics.pop()
end

return system