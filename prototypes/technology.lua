data:extend{
	{
		type = "technology",
		name = "laserfence",
		icon = modName.."/graphics/256icon.png",
		icon_size = 256,
		order = "a-h-c",
		effects = {
			{
				type = "unlock-recipe",
				recipe = "laserfence-post"
			}
		},
		prerequisites = {"laser", "military-science-pack"},
		unit = {
			count = 100,
			ingredients = {
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"military-science-pack", 1},
				{"chemical-science-pack", 1},
			},
			time = 30
		}
	}
}
