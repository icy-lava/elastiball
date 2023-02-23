local system = util.processingSystem(typedef.InputEntity)
local pointSystem = require 'system.point'

function system:process(entity: typedef.InputEntity, dt: number)
	entity.input:update()
	entity.pos = entity.pos + vec2(entity.input:get 'move') * dt ^ 2 * 100
	
	if util.mouseRel.length >= 5 then
		entity.input._activeDevice = 'kbm'
	end
	if entity.input:getActiveDevice() == 'joy' then
		entity.aim = vec2(entity.input:get('aim'))
	else
		entity.aim = entity.aim + util.mouseRel * config.mouse.baseSensitivity
		entity.aim.length = math.min(entity.aim.length, 1)
	end
	
	if entity.input:down 'boost' then
		entity.heat = math.min(entity.heat + dt / config.player.heat.up, 1)
	else
		entity.heat = math.max(entity.heat - dt / config.player.heat.down, 0)
	end
	local vnormal = (entity.pos - entity.lastPos).normalized
	entity.pos = entity.pos + vnormal * dt ^ 2 * 100 * entity.heat
	
	if not entity.link then
		local target: entity.target
		if entity.aim.length >= 0.3 then
			local naim = entity.aim.normalized
			local err = 1 / 0
			
			local entities = util.findSystemInstance(self.world.systems, pointSystem).entities
			for _, e in ipairs(entities) do
				local t = e as entity.target
				if not t.pinned then
					local delta = t.pos - entity.pos
					local dot = delta.normalized:dot(naim)
					if dot > 0.1 then
						local pass = delta.length / dot
						if pass < 300 then
							local newErr = delta.length / dot ^ 5
							if newErr < err then
								target = t
								err = newErr
							end
						end
					end
				end
			end
		end
			
		entity.target = target
	end
	
	if not entity.link and entity.target and entity.input:down 'grab' then
		entity.link = {
			linkA = entity as typedef.ObjectEntity,
			linkB = entity.target as typedef.ObjectEntity,
			distance = 50,--(entity.pos - entity.target.pos).length,
			inStrength = 0,
			outStrength = 0.02
		}
		self.world:addEntity(entity.link as tiny.Entity)
	end
	
	if entity.link and not entity.input:down 'grab' then
		self.world:removeEntity(entity.link as tiny.Entity)
		entity.link = nil
	end
end

return system