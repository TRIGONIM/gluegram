-- https://core.telegram.org/bots/api#sendphoto
-- https://core.telegram.org/bots/api#sending-files

local METHOD = TLG.NewMethod("sendPhoto")

-- 0-200 characters
function METHOD:SetCaption(s)
	return self:SetParam("caption", s)
end

-- parse_mode
-- disable_notification
-- reply_to_message_id
-- reply_markup

local BOT_MT = TLG.GetObject("BOT")
function BOT_MT:Photo(chat_id, photo) -- photo is an URL or existing ID on tlg servers
	return self:Request(METHOD, "Message")
		:SetParam("chat_id", chat_id)
		:SetParam("photo", photo)
end

-- TLG_CORE_BOT:Photo(TLG_AMD, "https://i.imgur.com/HI2uWrQ.jpg"):Send(prt)
