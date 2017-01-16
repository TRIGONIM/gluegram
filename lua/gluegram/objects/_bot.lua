local BOT = {}
BOT.__index = BOT

debug.getregistry().TelegramBot = BOT

-------------------------------------------

require("bromsock")



TLG.BOTS = TLG.BOTS or {}

function TLG.NewBot(sToken,sName)
	if TLG.BOTS[sName] then return TLG.BOTS[sName] end

	local bot_obj = setmetatable({
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

function BOT:GetToken()
	return self.token
end

-------------------------------------------

local function openSock(self,callback,try)
	self.sock = BromSock(BROMSOCK_TCP)

	print("vararg args2",self.port,"<")

	if !self.sock:Listen(self.port) then
		MsgC(Color(200,50,50),"TLG Socket not opened\n")

		if try > 5 then
			TLG.LogError("Сокет телеграмма не открылся. Проверьте не занят ли " .. self.port .. " порт")
			return
		end

		TLG.notifyGroup("root","Сокет для телеграмма не открылся и не готов принимать сообщения. Повторяем попытку")

		self.sock:Close()

		timer.Simple(try and (2 * try) or 0,function()
			openSock(self,callback,try or 1)
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

-- Update object in args
function BOT:UpdatesHook(fCallback)
	self.upd_cb = fCallback

	hook.Add("TLG.OnBotUpdate_" .. self.name,"Main",self.upd_cb)

	return self
end

-- CallbackQuery obj in args
function BOT:CBQHook(fCallback)
	self.cbq_cb = fCallback

	hook.Add("TLG.OnBotCallbackQuery_" .. self.name,"Main",self.cbq_cb)

	return self
end

function BOT:SetListenPort(iListenPort)
	self.port = iListenPort

	print("vararg args",iListenPort,self.port)

	openSock(self,function(msg)
		local tbl = util.JSONToTable(json)
		if tbl then -- не мусор пришел
			local UPD = TLG.SetMeta(tbl,"Update")
			hook.Run("TLG.OnBotUpdate_" .. self.name, UPD)

			if UPD["callback_query"] then
				hook.Run("TLG.OnBotCallbackQuery_" .. self.name, UPD:CallbackQuery())
			end
		end
	end)

	return self
end

function BOT:Message(iTo,sText)
	return TLG.NewMessage(self:GetToken(),iTo,sText)
end

-- Принимает объект сообщения полученной с сервера таблицы
-- По желанию, можно указать text, иначе он не изменится
-- sText указывать ОБЯЗАТЕЛЬНО, если указан bAppend
function BOT:EditMessage(msgObj,sText,bAppend)
	return TLG.NewMessage(
		self:GetToken(),
		msgObj["chat"]["id"],
		bAppend and (msgObj["text"] .. sText) or
		sText or msgObj["text"]
	):SetEditMessageID(msgObj["message_id"])
end