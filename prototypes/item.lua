data:extend{
	{
		type = "item",
		name = "laserfence-post",
		icon = modName.."/graphics/post-icon.png",
		icon_size = 64,
		subgroup = "defensive-structure",
		order = "b[srf]",
		place_result = "laserfence-connector",
		stack_size = 50
	},
	{
		type = "item",
		name = "laserfence-post-gate",
		icons = data.raw["electric-energy-interface"]["laserfence-post-gate"].icons,
		subgroup = "defensive-structure",
		order = "b[srf]",
		place_result = "laserfence-connector-gate",
		stack_size = 50
	}
}
