local record Entity
	pos: vec2
	lastPos: vec2
	input: baton.Player
	aim: vec2
end

local system: tiny.System<Entity> = tiny.processingSystem()

system.filter = tiny.requireAll('pos', 'lastPos', 'input', 'aim')

function system:process(entity: Entity, dt: number)
	entity.input:update()
	entity.pos = entity.pos + vec2(entity.input:get 'move') * dt ^ 2 * 600
	
	if util.mouseRel.length >= 5 then
		entity.input._activeDevice = 'kbm'
	end
	if entity.input:getActiveDevice() == 'joy' then
		entity.aim = vec2(entity.input:get('aim'))
	else
		entity.aim = entity.aim + util.mouseRel * 0.01
		if entity.aim.length2 > 1 then
			entity.aim.length = 1
		end
	end
end

return system