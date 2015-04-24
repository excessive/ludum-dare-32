local Timer = require "libs.hump.timer"
local Credits = {}

function Credits:enter()
	self.lines = love.filesystem.read("credits.txt")
	local font = love.graphics.getFont()
	local width, height = font:getWrap(self.lines, love.graphics.getWidth())
	height = height * font:getHeight()

	self.state = { width = width, y = love.graphics.getHeight(), opacity = 0 }
	Timer.tween(5, self.state, { y = love.graphics.getHeight() / 2 - height / 2 }, "out-quad")
	Timer.add(9, function()
		self:transition_out()
	end)
	self.input_locked = true

	-- prevent accidental instant skipping
	Timer.add(0.5, function()
		self.input_locked = false
	end)
end

function Credits:transition_out()
	Timer.clear()
	Timer.tween(1, self.state, { opacity = 255 }, "in-out-quad")
	Timer.add(1, function() Gamestate.switch(require "states.title") end)
end

function Credits:update(dt)
	if Preferences.hyper_speed then
		dt = dt * 4
	end

	Timer.update(dt)
end

function Credits:keypressed(key, is_repeat)
	if self.input_locked then
		return
	end

	if key == "return" or key == "space" then
		Signal.emit("play-back")
		self:transition_out()
	end
end

function Credits:mousepressed(x, y, button)
	if self.input_locked then
		return
	end
	if button == "l" then
		Signal.emit("play-back")
		self:transition_out()
	end
end

function Credits:draw()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.printf(self.lines, love.graphics.getWidth() / 2 - self.state.width / 2, self.state.y, love.graphics.getWidth(), "left")
	love.graphics.setColor(0, 0, 0, self.state.opacity)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
end

return Credits
