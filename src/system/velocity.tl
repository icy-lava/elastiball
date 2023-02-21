local record Entity
	lastPos: vec2
	pos: vec2
	pinned: boolean
end

local system: tiny.System<Entity> = tiny.processingSystem()

system.filter = tiny.requireAll('pos', 'lastPos')

function system:process(entity: Entity, _: number)
	if not entity.pinned then
		entity.pos, entity.lastPos = entity.pos * 2 - entity.lastPos, entity.pos
	end
end

return system