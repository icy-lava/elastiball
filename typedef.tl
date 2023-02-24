local type RecordDef = {string:string | RecordDef}
local components: RecordDef = {
	pos_t = 'vec2',
	lastPos_t = 'vec2',
	mass_t = 'number',
	heat_t = 'number',
	opacity_t = 'number',
	scale_t = 'number',
	pinned_t = 'boolean',
	aim_t = 'vec2',
	input_t = 'baton.Player',
	particles_t = '{love.graphics.ParticleSystem}',
	drawables_t = '{love.graphics.Drawable | function(entity: FullEntity)}',
	layer_t = 'integer',
	solids_t = '{shapes.Shape}',
	target_t = {
		pos = 'vec2',
		pinned = 'boolean'
	},
	linked_t = {
		pos = 'vec2',
		lastPos = 'vec2',
		pinned = 'boolean',
		mass = 'number',
	},
	link_t = {
		a = 'Linked',
		b = 'Linked',
		distance = 'number',
		error = 'number',
		strengthIn = 'number',
		strengthOut = 'number',
	},
	linkRef_t = 'LinkEntity',
	trigger_t = {
		radius = 'number',
		inverse = 'boolean',
		signal = 'signal<string>',
	},
	attraction_t = {
		force = 'number',
		distMin = 'number',
		distMax = 'number',
	},
}

local compKeys: {string} = {}; for k in pairs(components) do table.insert(compKeys, (k:gsub('_t$', ''))) end

local systems: {string:string} = {
	full = table.concat(compKeys, ' '),
	
	-- Entity types
	player         = 'pos drawables? layer? lastPos aim heat input mass? opacity? scale?',
	point          = 'pos drawables? layer? lastPos pinned',
	safezone       = 'pos drawables? layer? trigger',
	link           = 'link drawables? layer?',
	levelEnd       = 'pos drawables? layer? trigger particles attraction',
	
	-- Systems
	solids         = 'solids',
	aim            = 'pos aim opacity?',
	drawable       = 'drawables layer? pos? scale? opacity?',
	drawnPlayer    = 'pos lastPos aim heat opacity? scale? target?',
	verlet         = 'pos lastPos pinned?',
	gravity        = 'pos lastPos pinned?',
	input          = 'pos lastPos input heat aim? target? linkRef?',
	particleSystem = 'particles opacity? pos?',
	attractor      = 'pos attraction',
	trigger        = 'pos trigger'
}

local function spairs<K, V>(t: {K:V}, comparator: function(a: K, b: K): boolean): function(): (K, V)
	local keys: {K} = {}
	for key in pairs(t) do
		table.insert(keys, key)
	end
	table.sort(keys, comparator)
	local cor = coroutine.wrap(function()
		for _, key in ipairs(keys) do
			local value = t[key]
			coroutine.yield(key, value)
		end
	end) as function(): (K, V)
	return cor
end

local function componentCompare(a: string, b: string): boolean
	local at = not not a:match('_t$')
	local bt = not not b:match('_t$')
	if (at == bt) then
		return a < b
	elseif at then
		return true
	end
	return false
end

local function renderRecord(name: string, rec: RecordDef, indent: integer): string
	indent = indent or 0
	local lines = {string.format(name and '%srecord %s' or '%srecord', ('\t'):rep(indent), name)}
	indent = indent + 1
	
	for key, value in spairs(rec, componentCompare) do
		local typ = false
		if key:match('_t$') then
			key = key:sub(1, -3):gsub('^.', string.upper)
			typ = true
		end
		if value is string then
			if typ then
				table.insert(lines, string.format('%stype %s = %s', ('\t'):rep(indent), key, value))
			else
				table.insert(lines, string.format('%s%s: %s', ('\t'):rep(indent), key, value))
			end
		else
			local output = renderRecord(not typ and key, value, indent)
			if typ then
				output = string.format('%stype %s = %s', ('\t'):rep(indent), key, output:gsub('^%s+', ''))
			end
			table.insert(lines, output)
		end
	end
	table.insert(lines, ('\t'):rep(indent - 1) .. 'end')
	
	return table.concat(lines, '\n')
end

local function localRecord(name: string, rec: RecordDef, indent: integer): string
	return 'local ' .. renderRecord(name, rec, indent)
end

local enum Command 'gen' end
local command: Command = arg[1] as Command

if command == 'gen' then
	local output: {string} = {}
	local exports: {string} = {}
	
	local filters: {string} = {}
	for name, compList in spairs(systems) do
		local ename = name:gsub('^.', string.upper) .. 'Entity'
		local comps: RecordDef = {}
		local req: {string} = {}
		for comp in compList:gmatch('%S+') do
			if comp:match('%?$') then
				comp = comp:sub(1, -2)
			else
				table.insert(req, string.format('%q', comp))
			end
			comps[comp] = 'comp.' .. comp:gsub('^.', string.upper)
		end
		
		table.insert(output, localRecord(ename, comps))
		
		table.sort(req)
		table.insert(filters, string.format('[%s] = tiny.requireAll(%s)', ename, table.concat(req, ', ')))
		table.insert(exports, string.format('%s = %s', ename, ename))
	end
	
	table.insert(output, localRecord('comp', components))
	
	local filtersPrefix = 'local entityFilter: {FullEntity:tiny.EntityFilter} = '
	table.insert(output, string.format('%s{\n\t%s,\n}', filtersPrefix, table.concat(filters, ',\n\t')))
	
	table.insert(exports, string.format('%s = %s', 'filter', 'entityFilter'))
	table.insert(exports, string.format('%s = %s', 'comp', 'comp'))
	table.insert(output, string.format('%s{\n\t%s,\n}', 'return ', table.concat(exports, ',\n\t')))
	
	print(table.concat(output, '\n\n'))
else
	io.stderr:write(string.format('unknown command %q\n', command))
	os.exit(1)
end