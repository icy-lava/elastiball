return {
	particle = {
		scaleToUnit = 1 / 512
	},
	reticle = {
		radius = 12,
		distance = 100
	},
	button = {
		size = vec2(280, 72),
		radius = 12,
		spacing = 24,
		pad = 48,
	},
	camera = {
		zoom = 1.25
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
	},
	solid = {
		cornerRadius = 16,
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
	input = baton.new {controls = {},},
	inputDummy = baton.new {
		controls = {
			moveLeft  = {},
			moveRight = {},
			moveUp    = {},
			moveDown  = {},
			aimLeft   = {},
			aimRight  = {},
			aimUp     = {},
			aimDown   = {},
			grab      = {},
			boost     = {},
		},
		pairs = {
			move = {'moveLeft', 'moveRight', 'moveUp', 'moveDown'},
			aim =  {'aimLeft', 'aimRight', 'aimUp', 'aimDown'},
		},
	},
	exit = {
		radius = 300
	}
}