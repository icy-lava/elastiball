local record Target
	pos: vec2
end

local record Entity
	pos: vec2
	lastPos: vec2
	aim: vec2
	heat: number
	target: Target
end

local system: tiny.System<Entity> = util.drawSystem()

system.filter = tiny.requireAll('pos', 'lastPos', 'aim', 'player')

function system:preProcess(_: number)
	love.graphics.push 'all'
	love.graphics.setColor(1, 1, 1, 1)
end

function system:process(entity: Entity, _: number)
	local pos = entity.pos
	
	-- Reticle
	local aim = entity.aim * config.player.reticle.distance + pos
	love.graphics.setColor(color.withAlpha(color.player, 0.5))
	love.graphics.circle('fill', aim.x, aim.y, config.player.reticle.radius, 32)
	
	-- Body
	love.graphics.setColor(color.lerp(entity.heat, color.player, color.hot))
	
	local pcount: integer = 128
	local vel = (entity.pos - entity.lastPos) / FRAME_TIME
	local mag = vel.length
	if mag > 0 then
		local normal = vel / mag
		local angleOffset = normal.angle
		
		-- love.graphics.push()
		local points: {number} = {}
		for i = 0, pcount - 1 do
			local lerp = i / pcount
			local angle = lerp * math.pi * 2
			local pnormal = vec2(math.cos(angle + angleOffset), math.sin(angle + angleOffset))
			local dot = -pnormal:dot(normal)
			if dot < 0 then
				dot = 0
			end
			local offset = util.lerp(dot ^ 2, 0.0, mag / 50)
			local point = pnormal * config.player.body.radius - normal * offset
			points[i * 2 + 1] = point.x + entity.pos.x
			points[i * 2 + 2] = point.y + entity.pos.y
		end
		love.graphics.polygon('fill', points)
	else
		love.graphics.circle('fill', pos.x, pos.y, config.player.body.radius, pcount)
	end
	
	-- Target indicator
	if entity.target then
		local tpos = entity.target.pos
		love.graphics.setColor(color.withAlpha(color.player, 0.5))
		love.graphics.setLineWidth(3)
		love.graphics.circle('line', tpos.x, tpos.y, 32, 32)
	end
end

function system:postProcess(_: number)
	love.graphics.pop()
end

return system