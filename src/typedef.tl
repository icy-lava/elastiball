local record CompleteEntity
	aim: vec2
	distance: number
	endSignal: signal<string>
	error: number
	heat: number
	inStrength: number
	input: baton.Player
	lastPos: vec2
	link: LinkEntity
	linkA: ObjectEntity
	linkB: ObjectEntity
	mass: number
	outStrength: number
	pinned: boolean
	pos: vec2
	target: TargetEntity
end

local record DrawnPlayerEntity
	aim: vec2
	heat: number
	lastPos: vec2
	pos: vec2
	target: TargetEntity
end

local record GravityEntity
	lastPos: vec2
	pinned: boolean
	pos: vec2
end

local record InputEntity
	aim: vec2
	heat: number
	input: baton.Player
	lastPos: vec2
	link: LinkEntity
	mass: number
	pos: vec2
	target: TargetEntity
end

local record LevelEndEntity
	endSignal: signal<string>
	pos: vec2
end

local record LinkEntity
	distance: number
	error: number
	inStrength: number
	linkA: ObjectEntity
	linkB: ObjectEntity
	outStrength: number
end

local record ObjectEntity
	lastPos: vec2
	mass: number
	pinned: boolean
	pos: vec2
end

local record PlayerEntity
	lastPos: vec2
	pos: vec2
end

local record PointEntity
	lastPos: vec2
	pinned: boolean
	pos: vec2
end

local record TargetEntity
	pinned: boolean
	pos: vec2
end

local record VelocityEntity
	lastPos: vec2
	pinned: boolean
	pos: vec2
end

local entityFilter = {
	[CompleteEntity] = tiny.requireAll("mass", "linkB", "endSignal", "lastPos", "link", "target", "pinned", "inStrength", "aim", "pos", "linkA", "outStrength", "error", "distance", "input", "heat"),
	[DrawnPlayerEntity] = tiny.requireAll("pos", "lastPos", "aim", "heat"),
	[GravityEntity] = tiny.requireAll("pos", "lastPos"),
	[InputEntity] = tiny.requireAll("pos", "lastPos", "input", "aim", "heat"),
	[LevelEndEntity] = tiny.requireAll("pos", "endSignal"),
	[LinkEntity] = tiny.requireAll("linkA", "linkB", "distance"),
	[ObjectEntity] = tiny.requireAll("pos", "lastPos"),
	[PlayerEntity] = tiny.requireAll("pos", "lastPos"),
	[PointEntity] = tiny.requireAll("pos", "lastPos", "pinned"),
	[TargetEntity] = tiny.requireAll("pos"),
	[VelocityEntity] = tiny.requireAll("pos", "lastPos"),
}

return {
	CompleteEntity = CompleteEntity,
	DrawnPlayerEntity = DrawnPlayerEntity,
	GravityEntity = GravityEntity,
	InputEntity = InputEntity,
	LevelEndEntity = LevelEndEntity,
	LinkEntity = LinkEntity,
	ObjectEntity = ObjectEntity,
	PlayerEntity = PlayerEntity,
	PointEntity = PointEntity,
	TargetEntity = TargetEntity,
	VelocityEntity = VelocityEntity,
	filter = entityFilter
}
