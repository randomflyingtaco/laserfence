-- Basic setup, variables to use. (Might expose to settings sometime? Or perhaps make research allow for longer wall segments?)
local debugText = settings.startup["laserfence-debug-text"].value

local horz_wall, vert_wall = 1, 2
local dir_mods = {
	{x = 1, y = 0, variation = horz_wall},
	{x = -1, y = 0, variation = horz_wall},
	{x = 0, y = 1, variation = vert_wall},
	{x = 0, y = -1, variation = vert_wall}
}

local baseRange = settings.startup["laserfence-base-range"].value
local addedRange = settings.startup["laserfence-added-range"].value

local abs   = math.abs
local floor = math.floor
local ceil  = math.ceil
local max   = math.max
local min   = math.min
-- Functions translplanted + renamed to clarify

--Returns array containing up to 4 entities that could connect to an SRF emitter at the given position
--Assumes node_range, horz_wall, vert_wall, global.SRF_nodes
function CnC_SonicWall_FindNodes(surf, pos, force, dir)
	local node_range = baseRange + 1 + addedRange * global.laserfenceRangeUpgradeLevel[force.name]
	local near_nodes = {nil, nil, nil, nil}
	local near_dists = {node_range, node_range * -1, node_range, node_range * -1}
	for _, entry in pairs(global.SRF_nodes) do
		if entry.emitter.valid then
			if not force or force.name == entry.emitter.force.name then
				if surf.index == entry.emitter.surface.index then
					local x_diff = entry.position.x - pos.x
					local y_diff = entry.position.y - pos.y
					if (y_diff == 0) and (dir == horz_wall or dir == horz_wall + vert_wall) then  -- Horizontally aligned
						if x_diff > 0 and x_diff <= near_dists[1] then
							near_nodes[1] = entry.emitter
							near_dists[1] = x_diff
						elseif x_diff < 0 and x_diff >= near_dists[2] then
							near_nodes[2] = entry.emitter
							near_dists[2] = x_diff
						end
					elseif (x_diff == 0) and (dir == vert_wall or dir == horz_wall + vert_wall) then  -- Vertically aligned
						if y_diff > 0 and y_diff <= near_dists[3] then
							near_nodes[3] = entry.emitter
							near_dists[3] = y_diff
						elseif y_diff < 0 and y_diff >= near_dists[4] then
							near_nodes[4] = entry.emitter
							near_dists[4] = y_diff
						end
					end
				end
			end
		end
	end
	
	local connected_nodes = {}
	for _, node in pairs(near_nodes) do  -- Removes nils
		table.insert(connected_nodes, node)
	end
	return connected_nodes
end

--Called by on_built_entity in control.lua
--Modifies global.SRF_nodes, global.SRF_node_ticklist, global.SRF_segments
function CnC_SonicWall_AddNode(entity, tick)
	table.insert(global.SRF_nodes, {emitter = entity, position = entity.position})
	table.insert(global.SRF_node_ticklist, {emitter = entity, position = entity.position, tick = tick + ceil(entity.electric_buffer_size / entity.electric_input_flow_limit)})
	CnC_SonicWall_DisableNode(entity)  --Destroy any walls that went through where the wall was placed so it can calculate new walls
end

--Destroys walls connected to given SRF emitter
--Modifies global.SRF_segments
function CnC_SonicWall_DisableNode(entity)
	local surf = entity.surface
	local x = floor(entity.position.x)
	local y = floor(entity.position.y)
	
	for _, dir in pairs(dir_mods) do
		local tx = x + dir.x
		local ty = y + dir.y
		while global.SRF_segments[surf.index] and global.SRF_segments[surf.index][tx] and global.SRF_segments[surf.index][tx][ty] do
			local wall = global.SRF_segments[surf.index][tx][ty]
			if wall[1] == dir.variation then
				global.SRF_segments[surf.index][tx][ty][2].destroy()
				global.SRF_segments[surf.index][tx][ty] = nil
				local gate_beam = surf.find_entity("laserfence-beam-unselectable", {tx + 0.5, ty + 0.5})
				if gate_beam then gate_beam.destroy() end
			elseif wall[1] == horz_wall + vert_wall then
				global.SRF_segments[surf.index][tx][ty][1] = horz_wall + vert_wall - dir.variation
				global.SRF_segments[surf.index][tx][ty][2].graphics_variation = horz_wall + vert_wall - dir.variation
			end
			tx = tx + dir.x
			ty = ty + dir.y
		end
	end
	--Also destroy any wall that is on top of the node
	if global.SRF_segments[surf.index] and global.SRF_segments[surf.index][x] and global.SRF_segments[surf.index][x][y] then
		global.SRF_segments[surf.index][x][y][2].destroy()
		global.SRF_segments[surf.index][x][y] = nil
	end
end

--Called by on_entity_died in control.lua
--Modifies global.SRF_nodes, global.SRF_node_ticklist, global.SRF_low_power_ticklist
function CnC_SonicWall_DeleteNode(entity, tick)
	local k = find_value_in_table(global.SRF_nodes, entity.position, "position")
	if k then
		table.remove(global.SRF_nodes, k)
		if debugText then game.print("Destroyed SRF at x: "..entity.position.x.." y: "..entity.position.y.." removed from SRF_nodes, "..#global.SRF_nodes.." entries remain") end
	end
	
	k = find_value_in_table(global.SRF_node_ticklist, entity.position, "position")
	if k then
		table.remove(global.SRF_node_ticklist, k)
		if debugText then game.print("Destroyed SRF at x: "..entity.position.x.." y: "..entity.position.y.." removed from SRF_node_ticklist, "..#global.SRF_node_ticklist.." entries remain") end
	end

	k = find_value_in_table(global.SRF_low_power_ticklist, entity.position, "position")
	if k then
		table.remove(global.SRF_low_power_ticklist, k)
		if debugText then game.print("Destroyed SRF at x: "..entity.position.x.." y: "..entity.position.y.." removed from SRF_low_power_ticklist, "..#global.SRF_low_power_ticklist.." entries remain") end
	end

	CnC_SonicWall_DisableNode(entity)
	--Tell connected walls to reevaluate their connections
	local connected_nodes = CnC_SonicWall_FindNodes(entity.surface, entity.position, entity.force, horz_wall + vert_wall)
	for i = 1, #connected_nodes do
		if not find_value_in_table(global.SRF_node_ticklist, connected_nodes[i].position, "position") then
			table.insert(global.SRF_node_ticklist, {emitter = connected_nodes[i], position = connected_nodes[i].position, tick = tick + 10})
		end
	end
end

function CnC_SonicWall_DestroyedWall(entity)
	local surf = entity.surface
	local x = floor(entity.position.x)
	local y = floor(entity.position.y)
	local dir = entity.graphics_variation or (2 - entity.direction / 2)  -- Converts defines.direction to graphics variation
	local gate_beam = surf.find_entity("laserfence-beam-unselectable", {x + 0.5, y + 0.5})
	if gate_beam and (gate_beam.graphics_variation == dir) then
		gate_beam.destroy()
	end
	global.SRF_segments[surf.index][x][y] = nil
	for _, dir_mod in pairs(dir_mods) do
		if bit32.band(dir, dir_mod.variation) > 0 then
			local tx = x + dir_mod.x
			local ty = y + dir_mod.y
			while global.SRF_segments[surf.index] and global.SRF_segments[surf.index][tx] and global.SRF_segments[surf.index][tx][ty] do
				local wall = global.SRF_segments[surf.index][tx][ty]
				if wall[1] == dir_mod.variation then
					global.SRF_segments[surf.index][tx][ty][2].destroy()
					global.SRF_segments[surf.index][tx][ty] = nil
					local gate_beam = surf.find_entity("laserfence-beam-unselectable", {tx + 0.5, ty + 0.5})
					if gate_beam and (gate_beam.graphics_variation == dir) then
						gate_beam.destroy()
					end
				elseif wall[1] == horz_wall + vert_wall then
					global.SRF_segments[surf.index][tx][ty][1] = horz_wall + vert_wall - dir
					global.SRF_segments[surf.index][tx][ty][2].graphics_variation = horz_wall + vert_wall - dir
				end
				tx = tx + dir_mod.x
				ty = ty + dir_mod.y
			end
			-- find srf, set power to 5%, add ticklist
			local post = surf.find_entities_filtered{name = {"laserfence-post", "laserfence-post-gate"}, position = {tx + 0.5, ty + 0.5625}}[1]
			if post then
				post.energy = 0.2 * post.electric_buffer_size
				table.insert(global.SRF_node_ticklist, {emitter = post, position = post.position, tick = game.tick + ceil(post.electric_buffer_size / post.electric_input_flow_limit)})
			end
		end
	end
end

--Returns whether a wall of a given orientation can be placed at a given position
--Assumes global.SRF_segments, horz_wall, vert_wall
function CnC_SonicWall_TestWall(surf, pos, dir, node1, node2, gate_mode)
	local x = floor(pos[1])
	local y = floor(pos[2])
	if not global.SRF_segments[surf.index] then global.SRF_segments[surf.index] = {} end
	if not global.SRF_segments[surf.index][x] then global.SRF_segments[surf.index][x] = {} end
	local wall = global.SRF_segments[surf.index][x][y]
	if wall and wall[2].valid then
		if (wall[2].name == "laserfence-beam") and not gate_mode then  -- Neither fence is a gate
			return bit32.band(dir, wall[1]) == 0  -- Ok if existing wall is orthogonal to the direction we want
		elseif (wall[2].name == "laserfence-beam-gate") and gate_mode and (dir == wall[1]) then
			return false  -- Existing gate in the correct direction stops new gate, but isn't an obstruction
		end
	end
	local obstruction = surf.find_entities_filtered{area = {{x, y}, {x + 0.9, y + 0.9}}, collision_mask = "object-layer"}[1]
	if obstruction then
		if gate_mode and obstruction.prototype.type == "straight-rail" and ((dir == horz_wall and obstruction.direction == defines.direction.north)
				or (dir == vert_wall and obstruction.direction == defines.direction.east)) then
			return true  -- Allow gates to be placed across perpendicular rails
		end
		if debugText then game.print("Blocked by "..obstruction.name) end
		registerObstruction(obstruction, node1, node2)
		surf.create_entity{  -- Laser Fence blocked by __1__
				name = "laserfence-obstruction-text",
				position = {x = x - 1.5, y = y},
				text = {"entity-description.laserfence-obstruction-text", {"entity-name."..obstruction.name}},
				color = {r = 255, g = 255, b = 255},
		}
		return false
	end
	return true
end

--Makes a wall of a given orientation can be placed at a given position
--Assumes horz_wall, vert_wall
--Modifies global.SRF_segments
function CnC_SonicWall_MakeWall(surf, pos, dir, force, gate_mode)
	local x = floor(pos[1])
	local y = floor(pos[2])
	if not global.SRF_segments[surf.index] then global.SRF_segments[surf.index] = {} end
	if not global.SRF_segments[surf.index][x] then global.SRF_segments[surf.index][x] = {} end
	
	if not global.SRF_segments[surf.index][x][y] then
		local wall
		if gate_mode then
			local direction = dir == 1 and defines.direction.east or defines.direction.north
			wall = surf.create_entity{name="laserfence-beam-gate", position=pos, direction=direction, force=force, move_stuck_players=true}
		else
			wall = surf.create_entity{name="laserfence-beam", position=pos, force=force, move_stuck_players=true}
		end
		if wall then
			for _, entity in pairs(surf.find_entities_filtered{area = {{x, y}, {x + 0.9, y + 0.9}}, force = "enemy"}) do
				safeDamage(entity, 9999)
			end
			wall.graphics_variation = dir
			global.SRF_segments[surf.index][x][y] = {dir, wall}
		else
			error("Wall creation failed and not caught by TestWall. x: "..tostring(x).." y: "..tostring(y))
		end
	elseif not gate_mode then
		local wall = global.SRF_segments[surf.index][x][y]
		if wall[1] == horz_wall + vert_wall - dir then wall[1] = horz_wall + vert_wall end
		wall[2].graphics_variation = horz_wall + vert_wall
	end
end

--Makes a wall connecting two given emitters if an uninterupted wall is possible
--Assumes horz_wall, vert_wall
--Modifies global.SRF_segments
function tryCnC_SonicWall_MakeWall(node1, node2)
	local gate_mode = (node1.name == "laserfence-post-gate") and (node2.name == "laserfence-post-gate")
	local that_pos = node2.position
	if node1.position.x == that_pos.x and node1.position.y ~= that_pos.y then
		-- Safe to assume these are withing valid range because it only runs on node pairs from FindNodes
		if abs(that_pos.y - node1.position.y) > 1 then
			local sy, ty
			sy = min(node1.position.y, that_pos.y) + 1
			ty = max(node1.position.y, that_pos.y) - 1
			for y = sy, ty do
				if not CnC_SonicWall_TestWall(node1.surface, {node1.position.x, y}, vert_wall, node1, node2, gate_mode) then
					if debugText then game.print("Failed at x: "..that_pos.x.." y: "..y) end
					return
				end
			end
			for y = sy, ty do
				CnC_SonicWall_MakeWall(node1.surface, {node1.position.x, y}, vert_wall, node1.force, gate_mode)
			end
		end
	elseif node1.position.x ~= that_pos.x and node1.position.y == that_pos.y then
		if abs(that_pos.x - node1.position.x) > 1 then
			local sx, tx
			sx = min(node1.position.x, that_pos.x) + 1
			tx = max(node1.position.x, that_pos.x) - 1
			for x = sx, tx do
				if not CnC_SonicWall_TestWall(node1.surface, {x, node1.position.y}, horz_wall, node1, node2, gate_mode) then
					if debugText then game.print("Failed at x: "..x.." y: "..that_pos.y) end
					return
				end
			end
			for x = sx, tx do
				CnC_SonicWall_MakeWall(node1.surface, {x, node1.position.y}, horz_wall, node1.force, gate_mode)
			end
		end
	end
end

-- That's the end of the functions.
-- Below are things that used to be called in scripts, moved over here to clean things up
-- OnTick used to be in script.on_event(defines.events.on_tick, function(event), for example.
function CnC_SonicWall_OnTick(event)
	local cur_tick = event.tick
	for i = #global.SRF_node_ticklist, 1, -1 do
		local charging = global.SRF_node_ticklist[i]
		if not charging.emitter.valid then
			table.remove(global.SRF_node_ticklist, i)
		elseif charging.tick <= cur_tick then
			local charge_rem = charging.emitter.electric_buffer_size - charging.emitter.energy
			if charge_rem <= 0 then
				if debugText then game.print("Fully charged at x: "..charging.emitter.position.x.." y: "..charging.emitter.position.y) end
				local connected_nodes = CnC_SonicWall_FindNodes(charging.emitter.surface, charging.emitter.position,
																charging.emitter.force, horz_wall + vert_wall)
				for _, node in pairs(connected_nodes) do
					if node.energy > 0 then  --Doesn't need to be fully powered as long as it was once fully powered
						if not find_value_in_table(global.SRF_node_ticklist, node.position, "position") then
							if debugText then game.print("Trying to connect to x: "..node.position.x.." y: "..node.position.y) end
							tryCnC_SonicWall_MakeWall(charging.emitter, node)
						end
					end
				end
				table.remove(global.SRF_node_ticklist, i)
			else
				charging.tick = cur_tick + ceil(charge_rem / charging.emitter.electric_input_flow_limit)
			end
		end
	end
	
	if cur_tick % 60 == 0 then --Check for all emitters for low power once per second
		for i = #global.SRF_nodes, 1, -1 do
			local emitter = global.SRF_nodes[i].emitter
			local position = global.SRF_nodes[i].position
			if emitter.valid then
				local ticks_rem = emitter.energy / emitter.power_usage
				if ticks_rem > 5 and ticks_rem <= 65 then
					if not find_value_in_table(global.SRF_low_power_ticklist, emitter.position, "position") then
						table.insert(global.SRF_low_power_ticklist, {emitter = emitter, position = position, tick = cur_tick + ceil(ticks_rem)})
					end
				end
			else
				table.remove(global.SRF_nodes, i)
				if debugText then game.print("Removed invalid node at index "..tostring(i)) end
			end
		end
	end
	
	for i = #global.SRF_low_power_ticklist, 1, -1 do --Regularly check low power emitters to disable when their power runs out
		local low = global.SRF_low_power_ticklist[i]
		if not low.emitter.valid then
			table.remove(global.SRF_low_power_ticklist, i)
		elseif low.tick <= cur_tick and low.emitter then
			local ticks_rem = low.emitter.energy / low.emitter.power_usage
			if ticks_rem <= 5 then
				CnC_SonicWall_DeleteNode(low.emitter, cur_tick)  --Removes it from low power ticklist as well
				CnC_SonicWall_AddNode(low.emitter, cur_tick)
			elseif ticks_rem > 65 then
				table.remove(global.SRF_low_power_ticklist, i)  -- Fixes issue where nodes would get re-checked forever
			else
				low.tick = cur_tick + ceil(ticks_rem)
			end
		end
	end

	-- Manage gate hybrid entities
	for _, surface in pairs(game.surfaces) do
		for _, gate in pairs(surface.find_entities_filtered{name = "laserfence-beam-gate"}) do
			local beam = surface.find_entity("laserfence-beam-unselectable", gate.position)
			if gate.is_opening() or gate.is_opened() then
				if beam then
					beam.destroy()
				end
			else
				if not beam then
					beam = surface.create_entity{
						name = "laserfence-beam-unselectable",
						force = gate.force,
						position = gate.position
					}
					beam.destructible = false
					if gate.direction == defines.direction.east then
						beam.graphics_variation = horz_wall
					else
						beam.graphics_variation = vert_wall
					end
				end
			end
		end
	end
end

--Helper function
--Returns the key for a given value in a given table or false if it doesn't exist
--Optional subscript argument for when the list contains other lists
function find_value_in_table(list, value, subscript)
	if not list then return false end
	if not value then return false end
	for k, v in pairs(list) do
		if subscript then
			if util.table.compare(v[subscript], value) then return k end
		else
			if v == value then return k end
		end
	end
	return false
end

function CnC_SonicWall_OnInit()
	global.SRF_nodes = {}
	global.SRF_node_ticklist = {}
	global.SRF_segments = {}
	global.SRF_low_power_ticklist = {}
end
