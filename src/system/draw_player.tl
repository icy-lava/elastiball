local record Target
	pos: vec2
end

local record Entity
	pos: vec2
	aim: vec2
	target: Target
end

local system: tiny.System<Entity> = util.drawSystem()

system.filter = tiny.requireAll('pos', 'aim', 'player')

function system:preProcess(_: number)
	love.graphics.push 'all'
	love.graphics.setColor(1, 1, 1, 1)
end

function system:process(entity: Entity, _: number)
	local pos = entity.pos
	
	-- Reticle
	local aim = entity.aim * 100 + pos
	local col = color.player
	love.graphics.setColor(col[1], col[2], col[3], 0.5)
	love.graphics.circle('fill', aim.x, aim.y, 12, 32)
	
	-- Body
	love.graphics.setColor(color.player)
	love.graphics.circle('fill', pos.x, pos.y, 24, 32)
	
	-- Target indicator
	if entity.target then
		local tpos = entity.target.pos
		love.graphics.setColor(col[1], col[2], col[3], 0.5)
		love.graphics.setLineWidth(3)
		love.graphics.circle('line', tpos.x, tpos.y, 32, 32)
	end
end

function system:postProcess(_: number)
	love.graphics.pop()
end

return system