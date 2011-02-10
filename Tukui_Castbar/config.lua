local addon, ns = ...

ns.config={
    ["separateplayer"] = true, -- separate player castbar
    ["separatetarget"] = true, -- separate target castbar
	["bigcastbars"] = true, -- Bigger more visible castbars, reccomended for casters.
	player = {
		["yDistance"] = -200, -- Player castbar distance from the center of the screen.
		["width"] = 350, -- Width of player castbar.
		["height"] = 26, -- Height of player castbar.
	},
	target = { 
		["yDistance"] = -150, -- Target castbar distance from the center of the screen.
		["width"] = 250, -- Width of target castbar.
		["height"] = 21, -- Height of target castbar.
	}
}
