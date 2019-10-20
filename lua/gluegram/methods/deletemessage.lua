local BOT_MT = TLG.GetBot("base")
local METHOD = TLG.NewMethod("deleteMessage")

function BOT_MT:DeleteMessage(a, b)
	if istable(a) then
		local MSG = a
		return self:Request(METHOD)
			:SetParam("chat_id", MSG["chat"]["id"])
			:SetParam("message_id", MSG["message_id"])
	else
		return self:Request(METHOD)
			:SetParam("chat_id", a)
			:SetParam("message_id", b)
	end
end
