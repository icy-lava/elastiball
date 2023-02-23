return {
	particle = {
		scaleToUnit = 1 / 512
	},
	player = {
		heat = {
			up = 5,
			down = 2,
		},
		body = {
			radius = 24,
			mass = 5,
		},
		reticle = {
			radius = 12,
			distance = 100
		}
	},
	point = {
		radius = 20,
		pinRadius = 10,
		lineWidth = 6,
	},
	link = {
		lineWidth = 8,
	},
	mouse = {
		baseSensitivity = 0.01
	},
	input = baton.new {
		controls = {
			moveLeft  = {'key:left', 'key:a', 'axis:leftx-', 'button:dpleft'},
			moveRight = {'key:right', 'key:d', 'axis:leftx+', 'button:dpright'},
			moveUp    = {'key:up', 'key:w', 'axis:lefty-', 'button:dpup'},
			moveDown  = {'key:down', 'key:s', 'axis:lefty+', 'button:dpdown'},
			aimLeft   = {'axis:rightx-'},
			aimRight  = {'axis:rightx+'},
			aimUp     = {'axis:righty-'},
			aimDown   = {'axis:righty+'},
			grab      = {'key:space', 'mouse:1', 'button:a', 'button:rightshoulder', 'axis:triggerright+'},
			boost     = {'key:lctrl', 'mouse:2', 'button:b', 'button:leftshoulder', 'axis:triggerleft+'},
		},
		pairs = {
			move = {'moveLeft', 'moveRight', 'moveUp', 'moveDown'},
			aim =  {'aimLeft', 'aimRight', 'aimUp', 'aimDown'},
		},
		deadzone = 0.2,
		joystick = love.joystick.getJoysticks()[1],
	},
	exit = {
		radius = 300
	}
}