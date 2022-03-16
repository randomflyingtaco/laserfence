-- Just taking the relevant parts from https://github.com/factoriolib/flib/blob/master/migration.lua
-- because I can never actual flib.migration to work
local migration = {}
function migration.format_version(version)
	if version then
		local tbl = {}
		for v in string.gmatch(version, "%d+") do
			tbl[#tbl + 1] = string.format("%02d", v)
		end
		if next(tbl) then
			return table.concat(tbl, ".")
		end
	end
	return nil
end

function migration.upgradingToVersion(event, version)
	local changes = event.mod_changes[script.mod_name]
	if changes then
		local old_version = changes.old_version
		if old_version and migration.format_version(old_version) < migration.format_version(version) then
			return true
		end
	end
	return false
end

return migration
