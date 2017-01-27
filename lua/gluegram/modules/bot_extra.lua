-- бляя, от этих ретурнов точно надо как-то избавиться
-- это просто невыносимый пиздец
return function(BOT)
local BOT_MT = table.Copy(getmetatable(BOT)) -- и от этого тоже
-- todo найти нормальный способ изменять метатаблицу ОДНОГО объекта, а не всего класса

-- Перехватывает только нажатия inline кнопочек
function BOT_MT:CBQHook(fCallback,sUnName)
	self.cbq_hooks = self.cbq_hooks or {}
	self.cbq_hooks[sUnName] = fCallback

	self:HandleUpdates(function(UPD)
		if UPD["callback_query"] then
			for name,callback in pairs(self.cbq_hooks) do
				callback(TLG.SetMeta(UPD["callback_query"],"CallbackQuery"))
			end
		end
	end,"CBQHook")
end


-- Может быть несколько гмод серверов с одинаковыми виртуальными ботами, но все они будут подключены к 1 боту телеграма
-- Если все боты будут считаться "Мастерами" (главными), то многие сообщения, типа "Нужно ввести название сервера" при вводе /login без аргументов
-- будут отправляться всеми ботами в один чат, тем самым захламляя его. Это не очень приятно, правда?

-- Этим методом мы делаем "Главного" бота. Т.е. того, который будет сам "отвечать" за определенные "поступки"
function BOT_MT:SetMaster(bMaster)
	self.master = bMaster
	return self
end

function BOT_MT:IsMaster()
	return self.master
end

setmetatable(BOT,BOT_MT)
end