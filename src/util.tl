local record util
	mouseRel: vec2
end

function util.lerp<T>(t: number, a: T, b: T): T
	return ((a as number) * (1 - t) + (b as number) * t) as T
end

function util.damp<T>(smoothing: number, dt: number, a: T, b: T): T
	return util.lerp(1 - smoothing ^ dt, a, b)
end

function util.round(num: number): integer
	return math.floor(num + 0.5)
end

function util.perpendicular(vec: vec2): vec2
	return vec2(-vec.y, vec.x)
end

function util.cross(a: vec2, b: vec2): number
	return a.x * b.y - a.y * b.x
end

-- https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/reflect.xhtml
function util.reflect(vec: vec2, normal: vec2): vec2
	return vec - (2 * (vec * normal)) * normal
end

-- https://stackoverflow.com/a/51781408
function util.lineIntersect(p1: vec2, p2: vec2, p3: vec2, p4: vec2): vec2
	
	local detL1 = util.cross(p1, p2)
	local detL2 = util.cross(p3, p4)
	
	local delta1 = p1 - p2
	local delta2 = p3 - p4
	
	local xnom = util.cross(vec2(detL1, delta1.x), vec2(detL2, delta2.x))
	local ynom = util.cross(vec2(detL1, delta1.y), vec2(detL2, delta2.y))
	local denom = util.cross(delta1, delta2)
	
	if denom == 0 then
		return nil
	end
	
	return vec2(xnom / denom, ynom / denom)
end

function util.circleCorner(radius: number, v1: vec2, v2: vec2, v3: vec2): {vec2}
	local d1, d2 = v2 - v1, v3 - v2
	radius = math.min(radius, d1.length / 2, d2.length / 2)
	local n1, n2 = d1.normalized, d2.normalized
	local p1, p2 = util.perpendicular(n1) * radius, util.perpendicular(n2) * radius
	local dot = p1:dot(n2)
	if math.abs(dot) < 0.001 then return {v2} end
	if dot < 0 then
		p1 = -p1
		p2 = -p2
	end
	
	local c = util.lineIntersect(v1 + p1, v2 + p1, v2 + p2, v3 + p2)
	if not c then return {v2} end
	
	local c1, c2 = c - p1, c - p2
	
	local pcount = math.max(2, util.round((c2 - c1).length / 2))
	local points: {vec2} = {}
	for i = 0, pcount - 1 do
		local lerp = i / (pcount - 1)
		local p = util.lerp(lerp, p1, p2)
		p.length = radius
		points[i + 1] = c - p
	end
	return points
end

function util.roundedPoly(radius: number, points: {vec2}): {vec2}
	local newPoints: {vec2} = {}
	local pcount = #points
	for i = 0, pcount - 1 do
		local p1, p2, p3 = points[i + 1], points[(i + 1) % pcount + 1], points[(i + 2) % pcount + 1]
		for _, p in ipairs(util.circleCorner(radius, p1, p2, p3)) do
			table.insert(newPoints, p)
		end
	end
	return newPoints
end

function util.crect(mode: love.graphics.DrawMode, x: number, y: number, width: number, height: number, round: number)
	local x1, y1 = x - width / 2, y - height / 2
	local x2, y2 = x1 + width, y1 + height
	x1, y1, x2, y2 = util.round(x1), util.round(y1), util.round(x2), util.round(y2)
	love.graphics.rectangle(mode, x1, y1, x2 - x1, y2 - y1, round)
end

function util.drawCentered(drawable: love.graphics.Drawable, x: number, y: number, rot: number, scaleX: number, scaleY: number)
	local ox, oy = 0.0, 0.0
	if (drawable as love.Object):typeOf('Texture') then
		local texture = drawable as love.graphics.Texture
		ox, oy = texture:getDimensions()
		ox, oy = ox / 2, oy / 2
	end
	love.graphics.draw(drawable, x, y, rot, scaleX, scaleY, ox, oy)
end

function util.resetBaton()
	local prev = config.input
	config.input = baton.new {
		controls = {
			moveLeft  = {'key:left', 'sc:a', 'axis:leftx-', 'button:dpleft'},
			moveRight = {'key:right', 'sc:d', 'axis:leftx+', 'button:dpright'},
			moveUp    = {'key:up', 'sc:w', 'axis:lefty-', 'button:dpup'},
			moveDown  = {'key:down', 'sc:s', 'axis:lefty+', 'button:dpdown'},
			aimLeft   = {'axis:rightx-'},
			aimRight  = {'axis:rightx+'},
			aimUp     = {'axis:righty-'},
			aimDown   = {'axis:righty+'},
			grab      = {'mouse:1', 'button:a', 'button:rightshoulder', 'axis:triggerright+'},
			boost     = {},
		},
		pairs = {
			move = {'moveLeft', 'moveRight', 'moveUp', 'moveDown'},
			aim =  {'aimLeft', 'aimRight', 'aimUp', 'aimDown'},
		},
		deadzone = 0.2,
		joystick = love.joystick.getJoysticks()[1],
	}
	config.input._activeDevice = prev._activeDevice
end

function util.getLevelCount(): integer
	return 10
end

function util.system<T>(entity: T): tiny.System<T>
	local filt = typedef.filter[entity as nil]
	if not filt then
		error(string.format('unknown entity type (%s): %q', type(entity), entity))
	end
	local syst: tiny.System<T> = tiny.system()
	syst.filter = filt
	return syst
end

function util.processingSystem<T>(entity: T): tiny.System<T>
	local filt = typedef.filter[entity as nil]
	if not filt then
		error(string.format('unknown entity type (%s): %q', type(entity), entity))
	end
	local syst: tiny.System<T> = tiny.processingSystem()
	syst.filter = filt
	return syst
end

function util.sortedSystem<T>(entity: T): tiny.System<T>
	local filt = typedef.filter[entity as nil]
	if not filt then
		error(string.format('unknown entity type (%s): %q', type(entity), entity))
	end
	local syst: tiny.System<T> = tiny.sortedSystem()
	syst.filter = filt
	return syst
end

function util.sortedProcessingSystem<T>(entity: T): tiny.System<T>
	local filt = typedef.filter[entity as nil]
	if not filt then
		error(string.format('unknown entity type (%s): %q', type(entity), entity))
	end
	local syst: tiny.System<T> = tiny.sortedProcessingSystem()
	syst.filter = filt
	return syst
end

function util.drawSystem<T>(entity: T): tiny.System<T>
	local system: tiny.System<T> = util.processingSystem(entity)
	local temp = system as table
	temp.draw = true
	return system
end

function util.sortedDrawSystem<T>(entity: T): tiny.System<T>
	local system: tiny.System<T> = util.sortedProcessingSystem(entity)
	local temp = system as table
	temp.draw = true
	return system
end

function util.findSystemInstance<T, U>(systems: {tiny.System<U>}, class: tiny.System<T>): tiny.System<T>
	for _, syst in ipairs(systems as {tiny.System<any>}) do
		if syst.filter == class.filter then
			return syst as tiny.System<T>
		end
	end
	return nil
end

function util.findEntity<T>(entities: {tiny.Entity}, def: T): T
	local filt = typedef.filter[def as typedef.FullEntity]
	if not filt then
		error('def is not an entity definition')
	end
	for _, entity in ipairs(entities) do
		if filt(nil, entity) then
			return entity as T
		end
	end
	return nil
end

function util.findPlayer(entities: {tiny.Entity}): typedef.PlayerEntity
	return util.findEntity(entities, typedef.PlayerEntity)
end

function util.getCorners(a: vec2, b: vec2, pad: number): vec2, vec2
	pad = pad or 0
	local topLeft = vec2(math.min(a.x, b.x) - pad, math.min(a.y, b.y) - pad)
	local bottomRight = vec2(math.max(a.x, b.x) + pad, math.max(a.y, b.y) + pad)
	return topLeft, bottomRight
end

local function hex2nums(hex: string): {number}
	local nums: {number} = {}
	for match in hex:gsub('^#', ''):gmatch('..') do
		local num = tonumber(match, 16) / 255
		table.insert(nums, num)
	end
	return nums
end

function util.hex2rgb(hex: string): number, number, number
	local nums = hex2nums(hex)
	assert(#nums == 3, 'expected 3 elements in hex')
	return nums[1], nums[2], nums[3]
end

function util.hex2rgba(hex: string): number, number, number, number
	local nums = hex2nums(hex)
	assert(#nums == 4, 'expected 4 elements in hex')
	return nums[1], nums[2], nums[3], nums[4]
end

function util.instance<T>(t: T): T
	return setmetatable({} as T, {__index = t})
end

function util.levelNameToPath(name: string): string
	return string.format('asset/level/%s.json', name)
end

function util.levelExists(name: string): boolean
	local path = util.levelNameToPath(name)
	return not not love.filesystem.getInfo(path, 'file')
end

function util.ticksToSecs(ticks: integer): number
	return ticks / FPS
end

function util.secsToTicks(secs: number): integer
	return util.round(secs * FPS)
end

function util.imerge<T>(a: {T}, b: {T}): {T}
	local result: {T} = {}
	for i = 1, #a do
		result[i] = a[i]
	end
	for i = 1, #b do
		table.insert(result, b[i])
	end
	return result
end

function util.merge<K, V>(a: {K:V}, b: {K:V}): {K:V}
	local result: {K:V} = {}
	for k, v in pairs(a) do
		result[k] = v
	end
	for k, v in pairs(b) do
		result[k] = v
	end
	return result
end

return util