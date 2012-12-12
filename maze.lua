local maze = {}
local maze_mt = {__index = maze}

function makepair(tab, x)
	local y
	if x == nil then
		x = tab.x
		y = tab.y
	else
		x = tab
		y = x
	end
	return "(" .. x .. ", " .. y .. ")"
end

local directions = {
	-- N/S/E/W offsets
	{x = 0, y = 1},
	{x = 0, y = -1},
	{x = 1, y = 0},
	{x = -1, y = 0}
}

function maze:new(x, y)
	local t = setmetatable({x = x, y = y, grid={}}, maze_mt)

	for x_ = 1, x do
		t.grid[x_] = {}
		for y_ = 1, y do
			t.grid[x_][y_] = false
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

function maze:set(x, y, val)
	if val == nil then val = true end
	self.grid[x][y] = val
	return
end

function maze:get(x, y)
	-- todo: make this less fragileish
	if x < 1 or y < 1 then
		return false
	elseif x > self.x or y > self.y then
		return false
	end

	return self.grid[x][y]
end

function maze:clear(x, y)
	self.grid[x][y] = false
	return
end

function maze:draw()
	for x, ya in ipairs(self.grid) do
		for y,val in ipairs(ya) do
			if val then
				if val == 'done' then
					love.graphics.setColor(255, 0, 0)
				end
				love.graphics.rectangle('fill', x*5, y*5, 4, 4)
				love.graphics.setColor(255, 255, 255)
			end
		end
	end
end

-- todo: this feels ugly
local generate = function(self)
	print("generate() called")
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
			position.x = 1
		else
			position.x = self.x
		end
		position.y = math.random(1, self.y)
	else
		-- y
		if side == 0 then
			position.y = 1
		else
			position.y = self.y
		end
		position.x = math.random(1, self.x)
	end

	self:set(position.x, position.y)

	coroutine.yield(position)

	-- (2) Random walk!
	
	-- walks a single step. returns false if not able to go further
	function walk()
		local good_directions = {}
		for _,offset in ipairs(directions) do
			print( self:get(position.x + offset.x, position.y + offset.y))
			if not self:get(position.x + offset.x, position.y + offset.y) then
				table.insert(good_directions, offset)
			end
		end
		
		if #good_directions == 0 then
			love.graphics.setColor(255, 0, 0)
			return false
		end

		print(#good_directions)
		local direction = good_directions[math.random(1, #good_directions)]
		position.x = position.x + direction.x
		position.y = position.y + direction.y
		
		if position.x > self.x or position.y > self.y or position.x < 1 or
		   position.y < 1 then
		   self:set(position.x - direction.x, position.y - direction.y, 'done')
		   return 'done'
		end

		coroutine.yield(position)
		print("Going to " .. makepair(position))
		self:set(position.x, position.y)
		return true
	end
	
	-- do all the walking
	while true do
		local st = walk()
		if st == 'done' then
			coroutine.yield(st)
			return true
		end
		if st == false then
			coroutine.yield(false)
		end
	end
end

function maze:generate()
	return coroutine.create(function() return generate(self) end)
end

return maze
