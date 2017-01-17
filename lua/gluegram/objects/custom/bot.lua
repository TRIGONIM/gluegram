local BOT = TLG.NewObjectBase("BOT")
BOT.__call = function(self,...) return self:AddCommand(...) end

-------------------------------------------

require("bromsock")



TLG.BOTS = TLG.BOTS or {}

function TLG.NewBot(sToken,sName)
	print(1,sToken,sName)
	if TLG.BOTS[sName] then return TLG.BOTS[sName] end
	print(2,sToken,sName)

	local bot_obj = setmetatable({
		commands = {},
		sessions = {}, -- авторизированные пользователи

		token = sToken,
		name  = sName,
	}, BOT)

	TLG.BOTS[sName] = bot_obj

	return bot_obj
end

function TLG.GetBot(sName)
	return TLG.BOTS[sName]
end

-------------------------------------------

function BOT:Name()
	return self.name
end

function BOT:GetToken()
	return self.token
end

function BOT:GetCommands()
	return self.commands
end

-------------------------------------------

local function openSock(self,callback,try)
	self.sock = BromSock(BROMSOCK_TCP)

	if !self.sock:Listen(self.port) then
		MsgC(Color(200,50,50),"TLG Socket not opened\n")

		if try and try > 5 then
			TLG.notifyGroup("root","Сокет телеграмма не открылся.\nПроверьте не занят ли " .. self.port .. " порт")
			return
		end

		TLG.LogError(("Сокет для телеграмма не открылся и не готов принимать сообщения.\nПорт: %s\nПовторяем попытку (%s/5)"):format(self.port,try or 1))

		self.sock:Close()

		timer.Simple(try and (2 * try) or 0,function()
			openSock(self,callback,try and try + 1 or 1)
		end)
	else
		MsgC(Color(50,200,50),"TLG Socket successfuly set\n")

		self.sock:SetCallbackAccept(function(l_ssock, l_csock)
			if TLG.CFG.SocksIPWhitelist[l_csock:GetIP()] then
				l_csock:SetCallbackReceive(function(_, packet)
					callback(packet:ReadStringAll())
				end)
			else
				TLG.LogError("Этот хер пытался обратиться к сокету обновлений TLG с запрещенного ИП: " .. l_csock:GetIP())
			end

			l_csock:SetTimeout(1000)
			l_csock:ReceiveUntil("\r\n\r")
			l_ssock:Accept()
		end)
		self.sock:Accept()
	end
end

function BOT:SetListenPort(iListenPort)
	self.port = iListenPort

	print("SetListenPort",iListenPort,self.port)
	print("self.sock:GetPort()",self.sock and self.sock:GetPort() or "NO SOCK")
	print("self.sock:GetIP()",self.sock and self.sock:GetIP() or "NO SOCK")

	if self.sock and self.sock:GetPort() == self.port then
		--self.sock:Close()
		return self
	end

	-- Без зедаржки есть риск, что сокет не откроется
	timer.Simple(self.sock and 5 or 0,function()
		openSock(self,function(msg)
			local tbl = util.JSONToTable(msg)
			if tbl then -- не мусор пришел
				local UPD = TLG.SetMeta(tbl,"Update")
				hook.Call("TLG.OnBotUpdate_" .. self.name, nil, UPD)

				if UPD["callback_query"] then
					hook.Call("TLG.OnBotCallbackQuery_" .. self.name, nil, UPD:CallbackQuery())
				end
			end
		end)
	end)

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
	if istable(iTo) then -- USER object
		iTo = iTo["id"]
	end

	return TLG.SetMeta({
		chat_id   = iTo,
		text      = sText,
		bot_token = self:GetToken()
	},"Message")
end

-- Принимает объект сообщения полученной с сервера "Update" таблицы
-- По желанию, можно указать "text", иначе он не изменится
-- "sText" указывать ОБЯЗАТЕЛЬНО, если указан "bAppend"
function BOT:EditMessage(msgObj,sText,bAppend)
	return self:Message(
		msgObj["chat"]["id"],
		bAppend and (msgObj["text"] .. sText) or
		sText or msgObj["text"]
	):SetEditMessageID(msgObj["message_id"])
end


-------------------------------------------
-- Командный процессор
-------------------------------------------
function BOT:Auth(USER,bAuth)
	self.sessions[USER:ID()] = bAuth == true or nil -- не даем записать false. Лишняя память)
end

-- Проверяется, если "not CMD:IsPublic()"
function BOT:IsUserAuthed(USER)
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