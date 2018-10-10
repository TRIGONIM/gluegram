local BOT_MT = TLG.GetMeta("BOT")
local METHOD = TLG.NewMethod("deleteMessage")

function BOT_MT:DeleteMessage(MSG)
	return self:Request(METHOD)
		:SetParam("message_id", MSG["message_id"])
		:SetParam("chat_id", MSG["chat"]["id"])
end
