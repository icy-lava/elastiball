local record cam11
	type Transform = love.math.Transform
	record Camera
		attach: function(self: Camera, clip: boolean)
		detach: function(self: Camera)
		
		setDirty: function(self: Camera, dirty: boolean)
		setPos: function(self: Camera, x: number, y: number)
		setZoom: function(self: Camera, zoom: number)
		setAngle: function(self: Camera, angle: number)
		setViewport: function(self: Camera, x: integer, y: integer, w: integer, h: integer, fx: number, fy: number)
		
		toScreen: function(self: Camera, x: number, y: number): number, number
		toWorld: function(self: Camera, x: number, y: number): number, number
		
		getTransform: function(self: Camera): Transform
		getPos: function(self: Camera): number, number
		getX: function(self: Camera): number
		getY: function(self: Camera): number
		getZoom: function(self: Camera): number
		getAngle: function(self: Camera): number
		getViewport: function(self: Camera): integer, integer, integer, integer, number, number
		getVPTopLeft: function(self: Camera): number, number
		getVPBottomRight: function(self: Camera): number, number
		getVPFocusPoint: function(self: Camera): number, number
	end
	
	new: function(
		x: number, y: number, zoom: number, angle: number,
		viewport_x: integer, viewport_y: integer, viewport_w: integer, viewport_h: integer,
		focus_x: number, focus_y: number
	): Camera
	metamethod __call: function(
		self: cam11,
		x: number, y: number, zoom: number, angle: number,
		viewport_x: integer, viewport_y: integer, viewport_w: integer, viewport_h: integer,
		focus_x: number, focus_y: number
	): Camera
end

return cam11