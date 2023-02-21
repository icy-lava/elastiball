local record vivid
	LCHtoRGB: function(l: number, c: number, h: number): number, number, number
	LCHtoRGB: function(l: number, c: number, h: number, alpha: number): number, number, number, number
	LCHtoRGB: function(col: {number}): number, number, number, number
	LabtoRGB: function(l: number, c: number, h: number): number, number, number
	LabtoRGB: function(l: number, c: number, h: number, alpha: number): number, number, number, number
	LabtoRGB: function(col: {number}): number, number, number, number
	RGBtoLCH: function(l: number, c: number, h: number): number, number, number
	RGBtoLCH: function(l: number, c: number, h: number, alpha: number): number, number, number, number
	RGBtoLCH: function(col: {number}): number, number, number, number
	RGBtoLab: function(l: number, c: number, h: number): number, number, number
	RGBtoLab: function(l: number, c: number, h: number, alpha: number): number, number, number, number
	RGBtoLab: function(col: {number}): number, number, number, number
end

return vivid