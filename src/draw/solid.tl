return function(entity: typedef.FullEntity)
	love.graphics.setColor(color.solid)
	love.graphics.polygon('fill', entity.polygon)
end