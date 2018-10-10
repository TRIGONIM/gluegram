-- https://core.telegram.org/bots/api#sendlocation
local BOT_MT = TLG.GetObject("BOT")
local METHOD = TLG.NewMethod("sendLocation")

function METHOD:SetLive(live_period) -- 60-86400
	return self:SetParam("live_period", live_period)
end

-- disable_notification, reply_to_message_id, reply_markup
function BOT_MT:Location(chat_id, latitude, longitude)
	return self:Request(METHOD, "Message")
		:SetParam("chat_id", chat_id)
		:SetParam("latitude", latitude)
		:SetParam("longitude", longitude)
end


-- local BOT = TLG_CORE_BOT
-- local chat_id = TLG_AMD

-- BOT:Location(chat_id, 49.754342, 27.191522)
-- 	:SetLive(60 * 5)
-- 	:Send(function(MSG)
-- 		BOT:Message(chat_id, MSG:ID()):Send()
-- 	end)
