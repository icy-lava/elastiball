local system = util.processingSystem(typedef.InputEntity)
local pointSystem = require 'system.point'

function system:process(entity: typedef.InputEntity, dt: number)
	entity.input:update()
	local move = vec2(entity.input:get 'move') * dt ^ 2 * vec2(300, 100)
	entity.pos = entity.pos + move
	
	if entity.aim then
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
		
		if not entity.linkRef then
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
	end
	
	if entity.input:down 'grab' then
		if not entity.linkRef and entity.target then
			local link <total>: typedef.comp.Link = {
				-- FIXME: need a more robust way to convert entities here
				a = entity as typedef.comp.Linked,
				b = entity.target as typedef.comp.Linked,
				distance = 50,--(entity.pos - entity.target.pos).length,
				strengthIn = 0,
				strengthOut = 0.02,
				error = 0,
			}
			
			-- TODO: there should be standard functions to initialize entities
			local linkEntity <total>: typedef.LinkEntity = {
				link = link,
				drawables = {require 'draw.link'},
				layer = 20,
			}
			
			entity.linkRef = linkEntity
			
			self.world:addEntity(linkEntity as tiny.Entity)
		end
	else
		if entity.linkRef then
			self.world:removeEntity(entity.linkRef as tiny.Entity)
			entity.linkRef = nil
		end
	end
end

return system