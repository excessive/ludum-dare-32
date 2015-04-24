local exit = gui:get_element_by_id("exit")

function exit:on_mouse_clicked(button)
	if button == "l" then
		Signal.emit("exit")
	end
end
