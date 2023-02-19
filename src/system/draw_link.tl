local record Object
	pos: vec2
end

local record Entity
	linkA: Object
	linkB: Object
	distance: number
end

local system: tiny.System<Entity> = util.drawSystem()

system.filter = tiny.requireAll('linkA', 'linkB', 'distance')

function system:preProcess(_: number)
	love.graphics.push 'all'
	love.graphics.setLineWidth(3)
end

function system:process(entity: Entity, _: number)
	local apos, bpos = entity.linkA.pos, entity.linkB.pos
	love.graphics.line(apos.x, apos.y, bpos.x, bpos.y)
end

function system:postProcess(_: number)
	love.graphics.pop()
end

return system