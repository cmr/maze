function love.load()
	print("love.load called\n")
	maze = require 'maze'
	m = maze:new(30, 40)
	m:generate()
end

function love.draw()
	m:draw()
end