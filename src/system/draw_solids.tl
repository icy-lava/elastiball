local system = util.drawSystem(typedef.SolidsEntity)

function system:preProcess(_: number)
	love.graphics.push 'all'
	love.graphics.setColor(1, 1, 1, 1)
end

function system:process(entity: typedef.SolidsEntity, _: number)
	for _, solid in ipairs(entity.solids) do
		love.graphics.setColor(color.solid)
		solid:draw('fill')
	end
end

function system:postProcess(_: number)
	love.graphics.pop()
end

return system