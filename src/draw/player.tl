return function(entity: typedef.FullEntity)
	local pos = entity.pos
	local opacity = entity.opacity or 1
	local scale = entity.scale or 1

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