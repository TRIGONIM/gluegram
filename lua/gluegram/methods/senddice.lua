-- https://core.telegram.org/bots/api#senddice

local BOT_MT = TLG.GetBot("base")
local METHOD = TLG.NewMethod("sendDice")

function METHOD:ReplyTo(iReplyToMessageId)
	return self:SetParam("reply_to_message_id", iReplyToMessageId)
end

-- InlineKeyboardMarkup or ReplyKeyboardMarkup or ReplyKeyboardHide or ForceReply
function METHOD:SetReplyMarkup(objMarkup)
	return self:SetParam("reply_markup", util.TableToJSON(objMarkup))
end

function METHOD:Mute(bMute)
	return self:SetParam("disable_notification", bMute ~= false)
end


-- Создаем объект сообщения
function BOT_MT:Dice(iTo)
	if istable(iTo) then -- USER or CHAT object
		iTo = iTo["id"]
	end

	return self:Request(METHOD, "Message")
		:SetParam("chat_id", iTo)
end
