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
	
	record SafeDrag
		startPos: vec2
	end
	safeDrag: SafeDrag
	
	selected: {Data.UID:boolean}
	
	enum Mode
		'select' 'move' 'point' 'pin' 'link' 'player' 'end' 'safezone'
	end
	mode: Mode
	
	enum ModalOp
		'save' 'open'
	end
	
	record ModalContext
		op: ModalOp
		filename: string
	end
	
	font: love.graphics.Font
	bigFont: love.graphics.Font
	data: Data
	gridStep: vec2
	filename: string
	
	__index: Editor
end
Editor.__index = Editor

function Editor.new(): Editor
	return setmetatable({}, Editor)
end

local record EditorModal
	editor: Editor
	ctx: Editor.ModalContext
	text: string
	font: love.graphics.Font
	__index: EditorModal
end
EditorModal.__index = EditorModal

function EditorModal.new(): EditorModal
	return setmetatable({}, EditorModal)
end

local modes: {Editor.Mode} = {'select', 'move', 'point', 'pin', 'link', 'player', 'end', 'safezone'}
local modeIndices: {Editor.Mode:integer} = {}
for i, mode in ipairs(modes) do
	modeIndices[mode] = i
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
	elseif self.data.safezones[uid] then
		self.data.safezones[uid] = nil
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
	for uid in pairs(self.data.safezones) do
		self.selected[uid] = true
	end
end

function Editor:getClosestPoint(wx: number, wy: number): level.Data.Point, number
	local closest: level.Data.Point
	local distance2 = 1 / 0
	for _, point in pairs(self.data.points) do
		local newDistance2 = (point.pos - vec2(wx, wy)).length2
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

function Editor:isSelected(uid: level.Data.UID): boolean
	return self.selected[uid]
end

function Editor:isVecInSelection(wpos: vec2): boolean
	local topLeft, bottomRight = self:getSelectionCorners()
	if not topLeft then return false end
	local spos = vec2(self.camera:toScreen(wpos:split()))
	return spos.x >= topLeft.x and spos.y >= topLeft.y and spos.x < bottomRight.x and spos.y < bottomRight.y
end

function Editor:isHovered(uid: level.Data.UID): boolean
	local hpoint = self:getHoveredPoint()
	return hpoint and hpoint.uid == uid
end

function Editor:properColor(uid: level.Data.UID, col: {number}): {number}
	return color.contextual(col, self:isHovered(uid), self:isSelected(uid))
end

function Editor:moveUID(uid: level.Data.UID, move: vec2, relative: boolean): boolean
	local point = self.data.points[uid]
	if point then
		point.pos = (relative and point.pos or vec2()) + move
		return true
	end
	
	local safezone = self.data.safezones[uid]
	if safezone then
		safezone.pos = (relative and safezone.pos or vec2()) + move
		return true
	end
	
	return false
end

function Editor:newUID(): string
	self.data.lastUID = self.data.lastUID + 1
	return tostring(self.data.lastUID)
end

function Editor:doSave(filename: string)
	if filename and filename ~= '' then
		local data = level.encode(self.data)
		local filepath = '../../asset/level/' .. filename .. '.json'
		local stream = io.open(filepath, 'wb')
		if stream then
			stream:write(data)
			stream:close()
			self.filename = filename
			log.info(string.format('saved file to %q', filepath))
		else
			log.error(string.format('could not open file %q', filepath))
		end
	else
		log.error 'no filename present'
	end
end

function Editor:doOpen(filename: string)
	if filename and filename ~= '' then
		local filepath = '../../asset/level/' .. filename .. '.json'
		local stream = io.open(filepath, 'rb')
		if stream then
			local data = stream:read()
			stream:close()
			self.data = level.decode(data)
			self.filename = filename
			log.info(string.format('opened file %q', filepath))
		else
			log.error(string.format('could not open file %q', filepath))
		end
	else
		log.error 'no filename present'
	end
end

function Editor:addSafezone(safezone: level.Data.Safezone)
	safezone.uid = safezone.uid or self:newUID()
	self.data.safezones[safezone.uid] = safezone
end

function Editor:enter()
	self.camera = cam11(0, 0, 1, 0, 0, 0)
	self.mode = modes[1]
	self.font = love.graphics.newFont(16)
	self.bigFont = asset.font['Baloo2-Medium'](48)
	self.font:setLineHeight(1.25)
	
	local data <total>: level.Data = {
		points    = {},
		links     = {},
		safezones = {},
		player    = vec2(0, 0),
		lastUID   = 0,
		levelEnd  = vec2(100, 0),
		
		-- Yikes
		UID      = nil,
		Link     = nil,
		Point    = nil,
		Safezone = nil,
	}
	self.data = data
	
	self.selected = {}
	self.gridStep = vec2(15, 15)
	
	local defaultSafezone <total>: level.Data.Safezone = {
		uid = nil,
		radius = 500,
		pos = (data.player + data.levelEnd) / 2,
	}
	self:addSafezone(defaultSafezone)
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
				pos = wpos.copy,
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
		
		if self.mode == 'safezone' then
			self.safeDrag = {
				startPos = wpos.copy
			}
		end
		
		if self.mode == 'player' or self.mode == 'end' then
			self:deselectAll()
		end
	end
end

function Editor:mousereleased(mx: integer, my: integer, button: integer)
	if button == 3 then
		self.drag = nil
	end
	
	local wpos = vec2(self.camera:toWorld(mx, my))
	if button == 1 then
		if self:getSelectionCorners() then
			if not love.keyboard.isDown('lshift', 'rshift') then
				self.selected = {}
			end
			for uid, point in pairs(self.data.points) do
				if self:isVecInSelection(point.pos) then
					self.selected[uid] = true
				end
			end
			for uid, safezone in pairs(self.data.safezones) do
				if self:isVecInSelection(safezone.pos) then
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
		
		if self.safeDrag then
			local radius = (wpos - self.safeDrag.startPos).length
			local safezone <total>: level.Data.Safezone = {
				uid = nil,
				pos = self.safeDrag.startPos.copy,
				radius = radius,
			}
			self:addSafezone(safezone)
		end
		
		self.safeDrag = nil
		self.link = nil
		self.selection = nil
		self.move = nil
	end
end

function Editor:update(_: number)
	local wpos = vec2(self.camera:toWorld(love.mouse.getPosition()))
	if self.drag then
		local start = self.drag.startPos.copy
		local delta = start - wpos
		local camPos = vec2(self.camera:getPos())
		self.camera:setPos((camPos + delta):split())
	end
	
	if self.move then
		local delta = wpos - self.move.lastPos
		self.move.lastPos = wpos.copy
		for uid in pairs(self.selected) do
			self:moveUID(uid, delta, true)
		end
	end
	
	if self.mode == 'player' then
		if love.mouse.isDown(1) then
			self.data.player = wpos.copy
		end
	end
	
	if self.mode == 'end' then
		if love.mouse.isDown(1) then
			self.data.levelEnd = wpos.copy
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
	
	love.graphics.clear(color.background)
	
	local wpos = vec2(self.camera:toWorld(love.mouse.getPosition()))
	do -- Draw links
		love.graphics.setLineWidth(config.link.lineWidth)
		love.graphics.setColor(color.link)
		for _, link in pairs(self.data.links) do
			local a = self.data.points[link.a].pos.copy
			local b = self.data.points[link.b].pos.copy
			local delta = (b - a).normalized
			a = a + delta * config.point.radius
			b = b - delta * config.point.radius
			love.graphics.line(a.x, a.y, b.x, b.y)
		end
		
		-- Draw current link
		if self.link then
			love.graphics.setColor(color.labLerp(0.5, color.link, color.white))
			local a = self.data.points[self.link.startUID].pos.copy
			local b = wpos.copy
			local delta = (b - a).normalized
			a = a + delta * config.point.radius
			-- b = b - delta * config.point.radius
			local hpoint = self:getHoveredPoint()
			if hpoint and hpoint.uid ~= self.link.startUID then
				b = hpoint.pos.copy
			end
			love.graphics.line(a.x, a.y, b.x, b.y)
		end
	end
	
	do -- Draw points
		love.graphics.setLineWidth(config.point.lineWidth)
		for uid, point in pairs(self.data.points) do
			love.graphics.setColor(self:properColor(uid, color.point))
			
			love.graphics.circle('line', point.pos.x, point.pos.y, config.point.radius)
			if point.pinned then
				love.graphics.circle('fill', point.pos.x, point.pos.y, config.point.pinRadius)
			end
		end
	end
	
	do -- Draw player
		local pos = self.data.player
		love.graphics.setColor(color.player)
		love.graphics.setLineWidth(3)
		love.graphics.circle('fill', pos.x, pos.y, config.player.body.radius, 64)
		love.graphics.setColor(color.background)
		love.graphics.printf({{1, 1, 1, 1}, 'P'}, self.bigFont, pos.x - 16, math.floor(pos.y - self.bigFont:getHeight() / 2), 32, 'center')
	end
	
	do -- Draw level end
		local pos = self.data.levelEnd
		love.graphics.setColor(color.exit)
		love.graphics.setLineWidth(8)
		love.graphics.circle('line', pos.x, pos.y, config.exit.radius, 64)
		love.graphics.printf({{1, 1, 1, 1}, 'E'}, self.bigFont, pos.x - 16, math.floor(pos.y - self.bigFont:getHeight() / 2), 32, 'center')
	end
	
	do -- Draw safezone marker and stencil
		local safezones = self.data.safezones
		if self.safeDrag then
			local pos = self.safeDrag.startPos
			local uid = '0'
			local drag <total>: level.Data.Safezone = {
				uid = uid,
				pos = pos.copy,
				radius = (wpos - pos).length,
			}
			safezones = util.merge(safezones, {[uid] = drag})
		end
		for uid, safezone in pairs(safezones) do
			local pos = safezone.pos
			love.graphics.setColor(self:properColor(uid, color.safe))
			love.graphics.printf({{1, 1, 1, 1}, 'S'}, self.bigFont, pos.x - 16, math.floor(pos.y - self.bigFont:getHeight() / 2), 32, 'center')
		end
		love.graphics.stencil(function()
			for _, safezone in pairs(safezones) do
				love.graphics.circle('fill', safezone.pos.x, safezone.pos.y, safezone.radius)
			end
		end)
	end
	
	self.camera:detach()
	
	love.graphics.setStencilTest('notequal', 1)
	love.graphics.setColor(color.withAlpha(color.unsafe, 0.75))
	love.graphics.rectangle('fill', 0, 0, love.graphics.getDimensions())
	love.graphics.setStencilTest()
	
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
			local col: color.RGBA = {vivid.LCHtoRGB(10, 20, 10, 0.8)}
			if self.mode == mode then
				col = {vivid.LCHtoRGB(70, 50, 240, 0.9)}
			end
			
			local text = string.format('%d: %s\n', i, mode)
			
			table.insert(textArray, col)
			table.insert(textArray, text)
		end
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.printf(textArray, self.font, 8, 8, 500)
	end
end

function EditorModal:enter(editor: Editor, ctx: Editor.ModalContext)
	self.editor = editor
	self.ctx = ctx
	self.text = ctx.filename or ''
	self.font = love.graphics.newFont(32)
end

function EditorModal:draw()
	self.editor:draw()
	
	love.graphics.push 'all'
	
	love.graphics.setColor(0, 0, 0, 0.5)
	love.graphics.rectangle('fill', 0, 0, love.graphics.getDimensions())
	
	local gw, gh = love.graphics.getDimensions()
	if self.ctx.op == 'save' or self.ctx.op == 'open' then
		love.graphics.setColor(1, 1, 1, 1)
		local x = math.floor(gw / 2 - 200)
		local y = math.floor(gh * 2 / 3 - self.font:getHeight() / 2)
		love.graphics.printf({{1, 1, 1, 1}, self.text}, self.font, x, y, 400, 'center')
	end
	
	love.graphics.pop()
end

function EditorModal:textinput(text: string)
	self.text = self.text .. text
end

function EditorModal:keypressed(key: string)
	if key == 'escape' then
		scene:pop()
		return
	end
	
	if key == 'return' then
		if self.ctx.op == 'save' or self.ctx.op == 'open' then
			scene:pop(self.text)
		else
			log.warn('unknown op: ' .. tostring(self.ctx.op))
			scene:pop()
		end
		return
	end
	
	if key == 'backspace' then
		-- FIXME: this doesn't deal with UTF8
		self.text = self.text:sub(1, -2)
	end
end

function Editor:resume(modal: EditorModal, data: string)
	if modal.ctx then
		if modal.ctx.op == 'save' then
			self:doSave(data)
		elseif modal.ctx.op == 'open' then
			self:doOpen(data)
		else
			log.warn('unknown op: ' .. tostring(modal.ctx.op))
		end
	end
end

function Editor:keypressed(key: string)
	if key == 'f5' then
		scene:push(require 'scene.game'.new(), self.data)
		return
	end
	
	local num: integer = tonumber(key)
	if num and modes[num] then
		self.mode = modes[num]
		return
	end
	
	if key == 'delete' or key == 'x' then
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
	
	if key == 's' and love.keyboard.isDown('lctrl', 'rctrl') then
		if not self.filename or love.keyboard.isDown('lshift', 'rshift') then
			local ctx: Editor.ModalContext = {
				op = 'save',
				filename = self.filename,
			}
			scene:push(EditorModal.new(), ctx)
		else
			self:doSave(self.filename)
		end
		return
	end
	
	if key == 'o' and love.keyboard.isDown('lctrl', 'rctrl') then
		local ctx: Editor.ModalContext = {
			op = 'open',
			filename = self.filename,
		}
		scene:push(EditorModal.new(), ctx)
		return
	end
	
	if key == 'n' and love.keyboard.isDown('lctrl', 'rctrl') then
		scene:enter(Editor.new())
		return
	end
	
	if key == 'p' then
		self.camera:setPos(self.data.player.x, self.data.player.y)
		self.camera:setZoom(1)
		return
	end
end

return Editor