function love.quit()
	if appleCake then
		appleCake.endSession()
		local saveDir = love.filesystem.getSaveDirectory()
		local profilePath = saveDir .. '/profile.json'
		log.info(string.format('saved profile to %q', profilePath))
	end
end

function love.conf(t)
	require 'love.joystick'
	require 'global'
	
	t.identity = 'il-love-jam-2023'
	t.window.title = 'love jam 2023'
	
	t.window.vsync = 0
	t.window.display = cli.display
	t.window.width = cli.width
	t.window.height = cli.height
	t.window.resizable = true
	t.window.minwidth = 640
	t.window.minheight = 480
	t.window.msaa = WEB and 4 or 8
	
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
	util.resetBaton()
	cargo = require 'cargo'
	asset = {
		level = cargo.init {
			dir = 'asset/level',
			loaders = {
				json = level.load
			}
		},
		font = cargo.init 'asset/font',
		alpha_image = cargo.init {
			dir = 'asset/alpha_image',
			loaders = {
				png = function(path)
					local id = love.image.newImageData(path)
					id:mapPixel(function(_, _, r)
						return 1, 1, 1, r
					end)
					return assert(love.graphics.newImage(id), {mipmaps = true})
				end
			}
		},
		sound = cargo.init {
			dir = 'asset/sound',
			loaders = WEB and {
				wav = function(path)
					return love.audio.newSource(path, 'static')
				end,
				ogg = function(path)
					return love.audio.newSource(path, 'static')
				end,
			}
		}
	}
	asset.sound.noise:setLooping(true)
	love.audio.setDistanceModel('inverse')
	
	local profileAlphaImage = appleCake.profile('asset/alpha_image')
	asset.alpha_image()
	profileAlphaImage:stop()
	
	local profileAssetSound = appleCake.profile('asset/sound')
	asset.sound()
	profileAssetSound:stop()
	
	function gotoMenu()
		scene:enter(require 'scene.menu'.new())
	end
	
	function pushLevels()
		scene:push(require 'scene.levels'.new())
	end
	
	function pushSettings()
		scene:push(require 'scene.settings'.new())
	end
	
	function pushPause()
		scene:push(require 'scene.pause'.new())
	end
	
	local profileCam11 = appleCake.profile('cam11')
	cam11 = require 'cam11'
	profileCam11:stop()
	
	local profileSceneHook = appleCake.profile('scene:hook')
	scene:hook {
		exclude = {
			'load',
			'draw',
			'keypressed',
			'keyreleased',
			'resize',
		}
	}
	profileSceneHook:stop()
	
	local profileSceneEnter = appleCake.profile('scene:enter')
	if cli.editor then
		scene:enter(require 'scene.editor'.new())
	else
		scene:enter(require 'scene.menu'.new())
	end
	profileSceneEnter:stop()
end

local lastWidth, lastHeight
function love.resize(width, height)
	if lastWidth ~= width or lastHeight ~= height then
		appleCake.mark('resize', 'p', {width = width, height = height})
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
		if key == 'escape' then
			love.mouse.setRelativeMode(false)
		end
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

function love.draw()
	scene:emit('draw')
end

local profileEvent
local profileUpdate
local profileSubUpdate
local profileDraw
local profilePresent
local profileSleep
function love.run()
	local enableAppleCake = true
	appleCake = require 'AppleCake'(enableAppleCake)
	if enableAppleCake then
		appleCake.setBuffer(true)
		-- appleCake.enable('profile')
	end
	appleCake.beginSession(nil, 'il-love-jam-2023')
	local profileLoad = appleCake.profile('load')
	if love.load then love.load(love.arg.parseGameArguments(arg), arg) end
	profileLoad:stop()

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
			appleCake.countMemory()
			profileEvent = appleCake.profile('event-loop', nil, profileEvent)
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						profileEvent:stop()
						appleCake.mark 'quit-event'
						return a or 0
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
			profileEvent:stop()
		end
		
		appleCake.countMemory()

		-- Update dt, as we'll be passing it to update
		if love.timer then dt = dt + love.timer.step() end
		-- dt = love.timer.step()
		dt = math.min(dt, 0.1)
		
		if cli.dev then
			require('lovebird').update()
		end
		flux.update(dt)
		
		-- Call update and draw
		if dt >= FRAME_TIME then
			profileUpdate = appleCake.profile('update', nil, profileUpdate)
			while dt >= FRAME_TIME do
				profileSubUpdate = appleCake.profile('sub-update', nil, profileSubUpdate)
				love.update(FRAME_TIME)
				dt = dt - FRAME_TIME
				util.mouseRel = vec2()
				profileSubUpdate:stop()
			end
			profileUpdate:stop()
			appleCake.countMemory()
			
			if love.graphics.isActive() then
				profileDraw = appleCake.profile('draw', nil, profileDraw)
				
				love.graphics.origin()
				scene:emit('draw')
				profileDraw.args = love.graphics.getStats()
				
				profileDraw:stop()
				
				appleCake.countMemory()
	
				profilePresent = appleCake.profile('present', nil, profileDraw)
				love.graphics.present()
				profilePresent:stop()
				appleCake.countMemory()
			end
		end

		if appleCake.flush then appleCake.flush() end
		
		if love.timer and love.timer.getAverageDelta() < FRAME_TIME * 2 then
			profileSleep = appleCake.profile('sleep', nil, profileSleep)
			love.timer.sleep(0.002)
			profileSleep:stop()
		end
	end
end