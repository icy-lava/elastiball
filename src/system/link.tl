local system = util.processingSystem(typedef.LinkEntity)

local profile: AppleCake.Profile
function system:preProcess(_: number)
	profile = appleCake.profile('system.link', nil, profile)
end

function system:process(entity: typedef.LinkEntity, dt: number)
	local link = entity.link
	
	-- FIXME: IDK why it sometimes keeps the player entity in this system when the link gets set to nil
	if not link then
		return
	end
	
	local a, b = link.a, link.b
	local dpos = b.pos - a.pos
	local ddist = dpos.length
	local normal = dpos / ddist
	link.error = ddist - link.distance
	
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
	
	local strength = 3000.0
	if link.error < 0 then
		strength = strength * (link.strengthIn or 0.5)
	else
		strength = strength * (link.strengthOut or 1)
	end
	
	local newAPos = a.pos + normal * link.error * mulA * dt ^ 2 * strength
	local newBPos = b.pos - normal * link.error * mulB * dt ^ 2 * strength
	
	a.pos = newAPos
	b.pos = newBPos
end

function system:postProcess(_: number)
	profile:stop()
end

return system