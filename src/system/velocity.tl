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
	entity.lastDT = entity.lastDT or dt
	local dpos = entity.pos - entity.lastPos
	
	if entity.lastDT == 0 or dpos == vec2() then return end
	
	entity.lastPos = entity.pos
	entity.pos = entity.pos + dpos * dt / entity.lastDT
	entity.lastDT = dt
end

return system