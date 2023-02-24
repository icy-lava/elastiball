local record Over
	__index: Over
end
Over.__index = Over

function Over.new(): Over
	return setmetatable({}, Over)
end

function Over:draw()
	love.graphics.clear(0, 0, 0, 1)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print('game over')
end

return Over