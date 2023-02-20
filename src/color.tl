local type RGB = {number, number, number}
local type RGBA = {number, number, number, number}

local function hex(str: string): RGB
	return {util.hex2rgb(str)}
end

local color = {
	RGB  = RGB,
	RGBA = RGBA,
	
	player: RGB = hex '#c54789',
	background: RGB = hex '#6d273d',
	point: RGB = hex '#408d9d',
	link: RGB = hex '#465b63',
}

return color