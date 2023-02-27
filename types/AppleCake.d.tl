local record Profile end

function Profile:stop() end

local record Counter end

local record AppleCake
	type Profile = Profile
	type Counter = Counter
	
	type Args = {string:string | number}
	
	enum Option
		'all'
		'none'
		'profile'
		'mark'
		'counter'
	end
	enum Scope 'p' 't' end
	enum MemoryScale
		'byte'
		'kilobyte'
		'megabyte'
	end
	
	beginSession: function(path: string, name: string)
	endSession: function()
	setBuffer: function(buffer: boolean)
	flush: function()
	
	enableLevels: {Option:integer}
	enable: function(levels: Option)
	enable: function(levels: integer)
	
	profile: function(name: string, args: Args, profile: Profile): Profile
	profileFunc: function(args: Args, profile: Profile): Profile
	stopProfile: function(profile: Profile)
	
	mark: function(name: string, scope: Scope, args: Args)
	counter: function(name: string, args: Args, counter: Counter): Counter
	countMemory: function(memoryScale: MemoryScale)
	
	setName: function(name: string)
	setThreadName: function(name: string)
end

return AppleCake