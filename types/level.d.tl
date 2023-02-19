local record level
	record Data
		record Link
			a: integer
			b: integer
		end
		
		player: vec2
		points: {vec2}
		links: {Link}
		isPinned: {integer:boolean}
	end
	
	decode: function(str: string): Data
end

return level