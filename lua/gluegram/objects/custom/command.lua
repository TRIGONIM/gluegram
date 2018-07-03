local CMD_MT = TLG.NewObjectBase("COMMAND")


-- Добавляет альтернативу использования команды
function CMD_MT:AddAlias(name)
	self["bot"]["commands"][name] = self

	self.aliases = self.aliases or {}
	self.aliases[name] = true

	return self
end
