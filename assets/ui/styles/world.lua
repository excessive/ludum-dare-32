return {
	{ "#cover", {
		width      = "100%",
		height     = "100%",
		background_color = { 0, 0, 0, 200 },
		position   = "absolute",
		left       = 0,
		top        = 0,
		visible    = false,
		cursor     = "arrow",
		font_path  = "assets/fonts/Homenaje/HomenajeMod-Regular.otf",
		font_size  = 18,
		padding    = 50,
		text_color = darken({ 255, 255, 255, 255 }, 0.75)
	}},

	{ "#dialog", {
		background_color = { 0, 0, 0, 100 },
		padding   = 10,
		font_path = "assets/fonts/Homenaje/HomenajeMod-Regular.otf",
		font_size = 28,
		cursor    = "arrow",
		position  = "absolute",
		left      = 0,
		bottom    = 0,
		height    = 200,
	}},

	{ "#back", {
		width    = 80,
		position = "absolute",
		left     = 0,
		bottom   = 0,

		{ "button", {
			display    = "block",
			background_color = { 0, 0, 0, 100 },
			padding    = 10,
			text_align = "center",
			font_path  = "assets/fonts/Homenaje/HomenajeMod-Regular.otf",
			font_size  = 18,
			cursor     = "hand",
		}},

		{ "button:hover", "button.active", {
			background_color = { 0xff, 0xa8, 0x00, 200 },
			text_color = { 0xff, 0xfd, 0xfa, 255 },
		}},
	}},

	{ "#next", {
		width    = 80,
		position = "absolute",
		right     = 0,
		bottom   = 0,

		{ "button", {
			display    = "block",
			background_color = { 0, 0, 0, 100 },
			padding    = 10,
			text_align = "center",
			font_path  = "assets/fonts/Homenaje/HomenajeMod-Regular.otf",
			font_size  = 18,
			cursor     = "hand",
		}},

		{ "button:hover", {
			background_color = { 0xff, 0xa8, 0x00, 200 },
			text_color = { 0xff, 0xfd, 0xfa, 255 },
		}},
	}},

	{ "#exit_message", {
		position   = "absolute",
		top        = "50%",
		visible    = false,
		font_path  = "assets/fonts/Homenaje/HomenajeMod-Regular.otf",
		font_size  = 24,
		text_align = "center",
	}},

	{ "#exit", {
		width    = 80,
		position = "absolute",
		right    = 0,
		top      = 0,

		{ "button", {
			display    = "block",
			background_color = { 0, 0, 0, 100 },
			padding    = 10,
			text_align = "center",
			font_path  = "assets/fonts/Homenaje/HomenajeMod-Regular.otf",
			font_size  = 18,
			cursor     = "hand",
		}},

		{ "button:hover", {
			background_color = { 0xff, 0xa8, 0x00, 200 },
			text_color = { 0xff, 0xfd, 0xfa, 255 },
		}},
	}},
}
