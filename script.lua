local victory = "I have defeated the pervert"
local defeat = "I can't be a bride anymore!"
local enemies = require "enemies"

local script = {
	{
		"What?! The *entire* track team wants to see my panties?!",
		"But if they see my panties, they will...",
		"...",
		"Kyaa~!! Here they come!",
		battles = {
			{
				"Oh no, it's a pervert.",
				on_victory = victory,
				on_defeat = defeat,
				enemies = {
					enemies.hentai_senpai,
				},
			},
			{
				"Why won't he shut up about swimsuits?",
				on_victory = victory,
				on_defeat = defeat,
				enemies = {
					enemies.swimsuit_kun,
				}
			},
			{
				"Please leave me alone.",
				on_victory = victory,
				on_defeat = defeat,
				enemies = {
					enemies.doki_doki_chan,
				}
			}
		}
	},
	{
		"Oh no, another pervert",
		battles = {
			{
				"Why are you doing this to me?",
				on_victory = victory,
				on_defeat = defeat,
				enemies = {
					enemies.tsundere_track_star,
				}
			},
			{
				"Oh my god, why?",
				on_victory = victory,
				on_defeat = defeat,
				enemies = {
					enemies.majestic_man,
				}
			}
		},
	},
	{
		"You have got to be kidding me.",
		"Why is there a tank in the track club?",
		"...",
		"Stupid puns.",
		battles = {
			{
				"I just want to go home.",
				boss = true,
				on_victory = victory,
				on_defeat = defeat,
				enemies = {
					enemies.panzer,
				}
			}
		}
	},
	{
		"I won.",
		"...",
		"Also, thank you for playing.",
		"...this game sure is short."
	}
}

return script
