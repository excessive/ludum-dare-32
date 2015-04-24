local ffi = require "ffi" -- gotta get SDL_GL_GetProcAddress
require "ffi.imagedata" -- speed up mapPixel and friends by a lot
Gamestate = require "libs.hump.gamestate"
Signal    = require "libs.hump.signal"

Preferences = {
	debug         = false,
	mute          = false,
	master_volume = 0.80,
	sfx_volume    = 0.50,
	bgm_volume    = 0.30,
	voice_volume  = 0.80,
	hyper_speed   = false,
}

function love.load()
	ffi.cdef([[void *SDL_GL_GetProcAddress(const char *proc);]])

	-- Windows needs to use an external SDL
	local sdl_on_windows_tho
	if love.system.getOS() == "Windows" then
		sdl_on_windows_tho = require "ffi.sdl2"
	end

	-- Get handles for OpenGL
	local opengl = require "ffi.opengl"
	opengl.loader = function(fn)
		local ptr
		if sdl_on_windows_tho then
			ptr = sdl_on_windows_tho.GL_GetProcAddress(fn)
		else
			ptr = ffi.C.SDL_GL_GetProcAddress(fn)
		end

		return ptr
	end
	opengl:import()

	-- Prepare Gamestates
	Gamestate.registerEvents()
	Gamestate.switch(require "states.title")

	local sources = {
		next = love.audio.newSource("assets/audio/select.ogg"),
		back = love.audio.newSource("assets/audio/back.ogg")
	}

	Signal.register("play-next", function()
		sources.next:setVolume(Preferences.sfx_volume)
		sources.next:rewind()
		sources.next:play()
	end)

	Signal.register("play-back", function()
		sources.back:setVolume(Preferences.sfx_volume)
		sources.back:rewind()
		sources.back:play()
	end)

	Signal.register("toggle-mute", function()
		Preferences.mute = not Preferences.mute
		love.audio.setVolume(Preferences.mute and 0.0 or Preferences.master_volume)
	end)

	Signal.register("update-title", function()
		love.window.setTitle(string.format("Not My Panties! (FPS: %0.2f, MSPF: %0.3f)", love.timer.getFPS(), love.timer.getAverageDelta() * 1000))
	end)
end
