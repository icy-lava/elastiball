local record roomy
	type Scene = {SceneEvent:function(self: Scene, ...: any)}
	
	enum LoveEvent
		'directorydropped'
		'draw'
		'filedropped'
		'focus'
		'gamepadaxis'
		'gamepadpressed'
		'gamepadreleased'
		'joystickaxis'
		'joystickhat'
		'joystickpressed'
		'joystickreleased'
		'joystickremoved'
		'keypressed'
		'keyreleased'
		'load'
		'lowmemory'
		'mousefocus'
		'mousemoved'
		'mousepressed'
		'mousereleased'
		'quit'
		'resize'
		'run'
		'textedited'
		'textinput'
		'threaderror'
		'touchmoved'
		'touchpressed'
		'touchreleased'
		'update'
		'visible'
		'wheelmoved'
		'joystickadded'
	end
	
	enum SceneEvent
		'enter'
		'leave'
		'directorydropped'
		'draw'
		'filedropped'
		'focus'
		'gamepadaxis'
		'gamepadpressed'
		'gamepadreleased'
		'joystickaxis'
		'joystickhat'
		'joystickpressed'
		'joystickreleased'
		'joystickremoved'
		'keypressed'
		'keyreleased'
		'load'
		'lowmemory'
		'mousefocus'
		'mousemoved'
		'mousepressed'
		'mousereleased'
		'quit'
		'resize'
		'run'
		'textedited'
		'textinput'
		'threaderror'
		'touchmoved'
		'touchpressed'
		'touchreleased'
		'update'
		'visible'
		'wheelmoved'
		'joystickadded'
	end
	
	record Options
		include: {LoveEvent}
		exclude: {LoveEvent}
	end
	
	record Manager
		_scenes: {Scene}
		
		emit: function(self: Manager, event: SceneEvent, ...: any)
		enter: function(self: Manager, next: Scene, ...: any)
		push: function(self: Manager, next: Scene)
		pop: function(self: Manager, next: Scene)
		hook: function(self: Manager, options: Options)
	end
	
	new: function(): Manager
end

return roomy