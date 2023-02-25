local record Button
	pos: vec2
	size: vec2
	text: string
	color: color.RGB
	hoverColor: color.RGB
	textColor: color.RGB
	font: love.graphics.Font
	cornerRadius: number
	action: function(self: Button)
	parent: ButtonSet
	__index: Button
end
Button.__index = Button

function Button.new(): Button
	return setmetatable({pos = vec2(), size = vec2(16, 16)}, Button)
end

function Button:corners(): vec2, vec2
	return self.pos, self.pos + self.size
end

function Button:isHovered(): boolean
	local mpos = vec2(love.mouse.getPosition())
	local pos1, pos2 = self:corners()
	return mpos.x >= pos1.x and mpos.x < pos2.x and mpos.y >= pos1.y and mpos.y < pos2.y
end

local record ButtonSet
	-- focus: integer
	buttons: {Button}
	active: Button
	disabled: boolean
	__index: ButtonSet
end
ButtonSet.__index = ButtonSet

function ButtonSet.new(): ButtonSet
	return setmetatable({
		-- focus = 1,
		buttons = {},
	}, ButtonSet)
end

function ButtonSet:add(button: Button)
	table.insert(self.buttons, button)
	button.parent = self
end

function ButtonSet:getHoveredButton(): Button
	for _, button in ipairs(self.buttons) do
		if button:isHovered() then
			return button
		end
	end
	return nil
end

function ButtonSet:mousepressed(_, _, button: integer)
	if self.disabled then
		return
	end
	if button == 1 then
		local hovered = self:getHoveredButton()
		if hovered then
			self.active = hovered
		end
	end
end

function ButtonSet:mousereleased(_, _, button: integer)
	if button == 1 then
		if self.active then
			if self.active.action and self:getHoveredButton() == self.active then
				self.active:action()
			end
			self.active = nil
		end
	end
end

function Button:draw()
	love.graphics.push 'all'
	local _, _, _, alpha = love.graphics.getColor()
	local font = self.font or love.graphics.getFont()
	local text = self.text or ''
	local pos = self.pos
	local size = self.size
	local theight = util.round(pos.y + (size.y - font:getHeight()) / 2)
	local radius = self.cornerRadius or 6
	
	local col = self.color or color.white
	local ocol = self.textColor
	local l, c, h = vivid.RGBtoLCH(col)
	if not ocol then
		local ol, oc = 100 - l, 100 - c
		ocol = {vivid.LCHtoRGB(ol, oc, h)}
	end
	local parent = self.parent
	if parent then
		local hovered = parent:getHoveredButton() == self
		local active = parent.active == self
		if hovered ~= active then
			col = self.hoverColor or {vivid.LCHtoRGB(l + 20, c, h)}
		end
	end
	
	love.graphics.setColor(color.withAlpha(col, alpha))
	love.graphics.rectangle('fill', pos.x, pos.y, size.x, size.y, radius)
	love.graphics.setColor(color.withAlpha(ocol, alpha))
	love.graphics.printf(text, font, pos.x, theight, size.x, 'center')
	love.graphics.pop()
end

function ButtonSet:draw()
	for i = #self.buttons, 1, -1 do
		self.buttons[i]:draw()
	end
end

return {
	Button = Button,
	ButtonSet = ButtonSet
}