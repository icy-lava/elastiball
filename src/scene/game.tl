local record Game
	camera: cam11.Camera
	world: tiny.World
	__index: Game
end
Game.__index = Game

function Game:update(dt: number)
	-- self.camera:setAngle(self.camera:getAngle() + dt)
	self.world:update(dt, function(_: tiny.World, system: tiny.System<any>): boolean
		return not (system as table).draw
	end)
end

function Game:draw()
	self.camera:attach(true)
	love.graphics.clear(1, 0.5, 1, 1)
	-- love.graphics.clear(true)
	-- local pos = self.world.entities[1].pos as vec2
	-- love.graphics.print('hello', pos.x, pos.y)
	-- love.graphics.line(0.5, 0.5, 0.5, 100.5)
	-- love.graphics.rectangle('line', 0, 0, 24, 11)
	
	self.world:update(0, function(_: tiny.World, system: tiny.System<any>): boolean
		return not not (system as table).draw
	end)
	
	self.camera:detach()
end

function Game:resize(width: integer, height: integer)
	local fwch = WIDTH  * height -- Frame width  * Client height
	local fhcw = HEIGHT * width  -- Frame height * Client width
	
	local fitWidth: integer
	local fitHeight: integer
	
	if fwch < fhcw then
		fitWidth = math.floor(fwch / HEIGHT + 0.5)
		fitHeight = height
	else
		fitWidth = width
		fitHeight = math.floor(fhcw / WIDTH + 0.5)
	end
	
	local x = math.floor((width - fitWidth) / 2 + 0.5)
	local y = math.floor((height - fitHeight) / 2 + 0.5)
	
	self.camera:setZoom(math.min(fitWidth / WIDTH, fitHeight / HEIGHT))
	self.camera:setViewport(x, y, fitWidth, fitHeight)
end

function Game:enter()
	self.camera = cam11(0, 0, 1, 0, 0, 0, love.graphics.getWidth() as integer, love.graphics.getHeight() as integer)
	
	self.world = tiny.world()
	
	self.world:addSystem(require 'system.gravity')
	self.world:addSystem(require 'system.velocity')
	self.world:addSystem(require 'system.link')
	self.world:addSystem(require 'system.draw')
	
	local a: table = {
		pos = vec2(),
		lastPos = vec2(),
		-- lastDT = FRAME_TIME,
	}
	
	local b: table = {
		pos = vec2(100),
		lastPos = vec2(100),
		-- lastDT = FRAME_TIME,
	}
	
	local link: table = {
		linkA = a,
		linkB = b,
		distance = 500,
	}
	
	self.world:addEntity(a)
	self.world:addEntity(b)
	self.world:addEntity(link)
	
	self.world:refresh()
	
	self:resize(love.graphics.getDimensions() as (integer, integer))
end

function Game.new(): Game
	return setmetatable({}, Game)
end

return Game