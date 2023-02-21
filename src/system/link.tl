local system = util.processingSystem(typedef.LinkEntity)

function system:process(entity: typedef.LinkEntity, dt: number)
	local a, b = entity.linkA, entity.linkB
	local dpos = b.pos - a.pos
	local ddist = dpos.length
	local normal = dpos / ddist
	entity.error = ddist - entity.distance
	
	local inf = 1 / 0
	local massA = a.pinned and inf or a.mass or 1
	local massB = b.pinned and inf or b.mass or 1
	local massTotal = massA + massB
	
	local mulA, mulB = massB / massTotal, massA / massTotal
	if massA == inf then
		if massB == inf then
			return
		end
		mulA, mulB = 0, 1
	elseif massB == inf then
		mulA, mulB = 1, 0
	end
	
	local strength = 5000.0
	if entity.error < 0 then
		strength = strength * (entity.inStrength or 0.5)
	else
		strength = strength * (entity.outStrength or 1)
	end
	
	local newAPos = a.pos + normal * entity.error * mulA * dt ^ 2 * strength
	local newBPos = b.pos - normal * entity.error * mulB * dt ^ 2 * strength
	
	a.pos = newAPos
	b.pos = newBPos
end

return system