local record Game
	enum Safety 'unsafe' 'safe' 'dying' end
	
	camera: cam11.Camera
	cameraZoom: number
	flux: flux.Group
	world: tiny.World
	input: baton.Player
	hadInput: boolean
	inputHelpOpacity: number
	music: love.audio.Source
	
	player: typedef.PlayerEntity
	
	levelData: level.Data
	levelName: string
	
	levelEnd: boolean
	safety: Safety
	fadeColor: color.RGBA
	ticks: integer
	timerFont: love.graphics.Font
	profile: AppleCake.Profile
	
	__index: Game
end
Game.__index = Game

function Game.new(): Game
	return setmetatable({}, Game)
end

function Game:pushProfile()
	self.profile = appleCake.profile('scene.game', {levelName = self.levelName}, self.profile)
end

function Game:popProfile()
	self.profile:stop()
end

function Game:resumeMusic()
	local vol = {value = self.music:getVolume()}
	self.music:setLooping(true)
	self.music:play()
	flux.to(vol, 0.5, {value = 1})
	:onupdate(function()
		self.music:setVolume(vol.value)
	end)
	:ease 'quadinout'
end

function Game:pauseMusic()
	local vol = {value = self.music:getVolume()}
	self.music:play()
	flux.to(vol, 0.5, {value = 0})
	:ease 'quadinout'
	:onupdate(function()
		self.music:setVolume(vol.value)
	end)
	:oncomplete(function()
		self.music:pause()
	end)
end

function Game:getLevelTime(): number
	return util.ticksToSecs(self.ticks)
end

function Game:getLevelTimeString(): string
	local time = self:getLevelTime()
	local seconds = time % 60
	local minutes = math.floor(time / 60)
	return string.format('%d:%04.1f', minutes, seconds)
end

function Game:gotoLevel(name: string)
	scene:enter(Game.new(), name)
end

function Game:resetLevel()
	if self.levelName == 'live' then
		scene:enter(Game.new(), self.levelData)
	else
		stats.currentTotal = stats.currentTotal + self:getLevelTime()
		self:gotoLevel(self.levelName)
	end
end

function Game:endGame()
	stats.bestTotal = math.min(stats.bestTotal, stats.currentTotal)
	gotoMenu()
	love.mouse.setRelativeMode(false)
end

function Game:nextLevel()
	if self.levelName == 'live' then
		scene:pop()
	elseif self.levelName == 'menu' then
		stats.currentTotal = 0
		stats.runTimes = {}
		self:gotoLevel('1')
		love.mouse.setRelativeMode(true)
	else
		local levelNum = assert(tonumber(self.levelName), 'could not convert level name to number')
		levelNum = levelNum + 1
		local levelName = tostring(levelNum)
		if util.levelExists(levelName) then
			self:gotoLevel(levelName)
		else
			self.flux:to({}, 2, {})
			:oncomplete(function()
				self:endGame()
			end)
		end
	end
end

function Game:immobilizePlayer()
	self.player.input = config.inputDummy
	self.player.aim = nil
	self.world:addEntity(self.player as tiny.Entity)
end

function Game:onDeath()
	local tween = {value = 0}
	self.flux:to(tween, 1, {value = 1})
		:ease 'quadin'
		:onupdate(function()
			-- local fadeTo = color.labLerp(0.25, color.background, color.white)
			local fadeTo = color.black
			self.fadeColor = color.labLerp(tween.value, color.withAlpha(fadeTo, 0), fadeTo)
		end)
		:after(0.25, {})
		:oncomplete(function()
			self:resetLevel()
		end)
	
	self:immobilizePlayer()
end

function Game:onLevelEnd()
	self.levelEnd = true
	
	if self.levelName ~= 'menu' and self.levelName ~= 'live' then
		local time = util.ticksToSecs(self.ticks)
		stats.runTimes[self.levelName] = time
		stats.currentTotal = stats.currentTotal + time
		stats.bestTimes[self.levelName] = math.min(time, stats.bestTimes[self.levelName] or math.huge)
	end
	
	do -- Sound delayed
		self.flux:to({}, 0.25, {})
		:oncomplete(function()
			asset.sound.portal:play()
		end)
	end
	
	do -- Music fade
		local vol = {value = self.music:getVolume()}
		flux.to(vol, 1.5, {value = math.min(0.5, vol.value)})
		:ease 'quadinout'
		:onupdate(function()
			self.music:setVolume(vol.value)
		end)
	end
	
	do -- Opacity tween
		self.player.opacity = self.player.opacity or 1
		self.player.scale = self.player.scale or 1
		self.flux:to(self.player, 1.75, {opacity = 0, scale = 0.25}):ease 'quadin'
	end
	
	local cam = self.camera
	do -- Camera zoom tween
		local tween = {value = 0}
		local zoom = cam:getZoom()
		self.flux:to(tween, 1.75, {value = 1})
			:ease 'quartin'
			:delay(0.25)
			:onupdate(function()
				cam:setZoom(zoom * 2 ^ (tween.value * 4))
			end)
	end	
	
	do -- Camera rotation tween
		local tween = {value = 0}
		local rot = cam:getAngle()
		self.flux:to(tween, 2, {value = 1})
			:ease 'quartin'
			:onupdate(function()
				cam:setAngle(rot + tween.value * math.pi * 1)
			end)
	end
	
	do -- Fade tween
		local fade = {value = 0}
		self.flux:to(fade, 1.5, {value = 1})
			:ease 'quartin'
			:delay(0.5)
			:onupdate(function()
				self.fadeColor = color.withAlpha(color.black, fade.value)
			end)
			:after(0.25, {})
			:oncomplete(function()
				self:nextLevel()
			end)
	end
	
	do -- Noise tween
		asset.sound.noise:setVolume(1)
		local fade = {value = 1}
		self.flux:to(fade, 1.75, {value = 0})
			:ease 'quadout'
			:onupdate(function()
				asset.sound.noise:setVolume(fade.value)
			end)
	end
	
	self:immobilizePlayer()
end

function Game:update(dt: number)
	if not (self.levelEnd or self.safety == 'dying' or not self.hadInput) then
		self.ticks = self.ticks + 1
	end
	self.input:update()
	config.inputDummy:update()
	self.flux:update(dt)
	
	if not self.hadInput and (self.input:down 'grab' or self.input:down 'move') then
		self.hadInput = true
		self.flux:to(self, self.inputHelpOpacity * 0.25, {inputHelpOpacity = 0})
			:ease 'quadout'
	end
	
	if self.safety ~= 'dying' then
		self.safety = 'unsafe'
	end
	self.world:update(dt, function(_: tiny.World, system: tiny.System<any>): boolean
		if not self.hadInput and (
			system.filter == require 'system.gravity'.filter or
			system.filter == require 'system.verlet'.filter
		) then
			return false
		end
		return not (system as table).draw
	end)
	if not self.levelEnd and self.safety == 'unsafe' then
		self.safety = 'dying'
		self:onDeath()
	end
	
	if self.levelEnd then
		local p = self.player
		-- Cancel out gravity
		p.pos = p.pos - GRAVITY * dt * dt
		
		-- Apply velocity damping
		local delta = p.pos - p.lastPos
		local length = delta.length
		local normal = delta / length
		p.pos = p.pos - normal * dt * dt * length * 500
	end
	
	local pos = self.player.pos
	local lastPos = self.player.lastPos
	
	if self.levelEnd then
		local pos2 = self.levelData.levelEnd
		pos = pos2.copy
		lastPos = pos2.copy
	end
	
	local delta = (pos - lastPos) / dt
	local camPos = vec2(self.camera:getPos())
	local mult = 1
	local targetPos = pos + delta * vec2(mult * 1.5, mult)
	camPos = util.damp(0.4, dt, camPos, targetPos)
	self.camera:setPos(camPos.x, camPos.y)
	self.cameraZoom = util.damp(0.25, dt, self.cameraZoom, 1 / 1.125 ^ (delta.length2 / 4e5))
	
	love.audio.setPosition(camPos.x * 0.001, camPos.y * 0.001, 3000 * 0.001)
end

function Game:draw()
	local gw, gh = love.graphics.getDimensions()
	
	local prevZoom = self.camera:getZoom()
	self.camera:setZoom(prevZoom * self.cameraZoom * config.camera.zoom)
	self.camera:attach(true)
	
	love.graphics.clear(color.background)
	
	self.world:update(0, function(_: tiny.World, system: tiny.System<any>): boolean
		return not not (system as table).draw
	end)
	
	if self.inputHelpOpacity > 0 then
		love.graphics.setColor(1, 1, 1, self.inputHelpOpacity * 0.5)
		local pos = self.player.pos
		local scale = 0.5
		do
			local img = asset.alpha_image.controller as love.graphics.Drawable
			util.drawCentered(img, pos.x, pos.y - 100, 0, scale, scale)
		end
		do
			local img = asset.alpha_image.keyboard_mouse as love.graphics.Drawable
			util.drawCentered(img, pos.x, pos.y + 100, 0, scale, scale)
		end
	end
	
	self.camera:detach()
	self.camera:setZoom(prevZoom)
	
	local vpx, vpy, vpw, vph = self.camera:getViewport()
	
	if self.levelName ~= 'menu' then
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.printf(self:getLevelTimeString(), self.timerFont, vpx + 24, vpy + 24, 200, 'left')
	end
	
	-- Solid color overlay
	if self.fadeColor and self.fadeColor[4] > 0 then
		love.graphics.setColor(self.fadeColor)
		love.graphics.rectangle('fill', vpx, vpy, vpw, vph)
	end
	
	if false then -- Heat bar
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
	
	-- if cli.dev then
	-- 	love.graphics.setColor(1, 1, 1, 1)
	-- 	love.graphics.print(tostring(love.timer.getFPS()), 16, 16)
	-- end
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
	local levelData: level.Data
	if levelInfo is string then
		self.levelName = levelInfo
	else
		levelData = levelInfo
		self.levelName = 'live'
	end
	
	self:pushProfile()
	
	local gw, gh = love.graphics.getDimensions() as (integer, integer)
	
	util.resetBaton()
	self.flux = flux.group()
	self.world = tiny.world()
	self.input = config.input
	self.safety = 'safe'
	self.cameraZoom = 1
	self.inputHelpOpacity = 0
	self.ticks = 0
	
	self.timerFont = util.getFont('Quicksand-SemiBold', 32)
	
	-- Initialize systems
	util.profile('initialize-systems', nil, function()
		self.world:addSystem(util.instance(require 'system.point'))
		self.world:addSystem(util.instance(require 'system.attractor'))
		self.world:addSystem(util.instance(require 'system.solids'))
		
		self.world:addSystem(util.instance(require 'system.input'))
		self.world:addSystem(util.instance(require 'system.verlet'))
		self.world:addSystem(util.instance(require 'system.gravity'))
		self.world:addSystem(util.instance(require 'system.link'))
		self.world:addSystem(util.instance(require 'system.update_particles'))
		self.world:addSystem(util.instance(require 'system.trigger'))
		
		self.world:addSystem(util.instance(require 'system.draw_particles'))
		-- self.world:addSystem(util.instance(require 'system.draw_polygon'))
		self.world:addSystem(util.instance(require 'system.drawable'))
	end)
	
	-- Load level data
	if self.levelName ~= 'live' then
		util.profile('load-level', {levelName = self.levelName}, function()
			stats.runTimes[self.levelName] = 0
			local path = util.levelNameToPath(self.levelName)
			local levelString = love.filesystem.read(path)
			levelData = level.decode(levelString)
		end)
	end
	self.levelData = levelData
	
	-- Initialize points
	local points: {level.Data.UID:{string:any}} = {}
	util.profile('initialize-points', nil, function()
		for uid, point in pairs(levelData.points) do
			local entity <total>: typedef.PointEntity = {
				pos = point.pos.copy,
				lastPos = point.pos.copy,
				grabable = point.grabable,
				pinned = point.pinned,
				drawables = {require 'draw.point'},
				layer = 100,
			}
			self.world:addEntity(entity as table)
			points[uid] = entity
		end
	end)
	
	-- Initialize safezones
	util.profile('initialize-safezones', nil, function()
		-- It's probably OK to share the signal between multiple safezones
		local sig: signal<string> = signal.new()
		
		sig:connect(function()
			if self.safety ~= 'dying' then
				self.safety = 'safe'
			end
		end)
		
		for _, safezone in pairs(levelData.safezones) do
			local entity <total>: typedef.SafezoneEntity = {
				pos = safezone.pos.copy,
				trigger = {
					radius = safezone.radius,
					signal = sig,
				},
				drawables = nil,
				layer = nil,
			}
			self.world:addEntity(entity as table)
		end
	end)
	
	util.profile('initialize-links', nil, function()
		for _, link in pairs(levelData.links) do
			local a, b = points[link.a] as typedef.comp.Linked, points[link.b] as typedef.comp.Linked
			local linc <total>: typedef.comp.Link = {
				a = a,
				b = b,
				distance = (a.pos - b.pos).length,
				error = 0,
				strengthIn = nil,
				strengthOut = nil,
			}
			local entity <total>: typedef.LinkEntity = {
				link = linc,
				drawables = {require 'draw.link'},
				layer = 20,
			}
			self.world:addEntity(entity as table)
		end
	end)
	
	-- Initialize solids
	util.profile('initialize-solids', nil, function()
		for _, solid in pairs(levelData.solids) do
			local coords: {number} = {}
			for _, pos in ipairs(solid.points) do
				table.insert(coords, pos.x)
				table.insert(coords, pos.y)
			end
			local rcoords: {number} = {}
			for _, pos in ipairs(util.roundedPoly(config.solid.cornerRadius, solid.points)) do
				table.insert(rcoords, pos.x)
				table.insert(rcoords, pos.y)
			end
			local entity <total>: typedef.SolidEntity = {
				solids = {shapes.newPolygonShape(table.unpack(coords))},
				polygon = rcoords,
				drawables = {require 'draw.solid'},
			}
			self.world:addEntity(entity as table)
		end
	end)
	
	-- Initialize end portal
	util.profile('initialize-portal', nil, function()
		local pos = levelData.levelEnd
		local sig: signal<string> = signal.new()
		
		local particles: {love.graphics.ParticleSystem} = {}
		
		do -- Particle system 1
			local ps = love.graphics.newParticleSystem(asset.alpha_image.circle)
			ps:setParticleLifetime(3, 4)
			ps:setEmissionRate(100)
			ps:setSpeed(-150, -100)
			ps:setRadialAcceleration(-100, -50)
			ps:setTangentialAcceleration(100, 7000)
			ps:setLinearDamping(0.1)
			ps:setEmissionArea('borderellipse', config.exit.radius * 1, config.exit.radius * 1, 0, true)
			ps:setInsertMode('random')
			ps:setSizes(config.particle.scaleToUnit * 10, config.particle.scaleToUnit * 20, config.particle.scaleToUnit * 50)
			ps:setColors(
				color.withAlpha(color.exit, 0),
				color.withAlpha(color.exit, 0.3),
				color.withAlpha(color.exit, 0.9),
				color.withAlpha(color.exit, 0)
			)
			table.insert(particles, ps)
		end
		
		do -- Particle system 2
			local ps = love.graphics.newParticleSystem(asset.alpha_image.circle)
			ps:setParticleLifetime(3, 4)
			ps:setEmissionRate(50)
			ps:setSpeed(-150, -100)
			ps:setRadialAcceleration(5, 10)
			ps:setTangentialAcceleration(20, 50)
			ps:setEmissionArea('borderellipse', config.exit.radius * 2, config.exit.radius * 2, 0, true)
			ps:setInsertMode('random')
			ps:setSizes(config.particle.scaleToUnit * 10, config.particle.scaleToUnit * 30, config.particle.scaleToUnit * 100)
			ps:setColors(
				color.withAlpha(color.exit, 0),
				color.withAlpha(color.exit, 0.3),
				color.withAlpha(color.exit, 0.9),
				color.withAlpha(color.exit, 0)
			)
			table.insert(particles, ps)
		end
		
		do -- Particle system 3
			local ps = love.graphics.newParticleSystem(asset.alpha_image.circle)
			ps:setParticleLifetime(3, 4)
			ps:setEmissionRate(100)
			ps:setSpeed(-30, -10)
			ps:setRadialAcceleration(-100, -50)
			ps:setLinearDamping(0.5)
			ps:setTangentialAcceleration(50, 100)
			ps:setEmissionArea('ellipse', config.exit.radius * 1.1, config.exit.radius * 1.1, 0, true)
			ps:setInsertMode('random')
			ps:setSizes(config.particle.scaleToUnit * 50, config.particle.scaleToUnit * 100, config.particle.scaleToUnit * 50)
			ps:setColors(
				color.withAlpha(color.exit, 0),
				color.withAlpha(color.exit, 0.8),
				color.withAlpha(color.exit, 0)
			)
			table.insert(particles, ps)
		end
		
		local entity <total>: typedef.LevelEndEntity = {
			pos = pos.copy,
			trigger = {
				radius = config.exit.radius,
				signal = sig,
			},
			particles = particles,
			drawables = {require 'draw.portal'},
			layer = 10,
			attraction = {
				force = 1000,
				distMin = 150,
				distMax = 2000,
			},
		}
		
		sig:connect(function()
			if not self.levelEnd then
				self.levelEnd = true
				entity.attraction.force = entity.attraction.force * 3
				self:onLevelEnd()
			end
		end)
		
		self.world:addEntity(entity as table)
	end)
	
	-- Intialize player
	util.profile('initialize-player', nil, function()
		local particles: {love.graphics.ParticleSystem} = {}
		do -- Particle system 1
			local ps = love.graphics.newParticleSystem(asset.alpha_image.circle)
			ps:setParticleLifetime(0.4, 0.5)
			-- ps:setEmissionRate(10)
			-- ps:setSpeed(-150, -100)
			-- ps:setRadialAcceleration(-100, -50)
			-- ps:setTangentialAcceleration(100, 7000)
			-- ps:setLinearDamping(0.1)
			-- ps:setEmissionArea('borderellipse', config.exit.radius * 1, config.exit.radius * 1, 0, true)
			-- ps:setInsertMode('random')
			ps:setSizes(
				config.particle.scaleToUnit * config.player.body.radius * 2,
				config.particle.scaleToUnit * config.player.body.radius * 2 * 0.5
			)
			ps:setColors(
				color.withAlpha(color.player, 1),
				color.withAlpha(color.player, 0.25),
				color.withAlpha(color.player, 0.1),
				color.withAlpha(color.player, 0)
			)
			table.insert(particles, ps)
		end
		
		local pos = levelData.player
		local entity <total>: typedef.PlayerEntity = {
			pos = pos.copy,
			lastPos = pos.copy,
			aim = vec2(1, 0),
			drawables = {require 'draw.player', require 'draw.reticle'},
			particles = particles,
			velocityEmission = 0.5,
			mass = config.player.body.mass,
			heat = 0,
			input = self.input,
			opacity = 1,
			scale = 1,
			layer = 200,
		}
		self.world:addEntity(entity as table)
		self.camera = cam11(pos.x, pos.y, 1, 0, 0, 0, gw, gh)
		self.player = entity
	end)
	
	do -- Fade in tween
		local tween = {value = 1}
		self.fadeColor = color.withAlpha(color.black, 1)
		self.flux:to(tween, 1.5, {value = 0})
			:ease 'quadinout'
			:onupdate(function()
				self.fadeColor = color.withAlpha(color.black, tween.value)
			end)
			:oncomplete(function()
				if self.levelName == '1' and not self.hadInput then
					self.flux:to(self, 1.5, {inputHelpOpacity = 1})
						:ease 'quadinout'
				end
			end)
	end
	
	do -- Noise tween
		asset.sound.noise:setVolume(0)
		local fade = {value = 0}
		self.flux:to(fade, 2, {value = 1})
			:ease 'quadinout'
			:delay(0.5)
			:onupdate(function()
				asset.sound.noise:setVolume(fade.value)
			end)
	end
	
	self.world:refresh()
	self:resize(gw, gh)
	asset.sound.noise:setPosition(levelData.levelEnd.x * 0.001, levelData.levelEnd.y * 0.001, 0)
	asset.sound.noise:setLooping(true)
	asset.sound.noise:play()
	self.music = asset.sound.music
	if self.levelName ~= 'menu' then
		self:resumeMusic()
	end
end

function Game:resume()
	asset.sound.noise:play()
	self:resumeMusic()
	self:pushProfile()
end

function Game:leave()
	self:popProfile()
	-- love.mouse.setRelativeMode(false)
	asset.sound.noise:pause()
	-- pauseMusic(self.flux, self.music)
end

function Game:pause()
	self:popProfile()
	-- love.mouse.setRelativeMode(false)
	asset.sound.noise:pause()
	-- pauseMusic(self.flux, self.music)
end

function Game:keypressed(key: string)
	if cli.dev then
		if key == 'r' and love.keyboard.isDown('lctrl', 'rctrl') then
			self:resetLevel()
			return
		end
		if key == 'escape' and self.levelName == 'live' then
			scene:pop()
			return
		end
	end
	if key == 'escape' then
		pushPause()
	end
end

return Game