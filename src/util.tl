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

function util.crect(mode: love.graphics.DrawMode, x: number, y: number, width: number, height: number, round: number)
	local x1, y1 = x - width / 2, y - height / 2
	local x2, y2 = x1 + width, y1 + height
	x1, y1, x2, y2 = util.round(x1), util.round(y1), util.round(x2), util.round(y2)
	love.graphics.rectangle(mode, x1, y1, x2 - x1, y2 - y1, round)
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

function util.findSystemInstance<T, U>(systems: {tiny.System<U>}, class: tiny.System<T>): tiny.System<T>
	for _, syst in ipairs(systems as {tiny.System<any>}) do
		if syst.filter == class.filter then
			return syst as tiny.System<T>
		end
	end
	return nil
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

return util