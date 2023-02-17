WIDTH = 1920
HEIGHT = 1080

function love.conf(t)
	t.window.display = 2 -- TODO: don't hardcode this
	t.window.height = 720
	t.window.width = math.floor(720 * WIDTH / HEIGHT + 0.5)
	t.window.resizable = true
end

function love.load()
	
end

function love.draw()
	love.graphics.print('Hello world!', 100, 100)
end

function love.keypressed(key, scancode)
	if key == 'q' and love.keyboard.isDown('lctrl', 'rctrl') then
		love.event.quit()
		return
	elseif key == 'f11' or (key == 'return' and love.keyboard.isDown('lalt', 'ralt')) then
		love.window.setFullscreen(not love.window.getFullscreen())
	end
end