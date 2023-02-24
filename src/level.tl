local record level
	record Data
		type UID = string
		record Link
			uid: UID
			a: UID
			b: UID
		end
		
		record Point
			uid: UID
			pos: vec2
			pinned: boolean
		end
		
		record Safezone
			uid: UID
			pos: vec2
			radius: number
		end
		
		player: vec2
		levelEnd: vec2
		points: {UID:Point}
		links: {UID:Link}
		safezones: {UID:Safezone}
		lastUID: integer
	end
end

local function vec2pos(value: table)
	for k, v in pairs(value) do
		if vec2.isVector(v) then
			local vec = v as vec2
			value[k] = {x = vec.x, y = vec.y}
		elseif v is table then
			vec2pos(v)
		end
	end
end

local function pos2vec(value: table)
	for k, v in pairs(value) do
		if v is table then
			if v.x and v.y then
				value[k] = vec2(v.x as number, v.y as number)
			else
				pos2vec(v)
			end
		end
	end
end

function level.decode(str: string): level.Data
	local data = json.decode(str) as level.Data
	pos2vec(data as table)
	data.levelEnd = data.levelEnd or vec2()
	data.safezones = data.safezones or {}
	return data
end

function level.encode(data: level.Data): string
	vec2pos(data as table)
	local str = json.encode(data as json.Value)
	pos2vec(data as table)
	return str
end

function level.load(path: string): level.Data
	local data = love.filesystem.read(path)
	return level.decode(data)
end

return level