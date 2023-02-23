local components: {string:string} = {
	pos = 'vec2',
	lastPos = 'vec2',
	aim = 'vec2',
	input = 'baton.Player',
	heat = 'number',
	mass = 'number',
	pinned = 'boolean',
	distance = 'number',
	error = 'number',
	inStrength = 'number',
	outStrength = 'number',
	linkA = 'ObjectEntity',
	linkB = 'ObjectEntity',
	target = 'TargetEntity',
	link = 'LinkEntity',
	endSignal = 'signal<string>',
	particles = '{love.graphics.ParticleSystem}',
	attraction = 'number',
	attractionMinDist = 'number',
	attractionMaxDist = 'number',
	opacity = 'number',
	scale = 'number',
}

local compKeys: {string} = {}; for k in pairs(components) do table.insert(compKeys, k) end

local entities: {string:string} = {
	complete = table.concat(compKeys, ' '),
	
	object = 'pos lastPos mass? pinned?',
	target = 'pos pinned?',
	
	drawnPlayer = 'pos lastPos aim heat opacity? scale? target?',
	player = 'pos lastPos opacity? scale?',
	point = 'pos lastPos pinned',
	verlet = 'pos lastPos pinned?',
	gravity = 'pos lastPos pinned?',
	link = 'linkA linkB distance error? inStrength? outStrength?',
	input = 'pos lastPos input aim heat opacity? scale? mass? target? link?',
	levelEnd = 'pos endSignal',
	particleSystem = 'particles opacity? pos?',
	attractor = 'pos attraction attractionMinDist? attractionMaxDist?',
}

-- local type RecordDef = {string:string | RecordDef}

local fieldTemplate = "%s: %s"

local filterTemplate = "tiny.requireAll(%s)"

local recordTemplate = [[
local record %s
	%s
end]]

local enum Command
	'gen'
end

local command: Command = arg[1] as Command

if command == 'gen' then
	local records: {string} = {}
	local enames: {string} = {}
	local filters: {string:string} = {}
	for name, comps in pairs(entities) do
		local ename = name:gsub('^.', string.upper) .. 'Entity'
		table.insert(enames, ename)
		local compArray: {string} = {}
		local compArrayRequired: {string} = {}
		local fields: {string} = {}
		for comp in comps:gmatch('%S+') do
			local optional = false
			if comp:match('%?$') then
				optional = true
				comp = comp:sub(1, -2)
			end
			local compType = (components as {string:string})[comp]
			if not compType then
				io.stderr:write(string.format('no such component %q\n', comp))
				os.exit(1)
			end
			table.insert(compArray, comp)
			if not optional then
				table.insert(compArrayRequired, string.format('%q', comp))
			end
			table.insert(fields, string.format(fieldTemplate, comp, compType))
		end
		
		table.sort(fields)
		table.insert(records, string.format(
			recordTemplate,
			ename,
			table.concat(fields, '\n\t')
			-- string.format(filterTemplate, ename, table.concat(compArrayRequired, ', '))
		))
		filters[ename] = string.format(filterTemplate, table.concat(compArrayRequired, ', '))
	end
	
	table.sort(records)
	local output: string = table.concat(records, '\n\n')
	
	local filterMap: {string} = {}
	for _, ename in ipairs(enames) do
		table.insert(filterMap, string.format('[%s] = %s,', ename, filters[ename]))
	end
	table.sort(filterMap)
	output = output .. '\n\n' .. string.format('local entityFilter: {CompleteEntity:tiny.EntityFilter} = {\n\t%s\n}', table.concat(filterMap, '\n\t'))
	
	local outFields: {string} = {'filter = entityFilter'}
	for _, ename in ipairs(enames) do
		table.insert(outFields, string.format('%s = %s', ename, ename))
		-- table.insert(outFields, string.format('%sFilter = %sFilter,', ename, ename))
	end
	table.sort(outFields)
	output = output .. '\n\n' .. string.format('return {\n\t%s\n}', table.concat(outFields, ',\n\t'))
	
	print(output)
else
	io.stderr:write(string.format('unknown command %q\n', command))
	os.exit(1)
end