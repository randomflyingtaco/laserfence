local offset = 0.0625

local post_sprite = {
	layers = {
		{
			filename = modName.."/graphics/post.png",
			priority = "extra-high",
			frame_count = 1,
			axially_symmetrical = false,
			direction_count = 1,
			width = 128,
			height = 256,
			scale = 0.3,
			shift = {0, -0.7 + offset}
		},
		{
			filename = modName.."/graphics/post-shadow.png",
			priority = "extra-high",
			frame_count = 1,
			axially_symmetrical = false,
			direction_count = 1,
			width = 256,
			height = 128,
			scale = 0.3,
			draw_as_shadow = true,
			shift = {0.5, 0 + offset}
		}
	}
}

local baseRange = settings.startup["laserfence-base-range"].value
local addedRange = settings.startup["laserfence-added-range"].value
local power = settings.startup["laserfence-power"].value

function all4pipes(distance)
	local pipe_connections = {}
	for _,position in pairs({{0,1}, {0,-1}, {1,0}, {-1,0}}) do
		table.insert(pipe_connections, {position = position, max_underground_distance = distance})
	end
	return pipe_connections
end

data:extend{
	{
		type = "electric-energy-interface",
		name = "laserfence-post",
		icon = modName.."/graphics/post-icon.png",
		icon_size = 64,
		localised_description = {"entity-description.laserfence-post", baseRange},
		flags = {"placeable-neutral", "placeable-off-grid", "player-creation", "not-blueprintable"},
		collision_box = {{-0.49, -0.49 - offset}, {0.49, 0.49 - offset}},
		selection_box = {{-0.5, -0.5 - offset}, {0.5, 0.5 - offset}},
		minable = {mining_time = 0.5, result = "laserfence-post"},
		placeable_by = {item = "laserfence-post", count = 1},
		max_health = 200,
		repair_speed_modifier = 1.5,
		corpse = "wall-remnants",
		repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
		mined_sound = {filename = "__base__/sound/deconstruct-bricks.ogg"},
		vehicle_impact_sound = {filename = "__base__/sound/car-stone-impact.ogg", volume = 1.0},
		working_sound =	{
			sound = {
				filename = "__base__/sound/substation.ogg",
				volume = 0.4
			},
			idle_sound = {
				filename = "__base__/sound/accumulator-idle.ogg",
				volume = 0.4
			},
			max_sounds_per_type = 3,
			audible_distance_modifier = 0.5,
			fade_in_ticks = 30,
			fade_out_ticks = 40,
			use_doppler_shift = false
		},
		energy_source = {
			type = "electric",
			buffer_capacity = tostring(5 * power).."kJ",
			usage_priority = "primary-input",
			input_flow_limit = tostring(2 * power).."kW",
			output_flow_limit = "0kW",
			drain = "0kW"
		},
		energy_usage = tostring(power).."kW",
		--render_layer = "higher-object-under",
		animation = {
			layers = {
				{
					filename = modName.."/graphics/post-animation.png",
					priority = "extra-high",
					frame_count = 32,
					line_length = 16,
					animation_speed = 0.00002,
					axially_symmetrical = false,
					direction_count = 1,
					width = 128,
					height = 256,
					scale = 0.3,
					shift = {0, -0.7}
				}
			}
		},
		resistances = {
			{
				type = "physical",
				decrease = 3,
				percent = 20
			},
			{
				type = "impact",
				decrease = 45,
				percent = 60
			},
			{
				type = "explosion",
				decrease = 10,
				percent = 30
			},
			{
				type = "fire",
				percent = 30
			},
			{
				type = "laser",
				percent = 80
			}
		}
	},
	{
		type = "simple-entity",
		name = "laserfence-beam",
		icon = modName.."/graphics/beam-icon.png",
		icon_size = 64,
		flags = {"placeable-neutral", "player-creation", "not-repairable"},
		max_health = settings.startup["laserfence-health"].value,
		healing_per_tick = 0.01,
		is_military_target = true,
		subgroup = "remnants",
		order = "a[remnants]",
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		selection_priority = 1,
		collision_box = {{-0.49, -0.49}, {0.49, 0.49}},
		created_effect = {
			type = "direct",
			action_delivery = {
				type = "instant",
				source_effects = {
					type = "play-sound",
					sound = {
						filename = "__base__/sound/spidertron/spidertron-activate.ogg",
						-- "__base__/sound/fight/laser-2.ogg" 
						-- "__base__/sound/nightvision-on.ogg",
						-- "__base__/sound/lamp-activate.ogg",
						-- "__base__/sound/spidertron/spidertron-activate.ogg",
						volume = 0.2,
						speed = 1.2,
						aggregation = {
							max_count = 3,
							remove = true,
						},
					},
				},
			},
		},
		--render_layer = "higher-object-under",
		animations = {
			{
				filename = modName.."/graphics/beam-horz-animation.png",
				priority = "extra-high",
				frame_count = 32,
				line_length = 16,
				axially_symmetrical = false,
				direction_count = 1,
				width = 128,
				height = 256,
				scale = 0.3,
				shift = {0, -0.7 + offset},
				draw_as_glow = true
			},
			{
				filename = modName.."/graphics/beam-vert-animation.png",
				priority = "extra-high",
				frame_count = 32,
				line_length = 16,
				axially_symmetrical = false,
				direction_count = 1,
				width = 128,
				height = 256,
				scale = 0.3,
				shift = {0, -1.025 + offset},
				draw_as_glow = true
			},
			{
				filename = modName.."/graphics/beam-cross-animation.png",
				priority = "extra-high",
				frame_count = 32,
				line_length = 16,
				axially_symmetrical = false,
				direction_count = 1,
				width = 128,
				height = 256,
				scale = 0.3,
				shift = {0, -0.7 + offset},
				draw_as_glow = true
			}
		},
		-- resistances = {
		-- 	{
		-- 		type = "physical",
		-- 		decrease = 5
		-- 	},
		-- 	{
		-- 		type = "acid",
		-- 		percent = 30
		-- 	},
		-- 	{
		-- 		type = "explosion",
		-- 		percent = 70
		-- 	},
		-- 	{
		-- 		type = "fire",
		-- 		percent = 100
		-- 	},
		-- 	{
		-- 		type = "laser",
		-- 		percent = 100
		-- 	}
		-- },
		attack_reaction = {
			{
				range = 3,
				reaction_modifier = 1,
				damage_type = "physical",
				action = {
					type = "direct",
					action_delivery = {
						type = "instant",
						target_effects = {
							{
								type = "script",
								effect_id = "laserfence-reflect-damage"
							}
						}
					}
				}
			},
			{
				range = 3,
				reaction_modifier = 1,
				damage_type = "acid",
				action = {
					type = "direct",
					action_delivery = {
						type = "instant",
						target_effects = {
							{
								type = "script",
								effect_id = "laserfence-reflect-damage"
							}
						}
					}
				}
			}
		},
	},
	{
		type = "pipe-to-ground",
		name = "laserfence-connector",
		localised_name = {"entity-name.laserfence-post"},
		localised_description = {"entity-description.laserfence-post", baseRange},
		icon = modName.."/graphics/post-icon.png",
		icon_size = 64,
		flags = {"placeable-neutral", "player-creation"},
		collision_box = {{-0.49, -0.49}, {0.49, 0.49}},
		collision_mask = {"item-layer", "object-layer", "water-tile"}, -- disable collision
		fluid_box = {
			filter = "fluid-unknown",
			-- As long as most-upgraded version, so we can always use this prototype for the placement
			-- and the connection length will be limited by the end that has already been placed
			pipe_connections = all4pipes(baseRange + 1 + 3 * addedRange),
		},
		pictures = {
			up	= post_sprite,
			down  = post_sprite,
			left  = post_sprite,
			right = post_sprite,
		},
	},
	{
		type = "flying-text",
		name = "laserfence-obstruction-text",
		flags = {"not-on-map", "placeable-off-grid"},
		time_to_live = 180,
		speed = 1 / 60,
	}
}

if not settings.startup["laserfence-solid-walls"].value then
	data.raw["simple-entity"]["laserfence-beam"].collision_mask = {"item-layer", "object-layer", "water-tile"}
end

for i = 0,3 do
	local name = "laserfence-connector-"..tostring(i)
	local prototype = table.deepcopy(data.raw["pipe-to-ground"]["laserfence-connector"])
	prototype.name = name
	prototype.fluid_box.pipe_connections = all4pipes(baseRange + 1 + i * addedRange)
	data:extend{prototype}
end
