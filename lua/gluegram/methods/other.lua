local ACTION = TLG.NewMethod("sendChatAction")

function ACTION:SendTo(chat_id)
	return self:SetParam("chat_id", chat_id)
end

function ACTION:Set(action)
	return self:SetParam("action", action)
end




TLG.ACT_TYPING   = "typing"
TLG.ACT_PHOTO    = "upload_photo"
TLG.ACT_VIDEO    = "record_video"
TLG.ACT_AUDIO    = "record_audio"
TLG.ACT_DOCUMENT = "upload_document"
TLG.ACT_LOCATION = "find_location"

local BOT_MT = TLG.GetObject("BOT")
function BOT_MT:ChatAction(chat_id, action)
	return self:Request(ACTION):Set(action):SendTo(chat_id)
end

-- TLG_CORE_BOT:ChatAction(TLG_AMD, TLG.ACT_PHOTO):Send(prt)
