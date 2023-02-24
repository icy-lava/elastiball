local type RGB = {number, number, number}
local type RGBA = {number, number, number, number}

local function hex(str: string): RGB
	return {util.hex2rgb(str)}
end

local color = {
	RGB  = RGB,
	RGBA = RGBA,
	
	player: RGB = hex '#c54789',
	hot: RGB = hex '#f70041',
	heatbar: RGB = hex '#969696',
	exit: RGB = hex '#222222',
	background: RGB = hex '#6d273d',
	point: RGB = hex '#408d9d',
	link: RGB = hex '#465b63',
	safe: RGB = {vivid.LCHtoRGB(20, 30, 240)},
	unsafe: RGB = {vivid.LCHtoRGB(30, 80, 5)},
	white: RGB = {1, 1, 1},
	black: RGB = {0, 0, 0},
	selected: RGB = {vivid.LCHtoRGB(70, 90, 240)},
	hovered: RGB = {vivid.LCHtoRGB(95, 30, 240)},
}

function color.withAlpha(col: {number}, alpha: number): {number, number, number, number}
	return {col[1], col[2], col[3], alpha}
end

function color.lerp(t: number, a: {number}, b: {number}): {number}
	if #a == 4 or #b == 4 then
		return {
			util.lerp(t, a[1], b[1]),
			util.lerp(t, a[2], b[2]),
			util.lerp(t, a[3], b[3]),
			util.lerp(t, a[4] or 1, b[4] or 1),
		}
	end
	return {
		util.lerp(t, a[1], b[1]),
		util.lerp(t, a[2], b[2]),
		util.lerp(t, a[3], b[3]),
	}
end

function color.labLerp(t: number, a: {number}, b: {number}): {number}
	return {vivid.LabtoRGB(color.lerp(t, {vivid.RGBtoLab(a)}, {vivid.RGBtoLab(b)}))}
end

function color.asSelected(col: {number}): {number}
	return color.labLerp(0.5, col, color.selected)
end

function color.asHovered(col: {number}): {number}
	return color.labLerp(0.5, col, color.hovered)
end

function color.contextual(col: {number}, hovered: boolean, selected: boolean): {number}
	if hovered then
		col = color.asHovered(col)
	end
	if selected then
		col = color.asSelected(col)
	end
	return col
end

return color