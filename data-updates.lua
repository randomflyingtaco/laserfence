if mods["Factorio-Tiberium"] then
	data.raw.recipe["laserfence-post"].subgroup = "a-buildings"
	data.raw.recipe["laserfence-post-gate"].subgroup = "a-buildings"
	table.insert(data.raw.technology["laserfence"].prerequisites, "tiberium-military-2")
end

local function consolidateDamageEffects(TriggerEffects)
	local damageTotal = 0
	local damageType
	local out = {}
	for _,effect in pairs(TriggerEffects) do
		if effect.type == "damage" then
			damageTotal = damageTotal + effect.damage.amount
			damageType = damageType or effect.damage.type
		else
			table.insert(out, {effect})
		end
	end
	if damageTotal > 0 then
		table.insert(out, {type = "damage", damage = {amount = damageTotal, type = damageType}})
	end
	return out
end

-- Temporary fix to convert enemies with hybrid damage types into a single damage type
for name,unit in pairs(data.raw.unit) do
	if unit.attack_parameters and unit.attack_parameters.ammo_type and unit.attack_parameters.ammo_type.action and unit.attack_parameters.ammo_type.action.action_delivery then
		if unit.attack_parameters.ammo_type.action.action_delivery.target_effects then
			local effects = unit.attack_parameters.ammo_type.action.action_delivery.target_effects
			if not effects.type then
				unit.attack_parameters.ammo_type.action.action_delivery.target_effects = table.deepcopy(consolidateDamageEffects(effects))
			end
		elseif unit.attack_parameters.ammo_type.action.action_delivery[1] then
			for key,triggerDelivery in pairs(unit.attack_parameters.ammo_type.action.action_delivery) do
				local effects = triggerDelivery.target_effects
				if effects and not effects.type then
					unit.attack_parameters.ammo_type.action.action_delivery[key].target_effects = table.deepcopy(consolidateDamageEffects(effects))
				end
			end
		end
	end
end
