return function(entity: typedef.FullEntity)
	local width = config.point.lineWidth
	local radius = config.point.radius
	love.graphics.setLineWidth(width)
	local pos = entity.pos
	
	if entity.grabable == false then
		local offset = vec2(radius * 2, radius * 2)
		love.graphics.stencil(function()
			do
				local p1, p2 = pos - offset, pos + offset
				love.graphics.line(p1.x, p1.y, p2.x, p2.y)
			end
			offset = util.perpendicular(offset)
			do
				local p1, p2 = pos - offset, pos + offset
				love.graphics.line(p1.x, p1.y, p2.x, p2.y)
			end
		end)
		
		love.graphics.setStencilTest('equal', 0)
	end
	
	local col = (entity.grabable ~= false) and color.point or color.ungrabable
	love.graphics.setColor(col)
	love.graphics.circle('line', pos.x, pos.y, radius, 32)
	if entity.pinned then
		love.graphics.circle('fill', pos.x, pos.y, config.point.pinRadius, 32)
	end
	
	love.graphics.setStencilTest()
end