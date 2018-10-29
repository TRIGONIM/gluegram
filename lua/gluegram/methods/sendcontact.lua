-- https://core.telegram.org/bots/api#sendcontact
local BOT_MT = TLG.GetMeta("BOT")
local METHOD = TLG.NewMethod("sendContact")

function METHOD:SetName(first, last)
	return self:SetParam("first_name", first):SetParam("last_name", last)
end


function BOT_MT:Contact(chat_id, phone_number, first_name, last_name)
	return self:Request(METHOD, "Message")
		:SetParam("chat_id", chat_id)
		:SetParam("phone_number", phone_number)
		:SetName(first_name, last_name)
end

-- TLG_CORE_BOT:Contact(TLG_AMD, 79131153417, "Donate", "Qiwi"):Send()
