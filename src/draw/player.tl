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
		love.graphics.setColor(color.withAlpha(color.target, opacity * 0.75))
		love.graphics.setLineWidth(5)
		love.graphics.circle('line', tpos.x, tpos.y, 36 --[[ * scale]], 32)
		local scale = config.particle.scaleToUnit * 64 * 2
		love.graphics.setColor(color.withAlpha(color.target, opacity * 0.5))
		util.drawCentered(asset.alpha_image.faded as love.graphics.Drawable, tpos.x, tpos.y, 0, scale, scale)
	end
end