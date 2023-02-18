local record Entity
	pos: vec2
end

local system: tiny.System<Entity> = util.drawSystem()

system.filter = tiny.requireAll(
	filter.vector 'pos'
)

function system:process(entity: Entity, _: number)
	local pos = entity.pos
	love.graphics.circle('line', pos.x, pos.y, 10)
end

return system