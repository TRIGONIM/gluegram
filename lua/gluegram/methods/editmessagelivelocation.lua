-- https://core.telegram.org/bots/api#editMessageLiveLocation
local BOT_MT = TLG.GetMeta("BOT")
local METHOD = TLG.NewMethod("editMessageLiveLocation")

function METHOD:ByMessage(chat_id, message_id)
	return self:SetParam("chat_id", chat_id)
		:SetParam("message_id", message_id)
end

-- inline_message_id, reply_markup
function BOT_MT:UpdateLocation(latitude, longitude)
	return self:Request(METHOD)
		:SetParam("latitude", latitude)
		:SetParam("longitude", longitude)
end

-- TLG_CORE_BOT:UpdateLocation(49.7507, 27.1853)
-- 	:ByMessage(TLG_AMD, 462374)
-- 	:Send()
