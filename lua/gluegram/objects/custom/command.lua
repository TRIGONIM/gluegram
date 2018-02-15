local CMD = TLG.NewObjectBase("COMMAND")

--------------------------------
function CMD:Description()
	return self.description
end

function CMD:Help()
	return self.help
end

function CMD:IsPublic()
	return self.public
end

function CMD:ForMaster()
	return self.master
end

function CMD:CheckPassword(value)
	if !self.password then return true end

	if self.password.cryp then
		value = self.password.cryp(value)
	end

	return self.password.pass == value
end
--------------------------------
-- Будет отображаться в /cmd -- help или просто /help
function CMD:SetDescription(sDesc)
	self.description = sDesc
	return self
end

-- Пример использования команды
function CMD:SetHelp(sHelp) -- usage info
	self.help = sHelp
	return self
end

-- Может ли каждый желающий использовать команду
-- Если не указано или false, то проверка на авторизованность (:IsPublic())
-- происходит в objects/custom/bot.lua
function CMD:SetPublic(bPublic)
	self.public = bPublic
	return self
end

-- Команда будет обрабатываться только мастер сервером
-- Полезно, если есть несколько гмод серверов, а управление через 1 бот
-- Позволяет обрабатывать такие команды как /help только 1 сервером, вместо всех сразу
function CMD:SetForMaster(bForMasterServer)
	self.master = bForMasterServer
	return self
end

-- Добавляет альтернативу использования команды
function CMD:AddAlias(name)
	self["bot"]["commands"][name] = self

	self.aliases = self.aliases or {}
	self.aliases[name] = true

	return self
end

-- При попытке вызова команды вылезет нумпад
-- на котором надо будет ввести цифры iPass
-- После этого 30 мин чел сможет юзать комманду
-- Если вы не хотите, чтобы пароль был в открытом виде в коде,
-- то вместо iPass можно указать хэш и указать функцию хэширования
-- при вводе пароля он будет зашифрован через cryptFunc и сравнен с хэшем в iPass
function CMD:SetPassword(iPass,cryptFunc) -- ТОЛЬКО ЦИФРЫ
	self.password = {
		pass = iPass,
		cryp = cryptFunc
	}

	return self
end

-- Отправляет кейпад юзеру
function CMD:RequestPassword(USER)

end

--------------------------------

-- Функция может вернуть сообщение для быстрой отправки активатору команды
-- А вторым аргументом парс мод, например, Markdown
-- Пример обработки в bots/core/core_sv.lua
function CMD:Call(MSG,tArgs)
	return self.func(MSG,tArgs)
end