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
	},
	{
		type = "technology",
		name = "laserfence-range-1",
		icons = util.technology_icon_constant_range(modName.."/graphics/256icon.png"),
		order = "a-h-d",
		effects = {
			{
				type = "nothing",
				effect_description = {"technology-description.laserfence-range-effect", settings.startup["laserfence-added-range"].value}
			}
		},
		prerequisites = {"laserfence"},
		unit = {
			count = "100",
			ingredients = {
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"military-science-pack", 1},
				{"chemical-science-pack", 1},
			},
			time = 30
		},
		upgrade = true,
	},
	{
		type = "technology",
		name = "laserfence-range-2",
		icons = util.technology_icon_constant_range(modName.."/graphics/256icon.png"),
		order = "a-h-d",
		effects = {
			{
				type = "nothing",
				effect_description = {"technology-description.laserfence-range-effect", settings.startup["laserfence-added-range"].value}
			}
		},
		prerequisites = {"laserfence-range-1", "utility-science-pack"},
		unit = {
			count = "200",
			ingredients = {
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"military-science-pack", 1},
				{"chemical-science-pack", 1},
				{"utility-science-pack", 1},
			},
			time = 30
		},
		upgrade = true,
	},
	{
		type = "technology",
		name = "laserfence-range-3",
		icons = util.technology_icon_constant_range(modName.."/graphics/256icon.png"),
		order = "a-h-d",
		effects = {
			{
				type = "nothing",
				effect_description = {"technology-description.laserfence-range-effect", settings.startup["laserfence-added-range"].value}
			}
		},
		prerequisites = {"laserfence-range-2", "space-science-pack"},
		unit = {
			count = "1000",
			ingredients = {
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"military-science-pack", 1},
				{"chemical-science-pack", 1},
				{"utility-science-pack", 1},
				{"space-science-pack", 1},
			},
			time = 30
		},
		upgrade = true,
	},
}
