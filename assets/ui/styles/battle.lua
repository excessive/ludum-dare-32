return {
	{ "#message", {
		background_color = { 50, 60, 90, 100 },
		position = "absolute",
		top      = 0,
		visible  = false,
		padding = 15,
		font_path = "assets/fonts/Homenaje/HomenajeMod-Regular.otf",
		font_size = 18,
		text_align = "center",
	}},

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

	{ "#exit_message", {
		-- margin   = "auto",
		position = "absolute",
		top = "50%",
		visible  = false,
		font_path = "assets/fonts/Homenaje/HomenajeMod-Regular.otf",
		font_size = 24,
		text_align = "center",
	}},

	{ "#exit", {
		-- background_color = { 50, 60, 90, 100 },
		width = 80,
		position = "absolute",
		right = 0,
		top   = 0,

		{ "button", {
			display   = "block",
			background_color = { 0, 0, 0, 100 },
			padding   = 10,
			text_align = "center",
			font_path = "assets/fonts/Homenaje/HomenajeMod-Regular.otf",
			font_size = 18,
			cursor    = "hand",
		}},

		{ "button:hover", {
			background_color = { 0xff, 0xa8, 0x00, 200 },
			text_color = { 0xff, 0xfd, 0xfa, 255 },
		}},
	}},

	{ "#dialog", {
		background_color = { 0, 0, 0, 100 },
		padding   = { 10, 310, 10, 10 }, -- 310
		font_path = "assets/fonts/Homenaje/HomenajeMod-Regular.otf",
		font_size = 28,
		cursor    = "arrow",
		position  = "absolute",
		-- lol
		-- left      = -300,
		left      = 0,
		bottom    = 0,
		height    = 120,
	}},

	{ "#menu", {
		width   = 300,
		-- background_color = { 50, 60, 90, 100 },
		position = "absolute",
		right = 0,
		bottom = 0,

		{ "button", {
			display   = "block",
			border    = 0,
			background_color = { 0, 0, 0, 100 },
			padding   = 10,
			font_path = "assets/fonts/Homenaje/HomenajeMod-Regular.otf",
			font_size = 18,
			cursor = "hand",
		}},

		{ "button:hover", "button.active", {
			background_color = { 0xff, 0xa8, 0x00, 200 },
			text_color = { 0xff, 0xfd, 0xfa, 255 },
		}},

		{ "block", {
			position = "absolute",
			right = 0,
			bottom = 0,
		}},
	}},

	{ ".title", {
		text_align = "center",
		font_path  = "assets/fonts/Homenaje/HomenajeMod_Logo-Bold.otf",
		font_size  = 32,
		margin     = { 20, 20, 0, 20 },
	}},

	{ "#attack_menu", {
		visible = false,
	}},

	{ "#special_menu", {
		visible = false,
	}},

	{ "#flavour", {
		visible = false,
		background_color = { 0, 0, 0, 100 },
		padding   = 25,
		font_path = "assets/fonts/Homenaje/HomenajeMod-Regular.otf",
		font_size = 24,
		cursor    = "arrow",
		position  = "absolute",
		top       = 70,
		margin = { 0, "auto" },
	}},

	{ "#player_frame", {
		position         = "absolute",
		bottom           = 125,
		right            = 5,
	}},

	{ "#enemy_frame", {
		position         = "absolute",
		top              = 5,
		left             = 5,
	}},

	{ "#player_frame", "#enemy_frame", {
		background_color = { 0, 0, 0, 100 },
		width            = 280,
		height           = 70,
		margin           = 5,
		padding          = 10,
	}},

	{ "#player_name", "#player_hp", {
		text_align  = "right",
	}},

	{ "#player_name", "#player_hp", "#enemy_name", "#enemy_hp", {
		font_path        = "assets/fonts/Homenaje/HomenajeMod-Regular.otf",
		font_size        = 18,
	}},

	{ "#player_health_bar", "#enemy_health_bar", {
		background_color = { 0, 0, 0, 255 },
		width            = 260,
		height           = 10,
	}},

	{ "#player_health", "#enemy_health", {
		background_color = { 255, 0, 0, 255 },
		border           = 2,
		border_color     = { 0, 0, 0, 255 },
		width            = 125,
		height           = 10,
	}},
}
