local system = util.processingSystem(typedef.LevelEndEntity)

function system:process(entity: typedef.LevelEndEntity, _: number)
	local player = util.findPlayer(self.world.entities)
	if player then
		if ((player.pos - entity.pos).length < entity.trigger.radius) == (not entity.trigger.inverse) then
			entity.trigger.signal:emit()
		end
	end
end

return system