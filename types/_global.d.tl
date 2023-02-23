require 'love'
require 'global'
global cam11 = require 'cam11'
global cargo = require 'cargo'
global record asset
	level: {string:level.Data}
	font: {string:cargo.FontFunc}
	image: {string:love.graphics.Image}
end