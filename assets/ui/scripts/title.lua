--==[[ Play Button ]]==--

local play = gui:get_element_by_id("play")
local cursor = love.mouse.getSystemCursor("hand")

function play:on_mouse_clicked(button)
	if button == "l" then
		Signal.emit("play-next")
		Gamestate.switch(require "states.world")
	end
end

--==[[ Options Button ]]==--

local options = gui:get_element_by_id("options")

function options:on_mouse_clicked(button)
	if button == "l" then
		Signal.emit("play-next")
		Gamestate.switch(require "states.options")
	end
end

--==[[ Credits Button ]]==--

local credits = gui:get_element_by_id("credits")

function credits:on_mouse_clicked(button)
	if button == "l" then
		Signal.emit("play-next")
		Gamestate.switch(require "states.credits")
	end
end

--==[[ Exit Button ]]==--

local exit = gui:get_element_by_id("exit")

function exit:on_mouse_clicked(button)
	if button == "l" then
		Signal.emit("play-next")
		love.event.quit()
	end
end
