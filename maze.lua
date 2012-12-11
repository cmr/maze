local maze = {}

local maze_mt = {__index = maze}

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
end

function maze:clear(x, y)
	self.grid[x][y] = 0
end

function maze:draw()
	for x, ya in ipairs(self.grid) do
		for y,val in ipairs(ya) do
			if val == 1 then love.graphics.rectangle('fill', x*5, y*5, 4, 4) end
		end
	end
end

function maze:generate()
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
	
return maze