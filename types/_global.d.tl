require 'love'
require 'global'
global function gotoMenu()
	
end
global function pushLevels()
	
end
global function pushSettings()
	
end
global function pushPause()
	
end
global cam11 = require 'cam11'
global cargo = require 'cargo'
global type AppleCake = require 'AppleCake'
global appleCake: AppleCake
global record asset
	level: {string:level.Data}
	font: {string:cargo.FontFunc}
	alpha_image: {string:love.graphics.Image}
	sound: {string:love.audio.Source}
end