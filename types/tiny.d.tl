local record tiny
	type Entity = table
	type EntityFilter = function(system: System, entity: Entity): boolean
	type SystemFilter = function(world: World, system: System): boolean
		
	record World
		entities: {Entity}
		systems: {System}
	end
	
	world: function(...: System): World, System...
	world: function(...: Entity): World, Entity...
	world: function(...: table): World, table...
	
	addEntity: function(world: World, entity: Entity): Entity
	addSystem: function(world: World, system: System): System
	add: function(world: World, ...: Entity): Entity...
	add: function(world: World, ...: System): System...
	add: function(world: World, ...: table): table...
	
	removeEntity: function(world: World, entity: Entity): Entity
	removeSystem: function(world: World, entity: System): System
	remove: function(world: World, ...: Entity): Entity...
	remove: function(world: World, ...: System): System...
	remove: function(world: World, ...: table): table...
	
	refresh: function(world: World)
	update: function(world: World, dt: number, filter: SystemFilter)
	clearEntities: function(world: World)
	
	getEntityCount: function(world: World): integer
	getSystemCount: function(world: World): integer
	setSystemIndex: function(world: World, system: System, index: integer)
	
	record System
		world: World
		active: boolean
		entities: {Entity}
		interval: number
		index: integer
		indices: {Entity:integer}
		modified: boolean
		nocache: boolean
		
		update: function(self: System, dt: number)
		filter: EntityFilter
		onAdd: function(self: System, entity: Entity)
		onRemove: function(self: System, entity: Entity)
		onModify: function(self: System, dt: number)
		onAddToWorld: function(self: System, world: World)
		onRemoveFromWorld: function(self: System, world: World)
		preWrap: function(self: System, dt: number)
		postWrap: function(self: System, dt: number)
		
		-- Processing system
		preProcess: function(self: System, dt: number)
		process: function(self: System, entity: Entity, dt: number)
		postProcess: function(self: System, dt: number)
		
		-- Sorted system
		compare: function(self: System, a: Entity, b: Entity): boolean
	end
	
	system: function(t: table): System
	processingSystem: function(t: table): System
	sortedSystem: function(t: table): System
	sortedProcessingSystem: function(t: table): System
	
	requireAll: function(...: string | EntityFilter): EntityFilter
	requireAny: function(...: string | EntityFilter): EntityFilter
	rejectAll: function(...: string | EntityFilter): EntityFilter
	rejectAny: function(...: string | EntityFilter): EntityFilter
	filter: function(pattern: string): EntityFilter
end

return tiny