local system = util.sortedDrawSystem(typedef.DrawableEntity)

function system:compare(a: typedef.DrawableEntity, b: typedef.DrawableEntity): boolean
	local la, lb = a.layer or 0, b.layer or 0
	return la < lb
end

local profile: AppleCake.Profile
function system:preProcess(_: number)
	profile = appleCake.profile('system.drawable', nil, profile)
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
			util.drawCentered(drawable, pos.x, pos.y, 0, scale, scale)
		end
	end
end

function system:postProcess(_: number)
	love.graphics.pop()
	profile:stop()
end

return system