local record tiny
	type Entity = table
	type EntityFilter = function(system: System, entity: Entity): boolean
	type SystemFilter = function(world: World, system: System): boolean
	
	record World
		entities: {Entity}
		systems: {System}
		
		addEntity: function(self: World, entity: Entity): Entity
		addSystem: function<E>(self: World, system: System<E>): System<E>
		add: function(self: World, ...: Entity): Entity...
		add: function(self: World, ...: System): System...
		add: function(self: World, ...: table): table...
		
		removeEntity: function(self: World, entity: Entity): Entity
		removeSystem: function<E>(self: World, entity: System<E>): System<E>
		remove: function(self: World, ...: Entity): Entity...
		remove: function(self: World, ...: System): System...
		remove: function(self: World, ...: table): table...
		
		refresh: function(self: World)
		update: function(self: World, dt: number, filter: function<T>(world: World, system: System<T>): boolean)
		clearEntities: function(self: World)
		
		getEntityCount: function(self: World): integer
		getSystemCount: function(self: World): integer
		setSystemIndex: function(self: World, system: System, index: integer)
	end
	
	world: function(...: System): World, System...
	world: function(...: Entity): World, Entity...
	world: function(...: table): World, table...
	
	addEntity: function(world: World, entity: Entity): Entity
	addSystem: function<E>(world: World, system: System<E>): System<E>
	add: function(world: World, ...: Entity): Entity...
	add: function(world: World, ...: System): System...
	add: function(world: World, ...: table): table...
	
	removeEntity: function(world: World, entity: Entity): Entity
	removeSystem: function<E>(world: World, entity: System<E>): System<E>
	remove: function(world: World, ...: Entity): Entity...
	remove: function(world: World, ...: System): System...
	remove: function(world: World, ...: table): table...
	
	refresh: function(world: World)
	update: function(world: World, dt: number, filter: function<T>(world: World, system: System<T>): boolean)
	clearEntities: function(world: World)
	
	getEntityCount: function(world: World): integer
	getSystemCount: function(world: World): integer
	setSystemIndex: function(world: World, system: System, index: integer)
	
	record System<T>
		world: World
		active: boolean
		entities: {T}
		interval: number
		index: integer
		indices: {T:integer}
		modified: boolean
		nocache: boolean
		
		update: function(self: System, dt: number)
		filter: EntityFilter
		onAdd: function<E>(self: System<E>, entity: E)
		onRemove: function<E>(self: System<E>, entity: E)
		onModify: function(self: System, dt: number)
		onAddToWorld: function(self: System, world: World)
		onRemoveFromWorld: function(self: System, world: World)
		preWrap: function(self: System, dt: number)
		postWrap: function(self: System, dt: number)
		
		-- Processing system
		preProcess: function(self: System, dt: number)
		process: function<E>(self: System<E>, entity: E, dt: number)
		postProcess: function(self: System, dt: number)
		
		-- Sorted system
		compare: function<E>(self: System<E>, a: E, b: E): boolean
	end
	
	system: function<E>(t: table): System<E>
	processingSystem: function<E>(t: table): System<E>
	sortedSystem: function<E>(t: table): System<E>
	sortedProcessingSystem: function<E>(t: table): System<E>
	
	requireAll: function(...: string | EntityFilter): EntityFilter
	requireAny: function(...: string | EntityFilter): EntityFilter
	rejectAll: function(...: string | EntityFilter): EntityFilter
	rejectAny: function(...: string | EntityFilter): EntityFilter
	filter: function(pattern: string): EntityFilter
end

return tiny