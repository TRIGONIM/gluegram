-- Может быть несколько гмод серверов с одинаковыми виртуальными ботами, но все они будут подключены к 1 боту телеграма
-- Если все боты будут считаться "Мастерами" (главными), то многие сообщения, типа "Нужно ввести название сервера" при вводе /login без аргументов
-- будут отправляться всеми ботами в один чат, тем самым захламляя его. Это не очень приятно, правда?

-- Этим методом мы делаем "Главного" бота. Т.е. того, который будет сам "отвечать" за определенные "поступки"

local BOT_MT = TLG.GetObject("BOT")

function BOT_MT:SetMaster(bMaster)
	self.master = bMaster
	return self
end

function BOT_MT:IsMaster()
	return self.master
end


--------------------------------------------------------------


local CMD_MT = TLG.GetObject("COMMAND")

-- Команда будет обрабатываться только мастер сервером
-- Полезно, если есть несколько гмод серверов, а управление через 1 бот
-- Позволяет обрабатывать такие команды как /help только 1 сервером, вместо всех сразу
function CMD_MT:SetForMaster(bForMasterServer)
	self.master = bForMasterServer
	return self
end

function CMD_MT:ForMaster()
	return self.master
end




hook.Add("TLG.CanRunCommand","master ext",function(BOT, _, CMD, _)
	-- Игнорируем обработку, если нужен мастер сервер, а мы им не являемся
	if BOT:IsExtensionConnected("master") and CMD:ForMaster() and !BOT:IsMaster() then
		return
	end
end)
