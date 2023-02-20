local record Entity
	pos: vec2
end

local system: tiny.System<Entity> = util.drawSystem()

system.filter = tiny.requireAll(filter.vector 'pos', tiny.rejectAny(filter.has 'player'))

function system:preProcess(_: number)
	love.graphics.push 'all'
	love.graphics.setLineWidth(3)
end

function system:process(entity: Entity, _: number)
	local pos = entity.pos
	love.graphics.circle('line', pos.x, pos.y, 10, 16)
end

function system:postProcess(_: number)
	love.graphics.pop()
end

return system