local BOT_MT = TLG.GetBot("base")
local METHOD = TLG.NewMethod("editMessageText")

function METHOD:SetChatID(iID)
	return self:SetParam("chat_id", iID)
end

function METHOD:SetEditMessageID(iID)
	return self:SetParam("message_id", iID)
end

function METHOD:SetEditInlineMessageID(iID)
	return self:SetParam("inline_message_id", iID)
end

function METHOD:SetText(text) -- !!!
	return self:SetParam("text", text)
end

-- markdown, html
function METHOD:SetParseMode(sMode)
	return self:SetParam("parse_mode", sMode)
end

function METHOD:SetReplyMarkup(objMarkup)
	return self:SetParam("reply_markup", util.TableToJSON(objMarkup))
end


-- Принимает объект сообщения полученной с сервера "Update" таблицы
-- По желанию, можно указать "text", иначе он не изменится
-- "sText" указывать ОБЯЗАТЕЛЬНО, если указан "bAppend"
function BOT_MT:EditMessage(MSG, sText, bAppend)
	local msg_id, chat_id, text

	local id = tonumber(MSG)
	if id then
		msg_id  = id
		chat_id = sText
		text    = bAppend
	else
		MSG["text"] = bAppend and (MSG["text"] .. sText) or sText or MSG["text"]

		msg_id  = MSG["message_id"]
		chat_id = MSG["chat"]["id"]
		text    = MSG["text"]
	end

	return self:Request(METHOD, "Message")
		:SetText(text)
		:SetEditMessageID(msg_id)
		:SetChatID(chat_id)
end

-- TLG_CORE_BOT:Message(TLG_AMD, "key1: value1\nkey2: value2"):Send(PRINT)
-- TLG_CORE_BOT:EditMessage(463546, TLG_AMD, "key3: value3\nkey4: value4"):Send(PRINT)
