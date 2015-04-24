local enemies = {}
enemies.hentai_senpai = {
	hp   = 100,
	name = "Hentai-senpai",
	attacks = {
		peek = {
			weight = 25,
			chance = 0.25,
			damage = 30,
			count  = 5,
			name   = "Peek",
			text   = "%s tries to sneak a peek!"
		},
		harass = {
			weight = 75,
			chance = 0.85,
			damage = 18,
			count  = 7,
			name   = "Harass",
			text   = {
				"%s wants to hold your hand!",
				"%s wants to enjoy your bento!",
				"%s assures you he's a nice guy!"
			}
		}
	}
}

enemies.swimsuit_kun = {
	hp   = 250,
	name = "Swimsuit-kun",
	attacks = {
		peek = {
			weight = 25,
			chance = 0.25,
			damage = 30,
			count  = 5,
			name   = "Peek",
			text   = "%s tries to sneak a peek!"
		},
		harass = {
			weight = 75,
			chance = 0.85,
			damage = 20,
			count  = 7,
			name   = "Harass",
			text   = {
				"%s wants to hold your hand... wearing a swimsuit!",
				"%s wants to see you in a cute swimsuit!",
				"%s invites you to his place to try on swimsuits!"
			}
		}
	}
}

enemies.tsundere_track_star = {
	hp   = 370,
	name = "Tsundere Track Star",
	attacks = {
		peek = {
			weight = 15,
			chance = 0.25,
			damage = 30,
			count  = 5,
			name   = "Peek",
			text   = "%s isn't trying to peek because he likes you or anything!"
		},
		tsundere_flirt = {
			weight = 35,
			chance = 0.65,
			damage = 28,
			count  = 7,
			name   = "Tsundere Flirt",
			text   = {
				"%s will hold your hand, i-if you really want to!",
				"%s blushes and turns away, \"B-baka!\"",
			}
		},
		indirect_kiss = {
			weight = 50,
			chance = 0.65,
			damage = 38,
			count  = 7,
			name   = "Indirect Kissu",
			text   = {
				"%s offers you his juice box, if you're *that* thirsty!",
			}
		},
	}
}

enemies.doki_doki_chan = {
	hp   = 280,
	name = "Doki Doki-chan",
	attacks = {
		peek = {
			weight = 15,
			chance = 0.25,
			damage = 30,
			count  = 5,
			name   = "Peek",
			text   = "%s tries to flip your skirt! Kyaa!"
		},
		harass = {
			weight = 35,
			chance = 0.50,
			damage = 11,
			count  = 7,
			name   = "Harass",
			text   = {
				"%s gazes into your eyes as his heart beats harder!",
				"%s asks for your hand in marriage.",
			}
		},
		kiss = {
			weight = 50,
			chance = 0.65,
			damage = 38,
			count  = 7,
			name   = "Kiss",
			text   = {
				"%s puckers his lips and charges!",
			}
		},
	}
}

enemies.majestic_man = {
	hp   = 444,
	name = "Majestic Man",
	attacks = {
		harass = {
			weight = 25,
			chance = 0.50,
			damage = 32,
			count  = 7,
			name   = "Harass",
			text   = {
				"%s Smiles at you, teeth glistening in the sun.",
				"%s tells you about his hobbies and interests.",
			}
		},
		flex = {
			weight = 75,
			chance = 0.65,
			damage = 13,
			count  = 7,
			name   = "Flex",
			text   = {
				"%s Flexes his muscles at you!",
			}
		},
	}
}

enemies.panzer = {
	hp   = 1943,
	name = "Panzerkampfwagen IV Ausführung H-sensei",
	attacks = {
		gun = {
			weight = 5,
			chance = 0.05,
			damage = 666,
			count  = 7,
			name   = "Machine Gun",
			text   = {
				"%s is sick of your shit.",
			}
		},
		spin = {
			weight = 20,
			chance = 1.00,
			damage = 0,
			count  = 7,
			name   = "Spin In Place",
			text   = {
				"%s spins in place. Show off!",
			}
		},
		cannon = {
			weight = 75,
			chance = 0.15,
			damage = 28,
			count  = 7,
			name   = "Cannon",
			text   = {
				"%s shoots you a plushie! Kawaii~!",
			}
		},
	}
}

return enemies
