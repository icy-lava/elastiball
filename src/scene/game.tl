local record Game
	camera: cam11.Camera
	world: tiny.World
	__index: Game
end
Game.__index = Game

function Game:update(dt: number)
	self.world:update(dt, function(_: tiny.World, system: tiny.System<any>): boolean
		return not (system as table).draw
	end)
end

function Game:draw()
	self.camera:attach(true)
	love.graphics.clear(0.8, 0.2, 0.8, 1)
	
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
	self.camera = cam11(
		WIDTH / 2, HEIGHT / 2, 1, 0, 0, 0, love.graphics.getWidth() as integer, love.graphics.getHeight() as integer
	)
	
	self.world = tiny.world()
	
	self.world:addSystem(require 'system.input')
	self.world:addSystem(require 'system.velocity')
	self.world:addSystem(require 'system.gravity')
	
	local linkDummy: tiny.System<any> = tiny.system()
	local linkSystem = require 'system.link'
	function linkDummy:update(dt: number)
		local iterations = 3
		for _ = 1, iterations do
			linkSystem:update(dt / iterations)
		end
	end
	self.world:addSystem(linkDummy)
	linkSystem.active = false
	self.world:addSystem(linkSystem)
	
	self.world:addSystem(require 'system.draw_link')
	self.world:addSystem(require 'system.draw')
	self.world:addSystem(require 'system.draw_player')
	
	local levelString = love.filesystem.read('asset/level/1.tmj')
	local levelData = level.decode(levelString)
	
	local entities: {{string:any}} = {}
	
	-- for i, point in ipairs(levelData.points) do
	-- 	entities[i] = {
	-- 		pos = point.copy,
	-- 		lastPos = not levelData.isPinned[i] and point.copy or nil
	-- 	}
	-- end
	
	-- for _, link in ipairs(levelData.links) do
	-- 	local a, b = entities[link.a], entities[link.b]
	-- 	table.insert(entities, {
	-- 		linkA = a,
	-- 		linkB = b,
	-- 		distance = (a.pos as vec2 - b.pos as vec2).length
	-- 	})
	-- end
	
	-- table.insert(entities, {
	-- 	player = true,
	-- 	pos = levelData.player.copy,
	-- 	lastPos = levelData.player.copy,
	-- 	input = baton.new {
	-- 		controls = {
	-- 			left = {'key:left', 'key:a', 'axis:leftx-', 'button:dpleft'},
	-- 			right = {'key:right', 'key:d', 'axis:leftx+', 'button:dpright'},
	-- 			up = {'key:up', 'key:w', 'axis:lefty-', 'button:dpup'},
	-- 			down = {'key:down', 'key:s', 'axis:lefty+', 'button:dpdown'},
	-- 		},
	-- 		pairs = {
	-- 			move = {'left', 'right', 'up', 'down'}
	-- 		},
	-- 		joystick = love.joystick.getJoysticks()[1],
	-- 	}
	-- })
	
	for _, e in ipairs(entities) do
		self.world:addEntity(e)
	end
	
	self.world:refresh()
	
	self:resize(love.graphics.getDimensions() as (integer, integer))
end

function Game.new(): Game
	return setmetatable({}, Game)
end

return Game