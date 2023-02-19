local level = {}

function level.decode(str)
	local map = json.decode(str)
	
	local player
	local pins = {}
	local points = {}
	local links = {}
	for _, layer in ipairs(map.layers) do
		if layer.type == 'objectgroup' then
			for _, obj in ipairs(layer.objects) do
				-- Polygon objects turn into points and links
				local poly = obj.polygon or obj.polyline
				if poly then
					if obj.polygon then
						table.insert(poly, poly[1])
					end
					for i, point in ipairs(poly) do
						table.insert(points, vec2(point.x + obj.x, point.y + obj.y))
						if i ~= 1 then
							local p1, p2 = poly[i - 1], point
							table.insert(links, {
								a = vec2(p1.x + obj.x, p1.y + obj.y),
								b = vec2(p2.x + obj.x, p2.y + obj.y)
							})
						end
					end
				elseif obj.name:match('pin') then
					local v = vec2(obj.x, obj.y)
					table.insert(points, v)
					table.insert(pins, v.copy)
				elseif obj.name:match('player') then
					assert(not player, 'more than one player in the level')
					player = vec2(obj.x, obj.y)
				else
					log.warn('found unknown level object')
				end
			end
		else
			log.warn('found layer with non-objectgroup type: ' .. tostring(layer.type))
		end
	end
	
	-- Remove overlapping points with some error
	for i = #points, 2, -1 do
		for j = i - 1, 1, -1 do
			local p1, p2 = points[i], points[j]
			if (p1 - p2).length < 1 then
				table.remove(points, i)
				break
			end
		end
	end
	
	for _, link in ipairs(links) do
		for j, p in ipairs(points) do
			if type(link.a) ~= 'number' and (link.a - p).length < 1 then
				link.a = j
			elseif type(link.b) ~= 'number' and (link.b - p).length < 1 then
				link.b = j
			end
		end
		assert(type(link.a) == 'number' and type(link.b) == 'number', "link couldn't find it's points")
	end
	
	local isPinned = {}
	for _, pin in ipairs(pins) do
		for i, point in ipairs(points) do
			if (pin - point).length < 1 then
				isPinned[i] = true
			end
		end
	end
	
	return {
		player = assert(player, 'no player in the level'),
		points = points,
		links = links,
		isPinned = isPinned,
	}
end

return level