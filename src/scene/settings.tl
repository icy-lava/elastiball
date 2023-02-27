local type Menu = require 'scene.menu'
local record Settings
	ui: ui.ButtonSet
	uiOpacity: number
	font: love.graphics.Font
	flux: flux.Group
	prev: Menu
	fadeColor: color.RGBA
	__index: Settings
end
Settings.__index = Settings

function Settings.new(): Settings
	return setmetatable({}, Settings)
end

function Settings:resize(width: integer, height: integer)
	local bsize = config.button.settingsSize
	local spacing = config.button.spacing
	local levelCount = #self.ui.buttons - 1
	
	local cols = 1
	local rows = math.ceil(levelCount / cols)
	local layoutWidth = bsize.x * cols + spacing * (cols - 1)
	local layoutHeight = bsize.y * rows + spacing * (rows - 1)
	local buttonX: number
	local buttonY: number
	
	for i = 1, levelCount do
		if (i - 1) % cols == 0 then
			buttonX = util.round((width - layoutWidth) / 2)
		end
		buttonY = util.round((height - layoutHeight) / 2 + math.floor((i - 1) / cols) * (bsize.y + spacing))
		self.ui.buttons[i].pos = vec2(buttonX, buttonY)
		buttonX = buttonX + bsize.x + spacing
	end
	
	local pad = config.button.pad * 1.5
	self.ui.buttons[#self.ui.buttons].pos = (vec2(width, height) - config.button.size - vec2(pad, pad)).floor
	
	self.prev:resize(width, height)
end

function Settings:enter(prev: Menu)
	self.ui = ui.ButtonSet.new()
	self.prev = prev
	self.font = asset.font['Quicksand-SemiBold'](32)
	self.flux = flux.group()
	
	self.uiOpacity = 0
	self.flux:to(self, 1, {uiOpacity = 1})
		:ease 'quadinout'
		:after(0.5, {})
	
	local settings = self
	
	local function button(text: string): ui.Button
		local setting = ui.Button.new()
		setting.size = config.button.settingsSize.copy
		setting.font = self.font
		setting.text = text
		setting.color = color.buttonBack
		setting.textColor = color.buttonFore
		setting.cornerRadius = config.button.radius
		self.ui:add(setting)
		return setting
	end
	
	do -- VSync
		local function text(): string
			return love.window.getVSync() == 0 and 'VSync is OFF' or 'VSync is ON'
		end
		local setting = button(text())
		
		function setting:action()
			love.window.setVSync(love.window.getVSync() == 0 and 1 or 0)
			self.text = text()
		end
	end
	
	if not WEB then -- Fullscreen
		local function text(): string
			return love.window.getFullscreen() and 'Fullscreen' or 'Windowed'
		end
		local setting = button(text())
		
		function setting:action()
			love.window.setFullscreen(not love.window.getFullscreen())
			love.event.push('resize', love.graphics.getDimensions())
			self.text = text()
		end
	end
	
	do -- Particles
		local function text(): string
			return config.particle.enabled and 'Particles are ON' or 'Particles are OFF'
		end
		local setting = button(text())
		
		function setting:action()
			config.particle.enabled = not config.particle.enabled
			self.text = text()
		end
	end
	
	-- do -- Refresh input
	-- 	local setting = button('Refresh input')
		
	-- 	function setting:action()
	-- 		util.resetBaton()
	-- 	end
	-- end
	
	do -- Back button
		local backButton = button 'Back'
		backButton.font = asset.font['Quicksand-SemiBold'](48)
		backButton.size = config.button.size.copy
		
		function backButton:action()
			scene:pop()
		end
	end
	
	self:resize(love.graphics.getDimensions() as (integer, integer))
end

function Settings:mousepressed(...)
	self.ui:mousepressed(... as nil)
end

function Settings:mousereleased(...)
	self.ui:mousereleased(... as nil)
end

function Settings:draw()
	-- love.graphics.clear(color.withAlpha(color.black, 1))
	self.prev:draw()
	love.graphics.setColor(0, 0, 0, 0.75)
	love.graphics.rectangle('fill', 0, 0, love.graphics.getDimensions())
	love.graphics.setColor(1, 1, 1, self.uiOpacity)
	self.ui:draw()
	
	-- Solid color overlay
	if self.fadeColor and self.fadeColor[4] > 0 then
		love.graphics.setColor(self.fadeColor)
		love.graphics.rectangle('fill', 0, 0, love.graphics.getDimensions())
	end
end

function Settings:update(dt: number)
	self.prev:update(dt)
	self.flux:update(dt)
end

return Settings