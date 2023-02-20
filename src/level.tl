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
	
	decode: function(str: string): Data
end

return level