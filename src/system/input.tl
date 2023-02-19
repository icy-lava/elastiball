local record Entity
	pos: vec2
	-- lastPos: vec2
	input: baton.Player
end

local system: tiny.System<Entity> = tiny.processingSystem()

system.filter = tiny.requireAll(
	'pos',
	-- 'lastPos',
	'input'
)

function system:process(entity: Entity, dt: number)
	entity.input:update()
	entity.pos = entity.pos + vec2(entity.input:get 'move') * dt ^ 2 * 200
end

return system