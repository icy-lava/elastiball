local record Entity
	pos: vec2
	pinned: boolean
end

local system: tiny.System<Entity> = util.drawSystem()

system.filter = tiny.requireAll('pos', 'pinned')

function system:preProcess(_: number)
	love.graphics.push 'all'
	love.graphics.setLineWidth(6)
	love.graphics.setColor(1, 1, 1, 1)
end

function system:process(entity: Entity, _: number)
	local pos = entity.pos
	love.graphics.setColor(color.point)
	love.graphics.circle('line', pos.x, pos.y, 20, 32)
	if entity.pinned then
		love.graphics.circle('fill', pos.x, pos.y, 10, 32)
	end
end

function system:postProcess(_: number)
	love.graphics.pop()
end

return system