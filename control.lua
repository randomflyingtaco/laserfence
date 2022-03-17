require("util")
require("scripts/CnC_Walls") --Note, to make SonicWalls work / be passable
local migration = require("scripts/migration")

local debugText = settings.startup["laserfence-debug-text"].value

script.on_init(function()
	global.laserfenceOnEntityDestroyed = {}
	global.laserfenceObstruction = {}
	global.laserfenceDamageMulti = {}
	for name, force in pairs(game.forces) do
		local multi = force.get_ammo_damage_modifier("laser") or 0
		global.laserfenceDamageMulti[name] = multi
	end
	CnC_SonicWall_OnInit()
end)

script.on_configuration_changed(function(event)
	if migration.upgradingToVersion(event, "1.1.1") then
		game.print("Ran conversion for Laser Fence version 1.1.1")
		global.SRF_nodes = {}
		global.SRF_node_ticklist = {}
		global.SRF_low_power_ticklist = {}

		for _, surface in pairs(game.surfaces) do
			-- Reposition emitters
			for _, post in pairs(surface.find_entities_filtered{name = "laserfence-post"}) do
				post.teleport({post.position.x, math.floor(post.position.y) + 0.5625})
				CnC_SonicWall_AddNode(post, game.tick)
			end
		end
		-- Update global for new shared-obstruction registration
		for registration_number, entityInfo in pairs(global.laserfenceObstruction) do
			global.laserfenceObstruction[registration_number] = {entityInfo}
		end
	end
end)

commands.add_command("laserfenceRebuild",
	"Update globals",
	function()
		global.SRF_nodes = {}
		for _, surface in pairs(game.surfaces) do
			for _, srf in pairs(surface.find_entities_filtered{name = "laserfence-post"}) do
				table.insert(global.SRF_nodes, {emitter = srf, position = srf.position})
			end
		end
		game.player.print("Found " .. #global.SRF_nodes .. " laser fence posts")
	end
)

script.on_event(defines.events.on_tick, function(event)
	-- Update SRF Walls
	CnC_SonicWall_OnTick(event)
end
)

script.on_event(defines.events.on_script_trigger_effect, function(event)
	--Liquid Seed trigger
	if event.effect_id == "laserfence-reflect-damage" then
		local force = event.source_entity.force.name
		local multi = global.laserfenceDamageMulti[force]
		if debugText and event.target_entity then game.print("Dealing "..(10 * (1 + multi)).." reflect damage to "..event.target_entity.name) end
		safeDamage(event.target_entity, 10 * (1 + multi))
	end
end
)

function safeDamage(entityOrPlayer, damageAmount)
	if not entityOrPlayer.valid then return end
	if damageAmount <= 0 then return end
	local entity = entityOrPlayer
	if entityOrPlayer.is_player() then
		entity = entityOrPlayer.character  -- Need to damage character instead of player
	end
	if entity.valid and entity.health and entity.health > 0 then
		entity.damage(damageAmount, game.forces.player, "laser")
	end
end

function registerEntity(entity)  -- Cache relevant information to global and register
	local entityInfo = {}
	for _, property in pairs({"name", "type", "position", "surface", "force"}) do
		entityInfo[property] = entity[property]
	end
	local registration_number = script.register_on_entity_destroyed(entity)
	global.laserfenceOnEntityDestroyed[registration_number] = entityInfo
end

function registerObstruction(entity, node1, node2)  -- Cache relevant information to global and register
	local entityInfo = {}  -- TODO restructure so multilple walls can be registered to the same obstruction, also do the conversion
	entityInfo["node1"] = node1
	entityInfo["node2"] = node2
	for _, property in pairs({"name", "type", "position", "surface", "force"}) do
		entityInfo[property] = entity[property]
	end
	local registration_number = script.register_on_entity_destroyed(entity)
	if global.laserfenceObstruction[registration_number] then
		table.insert(global.laserfenceObstruction[registration_number], entityInfo)
	else
		global.laserfenceObstruction[registration_number] = {entityInfo}
	end
end

function on_new_entity(event)
	local new_entity = event.created_entity or event.entity --Handle multiple event types
	local surface = new_entity.surface
	local position = new_entity.position
	local force = new_entity.force
	if (new_entity.name == "laserfence-connector") then
		local emitter = surface.create_entity{
			name = "laserfence-post",
			position = {position.x, position.y + 0.0625},
			force = force,
			raise_built = true
		}
		registerEntity(emitter)
		CnC_SonicWall_AddNode(emitter, event.tick)
	end
end

script.on_event(defines.events.on_built_entity, on_new_entity)
script.on_event(defines.events.on_robot_built_entity, on_new_entity)
script.on_event(defines.events.script_raised_built, on_new_entity)
script.on_event(defines.events.script_raised_revive, on_new_entity)

function on_remove_entity(event)
	local entity = global.laserfenceOnEntityDestroyed[event.registration_number]
	if entity then
		local surface = entity.surface
		local position = entity.position
		local force = entity.force
		if (entity.name == "laserfence-post") then
			if surface and surface.valid then
				for _, connector in pairs(surface.find_entities_filtered{name = "laserfence-connector", position = {position.x, position.y - 0.0625}}) do
					connector.destroy()
				end
			end
			CnC_SonicWall_DeleteNode(entity, event.tick)
		end
		global.laserfenceOnEntityDestroyed[event.registration_number] = nil  -- Avoid this global growing forever
	elseif global.laserfenceObstruction[event.registration_number] then
		for _, entityInfo in pairs(global.laserfenceObstruction[event.registration_number]) do --TODO crash?
			if entityInfo then
				local node1 = entityInfo.node1
				local node2 = entityInfo.node2
				if node1.valid and node2.valid then
					tryCnC_SonicWall_MakeWall(node1, node2)
				end
			end
		end
		global.laserfenceObstruction[event.registration_number] = nil  -- Avoid this global growing forever
	end
end

script.on_event(defines.events.on_entity_destroyed, on_remove_entity)

script.on_event(defines.events.on_entity_died, function(event)
	if event.entity and (event.entity.name == "laserfence-beam") then
		CnC_SonicWall_DestroyedWall(event.entity)
	end
end
)

script.on_event({defines.events.on_research_finished, defines.events.on_research_reversed}, function(event)
	local force = event.research.force
	local multi = force.get_ammo_damage_modifier("laser") or 0
	global.laserfenceDamageMulti[force.name] = multi
end
)
