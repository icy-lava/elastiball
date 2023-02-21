local record Game
	camera: cam11.Camera
	world: tiny.World
	levelName: string
	input: baton.Player
	__index: Game
end
Game.__index = Game

function Game:update(dt: number)
	self.input:update()
	self.world:update(dt, function(_: tiny.World, system: tiny.System<any>): boolean
		return not (system as table).draw
	end)
	for _, entity in ipairs(self.world.entities) do
		if entity.player then
			local pos = entity.pos as vec2
			self.camera:setPos(pos.x, pos.y)
		end
	end
end

function Game:draw()
	local gw, gh = love.graphics.getDimensions()
	
	self.camera:attach(true)
	love.graphics.clear(color.background)
	
	self.world:update(0, function(_: tiny.World, system: tiny.System<any>): boolean
		return not not (system as table).draw
	end)
	
	self.camera:detach()
	
	do -- Heat bar
		local barWidth = util.round(gw * 3 / 4)
		local barY = gh - 100
		local barLeft = vec2((gw - barWidth) / 2, barY)
		local barRight = barLeft + vec2(barWidth, 0)
		local barCenter = (barLeft + barRight) / 2
		local pad = 12
		
		local heat = ((self as table).player as table).heat as number
		love.graphics.setColor(color.labLerp(heat, color.white, color.hot))
		util.crect('fill', barLeft.x, barLeft.y, 6, 32, 3)
		util.crect('fill', barRight.x, barRight.y, 6, 32, 3)
		util.crect('fill', barCenter.x, barCenter.y, (barWidth - pad * 2 - 6) * heat + 6, 6, 3)
	end
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

function Game:mousemoved(_: integer, _: integer, dx: integer, dy: integer)
	util.mouseRel = util.mouseRel + vec2(dx, dy)
end

function Game:mousepressed(_: integer)
	love.mouse.setRelativeMode(true)
end

function Game:enter(_: roomy.Scene, levelName: string)
	local gw, gh = love.graphics.getDimensions() as (integer, integer)
	
	self.world = tiny.world()
	
	self.world:addSystem(util.instance(require 'system.point'))
	
	self.world:addSystem(util.instance(require 'system.input'))
	self.world:addSystem(util.instance(require 'system.velocity'))
	self.world:addSystem(util.instance(require 'system.gravity'))
	
	local linkDummy: tiny.System<any> = tiny.system()
	local linkSystem = util.instance(require 'system.link')
	function linkDummy:update(dt: number)
		local iterations = 3
		for _ = 1, iterations do
			linkSystem:update(dt / iterations)
		end
	end
	self.world:addSystem(util.instance(linkDummy))
	linkSystem.active = false
	self.world:addSystem(linkSystem)
	
	self.world:addSystem(util.instance(require 'system.draw_link'))
	self.world:addSystem(util.instance(require 'system.draw_point'))
	self.world:addSystem(util.instance(require 'system.draw_player'))
	
	self.levelName = levelName
	local levelString = love.filesystem.read(string.format('asset/level/%d.json', levelName))
	local levelData = level.decode(levelString)
	
	local points: {level.Data.UID:{string:any}} = {}
	
	for uid, point in pairs(levelData.points) do
		local pos = vec2(point.pos.x, point.pos.y)
		local entity: {string:any} = {
			pos = pos.copy,
			lastPos = pos.copy,
			pinned = point.pinned,
		}
		self.world:addEntity(entity)
		points[uid] = entity
	end
	
	for _, link in pairs(levelData.links) do
		local a, b = points[link.a], points[link.b]
		local entity: {string:any} = {
			linkA = a,
			linkB = b,
			distance = (a.pos as vec2 - b.pos as vec2).length,
		}
		self.world:addEntity(entity)
	end
	
	self.input = config.input
	
	do
		local pos = vec2(levelData.player.x, levelData.player.y)
		local entity: {string:any} = {
			player = true,
			pos = pos.copy,
			lastPos = pos.copy,
			aim = vec2(1, 0),
			mass = config.player.body.mass,
			heat = 0,
			input = self.input
		}
		;(self as table).player = entity
		self.world:addEntity(entity)
		self.camera = cam11(pos.x, pos.y, 1, 0, 0, 0, gw, gh)
	end
	
	self.world:refresh()
	
	self:resize(gw, gh)
	
	love.mouse.setRelativeMode(true)
end

function Game:leave()
	love.mouse.setRelativeMode(false)
end

function Game.new(): Game
	return setmetatable({}, Game)
end

function Game:keypressed(key: string)
	if cli.dev then
		if key == 'r' and love.keyboard.isDown('lctrl', 'rctrl') then
			scene:enter(Game.new(), self.levelName)
			return
		end
	end
	if key == 'escape' then
		love.mouse.setRelativeMode(false)
		return
	end
end

return Game