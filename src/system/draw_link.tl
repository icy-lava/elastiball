local system = util.drawSystem(typedef.LinkEntity)

function system:preProcess(_: number)
	love.graphics.push 'all'
	love.graphics.setColor(1, 1, 1, 1)
end

function system:process(entity: typedef.LinkEntity, _: number)
	local apos, bpos = entity.linkA.pos, entity.linkB.pos
	local delta = (bpos - apos).normalized
	apos = apos + delta * 20
	bpos = bpos - delta * 20
	love.graphics.setColor(color.link)
	
	local errLen = -(entity.error or 0) / 50
	local thiccnessMult = 2 ^ math.atan(errLen)
	
	love.graphics.setLineWidth(8 * thiccnessMult)
	love.graphics.line(apos.x, apos.y, bpos.x, bpos.y)
end

function system:postProcess(_: number)
	love.graphics.pop()
end

return system