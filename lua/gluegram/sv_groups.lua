TLG.Groups = {}
TLG.Permissions = {}


-- When I wrote this, only God and I understood what I was doing
-- Now, God only knows
local function groupHasAccess( group, access )

	if TLG.Cfg.Groups[group].allow and TLG.Cfg.Groups[group].allow[access] then
		return true, TLG.Cfg.Groups[group].allow[access]
	end

	return false, ""
end

local function checkInheritedAccess( group, access )
	if TLG.Cfg.Groups[group] then
		local foundAccess, restrictionString = groupHasAccess( group, access )
		if foundAccess then
			return foundAccess, restrictionString
		else
			return checkInheritedAccess( TLG.Cfg.Groups[group].inherit_from, access )
		end
	else
		return false, ""
	end
end




-- Building full permissions table
for groupName, groupData in pairs(TLG.Cfg.Groups) do

	for perm,tag in pairs(groupData["allow"] or {}) do
		TLG.Permissions[perm] = perm -- присваивать надо чет поинтереснее
	end

end

for _,permission in pairs(TLG.Permissions) do

	for groupName,_ in pairs(TLG.Cfg.Groups) do
		local found,tag = checkInheritedAccess( groupName, permission )

		if found and !(TLG.Cfg.Groups[groupName]["deny"] and TLG.Cfg.Groups[groupName]["deny"][permission]) then
			TLG.Groups[groupName] = TLG.Groups[groupName] or {}
			TLG.Groups[groupName][permission] = tag
		end
	end

end