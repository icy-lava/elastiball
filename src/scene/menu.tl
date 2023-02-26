local type Game = require 'scene.game'
local record Menu
	ui: ui.ButtonSet
	uiOpacity: number
	font: love.graphics.Font
	recordFont: love.graphics.Font
	flux: flux.Group
	game: Game
	__index: Menu
end
Menu.__index = Menu

function Menu.new(): Menu
	return setmetatable({}, Menu)
end

function Menu:resize(width: integer, height: integer)
	local br = vec2(width, height)
	local _pad = config.button.pad
	local pad = vec2(_pad, _pad)
	local spacing = config.button.spacing
	local pos = br - config.button.size - pad
	for i = #self.ui.buttons, 1, -1 do
		local b = self.ui.buttons[i]
		b.pos = pos.copy
		pos = pos - vec2(0, b.size.y + spacing)
	end
	self.game:resize(width, height)
end

function Menu:enter()
	self.ui = ui.ButtonSet.new()
	self.font = asset.font['Quicksand-SemiBold'](48)
	self.recordFont = asset.font['Quicksand-SemiBold'](32)
	self.flux = flux.group()
	
	if not stats then
		local _stats <total>: Stats = {
			runTimes = {},
			currentTotal = 0,
			bestTimes = {},
			bestTotal = math.huge,
		}
		stats = _stats
	end
	
	self.uiOpacity = 0
	self.flux:to(self, 1, {uiOpacity = 1})
		:ease 'quadinout'
		:after(0.5, {})
	
	self.game = require 'scene.game'.new()
	self.game:enter(nil, 'menu')
	self.game.hadInput = true
	
	local particles = util.findSystemInstance(self.game.world.systems, require 'system.update_particles')
	for _ = 1, 240 do
		particles:update(1 / 60)
	end
	
	local menu = self
	
	do -- Start button
		local start = ui.Button.new()
		start.size = config.button.size.copy
		start.font = self.font
		start.text = 'Start'
		start.color = color.buttonBack
		start.textColor = color.buttonFore
		start.cornerRadius = config.button.radius
		
		function start:action()
			-- scene:enter(require 'scene.game'.new(), '1')
			self.parent.disabled = true
			menu.flux:to(menu, 0.25, {uiOpacity = 0})
				:ease 'quadin'
				:after(0.5, {})
				-- :oncomplete(function()
				-- 	scene:enter(require 'scene.game'.new(), '1')
				-- end)
			menu.game:onLevelEnd()
		end
		self.ui:add(start)
	end
	
	do -- Levels button
		local levels = ui.Button.new()
		levels.size = config.button.size.copy
		levels.font = self.font
		levels.text = 'Levels'
		levels.color = color.buttonBack
		levels.textColor = color.buttonFore
		levels.cornerRadius = config.button.radius
		
		function levels:action()
			
		end
		self.ui:add(levels)
	end
	
	do -- Settings button
		local settings = ui.Button.new()
		settings.size = config.button.size.copy
		settings.font = self.font
		settings.text = 'Settings'
		settings.color = color.buttonBack
		settings.textColor = color.buttonFore
		settings.cornerRadius = config.button.radius
		
		function settings:action()
			
		end
		self.ui:add(settings)
	end
	
	if not WEB then -- Exit button
		local exit = ui.Button.new()
		exit.size = config.button.size.copy
		exit.font = self.font
		exit.text = 'Exit'
		exit.color = color.buttonBack
		exit.textColor = color.buttonFore
		exit.cornerRadius = config.button.radius
		
		function exit:action()
			love.event.quit()
		end
		self.ui:add(exit)
	end
	
	self:resize(love.graphics.getDimensions() as (integer, integer))
end

function Menu:mousepressed(...)
	self.ui:mousepressed(... as nil)
end

function Menu:mousereleased(...)
	self.ui:mousereleased(... as nil)
end

function Menu:draw()
	love.graphics.clear(color.withAlpha(color.black, 1))
	self.game:draw()
	love.graphics.setColor(1, 1, 1, self.uiOpacity)
	self.ui:draw()
	
	if stats.currentTotal > 0 then
		local seconds = stats.currentTotal % 60
		local minutes = math.floor(stats.currentTotal / 60)
		local secondsBest = stats.bestTotal % 60
		local minutesBest = math.floor(stats.bestTotal / 60)
		local text = string.format('Time taken: %d:%05.2f\nBest time: %d:%05.2f', minutes, seconds, minutesBest, secondsBest)
		love.graphics.setColor(1, 1, 1, self.uiOpacity)
		love.graphics.printf(text, self.recordFont, 24, 24, 600, 'left')
	end
end

function Menu:update(dt: number)
	self.game:update(dt)
	local levelEnd = util.findEntity(self.game.world.entities, typedef.LevelEndEntity)
	self.game.camera:setPos(levelEnd.pos:split())
	self.flux:update(dt)
end

return Menu