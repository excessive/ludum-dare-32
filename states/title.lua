local domy  = require "libs.DOMy"
local Timer = require "libs.hump.timer"
local Title = {}

function Title:enter(from)
	self.gui = domy.new()
	self.gui:import_markup("assets/ui/markup/title.lua")
	self.gui:import_styles("assets/ui/styles/title.lua")
	self.gui:import_scripts("assets/ui/scripts/title.lua")
	self.gui:resize()

	-- Register all unused callbacks
	local callbacks = self.gui:get_callbacks()
	for _, v in ipairs(callbacks) do
		if not self[v] then
			self[v] = function(self, ...)
				self.gui[v](self.gui, ...)
			end
		end
	end

	self.item = 1
	self.options = self.gui:get_elements_by_query("#menu button")

	self.first_update = true
	self.exit_timer = Timer.new()
	self.mouse_coords = { love.mouse.getPosition() }
	love.graphics.setBackgroundColor(0, 0, 0)
	self:transition_in()
end

function Title:transition_in()
	local cover = self.gui:get_element_by_id("cover")
	cover:set_property("background_color", { 0, 0, 0, 255 })
	cover:set_property("visible", true)
	cover:set_property("opacity", 1.0)

	local wait_time = 0.125
	local fade_time = 0.25
	local time = 0
	local function fade(dt)
		time = time + dt
		local position = time / fade_time
		cover:set_property("opacity", 1 - position)
	end
	self.exit_timer:add(wait_time, function()
		self.exit_timer:do_for(fade_time, fade, function()
			cover:set_property("visible", false)
			cover:set_property("opacity", 0)
		end)
	end)
end

function Title:transition_out(nextfn)
	local cover = self.gui:get_element_by_id("cover")
	cover:set_property("background_color", { 0, 0, 0, 255 })
	cover:set_property("visible", true)
	cover:set_property("opacity", 0)

	local wait_time = 0.125
	local fade_time = 0.25
	local time = 0
	local function fade(dt)
		time = time + dt
		local position = time / fade_time
		cover:set_property("opacity", position)
	end
	self.exit_timer:add(wait_time, function()
		self.exit_timer:do_for(fade_time, fade, function()
			cover:set_property("visible", true)
			cover:set_property("opacity", 1.0)
			if nextfn then
				cover.value = "Loading..."
				self.exit_timer.add(wait_time, lume.combine(function() cover.value = nil end, nextfn))
			end
		end)
	end)
end

function Title:update(dt)
	if self.first_update then
		self.first_update = false
	end
	Signal.emit("update-title")

	local new_coords = { love.mouse.getPosition() }
	local old_coords = self.mouse_coords
	if old_coords[1] ~= new_coords[1] or old_coords[2] ~= new_coords[2] then
		self:mousemoved(new_coords[1], new_coords[2], new_coords[1] - old_coords[1], new_coords[2] - old_coords[2])
		self.mouse_coords = new_coords
	end

	self.exit_timer:update(dt)

	self.gui:update(dt)
end

function Title:draw()
	if self.first_update then
		return
	end
	self.gui:draw()
end

function Title:mousemoved(x, y, dx, dy)
	self.options[self.item]:remove_class("active")
end

function Title:keypressed(key, is_repeat)
	if key == "up" then
		if self.options[self.item]:has_class("active") then
			self.options[self.item]:remove_class("active")
			self.item = self.item - 1
			if self.item < 1 then
				self.item = self.item + #self.options
			end
			self.options[self.item]:add_class("active")
		end
	end
	if key == "tab" or key == "down" then
		if self.options[self.item]:has_class("active") then
			self.options[self.item]:remove_class("active")
			self.item = (self.item % #self.options) + 1
		end
		self.options[self.item]:add_class("active")
	end

	if key == "return" or key == " " then
		self.options[self.item]:on_mouse_clicked("l")
	end

	-- !!! make sure non-debug keys are above this !!!
	if key == "f12" then
		Preferences.debug = not Preferences.debug
	end

	if not Preferences.debug then
		return
	end
end

function Title:leave()
	self.gui = nil
	self.exit_timer = nil
end

return Title
