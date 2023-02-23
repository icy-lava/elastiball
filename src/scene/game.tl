local record Game
	camera: cam11.Camera
	world: tiny.World
	levelName: string
	input: baton.Player
	player: typedef.InputEntity
	levelEnd: boolean
	levelData: level.Data
	__index: Game
end
Game.__index = Game

function Game:update(dt: number)
	self.input:update()
	self.world:update(dt, function(_: tiny.World, system: tiny.System<any>): boolean
		return not (system as table).draw
	end)
	local pos = self.player.pos as vec2
	self.camera:setPos(pos.x, pos.y)
end

function Game:draw()
	local gw, gh = love.graphics.getDimensions()
	
	love.graphics.clear(color.background)
	
	self.camera:attach(true)
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

function Game:enter(_: roomy.Scene, levelInfo: string | level.Data)
	local gw, gh = love.graphics.getDimensions() as (integer, integer)
	
	self.world = tiny.world()
	
	self.world:addSystem(util.instance(require 'system.point'))
	self.world:addSystem(util.instance(require 'system.attractor'))
	
	self.world:addSystem(util.instance(require 'system.input'))
	self.world:addSystem(util.instance(require 'system.verlet'))
	self.world:addSystem(util.instance(require 'system.gravity'))
	self.world:addSystem(util.instance(require 'system.update_particles'))
	
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
	
	self.world:addSystem(util.instance(require 'system.level_end'))
	
	self.world:addSystem(util.instance(require 'system.draw_level_end'))
	self.world:addSystem(util.instance(require 'system.draw_particles'))
	self.world:addSystem(util.instance(require 'system.draw_link'))
	self.world:addSystem(util.instance(require 'system.draw_point'))
	self.world:addSystem(util.instance(require 'system.draw_player'))
	
	local levelData: level.Data
	if levelInfo is string then
		self.levelName = levelInfo
		local levelString = love.filesystem.read(string.format('asset/level/%s.json', self.levelName))
		levelData = level.decode(levelString)
	else
		levelData = levelInfo
		self.levelName = 'live'
	end
	self.levelData = levelData
	
	local points: {level.Data.UID:{string:any}} = {}
	
	for uid, point in pairs(levelData.points) do
		local pos = vec2(point.pos.x, point.pos.y)
		local entity: typedef.PointEntity = {
			pos = pos.copy,
			lastPos = pos.copy,
			pinned = point.pinned,
		}
		self.world:addEntity(entity as table)
		points[uid] = entity
	end
	
	for _, link in pairs(levelData.links) do
		local a, b = points[link.a] as typedef.ObjectEntity, points[link.b] as typedef.ObjectEntity
		local entity: typedef.LinkEntity = {
			linkA = a,
			linkB = b,
			distance = (a.pos as vec2 - b.pos as vec2).length,
		}
		self.world:addEntity(entity as table)
	end
	
	self.input = config.input
	
	do
		local pos = vec2(levelData.player.x, levelData.player.y)
		local entity = {
			pos = pos.copy,
			lastPos = pos.copy,
			aim = vec2(1, 0),
			mass = config.player.body.mass,
			heat = 0,
			input = self.input,
		}
		self.world:addEntity(entity as table)
		self.camera = cam11(pos.x, pos.y, 1, 0, 0, 0, gw, gh)
		self.player = entity
	end
	
	do
		local pos = vec2(levelData.levelEnd.x, levelData.levelEnd.y)
		local sig: signal<string> = signal.new()
		
		local this = self
		sig:connect(function()
			this.levelEnd = true
		end)
		
		local ps1 = love.graphics.newParticleSystem(asset.alpha_image.circle)
		ps1:setParticleLifetime(3, 4)
		ps1:setEmissionRate(100)
		ps1:setSpeed(-150, -100)
		ps1:setRadialAcceleration(-100, -50)
		ps1:setTangentialAcceleration(100, 7000)
		ps1:setLinearDamping(0.1)
		ps1:setEmissionArea('borderellipse', config.exit.radius * 1, config.exit.radius * 1, 0, true)
		ps1:setInsertMode('random')
		ps1:setSizes(config.particle.scaleToUnit * 10, config.particle.scaleToUnit * 20, config.particle.scaleToUnit * 50)
		ps1:setColors(
			color.withAlpha(color.exit, 0),
			color.withAlpha(color.exit, 0.3),
			color.withAlpha(color.exit, 0.9),
			color.withAlpha(color.exit, 0)
		)
		
		local ps2 = love.graphics.newParticleSystem(asset.alpha_image.circle)
		ps2:setParticleLifetime(3, 4)
		ps2:setEmissionRate(50)
		ps2:setSpeed(-150, -100)
		ps2:setRadialAcceleration(5, 10)
		ps2:setTangentialAcceleration(20, 50)
		ps2:setEmissionArea('borderellipse', config.exit.radius * 2, config.exit.radius * 2, 0, true)
		ps2:setInsertMode('random')
		ps2:setSizes(config.particle.scaleToUnit * 10, config.particle.scaleToUnit * 30, config.particle.scaleToUnit * 100)
		ps2:setColors(
			color.withAlpha(color.exit, 0),
			color.withAlpha(color.exit, 0.3),
			color.withAlpha(color.exit, 0.9),
			color.withAlpha(color.exit, 0)
		)
		
		local ps3 = love.graphics.newParticleSystem(asset.alpha_image.circle)
		ps3:setParticleLifetime(3, 4)
		ps3:setEmissionRate(100)
		ps3:setSpeed(-30, -10)
		ps3:setRadialAcceleration(-100, -50)
		ps3:setLinearDamping(0.5)
		ps3:setTangentialAcceleration(50, 100)
		ps3:setEmissionArea('ellipse', config.exit.radius * 1.1, config.exit.radius * 1.1, 0, true)
		ps3:setInsertMode('random')
		ps3:setSizes(config.particle.scaleToUnit * 50, config.particle.scaleToUnit * 100, config.particle.scaleToUnit * 50)
		ps3:setColors(
			color.withAlpha(color.exit, 0),
			color.withAlpha(color.exit, 0.8),
			color.withAlpha(color.exit, 0)
		)
		
		local entity = {
			pos = pos.copy,
			endSignal = sig,
			particles = {ps3, ps2, ps1},
			attraction = 1000,
			attractionMinDist = 150,
		}
		self.world:addEntity(entity as table)
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
			if self.levelName == 'live' then
				scene:enter(Game.new(), self.levelData)
			else
				scene:enter(Game.new(), self.levelName)
			end
			return
		end
		if key == 'escape' and self.levelName == 'live' then
			scene:pop()
		end
	end
	if key == 'escape' then
		love.mouse.setRelativeMode(false)
		return
	end
end

return Game