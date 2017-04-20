local SEND = {}

function SEND:SetParseMode(sMode) -- markdown, html
	return self:Param("parse_mode",sMode)
end

function SEND:DisableWebPagePreview(bDisable)
	return self:Param("disable_web_page_preview",bDisable)
end

function SEND:DisableNotification(bDisable)
	return self:Param("disable_notification",bDisable)
end

function SEND:ReplyTo(iReplyToMessageId)
	return self:Param("reply_to_message_id", tostring(iReplyToMessageId))
end

-- InlineKeyboardMarkup or ReplyKeyboardMarkup or ReplyKeyboardHide or ForceReply
-- https://tlgrm.ru/docs/bots/api#sendmessage
function SEND:SetReplyMarkup(objMarkup)
	return self:Param("reply_markup",util.TableToJSON(objMarkup))
end


TLG.RegisterMethod("sendMessage",SEND)
	:CallbackObject("Message")
	:AddParam("chat_id", tostring )
	:AddParam("text")








local EDIT = {}
table.Merge(EDIT,SEND)

function EDIT:SetEditMessageID(sID)
	return self:Param("message_id",tostring(sID))
end

function EDIT:SetEditInlineMessageID(sID)
	return self:Param("inline_message_id",tostring(sID))
end

function EDIT:SetChatID(sID)
	return self:Param("chat_id",tostring(sID))
end

TLG.RegisterMethod("editMessageText",EDIT)
	:CallbackObject("Message")
	:AddParam("text")

-- TLG.Request("editMessageText","token")
-- 	:BindParams("Блабла")
-- 	:SetChatID("-150284611")
-- 	:SetEditMessageID(54604)
-- 	:Send()