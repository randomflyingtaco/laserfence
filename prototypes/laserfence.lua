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

local gate_post_sprite = {
	layers = {
		{
			filename = "__base__/graphics/entity/gate/gate-vertical.png",
			height = 62,
			width = 38,
			x = 38 * 7,
			y = 62,
			shift = {
				0,
				-0.4375
			},
		},
		{
			filename = "__base__/graphics/entity/gate/gate-horizontal.png",
			height = 48,
			width = 34,
			x = 7 * 34,
			y = 48,
			shift = {
				0,
				-0.125
			}
		},
		post_sprite.layers[1],
		post_sprite.layers[2]
	}
}

local gate_icons = {
	{
		icon = modName.."/graphics/post-icon.png",
		icon_size = 64,
		scale = 1/2,
	},
	{
		icon = "__base__/graphics/icons/gate.png",
		icon_size = 64,
		icon_mipmaps = 4,
		scale = 3/16,
		shift = {10, -10},
	},
}

local baseRange = settings.startup["laserfence-base-range"].value
local addedRange = settings.startup["laserfence-added-range"].value
local basePower = settings.startup["laserfence-power"].value
local segmentPower = settings.startup["laserfence-segment-power"].value

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
		localised_description = {"entity-description.laserfence-post", baseRange, basePower, segmentPower},
		flags = {"placeable-neutral", "placeable-off-grid", "player-creation", "not-blueprintable"},
		collision_box = {{-0.49, -0.49 - offset}, {0.49, 0.49 - offset}},
		selection_box = {{-0.5, -0.5 - offset}, {0.5, 0.5 - offset}},
		minable = {mining_time = 0.5, result = "laserfence-post"},
		placeable_by = {item = "laserfence-post", count = 1},
		fast_replaceable_group = "laserfence",
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
			buffer_capacity = tostring(5 * basePower).."kJ",
			usage_priority = "primary-input",
			input_flow_limit = tostring(basePower + 2 * (baseRange + 3 * addedRange) * segmentPower).."kW",
			output_flow_limit = "0kW",
			drain = "0kW"
		},
		energy_usage = tostring(basePower).."kW",
		--render_layer = "higher-object-under",
		animation = {
			layers = {
				{
					filename = modName.."/graphics/post-animation.png",
					priority = "extra-high",
					frame_count = 32,
					line_length = 16,
					animation_speed = 0.02 / basePower,
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
		type = "simple-entity-with-force",
		name = "laserfence-beam",
		icon = modName.."/graphics/beam-icon.png",
		icon_size = 64,
		flags = {"placeable-neutral", "player-creation", "not-repairable"},
		max_health = settings.startup["laserfence-health"].value,
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		selection_priority = 1,
		collision_box = {{-0.49, -0.49}, {0.49, 0.49}},
		fast_replaceable_group = "laserfence",
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
		type = "gate",
		name = "laserfence-beam-gate",
		icon = modName.."/graphics/beam-icon.png",
		icon_size = 64,
		flags = {"placeable-neutral", "player-creation", "not-repairable"},
		max_health = settings.startup["laserfence-health"].value,
		is_military_target = true,
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		selection_priority = 1,
		collision_box = {{-0.29, -0.29}, {0.29, 0.29}},
		collision_mask = {},
		fast_replaceable_group = "laserfence",
		integration_patch_render_layer = "lower-object-above-shadow",
		render_layer = "lower-object-above-shadow",
		activation_distance = 4,
		corpse = "gate-remnants",
		dying_explosion = "gate-explosion",
		open_sound = {filename = "__base__/sound/silence-1sec.ogg"},
		close_sound = {filename = "__base__/sound/silence-1sec.ogg"},
		opening_speed = 1/16,
		timeout_to_close = 5,
		fadeout_interval = 15,
		horizontal_animation = {
			filename = "__base__/graphics/entity/gate/gate-horizontal.png",
			height = 48,
			width = 34,
			x = 7 * 34,
			y = 48,
			shift = {
				0,
				-0.125
			},
		},
		horizontal_rail_base = {
			filename = "__base__/graphics/entity/gate/gate-rail-base-horizontal.png",
			height = 54,
			width = 66,
			x = 7 * 66,
			y = 54,
			shift = {
				0,
				0.0625
			},
		},
		horizontal_rail_animation_left = {
			filename = "__base__/graphics/entity/gate/gate-rail-horizontal-left.png",
			height = 40,
			width = 34,
			x = 7 * 34,
			y = 40,
			shift = {
				0,
				-0.25
			},
		},
		horizontal_rail_animation_right = {
			filename = "__base__/graphics/entity/gate/gate-rail-horizontal-right.png",
			height = 40,
			width = 34,
			x = 7 * 34,
			y = 40,
			shift = {
				0,
				-0.25
			},
		},
		vertical_animation = {
			filename = "__base__/graphics/entity/gate/gate-vertical.png",
			height = 62,
			width = 38,
			x = 38 * 7,
			y = 62,
			shift = {
				0,
				-0.4375
			},
		},
		vertical_rail_base = {
			filename = "__base__/graphics/entity/gate/gate-rail-base-vertical.png",
			height = 66,
			width = 68,
			x = 68 * 7,
			y = 66,
			shift = {
				0,
				0
			},
		},
		vertical_rail_animation_left = {
			filename = "__base__/graphics/entity/gate/gate-rail-vertical-left.png",
			height = 62,
			width = 22,
			x = 22 * 7,
			y =62,
			shift = {
				0,
				-0.4375
			},
		},
		vertical_rail_animation_right = {
			filename = "__base__/graphics/entity/gate/gate-rail-vertical-right.png",
			height = 62,
			width = 22,
			x = 22 * 7,
			y = 62,
			shift = {
				0,
				-0.4375
			},
		},
		wall_patch = {
			filename = "__base__/graphics/entity/gate/gate-wall-patch.png",
			height = 48,
			width = 34,
			x = 34 * 7,
			y = 48,
			shift = {
				0,
				0.375
			},
		},
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
		flags = {"placeable-neutral", "player-creation", "not-deconstructable"},
		collision_box = {{-0.49, -0.49}, {0.49, 0.49}},
		collision_mask = {"item-layer", "object-layer", "water-tile"}, -- disable collision
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		placeable_by = {item = "laserfence-post", count = 1},
		fast_replaceable_group = "laserfence",
		fluid_box = {
			filter = "fluid-unknown",
			-- As long as most-upgraded version, so we can always use this prototype for the placement
			-- and the connection length will be limited by the end that has already been placed
			pipe_connections = all4pipes(baseRange + 1 + 3 * addedRange),
		},
		pictures = {
			up    = post_sprite,
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
	data.raw["simple-entity-with-force"]["laserfence-beam"].collision_mask = {"item-layer", "object-layer", "water-tile"}
end

local unselectable_beam = util.table.deepcopy(data.raw["simple-entity-with-force"]["laserfence-beam"])
unselectable_beam.type = "simple-entity-with-owner"  -- Since it isn't a military target
unselectable_beam.name = "laserfence-beam-unselectable"
unselectable_beam.selection_box = nil
unselectable_beam.attack_reaction = nil
unselectable_beam.secondary_draw_order = 2
data:extend{unselectable_beam}

local gate_post = util.table.deepcopy(data.raw["electric-energy-interface"]["laserfence-post"])
gate_post.name = "laserfence-post-gate"
gate_post.icon = nil
gate_post.icon_size = nil
gate_post.icons = gate_icons
gate_post.localised_description = {"entity-description.laserfence-post-gate", baseRange}
gate_post.minable.result = "laserfence-post-gate"
gate_post.placeable_by.item = "laserfence-post-gate"
data:extend{gate_post}

for i = 0,3 do
	local name = "laserfence-connector-"..tostring(i)
	local prototype = table.deepcopy(data.raw["pipe-to-ground"]["laserfence-connector"])
	prototype.name = name
	prototype.fluid_box.pipe_connections = all4pipes(baseRange + 1 + i * addedRange)
	data:extend{prototype}
end

local gate_connector = table.deepcopy(data.raw["pipe-to-ground"]["laserfence-connector"])
gate_connector.localised_name = {"entity-name.laserfence-post-gate"}
gate_connector.localised_description = {"entity-description.laserfence-post-gate", baseRange}
gate_connector.icons = gate_icons
gate_connector.icon = nil
gate_connector.icon_size = nil
gate_connector.placeable_by.item = "laserfence-post-gate"
gate_connector.fluid_box.pipe_connections = all4pipes(baseRange + 1)  -- Currently does not benefit from range upgrades
gate_connector.pictures = {
	up	  = gate_post_sprite,
	down  = gate_post_sprite,
	left  = gate_post_sprite,
	right = gate_post_sprite,
}
data:extend{gate_connector}
