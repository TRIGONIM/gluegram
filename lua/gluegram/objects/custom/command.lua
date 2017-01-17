
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

--------------------------------

function CMD:Call(MSG,tArgs)
	local reply = self.func(MSG,tArgs)
	if reply then
		self["bot"]
			:Message(MSG["chat"]["id"], "[" .. self["bot"]:Name() .. "]: " .. reply )
				:ReplyTo( MSG:ID() )
				:Send()
	end
end