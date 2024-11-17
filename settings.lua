data:extend{
	{
		type = "int-setting",
		name = "laserfence-health",
		setting_type = "startup",
		order = "a-a",
		default_value = 200,
		minimum_value = 1,
		maximum_value = 9999
	},
	{
		type = "int-setting",
		name = "laserfence-base-damage",
		setting_type = "startup",
		order = "b-a",
		default_value = 10,
		minimum_value = 0,
		maximum_value = 9999
	},
	{
		type = "bool-setting",
		name = "laserfence-beam-weapon-scaling",
		setting_type = "startup",
		order = "b-b",
		default_value = true
	},
	{
		type = "int-setting",
		name = "laserfence-base-range",
		setting_type = "startup",
		order = "c-a",
		default_value = 12,
		minimum_value = 1,
		maximum_value = 99
	},
	{
		type = "int-setting",
		name = "laserfence-added-range",
		setting_type = "startup",
		order = "c-b",
		default_value = 3,
		minimum_value = 1,
		maximum_value = 50  --Max underground pipe length is 255, so need (base + 3 * added) < 255 to not crash
	},
	{
		type = "int-setting",
		name = "laserfence-power",
		setting_type = "startup",
		order = "d-a",
		default_value = 400,
		minimum_value = 1,
		maximum_value = 50000
	},
	{
		type = "int-setting",
		name = "laserfence-segment-power",
		setting_type = "startup",
		order = "d-a",
		default_value = 10,
		minimum_value = 0,
		maximum_value = 1000
	},
	{
		type = "bool-setting",
		name = "laserfence-solid-walls",
		setting_type = "startup",
		order = "y-a",
		default_value = true
	},
	{
		type = "bool-setting",
		name = "laserfence-debug-text",
		setting_type = "startup",
		order = "z-z",
		default_value = false
	},
}

-- Automatically add info about defaults to descriptions
for _, type in pairs({"int-setting", "bool-setting"}) do
	for name, setting in pairs(data.raw[type]) do
		if string.sub(name, 1, 10) == "laserfence" then
			local default = setting.default_value
			if default == true then  -- Because true/false looks ugly
				default = {"mod-setting-description.laserfence-enabled"}
			elseif default == false then
				default = {"mod-setting-description.laserfence-disabled"}
			else
				default = tostring(default)
			end
			setting.localised_description = {"mod-setting-description.laserfence-template", {"mod-setting-description."..name}, default}
		end
	end
end
