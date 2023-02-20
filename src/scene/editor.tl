local record Editor
	type Data = level.Data
	
	camera: cam11.Camera
	
	record Drag
		startPos: vec2
	end
	drag: Drag
	
	record Selection
		startPos: vec2
	end
	selection: Selection
	
	record Move
		lastPos: vec2
	end
	move: Move
	
	record Link
		startUID: Data.UID
	end
	link: Link
	
	selected: {Data.UID:boolean}
	
	enum Mode
		'select' 'move' 'point' 'pin' 'link' 'player'
	end
	mode: Mode
	font: love.graphics.Font
	data: Data
	gridStep: vec2
	
	__index: Editor
end
Editor.__index = Editor

local modes: {Editor.Mode} = {'select', 'move', 'point', 'pin', 'link', 'player'}
local modeIndices: {Editor.Mode:integer} = {}
for i, mode in ipairs(modes) do
	modeIndices[mode] = i
end

local function vec2pos(v: vec2): level.Data.Position
	return {x = v.x, y = v.y}
end

local function pos2vec(p: level.Data.Position): vec2
	return vec2(p.x, p.y)
end

local function pos2(x: number, y: number): level.Data.Position
	return {x = x or 0, y = y or 0}
end

function Editor:getSelectionCorners(): vec2, vec2
	if self.selection then
		local start = vec2(self.camera:toScreen(self.selection.startPos.x, self.selection.startPos.y))
		local current = vec2(love.mouse.getPosition())
		return util.getCorners(start, current, 6)
	end
	return nil
end

function Editor:deleteUID(uid: level.Data.UID)
	if self.data.points[uid] then
		self.data.points[uid] = nil
		for luid, link in pairs(self.data.links) do
			if link.a == uid or link.b == uid then
				self:deleteUID(luid)
			end
		end
	elseif self.data.links[uid] then
		self.data.links[uid] = nil
	else
		log.warn('tried to delete a non-existant uid: ' .. tostring(uid))
	end
end

function Editor:deleteSelection()
	for uid in pairs(self.selected) do
		self:deleteUID(uid)
	end
end

function Editor:deselectAll()
	self.selected = {}
end

function Editor:selectAll()
	self.selected = {}
	for uid in pairs(self.data.points) do
		self.selected[uid] = true
	end
end

function Editor:getClosestPoint(wx: number, wy: number): level.Data.Point, number
	local closest: level.Data.Point
	local distance2 = 1 / 0
	for _, point in pairs(self.data.points) do
		local newDistance2 = (pos2vec(point.pos) - vec2(wx, wy)).length2
		if newDistance2 < distance2 then
			closest = point
			distance2 = newDistance2
		end
	end
	return closest, distance2 ^ 0.5
end

function Editor:getHoveredPoint(): level.Data.Point
	local point, distance = self:getClosestPoint(self.camera:toWorld(love.mouse.getPosition()))
	if distance < 30 then
		return point
	end
	return nil
end

function Editor:newUID(): string
	self.data.lastUID = self.data.lastUID + 1
	return tostring(self.data.lastUID)
end

function Editor:enter()
	self.camera = cam11(0, 0, 1, 0, 0, 0)
	self.mode = modes[1]
	self.font = love.graphics.newFont(16)
	self.font:setLineHeight(1.25)
	self.data = {
		points = {},
		links = {},
		player = {x = 0, y = 0},
		lastUID = 0,
	}
	self.selected = {}
	self.gridStep = vec2(15, 15)
end

function Editor:wheelmoved(_: number, dy: number)
	local mx, my = love.mouse.getPosition()
	local startPos = vec2(self.camera:toWorld(mx, my))
	
	local scale = 2 ^ (dy / 4)
	self.camera:setZoom(self.camera:getZoom() * scale)
	
	local newPos = vec2(self.camera:toWorld(mx, my))
	local delta = startPos - newPos
	self.camera:setPos(self.camera:getX() + delta.x, self.camera:getY() + delta.y)
end

function Editor:keypressed(key: string)
	local num: integer = tonumber(key)
	if num and modes[num] then
		self.mode = modes[num]
		return
	end
	
	if key == 'delete' then
		self:deleteSelection()
		return
	end
	
	if key == 'a' and love.keyboard.isDown('lctrl', 'rctrl') then
		if love.keyboard.isDown('lshift', 'rshift') then
			self:deselectAll()
		else
			self:selectAll()
		end
		return
	end
end

function Editor:mousepressed(x: integer, y: integer, button: integer)
	local wpos = vec2(self.camera:toWorld(x, y))
	
	if button == 3 then
		self.drag = {startPos = wpos.copy}
		return
	end
	
	if button == 1 then
		if self.mode == 'select' then
			self.selection = {
				startPos = wpos.copy
			}
			return
		end
		
		if self.mode == 'move' then
			self.move = {
				lastPos = wpos.copy
			}
			return
		end
		
		if self.mode == 'point' then
			local uid = self:newUID()
			self.data.points[uid] = {
				uid = uid,
				pos = vec2pos(wpos),
				pinned = false,
			}
			self:deselectAll()
			return
		end
		
		if self.mode == 'pin' then
			local point = self:getHoveredPoint()
			if point then
				point.pinned = not point.pinned
			end
			self:deselectAll()
			return
		end
		
		if self.mode == 'link' then
			local point = self:getHoveredPoint()
			if point then
				self.link = {
					startUID = point.uid
				}
			end
			self:deselectAll()
			return
		end
		
		if self.mode == 'player' then
			self:deselectAll()
		end
	end
end

function Editor:mousereleased(x: integer, y: integer, button: integer)
	if button == 3 then
		self.drag = nil
	end
	
	if button == 1 then
		local topLeft, bottomRight = self:getSelectionCorners()
		if topLeft then
			if not love.keyboard.isDown('lshift', 'rshift') then
				self.selected = {}
			end
			for uid, point in pairs(self.data.points) do
				local spos = vec2(self.camera:toScreen(point.pos.x, point.pos.y))
				if
					spos.x >= topLeft.x and spos.y >= topLeft.y and
					spos.x < bottomRight.x and spos.y < bottomRight.y
				then
					self.selected[uid] = true
				end
			end
		end
		
		if self.link then
			local point = self:getHoveredPoint()
			local a, b = self.link.startUID, point and point.uid
			if point and a ~= b then
				local unique = true
				for _, link in pairs(self.data.links) do
					if (link.a == a and link.b == b) or (link.b == a and link.a == b) then
						unique = false
						break
					end
				end
				if unique then
					local uid = self:newUID()
					self.data.links[uid] = {
						uid = uid,
						a = a,
						b = b,
					}
				end
			end
		end
		
		self.link = nil
		self.selection = nil
		self.move = nil
	end
end

function Editor:update(_: number)
	if self.drag then
		local start = self.drag.startPos.copy
		local current = vec2(self.camera:toWorld(love.mouse.getPosition()))
		local delta = start - current
		self.camera:setPos(self.camera:getX() + delta.x, self.camera:getY() + delta.y)
	end
	
	if self.move then
		local wpos = vec2(self.camera:toWorld(love.mouse.getPosition()))
		local delta = wpos - self.move.lastPos
		self.move.lastPos = wpos.copy
		for uid in pairs(self.selected) do
			local point = self.data.points[uid]
			point.pos = vec2pos(pos2vec(point.pos) + delta)
		end
	end
	
	if self.mode == 'player' then
		if love.mouse.isDown(1) then
			self.data.player = pos2(self.camera:toWorld(love.mouse.getPosition()))
		end
	end
end

function Editor:resize()
	self.camera:setDirty()
end

function Editor:draw()
	-- World
	love.graphics.push 'all'
	self.camera:attach()
	
	love.graphics.clear(vivid.LCHtoRGB(10, 20, 230, 1))
	
	do -- Draw points
		local hpoint = self:getHoveredPoint()
		love.graphics.setLineWidth(3)
		for uid, point in pairs(self.data.points) do
			if hpoint and hpoint.uid == uid then
				love.graphics.setColor(vivid.LCHtoRGB(95, 60, 240))
			elseif self.selected[uid] then
				love.graphics.setColor(vivid.LCHtoRGB(60, 80, 240))
			else
				love.graphics.setColor(vivid.LCHtoRGB(50, 10, 240))
			end
			
			love.graphics.circle('line', point.pos.x, point.pos.y, 10)
			if point.pinned then
				love.graphics.circle('fill', point.pos.x, point.pos.y, 5)
			end
		end
	end
	
	do -- Draw links
		love.graphics.setLineWidth(3)
		love.graphics.setColor(vivid.LCHtoRGB(50, 30, 240, 0.2))
		for _, link in pairs(self.data.links) do
			local a = self.data.points[link.a].pos
			local b = self.data.points[link.b].pos
			love.graphics.line(a.x, a.y, b.x, b.y)
		end
		
		-- Draw current link
		if self.link then
			local a = self.data.points[self.link.startUID].pos
			local b = pos2(self.camera:toWorld(love.mouse.getPosition()))
			local hpoint = self:getHoveredPoint()
			if hpoint and hpoint.uid ~= self.link.startUID then
				b = hpoint.pos
			end
			love.graphics.line(a.x, a.y, b.x, b.y)
		end
	end
	
	do -- Draw player
		local pos = self.data.player
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.setLineWidth(5)
		love.graphics.circle('line', pos.x, pos.y, 16)
		love.graphics.printf({{1, 1, 1, 1}, 'P'}, self.font, pos.x - 16, math.floor(pos.y - self.font:getHeight() / 2), 32, 'center')
	end
	
	self.camera:detach()
	love.graphics.pop()
	
	-- UI
	love.graphics.push 'all'
	
	do -- Draw selection
		local topLeft, bottomRight = self:getSelectionCorners()
		if topLeft then
			local size = bottomRight - topLeft
			love.graphics.setColor(vivid.LCHtoRGB(80, 50, 240, 0.1))
			love.graphics.rectangle('fill', topLeft.x, topLeft.y, size.x, size.y, 6)
			love.graphics.setColor(vivid.LCHtoRGB(50, 70, 240, 0.5))
			love.graphics.setLineWidth(3)
			love.graphics.rectangle('line', topLeft.x, topLeft.y, size.x, size.y, 6)
		end
	end
	
	love.graphics.pop()
	
	do -- Draw mode info
		local textArray: {table|string} = {}
		for i, mode in ipairs(modes) do
			local color: {number, number, number, number} = {vivid.LCHtoRGB(40, 20, 10, 0.8)}
			if self.mode == mode then
				color = {vivid.LCHtoRGB(60, 30, 240, 0.9)}
			end
			
			local text = string.format('%d: %s\n', i, mode)
			
			table.insert(textArray, color)
			table.insert(textArray, text)
		end
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.printf(textArray, self.font, 8, 8, 500)
	end
end

function Editor.new(): Editor
	return setmetatable({}, Editor)
end

return Editor