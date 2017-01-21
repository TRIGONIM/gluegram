local BOT = TLG.NewObjectBase("BOT")
BOT.__call = function(self,...) return self:AddCommand(...) end

-------------------------------------------

require("bromsock")


-------------------------------------------

function BOT:Name()
	return self.name
end

function BOT:GetToken()
	return self.token
end

-------------------------------------------

-- В fCallback будут передаваться новые UPDATE объекты
function BOT:SetListener(sName,fCallback)
	TLG.GetListener(sName):AddReceiver(self.name,fCallback)
	return self
end


-------------------------------------------

-- Update object in args
-- sName arg is optional. Just for remove ability in advance
-- do not use it if u don't understand how it work 
function BOT:UpdatesHook(fCallback,hookName)
	-- /Not sure this is needed
	self.upd_cb = self.upd_cb or {}
	hookName = hookName or #self.upd_cb + 1

	self.upd_cb[hookName] = fCallback
	-- \Not sure this is needed


	-- tostring нужен из-за гребанной hook либы в ULIB, наче будет
	-- lua/includes/util.lua:181: attempt to index local 'object' (a number value)
	-- 2. Call - addons/ulx_ulib/lua/ulib/shared/hook.lua:121
	-- 3. callback - addons/gluegram/lua/gluegram/objects/custom/bot.lua:106
	hook.Add("TLG.OnBotUpdate_" .. self.name,tostring(hookName),fCallback)

	return self
end

-- CallbackQuery obj in args
function BOT:CBQHook(fCallback,hookName)
	self.cbq_cb = self.cbq_cb or {}
	hookName = hookName or #self.cbq_cb + 1

	self.cbq_cb[hookName] = fCallback

	hook.Add("TLG.OnBotCallbackQuery_" .. self.name,tostring(hookName),fCallback)

	return self
end

-- Создаем объект сообщения
function BOT:Message(iTo,sText)
	if istable(iTo) then -- USER or CHAT object
		iTo = iTo["id"]
	end

	return TLG.Request("sendMessage",self:GetToken())
		:BindParams(iTo,sText)
end

-- Принимает объект сообщения полученной с сервера "Update" таблицы
-- По желанию, можно указать "text", иначе он не изменится
-- "sText" указывать ОБЯЗАТЕЛЬНО, если указан "bAppend"
function BOT:EditMessage(MSG,sText,bAppend)
	-- print("BOT:EditMessage(MSG,sText,bAppend)",MSG,sText,bAppend)
	-- PrintTable(MSG)

	return TLG.Request("editMessageText",self:GetToken())
		:BindParams(bAppend and (MSG["text"] .. sText) or sText or MSG["text"])
		:SetEditMessageID(MSG["message_id"])
		:SetChatID(MSG["chat"]["id"])
end


-------------------------------------------
-- Командный процессор
-------------------------------------------
function BOT:Auth(USER,bAuth)
	self.sessions[USER:ID()] = bAuth and USER or nil -- не даем записать false. Лишняя память)
end

-- Проверяется, если "not CMD:IsPublic()"
function BOT:GetSession(USER)
	return self.sessions[USER:ID()]
end

-- Создаем объект обработчика входящих команд
-- Подробнее в command.lua
function BOT:AddCommand(sCmd,fCallback)
	sCmd = string.lower(sCmd)

	local obj = TLG.SetMeta({
		func = fCallback,
		cmd  = sCmd,

		bot = self -- assign this bot for ability to quick answer from commands
	},"COMMAND")

	self.commands[sCmd] = obj

	return obj
end

function BOT:GetCommand(sCmd)
	return self.commands[sCmd]
end

function BOT:GetCommands()
	return self.commands
end

-- Может быть несколько гмод серверов с одинаковыми виртуальными ботами, но все они будут подключены к 1 боту телеграма
-- Если все боты будут считаться "Мастерами" (главными), то многие сообщения, типа "Нужно ввести название сервера" при вводе /login без аргументов
-- будут отправляться всеми ботами в один чат, тем самым захламляя его. Это не очень приятно, правда?

-- Этим методом мы делаем "Главного" бота. Т.е. того, который будет сам "отвечать" за определенные "поступки"
function BOT:SetMaster(bMaster)
	self.master = bMaster
	return self
end

function BOT:IsMaster()
	return self.master
end

-- Функция будет выполняться после /login botname
function BOT:SetMotd(fMotd)
	self.motd = fMotd
	return self
end
