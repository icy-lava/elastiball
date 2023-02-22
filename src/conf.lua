require 'love.joystick'
require 'global'

function love.conf(t)
	t.window.title = 'love jam 2023'
	
	t.window.vsync = 0
	t.window.display = cli.display
	t.window.width = cli.width
	t.window.height = cli.height
	t.window.resizable = true
	t.window.minwidth = 160
	t.window.minheight = 120
	t.window.msaa = 8
	
	t.modules.audio = true
    t.modules.data = true
    t.modules.event = true
    t.modules.font = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.joystick = true
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.physics = false
    t.modules.sound = true
    t.modules.system = true
    t.modules.thread = true
    t.modules.timer = true
    t.modules.touch = true
    t.modules.video = false
    t.modules.window = true
end

function love.load()
	cargo = require 'cargo'
	asset = {
		level = cargo.init {
			dir = 'asset/level',
			loaders = {
				json = level.load
			}
		},
		font = cargo.init 'asset/font'
	}
	cam11 = require 'cam11'
	scene:hook {
		exclude = {
			'load',
			'draw',
			'keypressed',
			'keyreleased',
			'resize',
		}
	}
	if cli.editor then
		scene:enter(require 'scene.editor'.new())
	else
		scene:enter(require 'scene.game'.new(), '1')
	end
end

local lastWidth, lastHeight
function love.resize(width, height)
	if lastWidth ~= width or lastHeight ~= height then
		lastWidth, lastHeight = width, height
		scene:emit('resize', width, height)
	end
end

local keyConsumed = {}
function love.keypressed(...)
	local key = ...
	if key == 'q' and love.keyboard.isDown('lctrl', 'rctrl') then
		love.event.quit()
	elseif key == 'f11' or (key == 'return' and love.keyboard.isDown('lalt', 'ralt')) then
		love.window.setFullscreen(not love.window.getFullscreen())
		love.event.push('resize', love.graphics.getDimensions())
	else
		scene:emit('keypressed', ...)
		return
	end
	keyConsumed[key] = true
end

function love.keyreleased(...)
	local key = ...
	if keyConsumed[key] then
		keyConsumed[key] = nil
	else
		scene:emit('keyreleased', ...)
	end
end

function love.run()
	if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end

	local dt = 0
	love.graphics.setLineStyle 'rough'
	-- Main loop time.
	return function()
		lastWidth, lastHeight = love.graphics.getDimensions()
		util.mouseRel = vec2()
		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a or 0
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end

		-- Update dt, as we'll be passing it to update
		if love.timer then dt = dt + love.timer.step() end
		-- dt = love.timer.step()
		dt = math.min(dt, 0.1)

		-- Call update and draw
		if love.update then
			local updated = false
			while dt >= FRAME_TIME do
				love.update(FRAME_TIME)
				dt = dt - FRAME_TIME
				updated = true
				util.mouseRel = vec2()
			end
			
			if updated and love.graphics and love.graphics.isActive() then
				love.graphics.origin()
	
				scene:emit('draw')
	
				love.graphics.present()
			end
		end

		if love.timer then love.timer.sleep(0.002) end
	end
end