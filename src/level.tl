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
		points: {UID:Point}
		links: {UID:Link}
		lastUID: integer
	end
end

function level.decode(str: string): level.Data
	return json.decode(str) as level.Data
end

function level.encode(data: level.Data): string
	return json.encode(data as json.Value)
end

return level