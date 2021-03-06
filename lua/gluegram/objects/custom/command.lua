local CMD_MT = TLG.NewObjectBase("COMMAND")

function CMD_MT:AddAlias(alias_or_list)
	local list = istable(alias_or_list) and alias_or_list or {alias_or_list}

	for _,alias in ipairs(list) do
		self["bot"]["commands"][alias] = self

		self.aliases[alias] = true
	end

	return self
end

function CMD_MT:IsAlias(alias)
	return self.aliases[alias] or false
end

function CMD_MT:SetMeta(k, v)
	self.meta[k] = v
	return self
end

function CMD_MT:GetMeta(k)
	return self.meta[k]
end
