local record cargo
	type FontFunc = function(size: integer): love.graphics.Font
	record Options
		dir: string
		loaders: {string:function(path: string): any}
		processors: {string:function(asset: any, filename: string)}
	end
	
	init: function<A>(options: Options): {string:A}
	init: function<A, B>(options: Options): {string:A | {string:B}}
	init: function<A, B, C>(options: Options): {string:A | {string:B | {string:C}}}
	init: function<A, B, C, D>(options: Options): {string:A | {string:B | {string:C | {string:D}}}}
	init: function<A, B, C, D, E>(options: Options): {string:A | {string:B | {string:C | {string:D | {string:E}}}}}
	init: function(options: Options): {string:any}
	
	init: function<A>(path: string): {string:A}
	init: function<A, B>(path: string): {string:A | {string:B}}
	init: function<A, B, C>(path: string): {string:A | {string:B | {string:C}}}
	init: function<A, B, C, D>(path: string): {string:A | {string:B | {string:C | {string:D}}}}
	init: function<A, B, C, D, E>(path: string): {string:A | {string:B | {string:C | {string:D | {string:E}}}}}
	init: function(path: string): {string:any}
end

return cargo