local system = util.processingSystem(typedef.VelocityEntity)

function system:process(entity: typedef.VelocityEntity, _: number)
	if not entity.pinned then
		entity.pos, entity.lastPos = entity.pos * 2 - entity.lastPos, entity.pos
	end
end

return system