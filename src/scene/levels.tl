local type Menu = require 'scene.menu'
local record Levels
	ui: ui.ButtonSet
	uiOpacity: number
	font: love.graphics.Font
	flux: flux.Group
	prev: Menu
	fadeColor: color.RGBA
	__index: Levels
end
Levels.__index = Levels

function Levels.new(): Levels
	return setmetatable({}, Levels)
end

function Levels:resize(width: integer, height: integer)
	local bsize = config.button.levelSize
	local spacing = config.button.spacing
	local levelCount = util.getLevelCount()
	
	local cols = 5
	local rows = math.ceil(levelCount / cols)
	local layoutWidth = bsize.x * cols + spacing * (cols - 1)
	local layoutHeight = bsize.y * rows + spacing * (rows - 1)
	local buttonX: number
	local buttonY: number
	
	for i = 1, levelCount do
		if i % cols == 1 then
			buttonX = util.round((width - layoutWidth) / 2)
		end
		buttonY = util.round((height - layoutHeight) / 2 + math.floor((i - 1) / cols) * (bsize.y + spacing))
		self.ui.buttons[i].pos = vec2(buttonX, buttonY)
		buttonX = buttonX + bsize.x + spacing
	end
	
	local pad = config.button.pad * 1.5
	self.ui.buttons[levelCount + 1].pos = (vec2(width, height) - config.button.size - vec2(pad, pad)).floor
	
	self.prev:resize(width, height)
end

function Levels:enter(prev: Menu)
	self.ui = ui.ButtonSet.new()
	self.prev = prev
	self.font = asset.font['Quicksand-SemiBold'](64)
	self.flux = flux.group()
	
	self.uiOpacity = 0
	self.flux:to(self, 1, {uiOpacity = 1})
		:ease 'quadinout'
		:after(0.5, {})
	
	local levels = self
		
	for i = 1, util.getLevelCount() do
		local levelName = tostring(i)
		local levelButton = ui.Button.new()
		levelButton.size = config.button.levelSize.copy
		levelButton.font = self.font
		levelButton.text = levelName
		levelButton.color = color.buttonBack
		levelButton.textColor = color.buttonFore
		levelButton.cornerRadius = config.button.radius
		
		function levelButton:action()
			self.parent.disabled = true
			levels.flux:to(levels, 0.25, {uiOpacity = 0})
				:ease 'quadin'
				:after(0.5, {})
			do
				local tween = {value = 0}
				levels.flux:to(tween, 0.5, {value = 1})
					:ease 'quadin'
					:onupdate(function()
						-- local fadeTo = color.labLerp(0.25, color.background, color.white)
						local fadeTo = color.black
						levels.fadeColor = color.labLerp(tween.value, color.withAlpha(fadeTo, 0), fadeTo)
					end)
					:after(0.25, {})
					:oncomplete(function()
						love.mouse.setRelativeMode(true)
						scene:enter(require 'scene.game'.new(), levelName)
					end)
			end
		end
		self.ui:add(levelButton)
	end
	
	do -- Back button
		local backButton = ui.Button.new()
		backButton.size = config.button.size.copy
		backButton.font = asset.font['Quicksand-SemiBold'](48)
		backButton.text = 'Back'
		backButton.color = color.buttonBack
		backButton.textColor = color.buttonFore
		backButton.cornerRadius = config.button.radius
		
		function backButton:action()
			scene:pop()
		end
		
		self.ui:add(backButton)
	end
	
	self:resize(love.graphics.getDimensions() as (integer, integer))
end

function Levels:mousepressed(...)
	self.ui:mousepressed(... as nil)
end

function Levels:mousereleased(...)
	self.ui:mousereleased(... as nil)
end

function Levels:draw()
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

function Levels:update(dt: number)
	self.prev:update(dt)
	self.flux:update(dt)
end

return Levels