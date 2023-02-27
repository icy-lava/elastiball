local system = util.processingSystem(typedef.GravityEntity)

local profile: AppleCake.Profile
function system:preProcess(_: number)
	profile = appleCake.profile('system.gravity', nil, profile)
end

function system:process(entity: typedef.GravityEntity, dt: number)
	if not entity.pinned then
		entity.pos = entity.pos + GRAVITY * dt ^ 2
	end
end

function system:postProcess(_: number)
	profile:stop()
end

return system