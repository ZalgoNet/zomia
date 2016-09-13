-- Tile map related utility functions
--
-- Tile maps are tables of structure:
--  name[x][y]
--
-- The values of each cell define the fixed features at that position on the map.
--
-- These values are known as map tile types.

maptiletypes = {
			[0]='rock',
			[1]='floor',
			[2]='closed door',
			[3]='open door',
			['T']='tree',
			['W']='water',
			['=']='bridge_horizontal'
	       }

-- Reference table of direction offsets
--  (Order is left, right, up, down, NW, SW, NE, SE)
directions   = {
			{0,-1},
			{0,1},
			{-1,0},
			{1,0},
			{-1,-1},
			{-1,1},
			{1,-1},
			{1,1}
	       };

-- New tilemap
function tilemap_new(width,height,defaultmaptiletype)
	width = math.floor(width) or resolutionTilesX
	height = math.floor(height) or resolutionTilesY
	defaultmaptiletype = defaultmaptiletype or 0
	local m={}
	for x=1,width,1 do
		m[x] = {}
		for y=1,height,1 do
			m[x][y] = defaultmaptiletype
		end
	end
	return m
end

-- Find all instances of a specific maptiletype on a tilemap
function tilemap_find_maptiletype(tilemap,maptiletype)
	local results = {}
	for x=1,#tilemap,1 do
		for y=1,#tilemap[1],1 do
			if tilemap[x][y] == maptiletype then
				table.insert(results,{x=x,y=y})
			end
		end
	end
	return results
end

-- Fill a rectangle on the tilemap with a certain maptiletype
function tilemap_draw_rectangle(tilemap,sx,sy,width,height,maptiletype)
	if tilemap == nil then
		print("ERROR: tilemap_draw_rectangle(): Passed a nil tilemap.")
		--os.exit()
	end
	print("tilemap_draw_rectangle() passed tilemap of dimensions " .. #tilemap .. "x" .. #tilemap[1] .. ", sx/sy = " .. sx .. "/" .. sy .. ", w/h = " .. width .. "/" .. height .. ", and maptiletype = '" .. maptiletype .. "'")
	sx = math.floor(sx)
	sy = math.floor(sy)
	width = math.floor(width)
	height = math.floor(height)
	for x=sx,sx+width,1 do
		for y=sy,sy+width,1 do
			if x>0 and y>0 and x<#tilemap and y<#tilemap[1] then
				print("tilemap_draw_rectangle() attempting to draw '" .. maptiletype .. "' at position " .. x .. "/" .. y .. " (vs. w/h " .. width .. "/" .. height .. ")")
				tilemap[x][y] = maptiletype
			end
		end
	end
end

-- Fill a circle on the tilemap with a certain maptiletype
function tilemap_draw_circle(tilemap,sx,sy,radius,maptiletyle)
	--[[
	for (i=max(0, x - radius - 1); i < max(DCOLS, x + radius); i++) {
		for (j=max(0, y - radius - 1); j < max(DROWS, y + radius); j++) {
			if ((i-x)*(i-x) + (j-y)*(j-y) < radius * radius + radius) {
				grid[i][j] = value;
			}
		}
	}
	--]]
	for i=math.max(0,sx-radius-1), math.max(#tilemap, sx+radius), 1 do
		for j=math.max(0,sy-radius-1), math.max(#tilemap[1],sy+radius),1 do
			if ((i-sx)*(i-sx) + (j-sy)*(j-sy)) < (radius*radius + radius) then
				tilemap[i][j] = maptiletype
			end
		end
	end

	return tilemap
end

-- Fill
function tilemap_fill(tilemap,maptiletype)
	for x=1,#tilemap,1 do
		for y=1,#tilemap[1],1 do
			tilemap[x][y] = maptiletype
		end
	end
	return tilemap
end

-- Check the validity of a set of coordinates given a specific tilemap
function tilemap_coordinates_valid(tilemap,x,y)
	if math.floor(x) == x and math.floor(y) == y and x > 0 and y > 0 and x < #tilemap and y < #tilemap[1] then
		return true
	end
	return false
end

-- Check the direction of a potential doorway.
--  If the indicated tile is a wall on the room stored in grid, and it could be the site of
--  a door out of that room, then return the outbound direction that the door faces.
--  Otherwise, return nil ("no direction").
function tilemap_door_direction(tilemap,x,y)

	-- If the square is something other than rock, it's already occupied, and we
	-- return a nil value to represent no direction
	if tilemap[x][y] != 0 then
		return nil
	end

	-- for the plain four directions (left, right, up, down)...
	for dir=1, 4, 1 do
		-- calculate coordinate offsets for adjacent tiles
		newx = x + directions[dir][0]
		newy = y + directions[dir][1]
		oppx = x - directions[dir][0]
		oppy = y - directions[dir][1]
		-- if both sets of coordinates lie within the map and the
		-- opposite coordinate is also floor (ie. standable)...
		if tilemap_coordinates_valid(oppx,oppy) and tilemap_coordinates_valid(newx,newy) and tilemap[oppx][oppy] == 1 then
			-- we have a result
			return dir
		end
	end

	return nil
end
