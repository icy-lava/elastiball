local system = util.drawSystem(typedef.LinkEntity)

function system:preProcess(_: number)
	love.graphics.push 'all'
	love.graphics.setColor(1, 1, 1, 1)
end

function system:process(entity: typedef.LinkEntity, _: number)
	local link = entity.link
	local apos, bpos = link.a.pos, link.b.pos
	local delta = (bpos - apos).normalized
	apos = apos + delta * config.point.radius
	bpos = bpos - delta * config.point.radius
	love.graphics.setColor(color.link)
	
	local errLen = -(link.error or 0) / 50
	local thiccnessMult = 2 ^ math.atan(errLen)
	
	love.graphics.setLineWidth(config.link.lineWidth * thiccnessMult)
	love.graphics.line(apos.x, apos.y, bpos.x, bpos.y)
end

function system:postProcess(_: number)
	love.graphics.pop()
end

return system