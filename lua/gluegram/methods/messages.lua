local SEND = {}

function SEND:SetChatID(iChatID) -- !!!
	return self:SetParam("chat_id",iChatID)
end

function SEND:SetText(sText) -- !!!
	return self:SetParam("text",sText)
end

-- markdown, html
function SEND:SetParseMode(sMode)
	return self:SetParam("parse_mode",sMode)
end

function SEND:DisableWebPagePreview(bDisable)
	return self:SetParam("disable_web_page_preview",bDisable)
end

function SEND:DisableNotification(bDisable)
	return self:SetParam("disable_notification",bDisable)
end

function SEND:ReplyTo(iReplyToMessageId)
	return self:SetParam("reply_to_message_id",iReplyToMessageId)
end

-- InlineKeyboardMarkup or ReplyKeyboardMarkup or ReplyKeyboardHide or ForceReply
-- https://tlgrm.ru/docs/bots/api#sendmessage
function SEND:SetReplyMarkup(objMarkup)
	return self:SetParam("reply_markup", util.TableToJSON(objMarkup))
end

TLG.RegisterMethod("sendMessage",SEND,"Message")








local EDIT = {}
table.Merge(EDIT,SEND)

function EDIT:SetNewText(text) -- !!!
	return self:SetParam("text",text)
end

function EDIT:SetEditMessageID(iID)
	return self:SetParam("message_id",iID)
end

function EDIT:SetEditInlineMessageID(iID)
	return self:SetParam("inline_message_id",iID)
end

function EDIT:SetChatID(iID)
	return self:SetParam("chat_id",iID)
end

TLG.RegisterMethod("editMessageText",EDIT,"Message")

-- TLG.Request("editMessageText","token")
-- 	:SetNewText("Блабла")
-- 	:SetChatID("-150284611")
-- 	:SetEditMessageID(54604)
-- 	:Send()




local DELETE = {}
function DELETE:SetDeletingMessageID(iID) -- !!!
	return self:SetParam("message_id",iID)
end

function DELETE:SetChatID(iID) -- !!!
	return self:SetParam("chat_id",iID)
end

TLG.RegisterMethod("deleteMessage",DELETE)

-- TLG_CORE_BOT:Message(TLG_AMD, "Test1"):Send(prt)
-- TLG.Request("deleteMessage",TLG_CORE_BOT:GetToken())
-- 	:SetDeletingMessageID(449769)
-- 	:SetChatID(TLG_AMD)
-- 	:Send(prt)