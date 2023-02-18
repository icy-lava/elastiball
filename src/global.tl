global argparse = require 'argparse'
local parser = argparse()

global WIDTH = 1920
global HEIGHT = 1080
global FPS = 60
global FRAME_TIME = 1 / FPS

global jit: table
local windows = jit.os == 'Windows'

parser:help_max_width(120)
parser:help_description_margin(30)
parser:add_help('--help -?')

parser:flag('--dev --developer')
	:description 'Enable developer mode'

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

if cli.show_console then
	((love as table)._openConsole as function)()
end

if cli.dev then
	log.outfile = '../log.txt'
else
	log.level = 'fatal'
end

global roomy = require 'roomy'
global scene = roomy.new()
global tiny = require 'tiny'