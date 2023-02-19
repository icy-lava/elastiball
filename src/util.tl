local record util
	
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