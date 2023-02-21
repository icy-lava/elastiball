local record Target
	pos: vec2
	pinned: boolean
end

local record Entity
	pos: vec2
	lastPos: vec2
	input: baton.Player
	aim: vec2
	target: Target
	link: table
end

local system: tiny.System<Entity> = tiny.processingSystem()

system.filter = tiny.requireAll('pos', 'lastPos', 'input', 'aim')
local pointSystem = require 'system.point'

function system:process(entity: Entity, dt: number)
	entity.input:update()
	entity.pos = entity.pos + vec2(entity.input:get 'move') * dt ^ 2 * 100
	
	if util.mouseRel.length >= 5 then
		entity.input._activeDevice = 'kbm'
	end
	if entity.input:getActiveDevice() == 'joy' then
		entity.aim = vec2(entity.input:get('aim'))
	else
		entity.aim = entity.aim + util.mouseRel * 0.01
		entity.aim.length = math.min(entity.aim.length, 1)
	end
	
	if not entity.link then
		local target: Target
		if entity.aim.length >= 0.3 then
			local naim = entity.aim.normalized
			local err = 1 / 0
			
			-- FIXME: there's not a straightforward way to access points from in here, so for now this hack will do
			for _, sys in ipairs(self.world.systems as {tiny.System<any>}) do
				if sys.filter == pointSystem.filter then
					-- print(1)
					for _, e in ipairs(sys.entities) do
						local t = e as Target
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
			end
		end
			
		entity.target = target
	end
	
	if entity.target and entity.input:pressed 'grab' then
		entity.link = {
			linkA = entity,
			linkB = entity.target,
			distance = (entity.pos - entity.target.pos).length,
			inStrength = 0,
			outStrength = 0.1
		}
		self.world:addEntity(entity.link)
	end
	
	if entity.link and entity.input:released 'grab' then
		self.world:removeEntity(entity.link)
		entity.link = nil
	end
end

return system