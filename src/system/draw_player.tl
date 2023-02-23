local system = util.drawSystem(typedef.DrawnPlayerEntity)

function system:preProcess(_: number)
	love.graphics.push 'all'
	love.graphics.setColor(1, 1, 1, 1)
end

function system:process(entity: typedef.DrawnPlayerEntity, _: number)
	local pos = entity.pos
	local opacity = entity.opacity or 1
	local scale = entity.scale or 1
	
	-- Reticle
	local aim = entity.aim * config.player.reticle.distance + pos
	love.graphics.setColor(color.withAlpha(color.player, opacity * 0.5))
	love.graphics.circle('fill', aim.x, aim.y, config.player.reticle.radius * scale, 32)
	
	-- Body
	love.graphics.setColor(color.withAlpha(color.lerp(entity.heat, color.player, color.hot), opacity))
	love.graphics.circle('fill', pos.x, pos.y, config.player.body.radius * scale, 64)
	
	-- Target indicator
	if entity.target then
		local tpos = entity.target.pos
		love.graphics.setColor(color.withAlpha(color.player, opacity * 0.5))
		love.graphics.setLineWidth(3)
		love.graphics.circle('line', tpos.x, tpos.y, 32 --[[ * scale]], 32)
	end
end

function system:postProcess(_: number)
	love.graphics.pop()
end

return system