local record Entity
	lastPos: vec2
	pos: vec2
end

local system: tiny.System<Entity> = tiny.processingSystem()

-- system.interval = FRAME_TIME * 4

system.filter = tiny.requireAll(
	filter.vector 'pos',
	filter.vector 'lastPos'
)

function system:process(entity: Entity, _: number)
	entity.pos, entity.lastPos = entity.pos * 2 - entity.lastPos, entity.pos
end

return system