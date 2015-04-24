local Timer = require "libs.hump.timer"
local GameOver = {}

function GameOver:enter()
	self.lines = "Game Over :("
	local font = love.graphics.getFont()
	local height = select(2, font:getWrap(self.lines, love.graphics.getWidth())) * font:getHeight()
	self.state = { y = love.graphics.getHeight() / 2 - height / 2, opacity = 0 }
	Timer.add(5, function()
		self:transition_out()
	end)
	self.input_locked = true

	-- prevent accidental instant skipping
	Timer.add(0.5, function()
		self.input_locked = false
	end)
end

function GameOver:transition_out()
	Timer.clear()
	Timer.tween(1, self.state, { opacity = 255 }, "in-out-quad")
	Timer.add(1, function() Gamestate.switch(require "states.title") end)
end

function GameOver:update(dt)
	if Preferences.hyper_speed then
		dt = dt * 4
	end

	Timer.update(dt)
end

function GameOver:keypressed(key, is_repeat)
	if self.input_locked then
		return
	end

	if key == "return" or key == "space" then
		Signal.emit("play-back")
		self:transition_out()
	end
end

function GameOver:mousepressed(x, y, button)
	if self.input_locked then
		return
	end
	if button == "l" then
		Signal.emit("play-back")
		self:transition_out()
	end
end

function GameOver:draw()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.printf(self.lines, 0, self.state.y, love.graphics.getWidth(), "center")
	love.graphics.setColor(0, 0, 0, self.state.opacity)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
end

return GameOver
