local domy  = require "libs.DOMy"
local lume = require "libs.lume"
local Timer = require "libs.hump.timer"
local Options = {}

function Options:enter(from)
	self.gui = domy.new()
	self.gui:import_markup("assets/ui/markup/options.lua")
	self.gui:import_styles("assets/ui/styles/title.lua")
	-- self.gui:import_scripts("assets/ui/scripts/options.lua")
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

	self:gui_shit()

	self:transition_in()
end

function Options:gui_shit()
	local volume_label = self.gui:get_element_by_id("volume_label")
	volume_label.value = string.format("Master Volume: %d%%", Preferences.master_volume * 100)

	local bgm_label = self.gui:get_element_by_id("bgm_label")
	bgm_label.value = string.format("Music Volume: %d%%", Preferences.bgm_volume * 100)

	local sfx_label = self.gui:get_element_by_id("sfx_label")
	sfx_label.value = string.format("Effects Volume: %d%%", Preferences.sfx_volume * 100)

	local voice_label = self.gui:get_element_by_id("voice_label")
	voice_label.value = string.format("Voice Volume: %d%%", Preferences.voice_volume * 100)

	local debug = self.gui:get_element_by_id("debug")
	if Preferences.debug then
		debug.value = "Debug (On)"
	else
		debug.value = "Debug (Off)"
	end

	function debug:on_mouse_clicked(button)
		if button == "l" then
			Preferences.debug = not Preferences.debug

			if Preferences.debug then
				debug.value = "Debug (On)"
			else
				debug.value = "Debug (Off)"
			end
		end
	end

	local mute = self.gui:get_element_by_id("mute")
	if Preferences.mute then
		mute.value = "Mute (On)"
	else
		mute.value = "Mute (Off)"
	end

	function mute:on_mouse_clicked(button)
		if button == "l" then
			Signal.emit('toggle-mute')

			if Preferences.mute then
				mute.value = "Mute (On)"
			else
				mute.value = "Mute (Off)"
			end
		end
	end

	local hyper_speed = self.gui:get_element_by_id("hyper_speed")
	if Preferences.hyper_speed then
		hyper_speed.value = "Hyper Speed (On)"
	else
		hyper_speed.value = "Hyper Speed (Off)"
	end

	function hyper_speed:on_mouse_clicked(button)
		if button == "l" then
			if Preferences.hyper_speed then
				hyper_speed.value = "Hyper Speed (On)"
			else
				hyper_speed.value = "Hyper Speed (Off)"
			end
		end
	end

	local volume_up = self.gui:get_element_by_id("volume_up")

	function volume_up:on_mouse_clicked(button)
		if button == "l" then
			Preferences.master_volume = Preferences.master_volume + 0.1
			volume_label.value = string.format("Master Volume: %d%%", Preferences.master_volume * 100)
			love.audio.setVolume(Preferences.mute and 0.0 or Preferences.master_volume)
		end
	end

	local volume_down = self.gui:get_element_by_id("volume_down")

	function volume_down:on_mouse_clicked(button)
		if button == "l" then
			Preferences.master_volume = Preferences.master_volume - 0.1
			volume_label.value = string.format("Master Volume: %d%%", Preferences.master_volume * 100)
			love.audio.setVolume(Preferences.mute and 0.0 or Preferences.master_volume)
		end
	end

	local bgm_volume_up = self.gui:get_element_by_id("bgm_volume_up")

	function bgm_volume_up:on_mouse_clicked(button)
		if button == "l" then
			Preferences.bgm_volume = Preferences.bgm_volume + 0.1
			bgm_label.value = string.format("Music Volume: %d%%", Preferences.bgm_volume * 100)
		end
	end

	local bgm_volume_down = self.gui:get_element_by_id("bgm_volume_down")

	function bgm_volume_down:on_mouse_clicked(button)
		if button == "l" then
			Preferences.bgm_volume = Preferences.bgm_volume - 0.1
			bgm_label.value = string.format("Music Volume: %d%%", Preferences.bgm_volume * 100)
		end
	end

	local sfx_volume_up = self.gui:get_element_by_id("sfx_volume_up")

	function sfx_volume_up:on_mouse_clicked(button)
		if button == "l" then
			Preferences.sfx_volume = Preferences.sfx_volume + 0.1
			sfx_label.value = string.format("Effects Volume: %d%%", Preferences.sfx_volume * 100)
		end
	end

	local sfx_volume_down = self.gui:get_element_by_id("sfx_volume_down")

	function sfx_volume_down:on_mouse_clicked(button)
		if button == "l" then
			Preferences.sfx_volume = Preferences.sfx_volume - 0.1
			sfx_label.value = string.format("Effects Volume: %d%%", Preferences.sfx_volume * 100)
		end
	end

	local voice_volume_up = self.gui:get_element_by_id("voice_volume_up")

	function voice_volume_up:on_mouse_clicked(button)
		if button == "l" then
			Preferences.voice_volume = Preferences.voice_volume + 0.1
			voice_label.value = string.format("Voice Volume: %d%%", Preferences.voice_volume * 100)
		end
	end

	local voice_volume_down = self.gui:get_element_by_id("voice_volume_down")

	function voice_volume_down:on_mouse_clicked(button)
		if button == "l" then
			Preferences.voice_volume = Preferences.voice_volume - 0.1
			voice_label.value = string.format("Voice Volume: %d%%", Preferences.voice_volume * 100)
		end
	end

	local exit = self.gui:get_element_by_id("exit")

	function exit:on_mouse_clicked(button)
		if button == "l" then
			Gamestate.switch(require "states.title")
		end
	end

	for _, v in ipairs(self.options) do
		local action = "play-next"
		if v.id == "exit" then
			action = "play-back"
		end
		v.on_mouse_clicked = lume.combine(v.on_mouse_clicked, function() Signal.emit(action) end)
	end
end

function Options:transition_in()
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

function Options:transition_out(nextfn)
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

function Options:update(dt)
	if self.first_update then
		self.first_update = false
	end

	if Preferences.hyper_speed then
		dt = dt * 4
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

function Options:draw()
	if self.first_update then
		return
	end
	self.gui:draw()
end

function Options:mousemoved(x, y, dx, dy)
	self.options[self.item]:remove_class("active")
end

function Options:keypressed(key, is_repeat)
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

function Options:leave()
	self.gui = nil
	self.exit_timer = nil
end

return Options
