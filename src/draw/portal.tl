return function(entity: typedef.FullEntity)
	love.graphics.setColor(color.exit)
	-- love.graphics.circle('fill', entity.pos.x, entity.pos.y, config.exit.radius * 0.5)
	local faded: love.graphics.Image = asset.alpha_image.faded
	local scale = config.particle.scaleToUnit * config.exit.radius * 2 * 1.25
	local ox, oy = (faded as love.graphics.Texture):getDimensions()
	ox, oy = ox / 2, oy / 2
	for i = 1, 2 do
		love.graphics.draw(faded as love.graphics.Drawable, entity.pos.x, entity.pos.y, 0, scale / i, scale / i, ox, oy)
	end
end