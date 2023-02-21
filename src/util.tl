local record util
	mouseRel: vec2
end

function util.lerp<T>(t: number, a: T, b: T): T
	return ((a as number) * (1 - t) + (b as number) * t) as T
end

function util.damp<T>(smoothing: number, dt: number, a: T, b: T): T
	return util.lerp(1 - smoothing ^ dt, a, b)
end

function util.drawSystem<T>(): tiny.System<T>
	local system: tiny.System<T> = tiny.processingSystem()
	local temp = system as table
	temp.draw = true
	return system
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

-- function util.validateValue<T>(value: any, template: T): T
-- 	if type(value) == type(template) then
-- 		if template is table then
-- 			for k, v in pairs(template) do
-- 				if not util.validateValue((value as table)[k], v) then
-- 					return nil
-- 				end
-- 			end
-- 		end
-- 		return value as T
-- 	end
-- 	return nil
-- end

return util