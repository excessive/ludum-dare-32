return {
	{ "#cover", {
		width = "100%",
		height = "100%",
		background_color = { 0, 0, 0, 200 },
		position = "absolute",
		left = 0,
		top = 0,
		visible  = false,
		cursor = "arrow",
	}},
	{ "#menu", {
		width   = 300,
		background_color = { 50, 60, 90, 100 },

		{ "text", {
			display   = "block",
			border    = 0,
			text_color = { 150, 150, 150, 255 },
			background_color = { 0, 0, 0, 150 },
			padding   = 10,
			font_path = "assets/fonts/Homenaje/HomenajeMod-Regular.otf",
			font_size = 18,
		}},

		{ "button", {
			display   = "block",
			border    = 0,
			background_color = { 0, 0, 0, 100 },
			padding   = 10,
			font_path = "assets/fonts/Homenaje/HomenajeMod-Regular.otf",
			font_size = 18,
			cursor = "hand",
		}},

		{ "#title", {
			text_align = "center",
			font_path  = "assets/fonts/Homenaje/HomenajeMod_Logo-Bold.otf",
			font_size  = 32,
			margin     = 0,
			text_color = { 255, 255, 255, 255 },
		}},

		{ "#exit", {
			background_color = { 80, 20, 20, 100 },
		}},

		{ "button:hover", "button.active", {
			background_color = { 0xff, 0xa8, 0x00, 200 },
			text_color = { 0xff, 0xfd, 0xfa, 255 },
		}},
	}},
}
