local domy   = require "libs.DOMy"
local Timer  = require "libs.hump.timer"
local lume   = require "libs.lume"
local cpml   = require "libs.cpml"
local Camera = require "libs.camera3d"
local Entity = require "entity"
local World  = {}

function World:enter(from)
	self.gui = domy.new()
	self.gui:import_markup("assets/ui/markup/world.lua")
	self.gui:import_styles("assets/ui/styles/world.lua")
	self.gui:import_scripts("assets/ui/scripts/world.lua")
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

	self.exit_timer = Timer.new()

	self.first_update = true
	love.graphics.setBackgroundColor(0, 0, 0)

	-- load Tsubasa
	self.tsubasa = Entity {
		position    = cpml.vec3(0, 0, 0),
		orientation = cpml.vec3(0, 0, 0),
		scale       = cpml.vec3(1, 1, 1),
		model       = "assets/models/ld-tsubasa.iqe",
		material    = "assets/materials/ld-tsubasa.mtl",
		shader      = "assets/shaders/shader.glsl",
	}

	-- load scene
	self.scene = Entity {
		position    = cpml.vec3(0, 0, -0.001),
		orientation = cpml.vec3(0, 0, 0),
		scale       = cpml.vec3(1, 1, 1),
		model       = "assets/models/ld32-scene.iqe",
		material    = "assets/materials/ld32-scene.mtl",
		shader      = "assets/shaders/shader.glsl",
	}

	self.camera  = Camera(cpml.vec3(0, -2, 1.5))
	self.camera:rotateXY(0, -100)

	self.script = require "script"
	self.state  = {
		battle     = 1,
		sub_battle = 1,
		line       = 1,
	}

	self.voice = {
		[1] = love.audio.newSource("assets/audio/tsubasa/entire_track_team.ogg"),
		[2] = love.audio.newSource("assets/audio/tsubasa/if_they_see.ogg"),
		[4] = love.audio.newSource("assets/audio/tsubasa/kyaa.ogg"),
	}

	self.bgm = love.audio.newSource("assets/audio/music/saywhatyouwill.mp3")
	self.bgm:setVolume(Preferences.bgm_volume)
	self.bgm:setLooping(true)

	for _, v in pairs(self.voice) do
		v:setVolume(Preferences.voice_volume)
	end

	local message = self.gui:get_element_by_id("dialog")
	message.value = self.script[self.state.battle][self.state.line]
	self.voice[self.state.line]:play()

	function message.on_mouse_clicked(element, button)
		if button == "l" then
			-- Disable Previous Voice
			if self.state.battle == 1 then
				if self.voice[self.state.line] then
					self.voice[self.state.line]:stop()
				end
			end

			-- Next line
			self.state.line = self.state.line + 1

			local value = self.script[self.state.battle][self.state.line]
			if value then
				element.value = value

				-- New Voice!
				if self.state.battle == 1 then
					if self.voice[self.state.line] then
						self.voice[self.state.line]:play()
					end
				end
			else
				self:transition_out(function()
					self:enter_battle()
				end)
			end
		end
	end

	local next_button = self.gui:get_element_by_id("next_button")
	function next_button.on_mouse_clicked(element, button)
		message:on_mouse_clicked("l")
	end

	self:register()
	self:transition_in()
end

function World:register()
	Signal.register("exit", function(...) self:exit_game() end)
	self.bgm:rewind()
	self.bgm:play()
	self.bgm:setVolume(Preferences.bgm_volume)
end

function World:unregister()
	Signal.clear("exit")
	self.bgm:stop()
	self.bgm:setVolume(0.0)
	if self.voice[self.state.line] then
		self.voice[self.state.line]:stop()
	end
end

function World:enter_battle(battle)
	self:unregister()
	local battle = self.script[self.state.battle]
	if battle and battle.battles then
		local sub_battle = battle.battles[self.state.sub_battle]
		Gamestate.push(require "states.battle", sub_battle)
	else
		self:unregister()
		Gamestate.switch(require "states.credits")
	end
end

function World:transition_in()
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

function World:transition_out(nextfn)
	self:unregister()

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
				self.exit_timer:add(wait_time, lume.combine(function() cover.value = nil end, nextfn))
			end
		end)
	end)
end

function World:resume(from, victory)
	self:register()
	self:transition_in()

	local sc = self.script
	local st = self.state

	if victory then
		st.sub_battle = st.sub_battle + 1

		if sc[st.battle].battles then
			local total_sub_battles = #sc[st.battle].battles
			if total_sub_battles < st.sub_battle then
				st.battle = st.battle + 1
				st.sub_battle = 1
				st.line = 1
			end
		end

		-- see if we should go immediately to the next battle...
		if self.state.line > #self.script[self.state.battle] then
			self:enter_battle()
		end

		local message = self.gui:get_element_by_id("dialog")
		message.value = self.script[self.state.battle][self.state.line]
	else
		self:unregister()
		Gamestate.switch(require "states.gameover")
	end
end

function World:keypressed(key, is_repeat)
	if key == "escape" then
		Signal.emit("exit")
	end

	if key == "pause" then
		Signal.emit("toggle-mute")
	end

	if key == "return" or key == " " then
		local message = self.gui:get_element_by_id("dialog")
		message:on_mouse_clicked("l")
	end

	-- !!! make sure non-debug keys are above this !!!
	if key == "f12" then
		Preferences.debug = not Preferences.debug
	end

	if not Preferences.debug then
		return
	end

	if key == "1" then
		self:transition_out(function()
			self.state.line = #self.script[self.state.battle] + 1
			self:enter_battle()
		end)
	end
end

function World:update(dt)
	-- reset animation on first frame to prevent the jump
	if self.first_update then
		self:reset_to_idle()
		self.first_update = false
	end

	self.camera:update()
	self.tsubasa:update(dt)
	self.scene:update(dt)

	if Preferences.hyper_speed then
		dt = dt * 4
	end

	Signal.emit("update-title")

	self.gui:update(dt)
	self.exit_timer:update(dt)
end

function World:draw()
	if self.first_update then
		return
	end

	local cc = love.math.gammaToLinear
	local color = cpml.vec3(cc(unpack(cpml.color.darken({255,255,255,255}, 0.75))))
	love.graphics.setBackgroundColor(color.x, color.y, color.z, color:dot(cpml.vec3(0.299, 0.587, 0.114)))

	-- Disable blending because we use/abuse the alpha channel for other stuff.
	-- gl.Disable(GL.BLEND)
	gl.Clear(bit.bor(tonumber(GL.DEPTH_BUFFER_BIT), tonumber(GL.COLOR_BUFFER_BIT)))
	gl.Enable(GL.DEPTH_TEST)
	gl.DepthFunc(GL.LESS)
	gl.DepthRange(0, 1)
	gl.ClearDepth(1.0)

	gl.Enable(GL.CULL_FACE)
	gl.CullFace(GL.BACK)

	-- IQE/IQM models use CW winding. I'm not entirely sure why, but that's how it is.
	-- It's convenient for us to follow IQM's winding, so we do it too.
	gl.FrontFace(GL.CW)

	local model = cpml.mat4()
		:translate(self.scene.position)
		:rotate(self.scene.orientation.z, { 0, 0, 1 })
		:scale(self.scene.scale)

	self.scene.model.shader:send("u_model", model:to_vec4s())
	self.camera:send(self.scene.model.shader)
	self.scene:draw(nil, model)

	local model = cpml.mat4()
		:translate(self.tsubasa.position)
		:rotate(self.tsubasa.orientation.z, { 0, 0, 1 })
		:scale(self.tsubasa.scale)

	self.tsubasa.model.shader:send("u_model", model:to_vec4s())
	self.camera:send(self.tsubasa.model.shader)
	self.tsubasa:draw(nil, model)

	gl.FrontFace(GL.CCW)
	gl.Disable(GL.CULL_FACE)
	gl.Disable(GL.DEPTH_TEST)
	-- gl.Enable(GL.BLEND)

	self.gui:draw()

	if Preferences.debug then
		local spacing = 24
		love.graphics.print(string.format("Battle: %d", self.state.battle), 0, spacing*0)
		love.graphics.print(string.format("Sub-Battle: %d", self.state.sub_battle), 0, spacing*1)
		love.graphics.print(string.format("Line: %d", self.state.line), 0, spacing*2)
	end
end

function World:leave()
	self.gui = nil
	self.exit_timer = nil
end

function World:exit_game()
	self.exit_timer:clear()

	local message = self.gui:get_element_by_id("exit_message")
	message:set_property("visible", true)
	message:set_property("opacity", 0.0)

	local cover = self.gui:get_element_by_id("cover")
	cover:set_property("background_color", { 0, 0, 0, 200 })
	cover:set_property("visible", true)
	message:set_property("opacity", 0.0)

	message.value = lume.randomchoice {
		"I'LL MISS YOU",
		";_;",
		"I-it's not like I wanted you to stay or anything! Baka!",
		"Now I'll never be a bride!",
	}

	local fade_in_time  = 0.25
	local fade_out_time = 0.5
	local message_time  = 0.5

	local time = 0
	local function fade_in(dt)
		time = time + dt
		local position = time / fade_in_time
		message:set_property("opacity", position)
		cover:set_property("opacity", position)
	end

	local function fade_out(dt)
		time = time + dt
		local position = time / fade_out_time
		message:set_property("opacity", 1 - position)
		cover:set_property("background_color", { 0, 0, 0, math.max(200, position * 255) })
	end

	local function wait()
		message:set_property("opacity", 1.0)
		cover:set_property("opacity", 1.0)
		self.exit_timer:add(message_time, function()
			time = 0
			self.exit_timer:do_for(fade_out_time, fade_out, function()
				Gamestate.switch(require "states.title")
			end)
		end)
	end

	Signal.emit("play-back")

	self.exit_timer:do_for(fade_in_time, fade_in, wait)
	self:unregister()
end

function World:reset_to_idle()
	local anim2
	local anim1 = function(a)
		a:animate("Idle1", anim2)
	end
	anim2 = function(a)
		a:animate("Idle2", anim1)
	end

	self.tsubasa:animate("StandingToIdle", anim1)
end

return World
