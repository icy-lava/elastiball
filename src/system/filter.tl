local record filter
	
end

function filter.vector(field: string): tiny.EntityFilter
	return function(_: tiny.System, entity: tiny.Entity): boolean
		return vec2.isVector(entity[field])
	end
end

local enum Type
	'number'
	'boolean'
	'string'
	'nil'
	'function'
	'table'
	'userdata'
	'cdata'
end

function filter.type(field: string, typ: Type): tiny.EntityFilter
	return function(_: tiny.System, entity: tiny.Entity): boolean
		return type(entity[field]) == typ
	end
end

function filter.typeOrNil(field: string, typ: Type): tiny.EntityFilter
	return tiny.requireAny(filter.type(field, typ), filter.type(field, 'nil'))
end

return filter