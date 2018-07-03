local BOT_MT = TLG.GetMeta("BOT")



local SEND = TLG.NewMethod("sendMessage")

function SEND:SetChatID(iChatID) -- !!!
	return self:SetParam("chat_id", iChatID)
end

function SEND:SetText(sText) -- !!!
	return self:SetParam("text", sText)
end

-- markdown, html
function SEND:SetParseMode(sMode)
	return self:SetParam("parse_mode", sMode)
end


function SEND:ReplyTo(iReplyToMessageId)
	return self:SetParam("reply_to_message_id", iReplyToMessageId)
end

-- InlineKeyboardMarkup or ReplyKeyboardMarkup or ReplyKeyboardHide or ForceReply
-- https://tlgrm.ru/docs/bots/api#sendmessage
function SEND:SetReplyMarkup(objMarkup)
	return self:SetParam("reply_markup", util.TableToJSON(objMarkup))
end


-- Создаем объект сообщения
function BOT_MT:Message(iTo, sText)
	if istable(iTo) then -- USER or CHAT object
		iTo = iTo["id"]
	end

	return self:Request(SEND, "Message")
		:SetChatID(iTo)
		:SetText(sText)
end

-- local markdown = "*bold*; _italic_; [url](google.com); ```lua\nprint('hello world')\n```"
-- TLG_CORE_BOT:Message(TLG_AMD, markdown):SetParseMode("markdown"):Send(prt)




local EDIT = TLG.NewMethod("editMessageText")

function EDIT:SetChatID(iID)
	return self:SetParam("chat_id", iID)
end

function EDIT:SetEditMessageID(iID)
	return self:SetParam("message_id", iID)
end

function EDIT:SetEditInlineMessageID(iID)
	return self:SetParam("inline_message_id", iID)
end

function EDIT:SetText(text) -- !!!
	return self:SetParam("text", text)
end

-- markdown, html
function EDIT:SetParseMode(sMode)
	return self:SetParam("parse_mode", sMode)
end

function EDIT:SetReplyMarkup(objMarkup)
	return self:SetParam("reply_markup", util.TableToJSON(objMarkup))
end


-- Принимает объект сообщения полученной с сервера "Update" таблицы
-- По желанию, можно указать "text", иначе он не изменится
-- "sText" указывать ОБЯЗАТЕЛЬНО, если указан "bAppend"
function BOT_MT:EditMessage(MSG, sText, bAppend)
	-- Обновляем локальный текст
	MSG["text"] = bAppend and (MSG["text"] .. sText) or sText or MSG["text"]

	return EDIT(self, "Message")
		:SetText(MSG["text"])
		:SetEditMessageID(MSG["message_id"])
		:SetChatID(MSG["chat"]["id"])
end





local DELETE = TLG.NewMethod("deleteMessage")

function DELETE:SetDeletingMessageID(iID) -- !!!
	return self:SetParam("message_id", iID)
end

function DELETE:SetChatID(iID) -- !!!
	return self:SetParam("chat_id", iID)
end

function BOT_MT:DeleteMessage(MSG)
	return DELETE(self)
		:SetDeletingMessageID(MSG["message_id"])
		:SetChatID(MSG["chat"]["id"])
end
