local system = util.processingSystem(typedef.TriggerEntity)

local profile: AppleCake.Profile
function system:preProcess(_: number)
	profile = appleCake.profile('system.trigger', nil, profile)
end

function system:process(entity: typedef.TriggerEntity, _: number)
	local player = util.findPlayer(self.world.entities)
	if player then
		if ((player.pos - entity.pos).length < entity.trigger.radius) == (not entity.trigger.inverse) then
			entity.trigger.signal:emit()
		end
	end
end

function system:postProcess(_: number)
	profile:stop()
end

return system