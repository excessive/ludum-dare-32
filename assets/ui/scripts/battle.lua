local battle_menu  = gui:get_element_by_id("battle_menu")
local attack_menu  = gui:get_element_by_id("attack_menu")
local special_menu = gui:get_element_by_id("special_menu")

local exit = gui:get_element_by_id("exit_button")

function exit:on_mouse_clicked(button)
	if button == "l" then
		Signal.emit("play-back")
		Signal.emit("exit")
	end
end

--==[[ Battle Menu ]]==--

-- Fight Button
local attack = gui:get_element_by_id("attack")

function attack:on_mouse_clicked(button)
	if button == "l" then
		Signal.emit("play-next")
		Signal.emit("update-active-menu", attack_menu.children)
		battle_menu:set_property("visible",  false)
		attack_menu:set_property("visible",  true)
		special_menu:set_property("visible", false)
	end
end

-- Special Button
local special = gui:get_element_by_id("special")

function special:on_mouse_clicked(button)
	if button == "l" then
		Signal.emit("play-next")
		Signal.emit("update-active-menu", special_menu.children)
		battle_menu:set_property("visible",  false)
		attack_menu:set_property("visible",  false)
		special_menu:set_property("visible", true)
	end
end

-- Flee Button
local flee = gui:get_element_by_id("flee")

function flee:on_mouse_clicked(button)
	if button == "l" then
		Signal.emit("play-back")
		local message = gui:get_element_by_id("message")
		Signal.emit("ui-message", message, "flee")
	end
end

--==[[ Attack Menu ]]==--

-- Swipe Button
local swipe = gui:get_element_by_id("attack_swipe")

function swipe:on_mouse_clicked(button)
	if button == "l" then
		Signal.emit("play-next")
		battle_menu:set_property("visible",  false)
		attack_menu:set_property("visible",  false)
		special_menu:set_property("visible", false)
		Signal.emit("attack-swipe")
	end
end

-- Dual Wield Button
local dual = gui:get_element_by_id("attack_dual")

function dual:on_mouse_clicked(button)
	if button == "l" then
		Signal.emit("play-next")
		battle_menu:set_property("visible",  false)
		attack_menu:set_property("visible",  false)
		special_menu:set_property("visible", false)
		Signal.emit("attack-dual")
	end
end

-- Cancel Button
local cancel = gui:get_element_by_id("attack_cancel")

function cancel:on_mouse_clicked(button)
	if button == "l" then
		Signal.emit("play-back")
		Signal.emit("update-active-menu", battle_menu.children)
		battle_menu:set_property("visible",  true)
		attack_menu:set_property("visible",  false)
		special_menu:set_property("visible", false)
	end
end

--==[[ Special Menu ]]==--

-- My Milk Button
local milk = gui:get_element_by_id("attack_milk")

function milk:on_mouse_clicked(button)
	if button == "l" then
		Signal.emit("play-next")
		battle_menu:set_property("visible",  false)
		attack_menu:set_property("visible",  false)
		special_menu:set_property("visible", false)
		Signal.emit("attack-milk")
	end
end

-- Girl Power Button
local kyaa = gui:get_element_by_id("attack_kyaa")

function kyaa:on_mouse_clicked(button)
	if button == "l" then
		Signal.emit("play-next")
		battle_menu:set_property("visible",  false)
		attack_menu:set_property("visible",  false)
		special_menu:set_property("visible", false)
		Signal.emit("attack-kyaa")
	end
end

--Cancel Button
local cancel = gui:get_element_by_id("special_cancel")

function cancel:on_mouse_clicked(button)
	if button == "l" then
		Signal.emit("play-back")
		Signal.emit("update-active-menu", battle_menu.children)
		battle_menu:set_property("visible",  true)
		attack_menu:set_property("visible",  false)
		special_menu:set_property("visible", false)
	end
end
