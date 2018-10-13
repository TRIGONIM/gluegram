local BOT_MT = TLG.GetMeta("BOT")
local METHOD = TLG.NewMethod("sendMessage")

function METHOD:SetChatID(iChatID) -- !!!
	return self:SetParam("chat_id", iChatID)
end

function METHOD:SetText(sText) -- !!!
	return self:SetParam("text", sText)
end

-- markdown, html
function METHOD:SetParseMode(sMode)
	return self:SetParam("parse_mode", sMode)
end


function METHOD:ReplyTo(iReplyToMessageId)
	return self:SetParam("reply_to_message_id", iReplyToMessageId)
end

-- InlineKeyboardMarkup or ReplyKeyboardMarkup or ReplyKeyboardHide or ForceReply
-- https://tlgrm.ru/docs/bots/api#sendmessage
function METHOD:SetReplyMarkup(objMarkup)
	return self:SetParam("reply_markup", util.TableToJSON(objMarkup))
end


-- Создаем объект сообщения
function BOT_MT:Message(iTo, sText)
	if istable(iTo) then -- USER or CHAT object
		iTo = iTo["id"]
	end

	return self:Request(METHOD, "Message")
		:SetChatID(iTo)
		:SetText(sText)
end

-- function BOT_MT:SendMarkdown(iTo, sText)
-- 	self:Message(iTo, sText):SetParseMode("markdown"):Send()
-- end

-- local markdown = "*bold*; _italic_; [url](google.com); ```lua\nprint('hello world')\n```"
-- TLG_CORE_BOT:Message(TLG_AMD, markdown):SetParseMode("markdown"):Send(prt)
