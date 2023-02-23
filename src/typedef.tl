local record comp
	type Aim = vec2
	type Attraction = record
		distMax: number
		distMin: number
		force: number
	end
	type Heat = number
	type Input = baton.Player
	type LastPos = vec2
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
	type Pos = vec2
	type Scale = number
	type Target = record
		pinned: boolean
		pos: vec2
	end
	type Trigger = record
		inverse: boolean
		radius: number
		signal: signal<string>
	end
end

local record AttractorEntity
	attraction: comp.Attraction
	pos: comp.Pos
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
	heat: comp.Heat
	input: comp.Input
	lastPos: comp.LastPos
	link: comp.Link
	linked: comp.Linked
	mass: comp.Mass
	opacity: comp.Opacity
	particles: comp.Particles
	pinned: comp.Pinned
	pos: comp.Pos
	scale: comp.Scale
	target: comp.Target
	trigger: comp.Trigger
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
	link: comp.Link
	mass: comp.Mass
	opacity: comp.Opacity
	pos: comp.Pos
	scale: comp.Scale
	target: comp.Target
end

local record LevelEndEntity
	attraction: comp.Attraction
	particles: comp.Particles
	pos: comp.Pos
	trigger: comp.Trigger
end

local record LinkEntity
	link: comp.Link
end

local record ParticleSystemEntity
	opacity: comp.Opacity
	particles: comp.Particles
	pos: comp.Pos
end

local record PlayerEntity
	aim: comp.Aim
	heat: comp.Heat
	input: comp.Input
	lastPos: comp.LastPos
	mass: comp.Mass
	opacity: comp.Opacity
	pos: comp.Pos
	scale: comp.Scale
end

local record PointEntity
	lastPos: comp.LastPos
	pinned: comp.Pinned
	pos: comp.Pos
end

local record VerletEntity
	lastPos: comp.LastPos
	pinned: comp.Pinned
	pos: comp.Pos
end

local entityFilter: {FullEntity:tiny.EntityFilter} = {
	[AttractorEntity] = tiny.requireAll("pos", "attraction"),
	[DrawnPlayerEntity] = tiny.requireAll("pos", "lastPos", "aim", "heat"),
	[FullEntity] = tiny.requireAll("pos", "target", "trigger", "pinned", "opacity", "scale", "particles", "link", "linked", "heat", "aim", "attraction", "input", "mass", "lastPos"),
	[GravityEntity] = tiny.requireAll("pos", "lastPos"),
	[InputEntity] = tiny.requireAll("pos", "lastPos", "input", "aim", "heat"),
	[LevelEndEntity] = tiny.requireAll("pos", "trigger", "particles", "attraction"),
	[LinkEntity] = tiny.requireAll("link"),
	[ParticleSystemEntity] = tiny.requireAll("particles"),
	[PlayerEntity] = tiny.requireAll("pos", "lastPos", "aim", "heat", "input"),
	[PointEntity] = tiny.requireAll("pos", "lastPos", "pinned"),
	[VerletEntity] = tiny.requireAll("pos", "lastPos"),
}

return {
	AttractorEntity = AttractorEntity,
	DrawnPlayerEntity = DrawnPlayerEntity,
	FullEntity = FullEntity,
	GravityEntity = GravityEntity,
	InputEntity = InputEntity,
	LevelEndEntity = LevelEndEntity,
	LinkEntity = LinkEntity,
	ParticleSystemEntity = ParticleSystemEntity,
	PlayerEntity = PlayerEntity,
	PointEntity = PointEntity,
	VerletEntity = VerletEntity,
	filter = entityFilter,
	comp = comp,
}
