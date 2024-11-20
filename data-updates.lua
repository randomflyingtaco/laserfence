if mods["Factorio-Tiberium"] then
	data.raw.recipe["laserfence-post"].subgroup = "a-buildings"
	data.raw.recipe["laserfence-post-gate"].subgroup = "a-buildings"
	table.insert(data.raw.technology["laserfence"].prerequisites, "tiberium-military-2")
end
