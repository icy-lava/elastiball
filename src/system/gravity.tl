local record Entity
	lastDT: number
	lastPos: vec2
	pos: vec2
end

local system: tiny.System<Entity> = tiny.processingSystem()

system.filter = tiny.requireAll(
	filter.vector 'lastPos',
	filter.vector 'pos',
	filter.typeOrNil('lastDT', 'number')
)

function system:process(entity: Entity, dt: number)
	entity.pos = entity.pos + GRAVITY * dt * dt
end

return system