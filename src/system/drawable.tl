local system = util.sortedDrawSystem(typedef.DrawableEntity)

function system:compare(a: typedef.DrawableEntity, b: typedef.DrawableEntity): boolean
	local la, lb = a.layer or 0, b.layer or 0
	return la < lb
end

function system:preProcess(_: number)
	love.graphics.push 'all'
end

function system:process(entity: typedef.DrawableEntity, _: number)
	local pos = entity.pos or vec2()
	local opacity = entity.opacity or 1
	local scale = entity.scale or 1
	for _, drawable in ipairs(entity.drawables) do
		love.graphics.setColor(1, 1, 1, opacity)
		if drawable is function(typedef.FullEntity) then
			drawable(entity as typedef.FullEntity)
		else
			local ox, oy = 0.0, 0.0
			if (drawable as love.Object):typeOf('Texture') then
				local texture = drawable as love.graphics.Texture
				ox, oy = texture:getDimensions()
				ox, oy = ox / 2, oy / 2
			end
			love.graphics.draw(drawable, pos.x, pos.y, 0, scale, scale, ox, oy)
		end
	end
end

function system:postProcess(_: number)
	love.graphics.pop()
end

return system