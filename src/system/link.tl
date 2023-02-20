local record Object
	lastDT: number
	pos: vec2
	lastPos: vec2
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
	
	local mulA, mulB = 1.0, 1.0
	if a.lastPos then
		if not b.lastPos then
			mulA, mulB = 2, 0
		end
	else
		if b.lastPos then
			mulA, mulB = 0, 2
		else
			mulA, mulB = 0, 0
		end
	end
	
	local newAPos = a.pos + normal * halfError * mulA
	local newBPos = b.pos - normal * halfError * mulB
	
	local smooth = 0.8
	a.pos = util.damp(smooth, dt, a.pos, newAPos)
	b.pos = util.damp(smooth, dt, b.pos, newBPos)
	-- a.pos = newAPos
	-- b.pos = newBPos
end

return system