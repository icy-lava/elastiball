local system = util.processingSystem(typedef.GravityEntity)

function system:process(entity: typedef.GravityEntity, dt: number)
	if not entity.pinned then
		entity.pos = entity.pos + GRAVITY * dt ^ 2
	end
end

return system