local record level
	record Data
		type UID = string
		record Link
			uid: UID
			a: UID
			b: UID
		end
		
		record Position
			x: number
			y: number
		end
		
		record Point
			uid: UID
			pos: Position
			pinned: boolean
		end
		
		player: Position
		levelEnd: Position
		points: {UID:Point}
		links: {UID:Link}
		lastUID: integer
	end
end

function level.decode(str: string): level.Data
	local data = json.decode(str) as level.Data
	data.levelEnd = data.levelEnd or {x = 0, y = 0}
	return data
end

function level.encode(data: level.Data): string
	return json.encode(data as json.Value)
end

function level.load(path: string): level.Data
	local data = love.filesystem.read(path)
	return level.decode(data)
end

return level