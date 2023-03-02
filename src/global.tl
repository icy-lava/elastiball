local system = (require as function) 'love.system' as love.system
global WEB = system.getOS() == 'Web'

global argparse = require 'argparse'
local parser = argparse()

global WIDTH = 1920
global HEIGHT = 1080
global FPS = 240
global FRAME_TIME = 1 / FPS

global jit: table
local windows = jit and jit.os == 'Windows' or false

parser:help_max_width(120)
parser:help_description_margin(30)
parser:add_help('--help -?')

parser:flag('--dev --developer')
	:description 'Enable developer mode'

parser:flag('--editor')
	:description 'Enter the level editor'

parser:option('--width -w')
	:description 'Specify the width of the window'
	:args(1)
	:convert(tonumber)

parser:option('--height -h')
	:description 'Specify the height of the window'
	:args(1)
	:convert(tonumber)

parser:option('--display')
	:description 'Specify which display to use'
	:args(1)
	:default('1')
	:convert(tonumber)

parser:flag('--show-console')
	:description 'Show a console window (ignored on non-Windows OS)'
	:hidden(not windows)

global record CLI
	dev: boolean
	editor: boolean
	display: integer
	width: integer
	height: integer
	show_console: boolean
end
global cli: CLI

local args = (((love as table).arg as table).parseGameArguments as function)(arg) as {string}
local status, result = parser:pparse(args)

global log = require 'log'

if not status then
	log.error(string.format('argparse error: %s\nfalling back to defaults...\n', result))
	cli = parser:parse({}) as CLI
else
	cli = result as CLI
end

local wantHeight = 720
local wantWidth = math.floor(wantHeight * WIDTH / HEIGHT + 0.5)
cli.height = cli.height or math.floor(cli.width and (cli.width * wantHeight / wantWidth) or wantHeight)
cli.width = cli.width or math.floor(cli.height * wantWidth / wantHeight)

if cli.show_console and (love as table)._openConsole then
	((love as table)._openConsole as function)()
end

if cli.dev then
	log.outfile = '../../log.txt'
else
	log.level = 'fatal'
end

global record Stats
	runTimes: {string:number}
	currentTotal: number
	bestTimes: {string:number}
	bestTotal: number
end
global stats: Stats

global baton = require 'baton'
global vec2 = require 'brinevector'
global config = require 'config'
global GRAVITY = vec2(0, 400)

global json = require 'json'
global flux = require 'flux'
global roomy = require 'roomy'
global scene = roomy.new()
global tiny = require 'tiny'
global signal = require 'signal'
global shapes = require 'hc.shapes'
global typedef = require 'typedef'
global vivid = require 'vivid'
global level = require 'level'
global record asset
	level: {string:level.Data}
	font: {string:cargo.FontFunc}
	alpha_image: {string:love.graphics.Image}
	sound: {string:love.audio.Source}
end
global util = require 'util'
global color = require 'color'
global ui = require 'ui'