local record shapes
	enum DrawMode 'fill' 'line' end
	type Shape = record
		move: function(self: Shape, x: number, y: number)
		moveTo: function(self: Shape, x: number, y: number)
		rotate: function(self: Shape, angle: number, cx: number, cy: number)
		setRotation: function(self: Shape, angle: number, cx: number, cy: number)
		scale: function(self: Shape, s: number)
		
		center: function(self: Shape): number, number
		rotation: function(self: Shape): number
		outcircle: function(self: Shape): number, number, number
		bbox: function(self: Shape): number, number, number, number
		support: function(self: Shape, dx: number, dy: number): number, number
		
		collidesWith: function(self: Shape, other: Shape): boolean, number, number
		contains: function(self: Shape, x: number, y: number): boolean
		intersectionsWithRay: function(self: Shape, x: number, y: number, dx: number, dy: number): {number}
		intersectsRay: function(self: Shape, x: number, y: number, dx: number, dy: number): boolean, number
		
		draw: function(self: Shape, mode: DrawMode)
	end
	
	newPolygonShape: function(...: number): Shape
	newCircleShape: function(cx: number, cy: number, radius: number): Shape
	newPointShape: function(x: number, y: number): Shape
end

return shapes