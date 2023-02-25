require 'love'
require 'global'
global function gotoMenu()
	
end
global cam11 = require 'cam11'
global cargo = require 'cargo'
global record asset
	level: {string:level.Data}
	font: {string:cargo.FontFunc}
	alpha_image: {string:love.graphics.Image}
end