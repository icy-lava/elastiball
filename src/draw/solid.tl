return function(entity: typedef.FullEntity)
	love.graphics.setColor(color.solid)
	util.roundedPoly(config.solid.cornerRadius, entity.polygon)
end