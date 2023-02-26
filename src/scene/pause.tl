local type Game = require 'scene.game'
local record Pause
	ui: ui.ButtonSet
	uiOpacity: number
	font: love.graphics.Font
	flux: flux.Group
	prev: Game
	fadeColor: color.RGBA
	__index: Pause
end
Pause.__index = Pause

function Pause.new(): Pause
	return setmetatable({}, Pause)
end

function Pause:resize(width: integer, height: integer)
	local bsize = config.button.pauseSize
	local spacing = config.button.spacing
	local levelCount = #self.ui.buttons
	
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
	
	-- local pad = config.button.pad * 1.5
	-- self.ui.buttons[#self.ui.buttons].pos = (vec2(width, height) - config.button.size - vec2(pad, pad)).floor
	
	self.prev:resize(width, height)
end

function Pause:resume()
	self.uiOpacity = 0
	self.flux:to(self, 1, {uiOpacity = 1})
		:ease 'quadinout'
		:after(0.5, {})
end

function Pause:enter(prev: Game)
	self.ui = ui.ButtonSet.new()
	self.prev = prev
	self.font = asset.font['Quicksand-SemiBold'](48)
	self.flux = flux.group()
	
	self.uiOpacity = 0
	self.flux:to(self, 1, {uiOpacity = 1})
		:ease 'quadinout'
		:after(0.5, {})
	
	local pause = self
	
	local function button(text: string): ui.Button
		local option = ui.Button.new()
		option.size = config.button.pauseSize.copy
		option.font = self.font
		option.text = text
		option.color = color.buttonBack
		option.textColor = color.buttonFore
		option.cornerRadius = config.button.radius
		self.ui:add(option)
		return option
	end
	
	do -- Resume
		local option = button 'Resume'
		
		function option:action()
			love.mouse.setRelativeMode(true)
			scene:pop()
		end
	end
	
	do -- Restart level
		local option = button 'Restart level'
		
		function option:action()
			love.mouse.setRelativeMode(true)
			scene:pop()
			prev:resetLevel()
		end
	end
	
	-- Including the levels button here would cause it to keep an extra game scene on the stack
	-- so let's just not lol
	
	-- do -- Levels
	-- 	local option = button 'Levels'
		
	-- 	function option:action()
	-- 		pushLevels()
	-- 	end
	-- end
	
	do -- Settings
		local option = button 'Settings'
		
		function option:action()
			pushSettings()
		end
	end
	
	do -- Main menu
		local option = button 'Main menu'
		
		function option:action()
			self.parent.disabled = true
			pause.flux:to(pause, 0.25, {uiOpacity = 0})
				:ease 'quadin'
				:after(0.5, {})
			do
				local tween = {value = 0}
				pause.flux:to(tween, 0.5, {value = 1})
					:ease 'quadin'
					:onupdate(function()
						-- local fadeTo = color.labLerp(0.25, color.background, color.white)
						local fadeTo = color.black
						pause.fadeColor = color.labLerp(tween.value, color.withAlpha(fadeTo, 0), fadeTo)
					end)
					:after(0.25, {})
					:oncomplete(function()
						scene:pop()
						gotoMenu()
					end)
			end
		end
	end
	
	-- do -- Back button
	-- 	local backButton = button 'Back'
		
	-- 	function backButton:action()
	-- 		scene:pop()
	-- 	end
	-- end
	
	self:resize(love.graphics.getDimensions() as (integer, integer))
	
	local mpos = self.ui.buttons[1].pos + self.ui.buttons[1].size / 2
	love.mouse.setPosition(mpos.x, mpos.y)
end

function Pause:mousepressed(...)
	self.ui:mousepressed(... as nil)
end

function Pause:mousereleased(...)
	self.ui:mousereleased(... as nil)
end

function Pause:draw()
	-- love.graphics.clear(color.withAlpha(color.black, 1))
	self.prev:draw()
	
	if scene._scenes[#scene._scenes] as Pause == self then
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
end

function Pause:update(dt: number)
	-- self.prev:update(dt)
	self.flux:update(dt)
end

return Pause