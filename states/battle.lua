local cpml   = require "libs.cpml"
local domy   = require "libs.DOMy"
local Entity = require "entity"
local Camera = require "libs.camera3d"
local Timer  = require "libs.hump.timer"
local lume   = require "libs.lume"
local Battle = {}

-- TODO: Multiple enemies
function Battle:enter(from, battle)
	battle = battle or {}
	local enemy = battle.enemies and battle.enemies[1] or {}

	self.lines = {}
	self.current_line = 1

	-- load battle text
	for i, v in ipairs(battle) do
		table.insert(self.lines, v)
	end

	self.gui = domy.new()
	self.gui:import_markup("assets/ui/markup/battle.lua")
	self.gui:import_styles("assets/ui/styles/battle.lua")
	self.gui:import_scripts("assets/ui/scripts/battle.lua")
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

	-- load Tsubasa
	self.tsubasa = Entity {
		position    = cpml.vec3(0, 0, 0),
		orientation = cpml.vec3(0, 0, math.pi),
		scale       = cpml.vec3(1, 1, 1),
		model       = "assets/models/ld-tsubasa.iqe",
		material    = "assets/materials/ld-tsubasa.mtl",
		shader      = "assets/shaders/shader.glsl",
		hp          = 143,
	}

	self.shadow = Entity {
		model    = "assets/models/plane.iqe",
		material = "assets/materials/plane.mtl",
		shader   = "assets/shaders/shader.glsl",
	}

	-- load enemy
	self.enemy = Entity {
		position    = enemy.name == "Panzerkampfwagen IV Ausführung H-sensei" and cpml.vec3(0, 5, 0) or cpml.vec3(0, 3, 0),
		orientation = enemy.name == "Panzerkampfwagen IV Ausführung H-sensei" and cpml.vec3(0, 0, math.pi) or cpml.vec3(0, 0, 0),
		scale       = cpml.vec3(1, 1, 1),
		model       = enemy.name == "Panzerkampfwagen IV Ausführung H-sensei" and "assets/models/tank.iqe" or "assets/models/ld-dudemanbro.iqe",
		material    = enemy.name == "Panzerkampfwagen IV Ausführung H-sensei" and "assets/materials/tank.mtl" or "assets/materials/generic.mtl",
		shader      = "assets/shaders/shader.glsl",
		name        = enemy.name or "Panzerkampfwagen IV Ausführung Huehuehue-sensei",
		attacks     = enemy.attacks,
		hp          = enemy.hp or 76239,
	}

	self:update_frames()

	local models    = "assets/models"
	local materials = "assets/materials"
	local generic   = "assets/materials/generic.mtl"
	local shader    = "assets/shaders/shader.glsl"

	local function thing(path, pos, orientation, scale, shadow_scale, material)
		if material then
			material = string.format("%s/%s", materials, material)
		else
			material = generic
		end

		return Entity {
			name = path,
			position = pos,
			orientation = orientation or cpml.vec3(0, 0, 0),
			scale = scale or cpml.vec3(1, 1, 1),
			shadow_scale = shadow_scale or cpml.vec3(1, 1, 1),
			model = string.format("%s/%s", models, path),
			material = material,
			shader = shader
		}
	end

	local v = cpml.vec3

	self.items = {
		thing("ld-prinny.iqe", v(7,5.2,0), v(0, 0, -math.pi / 3), v(2, 2, 2), v(1.25, 1.25, 1.25)),
		thing("ld-prinny.iqe", v(6.6,6.7,0), v(0, 0, -math.pi / 4), v(2, 2, 2), v(1.25, 1.25, 1.25)),
		thing("candy/candycane.iqe", v(5.4,-5.3,0), nil, nil, v(2, 2, 2)),
		thing("candy/lollipop.iqe", v(-6.9,-1,0), nil, v(3, 3, 3), v(0.25, 0.25, 0.25)),
		thing("candy/pirouline.iqe", v(5,7.6,0), nil, v(10, 10, 10), v(0.1, 0.1, 0.1)),
		thing("candy/pocky.iqe", v(-7.2,7.9,0), nil, v(10, 10, 10), v(0.1, 0.1, 0.1)),
		thing("ld32-scene.iqe", v(0, 0, -0.025), nil, v(1, 1, 1), v(0, 0, 0), "ld32-scene.mtl"),
	}

	self.player_one = true
	self.attacking  = false

	self.first_update  = true
	self.message_timer = Timer.new()
	self.exit_timer    = Timer.new()
	self.flavour_timer = Timer.new()

	self.trackable = cpml.vec3(0, 0, 0)

	self.camera_positions = {
		track         = { cpml.vec3(0,0,0), self.trackable },
		default       = { cpml.vec3(0, -3, 1.75), false, { 0, -150 } },
		facing        = { cpml.vec3(0, 2, 1.55), cpml.vec3(0, 0, 1.25) },
		enemy         = { cpml.vec3(5, 16, 5), self.tsubasa.position },
		overhead      = { cpml.vec3(0, -11, 11), cpml.vec3(0, 5, 0) },
		pokemon       = { cpml.vec3(2.5, -0.9, 1.6), cpml.vec3(0.2, 1, 0.8) },
		pokemon_enemy = { cpml.vec3(-2.5, 3.9, 1.6), cpml.vec3(0.2, 1.8, 0.8) },
		panzer        = { cpml.vec3(-7.0, 6.1, 5.0), cpml.vec3(0.2, 1.8, 1.5) },
	}
	self.camera_names = lume.keys(self.camera_positions)
	self.camera  = Camera()
	self:set_camera("default")

	self.on_victory = battle.on_victory
	self.on_defeat  = battle.on_defeat

	self.item_mode = false
	self.item = 1

	if battle.boss then
		self.bgm = love.audio.newSource("assets/audio/music/jp_Themesong_2.mp3")
	else
		self.bgm = love.audio.newSource("assets/audio/music/Horror_Adventure_v2.mp3")
	end
	self.bgm:setVolume(Preferences.bgm_volume)
	self.bgm:setLooping(true)

	self.voice = {
		left_swipe = love.audio.newSource("assets/audio/tsubasa/left_swipe.ogg"),
		two_stylin = love.audio.newSource("assets/audio/tsubasa/2_stylin_style.ogg"),
		my_milk    = love.audio.newSource("assets/audio/tsubasa/my_milk.ogg"),
		kyaa       = love.audio.newSource("assets/audio/tsubasa/girl_power.ogg"),
		defeat     = love.audio.newSource("assets/audio/tsubasa/cant_be_a_bride.ogg"),
		victory1   = love.audio.newSource("assets/audio/tsubasa/defeated_a_pervert.ogg"),
		victory2   = love.audio.newSource("assets/audio/tsubasa/defeated_another_pervert.ogg"),
		victory3   = love.audio.newSource("assets/audio/tsubasa/take_that_pervert.ogg"),
	}

	for _, v in pairs(self.voice) do
		v:setVolume(Preferences.voice_volume)
	end

	self.mouse_coords = { love.mouse.getPosition() }
	self.options = {}
	self.item = 1

	self:register()

	Signal.emit("update-active-menu", { self.gui:get_element_by_id("attack"), self.gui:get_element_by_id("special"), self.gui:get_element_by_id("flee") })
end

function Battle:register()
	Signal.register("attack-swipe", function(...) self:attack_swipe(...) end)
	Signal.register("attack-dual",  function(...) self:attack_dual(...) end)
	Signal.register("attack-milk",  function(...) self:attack_milk(...) end)
	Signal.register("attack-kyaa",  function(...) self:attack_kyaa(...) end)

	Signal.register("battle-message",  function(...) self:battle_message(...) end)
	Signal.register("ui-message",      function(...) self:show_message(...) end)
	Signal.register("flavour-message", function(...) self:show_flavour_message(...) end)
	Signal.register("exit",            function(...) self:exit_game(...) end)
	Signal.register("victory",         function(...) self:transition_out(...) end)

	Signal.register("update-active-menu", function(...) self:update_binds(...) end)

	Signal.emit("battle-message", self.lines[self.current_line] or "fite me m9")

	self.gui:get_element_by_id("dialog").on_mouse_clicked = function(el, button)
		self.current_line = self.current_line + 1
		local next_value = self.lines[self.current_line] or ""
		if button == "l" then
			Signal.emit("battle-message", next_value)
		end
	end

	self.bgm:rewind()
	self.bgm:play()
end

function Battle:update_binds(items)
	local argh = self.gui:get_elements_by_query(".active")
	for k, v in pairs(argh) do
		v:remove_class("active")
	end
	self.item = 1
	self.options = items
end

function Battle:unregister()
	Signal.clear("attack-dual")
	Signal.clear("attack-swipe")
	Signal.clear("attack-milk")
	Signal.clear("attack-girl")

	Signal.clear("update-active-menu")

	Signal.clear("battle-message")
	Signal.clear("ui-message")
	Signal.clear("victory")
	Signal.clear("exit")

	self.bgm:stop()
end

function Battle:mousemoved(x, y, dx, dy)
	if self.options[self.item] then
		self.options[self.item]:remove_class("active")
	end
	self.item = 1
end

function Battle:transition_out(victory)
	local cover = self.gui:get_element_by_id("cover")
	cover:set_property("background_color", { 0, 0, 0, 255 })
	cover:set_property("visible", true)
	cover:set_property("opacity", 0)

	local wait_time = 0.125
	local fade_time = 0.25
	local time = 0
	local function nextfn()
		Gamestate.pop(victory)
	end
	local function fade(dt)
		time = time + dt
		local position = time / fade_time
		cover:set_property("opacity", position)
	end
	self.exit_timer:add(wait_time, function()
		self.exit_timer:do_for(fade_time, fade, function()
			cover:set_property("visible", true)
			cover:set_property("opacity", 1.0)
			cover.value = "Loading..."
			self.exit_timer:add(wait_time, lume.combine(function() cover.value = nil end, nextfn))
		end)
	end)

	self:unregister()
end

function Battle:set_camera(name)
	self.current_camera = name
	if name == "free" then
		self.camera.forced_transforms = true
		return
	else
		self.camera.forced_transforms = false
	end

	local cam_data = self.camera_positions[name]
	assert(cam_data, "Invalid camera \"" .. name .. "\"")
	self.camera:move_to(self.camera_positions[name][1])
	self.camera:track(cam_data[2])
	if cam_data[3] then
		self.camera.current_pitch = 0
		self.camera.direction = cpml.vec3(0, 1, 0)
		self.camera:rotateXY(cam_data[3][1], cam_data[3][2])
	end
end

function Battle:update(dt)
	Signal.emit("update-title")

	if Preferences.hyper_speed then
		dt = dt * 4
	end

	local new_coords = { love.mouse.getPosition() }
	local old_coords = self.mouse_coords
	if old_coords[1] ~= new_coords[1] or old_coords[2] ~= new_coords[2] then
		self:mousemoved(new_coords[1], new_coords[2], new_coords[1] - old_coords[1], new_coords[2] - old_coords[2])
		self.mouse_coords = new_coords
	end

	self.camera:update()
	self.tsubasa:update(dt)
	self.enemy:update(dt)

	-- reset animation on first frame to prevent the jump
	if self.first_update then
		self:reset_to_idle()
		if self.enemy.name ~= "Panzerkampfwagen IV Ausführung H-sensei" then
			self.enemy:animate("EnemyIdle1")
		end
		self.first_update = false
	end

	self.gui:update(dt)

	Timer.update(dt)
	self.message_timer:update(dt)
	self.flavour_timer:update(dt)
	self.exit_timer:update(dt)
end

function Battle:draw()
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

	self.camera:send(self.shadow.model.shader)

	local model = cpml.mat4()
		:translate(self.tsubasa.position)
		:rotate(self.tsubasa.orientation.z, { 0, 0, 1 })
		:scale(self.tsubasa.scale)

	-- draw items
	local transforms = {}
	for i, v in ipairs(self.items) do
		local m = cpml.mat4()
			:translate(v.position)
			:rotate(v.orientation.z, { 0, 0, 1 })
			:scale(v.scale)

		transforms[i] = m
		v.model.shader:send("u_model", m:to_vec4s())
		self.camera:send(v.model.shader)
		-- I don't have the blend file omg why
		if v.name == "skydome.iqe" then
			gl.FrontFace(GL.CCW)
		else
			gl.FrontFace(GL.CW)
		end
		v:draw(nil, m)
	end
	gl.FrontFace(GL.CW)

	self.shadow.model.shader:send("u_model", model:to_vec4s())
	self.tsubasa.model.shader:send("u_model", model:to_vec4s())
	self.camera:send(self.tsubasa.model.shader)
	self.shadow:draw(nil, model)
	self.tsubasa:draw(nil, model)

	local enemy_model = cpml.mat4()
		:translate(self.enemy.position)
		:rotate(self.enemy.orientation.z, { 0, 0, 1 })
		:scale(self.enemy.scale)

	local enemy_shadow_model = enemy_model:scale(self.enemy.name == "Panzerkampfwagen IV Ausführung H-sensei" and cpml.vec3(5, 5, 5) or cpml.vec3(1,1,1))

	self.shadow.model.shader:send("u_model", enemy_shadow_model:to_vec4s())
	self.enemy.model.shader:send("u_model", enemy_model:to_vec4s())
	self.camera:send(self.enemy.model.shader)

	self.shadow:draw(nil, enemy_shadow_model)
	self.enemy:draw(nil, enemy_model)

	-- draw all shadows last because they don't depth write
	gl.DepthMask(GL.FALSE)
	for i, v in ipairs(self.items) do
		local m = transforms[i]:scale(v.shadow_scale)

		self.shadow.model.shader:send("u_model", m:to_vec4s())
		self.camera:send(v.model.shader)
		self.shadow:draw(nil, m)
	end
	gl.DepthMask(GL.TRUE)

	gl.FrontFace(GL.CCW)
	gl.Disable(GL.CULL_FACE)
	gl.Disable(GL.DEPTH_TEST)
	-- gl.Enable(GL.BLEND)

	self.gui:draw()

	if Preferences.debug then
		love.graphics.setColor(255,0,0,255)
		love.graphics.print(string.format("X: %s, Y: %s, Z: %s", self.camera.position.x, self.camera.position.y, self.camera.position.z), 10, 0)
		love.graphics.print(string.format("X: %s, Y: %s, Z: %s", self.trackable.x, self.trackable.y, self.trackable.z), 10, 24)
		love.graphics.print(string.format("Camera: %s", self.current_camera), 10, 48)
		love.graphics.print(string.format("Mode: %s", self.item_mode and "Item" or "Camera"), 10, 72)
		love.graphics.setColor(255,255,255,255)
	end
end

function Battle:keypressed(key)
	if key == "escape" then
		Signal.emit("exit")
	end

	if key == "pause" then
		Signal.emit("toggle-mute")
	end

	if not self.attacking then
		if key == "up" then
			if self.options[self.item]:has_class("active") then
				self.options[self.item]:remove_class("active")
				self.item = self.item - 1
				if self.item < 1 then
					self.item = self.item + #self.options
				end
				print(self.item)
				self.options[self.item]:add_class("active")
			end
		end
		if key == "tab" or key == "down" then
			if not self.options[self.item] then
				print(self.item)
				for k, v in pairs(self.options) do
					print(k, v)
				end
				print("WE DON'T HAVE TIME FOR THIS")
			end
			if self.options[self.item]:has_class("active") then
				self.options[self.item]:remove_class("active")
				self.item = (self.item % #self.options) + 1
			end
			self.options[self.item]:add_class("active")
		end

		if key == "return" or key == " " then
			if self.options[self.item] then
				self.options[self.item]:on_mouse_clicked("l")
			end
		end
	end

	-- !!! make sure non-debug keys are above this !!!
	if key == "f12" then
		Preferences.debug = not Preferences.debug
	end

	if not Preferences.debug then
		return
	end

	if key == "m" then
		self.item_mode = not self.item_mode
		if self.item_mode then
			print("item mode")
		else
			print("camera mode")
		end
	end

	local pos
	if not self.item_mode then
		pos = self.camera.position
	else
		pos = self.items[self.item].position
	end

	if key == "tab" and self.item_mode then
		self.item = (self.item % #self.items) + 1
		print("item: " .. self.item)
	end

	for i = 1, 10 do
		if key == tostring(i % 10) then
			if self.camera_names[i] then
				self:set_camera(self.camera_names[i])
			end
		end
	end

	-- adjust camera and look point
	if Preferences.debug then
		if key == "left" then
			pos.x = pos.x - 0.1
		end

		if key == "right" then
			pos.x = pos.x + 0.1
		end

		if key == "up" then
			pos.y = pos.y + 0.1
		end

		if key == "down" then
			pos.y = pos.y - 0.1
		end

		if key == "kp0" then
			pos.z = pos.z + 0.1
		end

		if key == "rctrl" then
			pos.z = pos.z - 0.1
		end

		if self.item_mode then
			if key == "d" then
				for k, v in ipairs(self.items) do
					print(v.name, v.position)
				end
			end

			if key == "c" then
				print(self.items[self.item].name, self.items[self.item].position)
			end
		end

		local pos = self.trackable

		if key == "kp4" then
			pos.x = pos.x - 0.1
		end

		if key == "kp6" then
			pos.x = pos.x + 0.1
		end

		if key == "kp8" then
			pos.y = pos.y + 0.1
		end

		if key == "kp2" then
			pos.y = pos.y - 0.1
		end

		if key == "kp7" then
			pos.z = pos.z - 0.1
		end

		if key == "kp9" then
			pos.z = pos.z + 0.1
		end
	end
end

function Battle:mousepressed(x, y, button)
	if self.attacking then return end

	self.gui:mousepressed(x, y, button)
end

function Battle:leave()
	self.lines            = nil
	self.current_line     = nil
	self.gui              = nil
	self.tsubasa          = nil
	self.shadow           = nil
	self.enemy            = nil
	self.player_one       = nil
	self.attacking        = nil
	self.first_update     = nil
	self.message_timer    = nil
	self.flavour_timer    = nil
	self.exit_timer       = nil
	self.camera_positions = nil
	self.camera_names     = nil
	self.camera           = nil
	self.on_victory       = nil
	self.on_defeat        = nil
end

function Battle:calc_damage(attack, chance, player, enemy)
	-- Did you even hit?
	local roll = love.math.random()

	if roll > chance then
		Signal.emit("battle-message", string.format("%s used %s!\nIt missed!", player.name, attack.name))
	else
		local damage = math.ceil(attack.damage * (love.math.random(85, 115) / 100))
		enemy.hp = enemy.hp - damage

		Signal.emit("battle-message",  string.format("%s used %s!\nIt did %d damage!", player.name, attack.name, damage))
	end

	if enemy.hp < 0 then enemy.hp = 0 end

	self:update_frames()

	if enemy.hp == 0 then
		if self.player_one then
			self:victory()
		else
			self:defeat()
		end
	else
		self.player_one = not self.player_one

		if self.player_one then
			self.attacking = false
			local menu = self.gui:get_element_by_id("battle_menu")
			menu:set_property("visible", true)
			self.options = menu.children
			self.item = 1

			self:set_camera("default")
		else
			Timer.add(love.math.random(0.85, 1.65), function() self:ai_choose_attack() end)
		end
	end
end

function Battle:victory()
	local callback = function()
		Signal.emit("victory", true)
	end

	-- Set Camera
	self:set_camera("facing")

	-- Play Voice
	local r = love.math.random(1,3)
	self.voice["victory"..r]:play()

	-- Turn on Animation
	self.tsubasa:animate("Idle1", callback)
	Signal.emit("battle-message", self.on_victory)
end

function Battle:defeat()
	local callback = function()
		Signal.emit("victory", false)
	end

	-- Set Camera
	self:set_camera("enemy")

	-- Play Voice
	self.voice.defeat:play()

	-- Turn on Animation
	self.tsubasa:animate("Idle1", callback)
	Signal.emit("battle-message", self.on_defeat)
end

function Battle:attack_swipe(...)
	-- Attack Info
	local attack = {
		name   = "Left Swipe",
		damage = 25,
		text   = "%s swiped to the left! No thanks!",
	}

	-- Set state
	self.attacking = true

	-- Set Camera
	self:set_camera("pokemon")

	-- Calculate Damage as callback
	local callback = function()
		self:reset_to_idle()
		self:calc_damage(attack, 0.95, self.tsubasa, self.enemy)
	end

	local reset = function()
		if self.enemy.name ~= "Panzerkampfwagen IV Ausführung H-sensei" then
			self.enemy:animate("EnemyIdle1")
		end
	end

	local swipe = function()
		self.tsubasa:animate("AttackFling", callback)
		self.enemy:animate("EnemyFlung", reset)
	end

	-- Turn on Animation
	self.tsubasa:animate("AttackStab", swipe)

	-- Play Voice
	self.voice.left_swipe:play()

	-- Display Flavour text
	Signal.emit("flavour-message", self.gui:get_element_by_id("flavour"), attack.text, self.tsubasa, self.enemy)

	-- VFX?
end

function Battle:attack_dual(...)
	-- Attack Info
	local attack = {
		name   = "2 Stylin' Style",
		damage = 50,
		text   = "%s pulled out another stylus! But from where?!",
	}

	-- Set state
	self.attacking = true

	-- Set Camera
	self:set_camera("pokemon")

	-- Calculate Damage as callback
	local callback = function()
		self:reset_to_idle()
		self:calc_damage(attack, 0.75, self.tsubasa, self.enemy)
	end

	local fling2 = function()
		self.tsubasa:animate("AttackFling", callback)
		self.enemy:animate("EnemyFlung", reset)
	end

	local reset = function()
		if self.enemy.name ~= "Panzerkampfwagen IV Ausführung H-sensei" then
			self.enemy:animate("EnemyIdle1")
		end
	end

	local swipe = function()
		self.tsubasa:animate("AttackFling", fling2)
	end

	-- Turn on Animation
	self.tsubasa:animate("AttackStab", swipe)

	-- Play Voice
	self.voice.two_stylin:play()

	-- Display Flavour text
	Signal.emit("flavour-message", self.gui:get_element_by_id("flavour"), attack.text, self.tsubasa, self.enemy)

	-- VFX?
end

function Battle:attack_milk(...)
	-- Attack Info
	local attack = {
		name   = "My Milk",
		damage = Preferences.debug and 500 or 77,
		text   = "%s offers %s a mysterious white fluid of questionable origin...",
	}

	-- Set state
	self.attacking = true

	-- Set Camera
	self:set_camera("pokemon")

	-- Calculate Damage as callback
	local callback = function()
		self:reset_to_idle()
		self:calc_damage(attack, Preferences.debug and 1.0 or 0.75, self.tsubasa, self.enemy)
	end

	local reset = function()
		if self.enemy.name ~= "Panzerkampfwagen IV Ausführung H-sensei" then
			self.enemy:animate("EnemyIdle1")
		end
	end

	local swipe = function()
		self.tsubasa:animate("AttackFling", callback)
		self.enemy:animate("EnemyFlung", reset)
	end

	-- Turn on Animation
	self.tsubasa:animate("AttackStab", swipe)

	-- Play Voice
	self.voice.my_milk:play()

	-- Display Flavour text
	Signal.emit("flavour-message", self.gui:get_element_by_id("flavour"), attack.text, self.tsubasa, self.enemy)

	-- VFX?
end

function Battle:attack_kyaa(...)
	-- Attack Info
	local attack = {
		name   = "Girl Power",
		damage = Preferences.debug and 500 or 100,
		text   = "%s asserts the femininity of a goddess! Kyaa~!",
	}

	-- Set state
	self.attacking = true

	-- Set Camera
	self:set_camera("pokemon")

	-- Play Voice
	self.voice.kyaa:play()

	-- Calculate Damage as callback
	local callback = function()
		self:reset_to_idle()
		self:calc_damage(attack, Preferences.debug and 1.0 or 0.50, self.tsubasa, self.enemy)
	end

	local reset = function()
		if self.enemy.name ~= "Panzerkampfwagen IV Ausführung H-sensei" then
			self.enemy:animate("EnemyIdle1")
		end
	end

	local swipe = function()
		self.tsubasa:animate("AttackFling", callback)
		self.enemy:animate("EnemyFlung", reset)
	end

	-- Turn on Animation
	self.tsubasa:animate("AttackStab", swipe)

	-- Display Flavour text
	Signal.emit("flavour-message", self.gui:get_element_by_id("flavour"), attack.text, self.tsubasa, self.enemy)

	-- VFX?
end

function Battle:ai_choose_attack()
	local choice = {}

	-- Weighted choices!
	for k, v in pairs(self.enemy.attacks) do
		choice[k] = v.weight
	end

	-- Call the attack!
	local attack = lume.weightedchoice(choice)
	self["ai_attack_"..attack](self, attack)
end

function Battle:ai_attack_harass(name)
	local attack = self.enemy.attacks[name]

	-- Set Camera
	self:set_camera("pokemon_enemy")

	local callback = function()
		self.enemy:animate("EnemyIdle1")
		self:calc_damage(attack, attack.chance, self.enemy, self.tsubasa)
	end

	-- Turn on Animation
	self.enemy:animate("EnemyFlex", callback)

	-- Display Flavour text
	Signal.emit("flavour-message", self.gui:get_element_by_id("flavour"), attack.text, self.enemy, self.tsubasa)
end

function Battle:ai_attack_peek(name)
	local attack = self.enemy.attacks[name]

	-- Set Camera
	self:set_camera("pokemon_enemy")

	local callback = function()
		self.enemy:animate("EnemyIdle1")
		self:calc_damage(attack, attack.chance, self.enemy, self.tsubasa)
	end

	-- Turn on Animation
	self.enemy:animate("EnemyAttack1", callback)

	-- Display Flavour text
	Signal.emit("flavour-message", self.gui:get_element_by_id("flavour"), attack.text, self.enemy, self.tsubasa)
end

function Battle:ai_attack_tsundere_flirt(name)
	local attack = self.enemy.attacks[name]

	-- Set Camera
	self:set_camera("pokemon_enemy")

	local callback = function()
		self.enemy:animate("EnemyIdle1")
		self:calc_damage(attack, attack.chance, self.enemy, self.tsubasa)
	end

	-- Turn on Animation
	self.enemy:animate("EnemyFlex", callback)

	-- Display Flavour text
	Signal.emit("flavour-message", self.gui:get_element_by_id("flavour"), attack.text, self.enemy, self.tsubasa)
end

function Battle:ai_attack_indirect_kiss(name)
	local attack = self.enemy.attacks[name]

	-- Set Camera
	self:set_camera("pokemon_enemy")

	local callback = function()
		self.enemy:animate("EnemyIdle1")
		self:calc_damage(attack, attack.chance, self.enemy, self.tsubasa)
	end

	-- Turn on Animation
	self.enemy:animate("EnemyAttack1", callback)

	-- Display Flavour text
	Signal.emit("flavour-message", self.gui:get_element_by_id("flavour"), attack.text, self.enemy, self.tsubasa)
end

function Battle:ai_attack_kiss(name)
	local attack = self.enemy.attacks[name]

	-- Set Camera
	self:set_camera("pokemon_enemy")

	local callback = function()
		self.enemy:animate("EnemyIdle1")
		self:calc_damage(attack, attack.chance, self.enemy, self.tsubasa)
	end

	-- Turn on Animation
	self.enemy:animate("EnemyAttack1", callback)

	-- Display Flavour text
	Signal.emit("flavour-message", self.gui:get_element_by_id("flavour"), attack.text, self.enemy, self.tsubasa)
end

function Battle:ai_attack_flex(name)
	local attack = self.enemy.attacks[name]

	-- Set Camera
	self:set_camera("pokemon_enemy")

	local callback = function()
		self.enemy:animate("EnemyIdle1")
		self:calc_damage(attack, attack.chance, self.enemy, self.tsubasa)
	end

	-- Turn on Animation
	self.enemy:animate("EnemyFlex", callback)

	-- Display Flavour text
	Signal.emit("flavour-message", self.gui:get_element_by_id("flavour"), attack.text, self.enemy, self.tsubasa)
end

function Battle:ai_attack_gun(name)
	local attack = self.enemy.attacks[name]

	-- Set Camera
	self:set_camera("panzer")

	local callback = function()
		self:calc_damage(attack, attack.chance, self.enemy, self.tsubasa)
	end

	-- Delay Move
	Timer.add(1, callback)

	-- Display Flavour text
	Signal.emit("flavour-message", self.gui:get_element_by_id("flavour"), attack.text, self.enemy, self.tsubasa)
end

function Battle:ai_attack_spin(name)
	local attack = self.enemy.attacks[name]

	-- Set Camera
	self:set_camera("panzer")

	local callback = function()
		self:calc_damage(attack, attack.chance, self.enemy, self.tsubasa)
	end

	-- Turn on Animation
	self.enemy:animate("Spin", callback)

	-- Display Flavour text
	Signal.emit("flavour-message", self.gui:get_element_by_id("flavour"), attack.text, self.enemy, self.tsubasa)
end

function Battle:ai_attack_cannon(name)
	local attack = self.enemy.attacks[name]

	-- Set Camera
	self:set_camera("panzer")

	local callback = function()
		self:calc_damage(attack, attack.chance, self.enemy, self.tsubasa)
	end

	-- Delay Move
	Timer.add(1, callback)

	-- Display Flavour text
	Signal.emit("flavour-message", self.gui:get_element_by_id("flavour"), attack.text, self.enemy, self.tsubasa)
end


function Battle:reset_to_idle()
	local anim2
	local anim1 = function(a)
		a:animate("Idle1", anim2)
	end
	anim2 = function(a)
		a:animate("Idle2", anim1)
	end

	self.tsubasa:animate("StandingToIdle", anim1)
end

function Battle:battle_message(text)
	local message = self.gui:get_element_by_id("dialog")
	message.value = text or "ya fucked up, son"
end

function Battle:show_message(message, event)
	self.message_timer:clear()

	message:set_property("visible", true)
	message:set_property("opacity", 0.0)

	local messages = {
		flee = "You can't flee from a trainer battle!"
	}
	message.value = messages[event] or "FLAGRANT ERROR"

	local fade_in_time  = 0.25
	local fade_out_time = 0.5
	local message_time  = 1.5

	local time = 0
	local function fade_in(dt)
		time = time + dt
		local position = time / fade_in_time
		message:set_property("opacity", position)
	end

	local function fade_out(dt)
		time = time + dt
		local position = time / fade_out_time
		message:set_property("opacity", 1 - position)
	end

	local function wait()
		message:set_property("opacity", 1.0)
		self.message_timer:add(message_time, function()
			time = 0
			self.message_timer:do_for(fade_out_time, fade_out, function()
				message:set_property("visible", false)
			end)
		end)
	end

	self.message_timer:do_for(fade_in_time, fade_in, wait)
end

function Battle:show_flavour_message(message, text, player, enemy)
	self.flavour_timer:clear()

	message:set_property("visible", true)
	message:set_property("opacity", 0.0)

	if type(text) == "table" then
		text = lume.randomchoice(text)
	end

	message.value = string.format(text, player.name, enemy.name)

	local fade_in_time  = 0.25
	local fade_out_time = 0.5
	local message_time  = 1.5

	local time = 0
	local function fade_in(dt)
		time = time + dt
		local position = time / fade_in_time
		message:set_property("opacity", position)
	end

	local function fade_out(dt)
		time = time + dt
		local position = time / fade_out_time
		message:set_property("opacity", 1 - position)
	end

	local function wait()
		message:set_property("opacity", 1.0)
		self.flavour_timer:add(message_time, function()
			time = 0
			self.flavour_timer:do_for(fade_out_time, fade_out, function()
				message:set_property("visible", false)
			end)
		end)
	end

	self.flavour_timer:do_for(fade_in_time, fade_in, wait)
end

function Battle:exit_game()
	self.exit_timer:clear()

	local message = self.gui:get_element_by_id("exit_message")
	message:set_property("visible", true)
	message:set_property("opacity", 0.0)

	local cover = self.gui:get_element_by_id("cover")
	cover:set_property("visible", true)
	message:set_property("opacity", 0.0)

	message.value = lume.randomchoice {
		"Goodbye, my friend :(",
		"Goodbye, cruel world. I'm leaving you today. Goodbye... Goodbye... Goodbye.",
		"KBYE",
		"I'LL MISS YOU",
		"Salut!",
		";_;",
		"o7",
		"I-it's not like I wanted you to stay or anything! Baka!",
	}

	local fade_in_time  = 0.25
	local fade_out_time = 0.5
	local message_time  = 2

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

	self.exit_timer:do_for(fade_in_time, fade_in, wait)

	Signal.emit("play-back")

	self:unregister()
end

function Battle:update_frames()
	local player = self.gui:get_element_by_id("player_frame")
	player.children[1].value = self.tsubasa.name
	player.children[2].value = string.format("%d / %d", self.tsubasa.hp, self.tsubasa.max_hp)

	local health = self.gui:get_element_by_id("player_health")
	health:set_property("width", self.tsubasa.hp / self.tsubasa.max_hp * 260)

	local enemy = self.gui:get_element_by_id("enemy_frame")
	enemy.children[1].value = self.enemy.name
	enemy.children[2].value = string.format("%d / %d", self.enemy.hp, self.enemy.max_hp)

	local health = self.gui:get_element_by_id("enemy_health")
	health:set_property("width", self.enemy.hp / self.enemy.max_hp * 260)
end

return Battle
