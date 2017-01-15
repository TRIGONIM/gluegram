local BOT = {}
BOT.__index = BOT

debug.getregistry().TelegramBot = BOT

-------------------------------------------

function TLG.NewBot(sToken)
	return setmetatable({
		token = sToken
	}, BOT)
end

-------------------------------------------

function BOT:GetToken()
	return self.token
end

-------------------------------------------

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