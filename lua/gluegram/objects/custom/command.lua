local CMD_MT = TLG.NewObjectBase("COMMAND")


-- Добавляет альтернативу использования команды
function CMD_MT:AddAlias(alias_or_list)
	local list = istable(alias_or_list) and alias_or_list or {alias_or_list}

	for _,alias in ipairs(list) do
		self["bot"]["commands"][alias] = self

		self.aliases = self.aliases or {}
		self.aliases[alias] = true
	end

	return self
end
