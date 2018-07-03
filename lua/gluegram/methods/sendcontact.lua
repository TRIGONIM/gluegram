-- https://core.telegram.org/bots/api#sendcontact
local CONTACT = TLG.NewMethod("sendContact")

function CONTACT:SetName(first, last)
	return self:SetParam("first_name", first):SetParam("last_name", last)
end

local BOT_MT = TLG.GetObject("BOT")
function BOT_MT:Contact(chat_id, phone_number, first_name, last_name)
	return self:Request(CONTACT, "Message")
		:SetParam("chat_id", chat_id)
		:SetParam("phone_number", phone_number)
		:SetName(first_name, last_name)
end

-- TLG_CORE_BOT:Contact(TLG_AMD, 79131153417, "Donate", "Qiwi"):Send()
