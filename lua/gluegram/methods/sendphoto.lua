-- https://core.telegram.org/bots/api#sendphoto
-- https://core.telegram.org/bots/api#sending-files

local BOT_MT = TLG.GetBot("base")
local METHOD = TLG.NewMethod("sendPhoto")

-- 0-200 characters
function METHOD:SetCaption(s)
	return self:SetParam("caption", (string.utf8sub or string.sub)(s, 1,200))
end

function METHOD:ReplyTo(iReplyToMessageId)
	return self:SetParam("reply_to_message_id", iReplyToMessageId)
end

function METHOD:SetParseMode(sMode)
	return self:SetParam("parse_mode", sMode)
end

-- disable_notification
-- reply_markup


function BOT_MT:Photo(chat_id, photo) -- photo is an URL or existing ID on tlg servers
	return self:Request(METHOD, "Message")
		:SetParam("chat_id", chat_id)
		:SetParam("photo", photo)
end

-- TLG_CORE_BOT:Photo(TLG_AMD, "https://i.imgur.com/HI2uWrQ.jpg"):Send(prt)
