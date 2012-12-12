local maze = {}
local maze_mt = {__index = maze}

function makepair(tab, x)
	if x == nil then
		local x = position.x
		local y = position.y
	else
		local x = tab
		local y = x
	end
	return "(" .. x .. ", " .. y .. ")"
end

local directions = {
	-- Each of these is a pair of offsets for each of the 8 directions that can
	-- be moved in in a square grid.
	{x = 0, y = 1},
	{x = 0, y = -1},
	{x = 1, y = 1},
	{x = 1, y = -1},
	{x = 1, y = 0},
	{x = -1, y = 1},
	{x = -1, y = -1},
	{x = -1, y = 0}
}

function maze:new(x, y)
	local t = setmetatable({x = x, y = y, grid={}}, maze_mt)

	for x_ = 1, x do
		t.grid[x_] = {}
		for y_ = 1, y do
			t.grid[x_][y_] = 0
		end
	end

	return t
end

function maze:locOnBorder(x, y)
	if x == 0 or x == self.x then
		return true
	end

	if y == 0 or y == self.y then
		return true
	end

	return false
end

function maze:set(x, y)
	self.grid[x][y] = 1
	return
end

function maze:clear(x, y)
	self.grid[x][y] = 0
	return
end

function maze:draw()
	for x, ya in ipairs(self.grid) do
		for y,val in ipairs(ya) do
			love.graphics.setColor(255, 255, 255)
			if val == 1 then love.graphics.rectangle('fill', x*5, y*5, 4, 4) end
		end
	end
end

-- todo: this feels ugly
local generate = function(self)
	--[[
		1. pick a random point on the edge
		2. do a random walk, not walking over previously visited squares, until
		   either can't walk anymore (restart) or left the grid
	]]
	-- (1) X or Y axis?
	local x_or_y = math.random(0, 1)
	-- top/left or bottom/right?
	local side = math.random(0, 1)
	local position = {}
	if x_or_y == 0 then
		-- x
		if side == 0 then
			position.x = 0
		else
			position.x = self.x
		end
		position.y = math.random(1, self.y)
	else
		-- y
		if side == 0 then
			position.y = 0
		else
			position.y = self.y
		end
		position.x = math.random(1, self.x)
	end

	self:set(position.x, position.y)

	-- (2) Random walk!
	
	-- walks a single step. returns false if not able to go further
	function walk()
		local good_directions = {}
		for _,offset in directions do
			if not self:get(position.x + offset.x, position.y + offset.y) then
				good_directions.insert(offset)
			end
		end
		
		if #good_directions == 0 then return false end
		
		local direction = good_directions[math.random(1, #good_directions)]
		position.x = position.x + offset.x
		position.y = position.y + offset.y
		
		if position.x > self.x or position.y > self.y or position.x < 1 or
		   position.y < 1 then
		   return 'done'
		end

		self:set(position.x, position.y)
		return true
	end
	
	-- do all the walking
	while true do
		local st = walk()
		if st == 'done' then
			return true
		end
		if st == false then
			return false
		end
		coroutine.yield()
	end
end

function maze:generate()
	return coroutine.create(function() return generate(self) end)
end

return maze