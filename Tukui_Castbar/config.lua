local _, ns = ...

ns.config={
	["separateplayer"] = true, -- Create a separate player castbar.
	["separatetarget"] = true, -- Create a separate target castbar.
	["template"] = "Default", -- Template, that should be used.
	player = {
		["yDistance"] = -200, -- Player castbar distance from the center of the screen.
		["width"] = 350, -- Width of player castbar.
		["height"] = 26, -- Height of player castbar.
		["iconright"] = false, -- Display icon on right side of the bar. (not working yet)
		["fontsize"] = 12, -- Fontsize for spellname and cast time.
		["showticks"] = true, -- Display icon on right side of the bar. (not working yet)
		["fontcolor"] = {0.84, 0.75, 0.65}, -- Fontcolor for spellname and cast time.
		["castingcolor"] = {1.0, 0.49, 0, 0.5}, -- Color for normal cast.
		["channelingcolor"] = {0.32, 0.3, 1, 0.5}, -- Color for channeled spells.
		["latencycolor"] = {1, 0, 0, 0.5}, -- Color of latency part.
	},
	target = { 
		["yDistance"] = -150, -- Target castbar distance from the center of the screen.
		["width"] = 250, -- Width of target castbar.
		["height"] = 21, -- Height of target castbar.
		["iconright"] = false, -- Display icon on right side of the bar. (not working yet)
		["fontsize"] = 12, -- Fontsize for spellname and cast time.
		["fontcolor"] = {0.84, 0.75, 0.65}, -- Fontcolor for spellname and cast time.
		["interruptablecolor"] = {1, 0.7, 0, 0.5}, -- Color for interruptable spells.
		["noninterruptablecolor"] = {0.78, 0.25, 0.25, 0.5}, -- Color for noninterruptable spells.
	}
}
