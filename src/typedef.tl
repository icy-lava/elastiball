local record AimEntity
	aim: comp.Aim
	opacity: comp.Opacity
	pos: comp.Pos
end

local record AttractorEntity
	attraction: comp.Attraction
	pos: comp.Pos
end

local record DrawableEntity
	drawables: comp.Drawables
	layer: comp.Layer
	opacity: comp.Opacity
	pos: comp.Pos
	scale: comp.Scale
end

local record DrawnPlayerEntity
	aim: comp.Aim
	heat: comp.Heat
	lastPos: comp.LastPos
	opacity: comp.Opacity
	pos: comp.Pos
	scale: comp.Scale
	target: comp.Target
end

local record FullEntity
	aim: comp.Aim
	attraction: comp.Attraction
	drawables: comp.Drawables
	grabable: comp.Grabable
	heat: comp.Heat
	input: comp.Input
	lastPos: comp.LastPos
	layer: comp.Layer
	link: comp.Link
	linkRef: comp.LinkRef
	linked: comp.Linked
	mass: comp.Mass
	opacity: comp.Opacity
	particles: comp.Particles
	pinned: comp.Pinned
	polygon: comp.Polygon
	pos: comp.Pos
	scale: comp.Scale
	solids: comp.Solids
	target: comp.Target
	trigger: comp.Trigger
	velocityEmission: comp.VelocityEmission
end

local record GravityEntity
	lastPos: comp.LastPos
	pinned: comp.Pinned
	pos: comp.Pos
end

local record InputEntity
	aim: comp.Aim
	heat: comp.Heat
	input: comp.Input
	lastPos: comp.LastPos
	linkRef: comp.LinkRef
	pos: comp.Pos
	target: comp.Target
end

local record LevelEndEntity
	attraction: comp.Attraction
	drawables: comp.Drawables
	layer: comp.Layer
	particles: comp.Particles
	pos: comp.Pos
	trigger: comp.Trigger
end

local record LinkEntity
	drawables: comp.Drawables
	layer: comp.Layer
	link: comp.Link
end

local record ParticleSystemEntity
	lastPos: comp.LastPos
	opacity: comp.Opacity
	particles: comp.Particles
	pos: comp.Pos
	velocityEmission: comp.VelocityEmission
end

local record PlayerEntity
	aim: comp.Aim
	drawables: comp.Drawables
	heat: comp.Heat
	input: comp.Input
	lastPos: comp.LastPos
	layer: comp.Layer
	mass: comp.Mass
	opacity: comp.Opacity
	particles: comp.Particles
	pos: comp.Pos
	scale: comp.Scale
	velocityEmission: comp.VelocityEmission
end

local record PointEntity
	drawables: comp.Drawables
	grabable: comp.Grabable
	lastPos: comp.LastPos
	layer: comp.Layer
	pinned: comp.Pinned
	pos: comp.Pos
end

local record SafezoneEntity
	drawables: comp.Drawables
	layer: comp.Layer
	pos: comp.Pos
	trigger: comp.Trigger
end

local record SolidEntity
	drawables: comp.Drawables
	polygon: comp.Polygon
	solids: comp.Solids
end

local record SolidsEntity
	solids: comp.Solids
end

local record TriggerEntity
	pos: comp.Pos
	trigger: comp.Trigger
end

local record VerletEntity
	lastPos: comp.LastPos
	pinned: comp.Pinned
	pos: comp.Pos
end

local record comp
	type Aim = vec2
	type Attraction = record
		distMax: number
		distMin: number
		force: number
	end
	type Drawables = {love.graphics.Drawable | function(entity: FullEntity)}
	type Grabable = boolean
	type Heat = number
	type Input = baton.Player
	type LastPos = vec2
	type Layer = integer
	type LinkRef = LinkEntity
	type Link = record
		a: Linked
		b: Linked
		distance: number
		error: number
		strengthIn: number
		strengthOut: number
	end
	type Linked = record
		lastPos: vec2
		mass: number
		pinned: boolean
		pos: vec2
	end
	type Mass = number
	type Opacity = number
	type Particles = {love.graphics.ParticleSystem}
	type Pinned = boolean
	type Polygon = {number}
	type Pos = vec2
	type Scale = number
	type Solids = {shapes.Shape}
	type Target = record
		pinned: boolean
		pos: vec2
	end
	type Trigger = record
		inverse: boolean
		radius: number
		signal: signal<string>
	end
	type VelocityEmission = number
end

local entityFilter: {FullEntity:tiny.EntityFilter} = {
	[AimEntity] = tiny.requireAll("aim", "pos"),
	[AttractorEntity] = tiny.requireAll("attraction", "pos"),
	[DrawableEntity] = tiny.requireAll("drawables"),
	[DrawnPlayerEntity] = tiny.requireAll("aim", "heat", "lastPos", "pos"),
	[FullEntity] = tiny.requireAll("aim", "attraction", "drawables", "grabable", "heat", "input", "lastPos", "layer", "link", "linkRef", "linked", "mass", "opacity", "particles", "pinned", "polygon", "pos", "scale", "solids", "target", "trigger", "velocityEmission"),
	[GravityEntity] = tiny.requireAll("lastPos", "pos"),
	[InputEntity] = tiny.requireAll("heat", "input", "lastPos", "pos"),
	[LevelEndEntity] = tiny.requireAll("attraction", "particles", "pos", "trigger"),
	[LinkEntity] = tiny.requireAll("link"),
	[ParticleSystemEntity] = tiny.requireAll("particles"),
	[PlayerEntity] = tiny.requireAll("aim", "heat", "input", "lastPos", "pos"),
	[PointEntity] = tiny.requireAll("lastPos", "pinned", "pos"),
	[SafezoneEntity] = tiny.requireAll("pos", "trigger"),
	[SolidEntity] = tiny.requireAll("drawables", "polygon", "solids"),
	[SolidsEntity] = tiny.requireAll("solids"),
	[TriggerEntity] = tiny.requireAll("pos", "trigger"),
	[VerletEntity] = tiny.requireAll("lastPos", "pos"),
}

return {
	AimEntity = AimEntity,
	AttractorEntity = AttractorEntity,
	DrawableEntity = DrawableEntity,
	DrawnPlayerEntity = DrawnPlayerEntity,
	FullEntity = FullEntity,
	GravityEntity = GravityEntity,
	InputEntity = InputEntity,
	LevelEndEntity = LevelEndEntity,
	LinkEntity = LinkEntity,
	ParticleSystemEntity = ParticleSystemEntity,
	PlayerEntity = PlayerEntity,
	PointEntity = PointEntity,
	SafezoneEntity = SafezoneEntity,
	SolidEntity = SolidEntity,
	SolidsEntity = SolidsEntity,
	TriggerEntity = TriggerEntity,
	VerletEntity = VerletEntity,
	filter = entityFilter,
	comp = comp,
}
