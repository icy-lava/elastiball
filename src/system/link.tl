local record Object
	lastDT: number
	lastPos: vec2
	pos: vec2
end

local record Entity
	linkA: Object
	linkB: Object
	distance: number
end

local system: tiny.System<Entity> = tiny.processingSystem()

system.filter = tiny.requireAll('linkA', 'linkB', 'distance')

function system:process(entity: Entity, dt: number)
	local a, b = entity.linkA, entity.linkB
	local dpos = b.pos - a.pos
	local ddist = dpos.length
	local normal = dpos / ddist
	local halfError = (ddist - entity.distance) / 2
	
	local newAPos = a.pos + normal * halfError
	local newBPos = b.pos - normal * halfError
	
	local smooth = 0.001
	a.pos = util.damp(smooth, dt, a.pos, newAPos)
	b.pos = util.damp(smooth, dt, b.pos, newBPos)
end

return system